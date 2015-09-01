
import std.stdio;

// Test function inlining

debug = NRVO;

/************************************/

int foo(int i)
{
    return i;
}

int bar()
{
    return foo(3) + 4;
}

void test1()
{
    printf("%d\n", bar());
    assert(bar() == 7);
}


/************************************/

struct Foo2
{
    int a,b,c,e,f,g;
}


int foo2(Foo2 f)
{
    f.b += 73;
    return f.b;
}

int bar2()
{
    Foo2 gg;

    gg.b = 6;
    return foo2(gg) + 4;
}

void test2()
{
    printf("%d\n", bar2());
    assert(bar2() == 83);
}


/************************************/

struct Foo3
{
    int bar() { return y + 3; }
    int y = 4;
}

void test3()
{
    Foo3 f;

    assert(f.bar() == 7);
}


/************************************/

void func(void function () v)
{
}

void test4()
{
   static void f1() { }
   
   func(&f1);
   //func(f1);  
} 


/************************************/

void foo5(ubyte[16] array)
{
    bar5(array.ptr);
}

void bar5(ubyte *array)
{
}

void abc5(ubyte[16] array)
{
    foo5(array);
}

void test5()
{
}

/************************************/

struct Struct
{
    real foo()
    {
        return 0;
    }

    void bar(out Struct Q)
    {
        if (foo() < 0)
            Q = this; 
    }
}

void test6()
{
}

/************************************/

struct S7(T)
{
    immutable(T)[] s;
}

T foo7(T)(T t)
{
    enum S7!(T)[] i = [{"hello"},{"world"}];
    auto x = i[0].s;
    return t;
}

void test7()
{
    auto x = foo7('c');
}

/************************************/

// 10833
string fun10833(T...)()
{
    foreach (v ; T)
        return v;
    assert(0);
}

void test10833()
{
    auto a = fun10833!("bar")();
}

/************************************/
// Bugzilla 4825

int a8() {
    int r;
    return r;
}

int b8() {
    return a8();
}

void test8() {
    void d() {
        auto e = b8();
    }
    static const int f = b8();
}

/************************************/
// 4841

auto fun4841a()
{
    int i = 42;
    struct Result
    {
        this(int u) {}
        auto bar()
        {
            // refer context of fun4841a
            return i;
        }
    }
    return Result();
}
void test4841a()
{
    auto t = fun4841a();
    auto x = t.bar();
    assert(x == 42);
}

auto fun4841b()
{
    int i = 40;
    auto foo()  // hasNestedFrameRefs() == false
    {
        //
        struct Result
        {
            this(int u) {}
            auto bar()
            {
                // refer context of fun4841b
                return i + 2;
            }
        }
        return Result();
    }
    return foo();
}
void test4841b()
{
    auto t = fun4841b();
    assert(cast(void*)t.tupleof[$-1] !is null);     // Result to fun4841b
    auto x = t.bar();
    assert(x == 42);
}

auto fun4841c()
{
    int i = 40;
    auto foo()  // hasNestedFrameRefs() == true
    {
        int g = 2;
        struct Result
        {
            this(int u) {}
            auto bar()
            {
                // refer context of fun4841c and foo
                return i + g;
            }
        }
        return Result();
    }
    return foo();
}
void test4841c()
{
    auto t = fun4841c();
    assert(  cast(void*)t.tupleof[$-1] !is null);   // Result to foo
    assert(*cast(void**)t.tupleof[$-1] !is null);   // foo to fun4841c
    auto x = t.bar();
    assert(x == 42);
}

void test4841()
{
    test4841a();
    test4841b();
    test4841c();
}

/************************************/
// 7261

struct AbstractTask
{
    ubyte taskStatus;
}

struct Task
{
    AbstractTask base;
    alias base this;

    void opAssign(Task rhs)
    {
    }

    ~this()
    {
        if (taskStatus != 3) { }
    }
}

/************************************/
// 9356

void test9356()
{
    static inout(char)[] bar (inout(char)[] a)
    {
        return a;
    }

    string result;
    result ~= bar("abc");
    assert(result == "abc");
}

/************************************/
// 12079

void test12079()
{
    string[string][string] foo;

    foo.get("bar", null).get("baz", null);
}

/************************************/
// 12243

char f12243() { return 'a'; }

void test12243()
{
    string s;
    s ~= f12243();
}

/************************************/
// 11201

struct Foo11201
{
    int a;
    float b;

    Foo11201 func()() const { return this; }
}

auto f11201()(Foo11201 a) { return a; }

void test11201()
{
    auto a = Foo11201(0, 1);

    assert(f11201(a.func!()()) == a);
}

/************************************/
// 11223

struct Tuple11223(T...)
{
    T values;

    void opAssign(Tuple11223 rhs)
    {
        if (0)
            values = rhs.values;
        else
            assert(1);
    }
}

void test11223()
{
    Tuple11223!string tmp;
    tmp = Tuple11223!string();
}

/************************************/


void foo3918()
{
    import core.stdc.stdlib : alloca;
    void[] mem = alloca(1024)[0..1024];
}

void test3918()
{
    foreach(i; 0 .. 10_000_000)
    {
        foo3918();
    }
}

/************************************/
// 11314

struct Tuple11314(T...)
{
    T values;

    void opAssign(typeof(this) rhs)
    {
        if (0)
            values[] = rhs.values[];
        else
            assert(1);
    }
}

struct S11314 {}

void test11314()
{
    Tuple11314!S11314 t;
    t = Tuple11314!S11314(S11314.init);
}

/************************************/
// 11224

S11224* ptr11224;

struct S11224
{
    this(int)
    {
        ptr11224 = &this;
        /*printf("ctor &this = %p\n", &this);*/
    }
    this(this)
    {
        /*printf("cpctor &this = %p\n", &this);*/
    }
    int num;
}
S11224 foo11224()
{
    S11224 s = S11224(1);
    //printf("foo  &this = %p\n", &s);
    assert(ptr11224 is &s);
    return s;
}
void test11224()
{
    auto s = foo11224();
    //printf("main &this = %p\n", &s);
    assert(ptr11224 is &s);
}

/************************************/
// 11322

bool b11322;
uint n11322;

ref uint fun11322()
{
    if (b11322)
        return n11322;
    else
        return n11322;
}

void test11322()
{
    fun11322()++;
    assert(n11322 == 1);
    fun11322() *= 5;
    assert(n11322 == 5);
}

/************************************/
// 11394

debug(NRVO) static void* p11394a, p11394b, p11394c;

static int[3] make11394(in int x) pure
{
    typeof(return) a;
    a[0] = x;
    a[1] = x + 1;
    a[2] = x + 2;
    debug(NRVO) p11394a = cast(void*)a.ptr;
    return a;
}

struct Bar11394
{
    immutable int[3] arr;

    this(int x)
    {
        this.arr = make11394(x);    // NRVO should work
        debug(NRVO) p11394b = cast(void*)this.arr.ptr;
    }
}

void test11394()
{
    auto b = Bar11394(5);
    debug(NRVO) p11394c = cast(void*)b.arr.ptr;
  //debug(NRVO) printf("p1 = %p\np2 = %p\np3 = %p\n", p11394a, p11394b, p11394c);
    debug(NRVO) assert(p11394a == p11394b);
    debug(NRVO) assert(p11394b == p11394c);
}

/**********************************/
// 12080

class TZ12080 {}

struct ST12080
{
    ST12080 opBinary()() const pure nothrow
    {
        auto retval = ST12080();
        return retval;  // NRVO
    }

    long  _stdTime;
    immutable TZ12080 _timezone;
}

class Foo12080
{

    ST12080 bar;
    bool quux;

    public ST12080 sysTime()
    out {}
    body
    {
        if (quux)
            return ST12080();

        return bar.opBinary();
        // returned value is set to __result
        // --> Inliner wrongly created the second DeclarationExp for __result.
    }
}

/**********************************/
// 13503

void f13503a(string[] s...)
{
    assert(s[0] == "Cheese");
}

auto f13503b(string arg)
{
    string result = arg;
    return result;
}

string f13503c(string arg)
{
    string result = arg;
    return result;
}

void test13503()
{
    f13503a(f13503b("Cheese"));
    f13503a(f13503c("Cheese"));
}

/**********************************/
// 14267

// EXTRA_SOURCES: imports/a14267.d
import imports.a14267;

void test14267()
{
    foreach (m; __traits(allMembers, SysTime14267))
    {
        static if (is(typeof(__traits(getMember, SysTime14267, m))))
        {
            foreach (func; __traits(getOverloads, SysTime14267, m))
            {
                auto prot = __traits(getProtection, func);
                static if (__traits(isStaticFunction, func))
                {
                    static assert(func.stringof == "min()");
                    auto result = func;
                }
            }
        }
    }
}

/**********************************/

int main()
{
    test1();
    test2();
    test3();
    test3918();
    test4();
    test5();
    test9356();
    test6();
    test7();
    test8();
    test4841();
    test11201();
    test11223();
    test11314();
    test11224();
    test11322();
    test11394();
    test13503();

    printf("Success\n");
    return 0;
}
