import std.exception : assumeUnique;
import std.conv : text;
import std.range : take, chain, drop;
import std.string : startsWith, replace;
import std.format : formattedWrite, format;
import std.uni : asCapitalized;
import std.json;
import std.getopt;
import std.file : readText;
import std.path : dirName;
import std.stdio;

bool keepDeco = false;
enum rootDir = __FILE_FULL_PATH__.dirName.dirName;

void usage()
{
    writeln("Usage: santize_json [--keep-deco] <input-json> [<output-json>]");
}
int main(string[] args)
{
    getopt(args,
        "keep-deco", &keepDeco);
    args = args[1 .. $];
    if (args.length == 0)
    {
        usage();
        return 1;
    }
    string inFilename = args[0];
    File outFile;
    if(args.length == 1)
    {
        outFile = stdout;
    }
    else if(args.length == 2)
    {
        outFile = File(args[1], "w");
    }
    else
    {
        writeln("Error: too many command line arguments");
        return 1;
    }

    auto json = parseJSON(readText(inFilename));
    sanitize(json);

    outFile.writeln(json.toJSON(true, JSONOptions.doNotEscapeSlashes));
    return 0;
}

string capitalize(string s)
{
    return text(s.take(1).asCapitalized.chain(s.drop(1)));
}

void sanitize(JSONValue root)
{
    if (root.type == JSONType.array)
    {
        sanitizeSyntaxNode(root);
    }
    else
    {
        assert(root.type == JSONType.object);
        auto rootObject = root.object;
        static foreach (name; ["compilerInfo", "buildInfo", "semantics"])
        {{
            auto node = rootObject.get(name, JSONValue.init);
            if (node.type != JSONType.null_)
            {
                mixin("sanitize" ~ name.capitalize ~ "(node.object);");
            }
        }}
        {
            auto modules = rootObject.get("modules", JSONValue.init);
            if (modules.type != JSONType.null_)
            {
                sanitizeSyntaxNode(modules);
            }
        }
    }
}

void removeString(JSONValue* value)
{
    assert(value.type == JSONType.string || value.type == JSONType.null_);
    *value = JSONValue("VALUE_REMOVED_FOR_TEST");
}
void removeNumber(JSONValue* value)
{
    assert(value.type == JSONType.integer || value.type == JSONType.uinteger);
    *value = JSONValue(0);
}
void removeStringIfExists(JSONValue* value)
{
    if (value !is null)
        removeString(value);
}
void removeArray(JSONValue* value)
{
    assert(value.type == JSONType.array);
    *value = JSONValue([JSONValue("VALUES_REMOVED_FOR_TEST")]);
}

void sanitizeCompilerInfo(ref JSONValue[string] buildInfo)
{
    removeString(&buildInfo["version"]);
    removeNumber(&buildInfo["__VERSION__"]);
    removeString(&buildInfo["vendor"]);
    removeNumber(&buildInfo["size_t"]);
    removeArray(&buildInfo["platforms"]);
    removeArray(&buildInfo["architectures"]);
    removeArray(&buildInfo["predefinedVersions"]);
}
void sanitizeBuildInfo(ref JSONValue[string] buildInfo)
{
    removeString(&buildInfo["cwd"]);
    removeString(&buildInfo["argv0"]);
    removeString(&buildInfo["config"]);
    removeString(&buildInfo["libName"]);
    {
        auto importPaths = buildInfo["importPaths"].array;
        foreach(ref path; importPaths)
        {
            path = JSONValue(normalizeFile(path.str));
        }
    }
    removeArray(&buildInfo["objectFiles"]);
    removeArray(&buildInfo["libraryFiles"]);
    removeString(&buildInfo["mapFile"]);
}
void sanitizeSyntaxNode(ref JSONValue value)
{
    if (value.type == JSONType.array)
    {
        foreach (ref element; value.array)
        {
            sanitizeSyntaxNode(element);
        }
    }
    else if(value.type == JSONType.object)
    {
        foreach (name; value.object.byKey)
        {
            if (name == "file")
                removeString(&value.object[name]);
            else if (name == "offset")
                removeNumber(&value.object[name]);
            else if (!keepDeco && name == "deco")
                removeString(&value.object[name]);
            else
                sanitizeSyntaxNode(value.object[name]);
        }
    }
}

string getOptionalString(ref JSONValue[string] obj, string name)
{
    auto node = obj.get(name, JSONValue.init);
    if (node.type == JSONType.null_)
        return null;
    assert(node.type == JSONType.string, format("got %s where STRING was expected", node.type));
    return node.str;
}

void sanitizeSemantics(ref JSONValue[string] semantics)
{
    import std.array : appender;

    auto modulesArrayPtr = &semantics["modules"].array();
    auto newModules = appender!(JSONValue[])();
    foreach (ref semanticModuleNode; *modulesArrayPtr)
    {
        auto semanticModule = semanticModuleNode.object();
        auto moduleName = semanticModule.getOptionalString("name");
        if(moduleName.startsWith("std.", "core.", "etc.", "rt.") || moduleName == "object")
        {
           // remove druntime/phobos modules since they can change for each
           // platform
           continue;
        }
        auto fileNode = &semanticModule["file"];
        *fileNode = JSONValue(normalizeFile(fileNode.str));
        newModules.put(JSONValue(semanticModule));
    }
    *modulesArrayPtr = newModules.data;
}

auto normalizeFile(string file)
{
    import std.path : buildNormalizedPath, relativePath;
    file = file.buildNormalizedPath.relativePath(rootDir);
    version(Windows)
        return file.replace("\\", "/");
    return file;
}
