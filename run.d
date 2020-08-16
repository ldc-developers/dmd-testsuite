#!/usr/bin/env rdmd
/**
DMD testsuite runner

Usage:
  ./run.d <test-file>...

Example:
  ./run.d runnable/template2962.d fail_compilation/fail282.d

See the README.md for all available test targets
*/

import std.algorithm, std.conv, std.datetime, std.exception, std.file, std.format,
       std.getopt, std.parallelism, std.path, std.process, std.range, std.stdio,
       std.string, std.traits, core.atomic;

import tools.paths;

const scriptDir = __FILE_FULL_PATH__.dirName.buildNormalizedPath;
immutable testDirs = ["runnable", "runnable_cxx", "compilable", "fail_compilation", "dshell"];
shared bool verbose; // output verbose logging
shared bool force; // always run all tests (ignores timestamp checking)
shared string hostDMD; // path to host DMD binary (used for building the tools)
shared string unitTestRunnerCommand;

// These long-running runnable tests will be put in front, in this order, to
// make parallelization more effective.
immutable slowRunnableTests = [
    "test17338.d",
    "testthread2.d",
    "sctor.d",
    "sctor2.d",
    "sdtor.d",
    "test9259.d",
    "test11447c.d",
    "template4.d",
    "template9.d",
    "ifti.d",
    "test12.d",
    "test22.d",
    "test23.d",
    "test28.d",
    "test34.d",
    "test42.d",
    "test17072.d",
    "testgc3.d",
    "link2644.d",
    "link13415.d",
    "link14558.d",
    "hospital.d",
    "interpret.d",
    "xtest46.d",
];

enum toolsDir = testPath("tools");

enum TestTools
{
    unitTestRunner = TestTool("unit_test_runner", [toolsDir.buildPath("paths")]),
    testRunner = TestTool("d_do_test", ["-I" ~ toolsDir, "-i", "-version=NoMain"]),
    jsonSanitizer = TestTool("sanitize_json"),
    dshellPrebuilt = TestTool("dshell_prebuilt", null, Yes.linksWithTests),
}

immutable struct TestTool
{
    /// The name of the tool.
    string name;

    /// Extra arguments that should be supplied to the compiler when compiling the tool.
    string[] extraArgs;

    /// Indicates the tool is a binary that links with tests
    Flag!"linksWithTests" linksWithTests;

    alias name this;
}

int main(string[] args)
{
    try
        return tryMain(args);
    catch (SilentQuit sq)
        return sq.exitCode;
}

int tryMain(string[] args)
{
    bool runUnitTests, dumpEnvironment;
    int jobs = totalCPUs;
    auto res = getopt(args,
        std.getopt.config.passThrough,
        "j|jobs", "Specifies the number of jobs (commands) to run simultaneously (default: %d)".format(totalCPUs), &jobs,
        "v", "Verbose command output", (cast(bool*) &verbose),
        "f", "Force run (ignore timestamps and always run all tests)", (cast(bool*) &force),
        "u|unit-tests", "Runs the unit tests", &runUnitTests,
        "e|environment", "Print current environment variables", &dumpEnvironment,
    );
    if (res.helpWanted)
    {
        defaultGetoptPrinter(`./run.d <test-file>...

Examples:

    ./run.d runnable/template2962.d                              # runs a specific tests
    ./run.d runnable/template2962.d fail_compilation/fail282.d   # runs multiple specific tests
    ./run.d fail_compilation                                     # runs all tests in fail_compilation
    ./run.d all                                                  # runs all tests
    ./run.d clean                                                # remove all test results
    ./run.d -u -- unit/deinitialization.d -f Module              # runs the unit tests in the file "unit/deinitialization.d" with a UDA containing "Module"

Options:
`, res.options);
        "\nSee the README.md for a more in-depth explanation of the test-runner.".writeln;
        return 0;
    }

    defaultPoolThreads = jobs - 1; // main thread executes tasks as well

    // parse arguments
    args.popFront;
    args2Environment(args);

    // Run the test suite without default permutations
    if (args == ["quick"])
    {
        args = null;
        environment["ARGS"] = "";
    }

    // allow overwrites from the environment
    hostDMD = environment.get("HOST_DMD", "dmd");
    unitTestRunnerCommand = resultsDir.buildPath("unit_test_runner").exeName;

    // bootstrap all needed environment variables
    auto env = getEnvironment;

    if (runUnitTests)
    {
        verifyCompilerExists(env);
        ensureToolsExists(env, TestTools.unitTestRunner);
        return spawnProcess(unitTestRunnerCommand ~ args).wait();
    }

    // default target
    if (!args.length)
        args = ["all"];

    // move any long-running tests to the front
    static size_t sortKey(in ref Target target)
    {
        const name = target.normalizedTestName;
        if (name.startsWith("runnable"))
        {
            const i = slowRunnableTests.countUntil(name[9 .. $]);
            if (i != -1)
                return i;
        }
        return size_t.max;
    }

    auto targets = args
        .predefinedTargets // preprocess
        .array
        .filterTargets(env);

    // Do a manual schwartzSort until all host compilers have a fix
    // for the invalid "lhs internal pointer" error (probably >= v2.093)
    // See https://github.com/dlang/phobos/pull/7524
    foreach (ref target; targets)
        target.sortKey = sortKey(target);

    targets.sort!("a.sortKey < b.sortKey", SwapStrategy.stable);

    if (targets.length > 0)
    {
        verifyCompilerExists(env);

        if (verbose || dumpEnvironment)
        {
            writefln("================================================================================");
            foreach (key, value; env)
                writefln("%s=%s", key, value);
            writefln("================================================================================");
        }

        bool failed;
        ensureToolsExists(env, EnumMembers!TestTools);
        foreach (target; parallel(targets, 1))
        {
            log("run: %-(%s %)", target.args);
            int status = spawnProcess(target.args, env, Config.none, scriptDir).wait;
            if (status != 0)
            {
                writeln(">>> TARGET FAILED: ", target.filename);
                failed = true;
            }
        }
        if (failed)
            return 1;
    }

    return 0;
}

/// Verify that the compiler has been built.
void verifyCompilerExists(string[string] env)
{
    if (!env["DMD"].exists)
    {
        stderr.writefln("%s doesn't exist, try building dmd with:\nmake -fposix.mak -j8 -C%s", env["DMD"], scriptDir.dirName.relativePath);
        quitSilently(1);
    }
}

/**
Builds the binary of the tools required by the testsuite.
Does nothing if the tools already exist and are newer than their source.
*/
void ensureToolsExists(string[string] env, const TestTool[] tools ...)
{
    resultsDir.mkdirRecurse;

    shared uint failCount = 0;
    foreach (tool; tools.parallel(1))
    {
        string targetBin;
        string sourceFile;
        if (tool.linksWithTests)
        {
            targetBin = resultsDir.buildPath(tool).objName;
            sourceFile = toolsDir.buildPath(tool, tool ~ ".d");
        }
        else
        {
            targetBin = resultsDir.buildPath(tool).exeName;
            sourceFile = toolsDir.buildPath(tool ~ ".d");
        }
        if (targetBin.timeLastModified.ifThrown(SysTime.init) >= sourceFile.timeLastModified)
            writefln("%s is already up-to-date", tool);
        else
        {
            string[] command;
            string[string] commandEnv = null;
            if (tool.linksWithTests)
            {
                // This will compile the dshell library thus needs the actual
                // DMD compiler under test
                command = [
                    env["DMD"],
                    "-conf=",
                    "-m"~env["MODEL"],
                    "-of" ~ targetBin,
                    "-c",
                    sourceFile
                ] ~ getPicFlags(env);
                commandEnv = env;
            }
            else
            {
                command = [
                    hostDMD,
                    "-m"~env["MODEL"],
                    "-of"~targetBin,
                    sourceFile
                ] ~ tool.extraArgs;
            }

            writefln("Executing: %-(%s %)", command);
            stdout.flush();
            if (spawnProcess(command, commandEnv).wait)
            {
                stderr.writefln("failed to build '%s'", targetBin);
                atomicOp!"+="(failCount, 1);
            }
        }
    }
    if (failCount > 0)
        quitSilently(1); // error already printed

    // ensure output directories exist
    foreach (dir; testDirs)
        resultsDir.buildPath(dir).mkdirRecurse;
}

/// A single target to execute.
struct Target
{
    /**
    The filename of the target.

    Might be `null` if the target is not for a single file.
    */
    string filename;

    /// The arguments how to execute the target.
    string[] args;

    /// Returns: the normalized test name
    static string normalizedTestName(string filename)
    {
        return filename
            .absolutePath
            .dirName
            .baseName
            .buildPath(filename.baseName);
    }

    string normalizedTestName() const
    {
        return Target.normalizedTestName(filename);
    }

    /// Returns: `true` if the test exists
    bool exists() const
    {
        // This is assumed to be the `unit_tests` target which always exists
        if (filename.empty)
            return true;

        return testPath(normalizedTestName).exists;
    }

    size_t sortKey;
}

/**
Goes through the target list and replaces short-hand targets with their expanded version.
Special targets:
- clean -> removes resultsDir + immediately stops the runner
*/
auto predefinedTargets(string[] targets)
{
    static findFiles(string dir)
    {
        return testPath(dir).dirEntries("*{.d,.sh}", SpanMode.shallow).map!(e => e.name);
    }

    static Target createUnitTestTarget()
    {
        Target target = { args: [unitTestRunnerCommand] };
        return target;
    }

    static Target createTestTarget(string filename)
    {
        Target target = {
            filename: filename,
            args: [
                resultsDir.buildPath(TestTools.testRunner.name.exeName),
                Target.normalizedTestName(filename)
            ]
        };

        return target;
    }

    Appender!(Target[]) newTargets;
    foreach (t; targets)
    {
        t = t.buildNormalizedPath; // remove trailing slashes
        switch (t)
        {
            case "clean":
                if (resultsDir.exists)
                    resultsDir.rmdirRecurse;
                quitSilently(0);
                break;

            case "run_runnable_tests", "runnable":
                newTargets.put(findFiles("runnable").map!createTestTarget);
                break;

            case "run_runnable_cxx_tests", "runnable_cxx":
                newTargets.put(findFiles("runnable_cxx").map!createTestTarget);
                break;

            case "run_fail_compilation_tests", "fail_compilation", "fail":
                newTargets.put(findFiles("fail_compilation").map!createTestTarget);
                break;

            case "run_compilable_tests", "compilable", "compile":
                newTargets.put(findFiles("compilable").map!createTestTarget);
                break;

            case "run_dshell_tests", "dshell":
                newTargets.put(findFiles("dshell").map!createTestTarget);
                break;

            case "all":
                newTargets ~= createUnitTestTarget();
                foreach (testDir; testDirs)
                    newTargets.put(findFiles(testDir).map!createTestTarget);
                break;
            case "unit_tests":
                newTargets ~= createUnitTestTarget();
                break;
            default:
                newTargets ~= createTestTarget(t);
        }
    }
    return newTargets.data;
}

// Removes targets that do not need updating (i.e. their .out file exists and is newer than the source file)
auto filterTargets(Target[] targets, string[string] env)
{
    bool error;
    foreach (target; targets)
    {
        if (!target.exists)
        {
            writefln("Warning: %s can't be found", target.normalizedTestName);
            error = true;
        }
    }
    if (error)
        quitSilently(1);

    Target[] targetsThatNeedUpdating;
    foreach (t; targets)
    {
        immutable testName = t.normalizedTestName;
        auto resultRunTime = resultsDir.buildPath(testName ~ ".out").timeLastModified.ifThrown(SysTime.init);
        if (!force && resultRunTime > testPath(testName).timeLastModified &&
                resultRunTime > env["DMD"].timeLastModified.ifThrown(SysTime.init))
            writefln("%s is already up-to-date", testName);
        else
            targetsThatNeedUpdating ~= t;
    }
    return targetsThatNeedUpdating;
}

// Add additional make-like assignments to the environment
// e.g. ./run.d ARGS=foo -> sets ARGS to 'foo'
void args2Environment(ref string[] args)
{
    bool tryToAdd(string arg)
    {
        const sep = arg.indexOf('=');
        if (sep == -1)
            return false;

        environment[arg[0 .. sep]] = arg[sep+1 .. $];
        return true;
    }
    args = args.filter!(a => !tryToAdd(a)).array;
}

/**
Checks whether the environment already contains a value for key and if so, sets
the found value to the new environment object.
Otherwise uses the `default_` value as fallback.

Params:
    env = environment to write the check to
    key = key to check for existence and write into the new env
    default_ = fallback value if the key doesn't exist in the global environment
*/
auto getDefault(string[string] env, string key, string default_)
{
    if (key in environment)
        env[key] = environment[key];
    else
        env[key] = default_;

    return env[key];
}

// Sets the environment variables required by d_do_test and sh_do_test.sh
string[string] getEnvironment()
{
    string[string] env;

    env["RESULTS_DIR"] = resultsDir;
    env["OS"] = os;
    env["MODEL"] = model;
    env["DMD_MODEL"] = dmdModel;
    env["BUILD"] = build;
    env["EXE"] = exeExtension;
    env["DMD"] = dmdPath;
    env.getDefault("DMD_TEST_COVERAGE", "0");

    const generatedSuffix = "generated/%s/%s/%s".format(os, build, model);

    version(Windows)
    {
        env.getDefault("ARGS", "-inline -release -g -O");
        env["OBJ"] = ".obj";
        env["DSEP"] = `\\`;
        env["SEP"] = `\`;
        auto druntimePath = environment.get("DRUNTIME_PATH", testPath(`..\..\druntime`));
        auto phobosPath = environment.get("PHOBOS_PATH", testPath(`..\..\phobos`));
        env["DFLAGS"] = `-I%s\import -I%s`.format(druntimePath, phobosPath);
        env["LIB"] = phobosPath ~ ";" ~ environment.get("LIB");
    }
    else
    {
        env.getDefault("ARGS", "-inline -release -g -O -fPIC");
        env["OBJ"] = ".o";
        env["DSEP"] = "/";
        env["SEP"] = "/";
        auto druntimePath = environment.get("DRUNTIME_PATH", testPath(`../../druntime`));
        auto phobosPath = environment.get("PHOBOS_PATH", testPath(`../../phobos`));

        // default to PIC on x86_64, use PIC=1/0 to en-/disable PIC.
        // Note that shared libraries and C files are always compiled with PIC.
        bool pic;
        version(X86_64)
            pic = true;
        else version(X86)
            pic = false;
        if (environment.get("PIC", "0") == "1")
            pic = true;

        env["PIC_FLAG"]  = pic ? "-fPIC" : "";
        env["DFLAGS"] = "-I%s/import -I%s".format(druntimePath, phobosPath)
            ~ " -L-L%s/%s".format(phobosPath, generatedSuffix);
        bool isShared = environment.get("SHARED") != "0" && os.among("linux", "freebsd") > 0;
        if (isShared)
            env["DFLAGS"] = env["DFLAGS"] ~ " -defaultlib=libphobos2.so -L-rpath=%s/%s".format(phobosPath, generatedSuffix);

        if (pic)
            env["REQUIRED_ARGS"] = environment.get("REQUIRED_ARGS") ~ " " ~ env["PIC_FLAG"];

        version(OSX)
            version(X86_64)
                env["D_OBJC"] = "1";
    }
    return env;
}

// Logging primitive
auto log(T...)(T args)
{
    if (verbose)
        writefln(args);
}

// Add the executable filename extension to the given `name` for the current OS.
auto exeName(T)(T name)
{
    version(Windows)
        name ~= ".exe";
    return name;
}

// Add the object filename extension to the given `name` for the current OS.
auto objName(T)(T name)
{
    version(Windows)
        return name ~ ".obj";
    else
        return name ~ ".o";
}

/// Return the correct pic flags as an array of strings
string[] getPicFlags(string[string] env)
{
    version(Windows) {} else
    {
        const picFlags = env["PIC_FLAG"];
        if (picFlags.length)
            return picFlags.split();
    }
    return cast(string[])[];
}

/++
Signals a silent termination while still retaining a controlled shutdown
(including destructors, scope guards, etc).

quitSilently(...) should be used instead of exit(...)
++/
class SilentQuit : Exception
{
    /// The exit code
    const int exitCode;

    ///
    this(const int exitCode)
    {
        super(null, null, null);
        this.exitCode = exitCode;
    }
}

/++
Aborts the current execution by throwing an exception

Params:
    exitCode = the exit code

Throws: a SilentQuit instance wrapping exitCode
++/
void quitSilently(const int exitCode)
{
    throw new SilentQuit(exitCode);
}
