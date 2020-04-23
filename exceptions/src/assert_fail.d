import core.stdc.stdio : fprintf, stderr;
import core.internal.dassert : _d_assert_fail;

void test(string comp = "==", A, B)(A a, B b, string msg, size_t line = __LINE__)
{
    test(_d_assert_fail!(comp, A, B)(a, b), msg, line);
}

void test(const string actual, const string expected, size_t line = __LINE__)
{
    import core.exception : AssertError;

    if (actual != expected)
    {
        const msg = "Mismatch!\nExpected: <" ~ expected ~ ">\nActual:   <" ~ actual ~ '>';
        throw new AssertError(msg, __FILE__, line);
    }
}

void testIntegers()()
{
    test(1, 2, "1 != 2");
    test(-10, 8, "-10 != 8");
    test(byte.min, byte.max, "-128 != 127");
    test(ubyte.min, ubyte.max, "0 != 255");
    test(short.min, short.max, "-32768 != 32767");
    test(ushort.min, ushort.max, "0 != 65535");
    test(int.min, int.max, "-2147483648 != 2147483647");
    test(uint.min, uint.max, "0 != 4294967295");
    test(long.min, long.max, "-9223372036854775808 != 9223372036854775807");
    test(ulong.min, ulong.max, "0 != 18446744073709551615");
    test(shared(ulong).min, shared(ulong).max, "0 != 18446744073709551615");

    int testFun() { return 1; }
    test(testFun(), 2, "1 != 2");
}

void testIntegerComparisons()()
{
    test!"!="(2, 2, "2 == 2");
    test!"<"(2, 1, "2 >= 1");
    test!"<="(2, 1, "2 > 1");
    test!">"(1, 2, "1 <= 2");
    test!">="(1, 2, "1 < 2");
}

void testFloatingPoint()()
{
    test(1.5, 2.5, "1.5 != 2.5");
    test(float.max, -float.max, "3.40282e+38 != -3.40282e+38");
    test(double.max, -double.max, "1.79769e+308 != -1.79769e+308");
    test(real(1), real(-1), "1 != -1");

    test(ifloat.max, -ifloat.max, "3.40282e+38i != -3.40282e+38i");
    test(idouble.max, -idouble.max, "1.79769e+308i != -1.79769e+308i");
    test(ireal(1i), ireal(-1i), "1i != -1i");

    test(cfloat.max, -cfloat.max, "3.40282e+38 + 3.40282e+38i != -3.40282e+38 + -3.40282e+38i");
    test(cdouble.max, -cdouble.max, "1.79769e+308 + 1.79769e+308i != -1.79769e+308 + -1.79769e+308i");
    test(creal(1 + 2i), creal(-1 + 2i), "1 + 2i != -1 + 2i");
}

void testPointers()
{
    static struct S
    {
        string toString() const { return "S(...)"; }
    }

    static if ((void*).sizeof == 4)
        enum ptr = "0x12345670";
    else
        enum ptr = "0x123456789ABCDEF0";

    int* p = cast(int*) mixin(ptr);
    test(cast(S*) p, p, ptr ~ " != " ~ ptr);
}

void testStrings()
{
    test("foo", "bar", `"foo" != "bar"`);
    test("", "bar", `"" != "bar"`);

    char[] dlang = "dlang".dup;
    const(char)[] rust = "rust";
    test(dlang, rust, `"dlang" != "rust"`);

    // https://issues.dlang.org/show_bug.cgi?id=20322
    test("left"w, "right"w, `"left" != "right"`);
    test("left"d, "right"d, `"left" != "right"`);

    test('A', 'B', "'A' != 'B'");
    test(wchar('❤'), wchar('∑'), "'❤' != '∑'");
    test(dchar('❤'), dchar('∑'), "'❤' != '∑'");

    // Detect invalid code points
    test(char(255), 'B', "cast(char) 255 != 'B'");
    test(wchar(0xD888), wchar('∑'), "cast(wchar) 55432 != '∑'");
    test(dchar(0xDDDD), dchar('∑'), "cast(dchar) 56797 != '∑'");
}

void testToString()()
{
    class Foo
    {
        this(string payload) {
            this.payload = payload;
        }

        string payload;
        override string toString() {
            return "Foo(" ~ payload ~ ")";
        }
    }
    test(new Foo("a"), new Foo("b"), "Foo(a) != Foo(b)");

    scope f = cast(shared) new Foo("a");
    test!"!="(f, f, "Foo(a) == Foo(a)");

    // Verifiy that the const toString is selected if present
    static struct Overloaded
    {
        string toString()
        {
            return "Mutable";
        }

        string toString() const
        {
            return "Const";
        }
    }

    test!"!="(Overloaded(), Overloaded(), "Const == Const");

    Foo fnull = null;
    test!"!is"(fnull, fnull, "`null` is `null`");
}


void testArray()()
{
    test([1], [0], "[1] != [0]");
    test([1, 2, 3], [0], "[1, 2, 3] != [0]");

    // test with long arrays
    int[] arr;
    foreach (i; 0 .. 100)
        arr ~= i;
    test(arr, [0], "[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, ...] != [0]");

    // Ignore fake arrays
    static struct S
    {
        int[2] arr;
        int[] get() { return arr[]; }
        alias get this;
    }

    const a = S([1, 2]);
    test(a, S([3, 4]), "S([1, 2]) != S([3, 4])");
}

void testStruct()()
{
    struct S { int s; }
    struct T { T[] t; }
    test(S(0), S(1), "S(0) != S(1)");
    test(T([T(null)]), T(null), "T([T([])]) != T([])");

    // https://issues.dlang.org/show_bug.cgi?id=20323
    static struct NoCopy
    {
        @disable this(this);
    }

    NoCopy n;
    test(_d_assert_fail!"!="(n, n), "NoCopy() == NoCopy()");

    shared NoCopy sn;
    test(_d_assert_fail!"!="(sn, sn), "NoCopy() == NoCopy()");
}

void testAA()()
{
    test([1:"one"], [2: "two"], `[1: "one"] != [2: "two"]`);
    test!"in"(1, [2: 3], "1 !in [2: 3]");
    test!"in"("foo", ["bar": true], `"foo" !in ["bar": true]`);
}


void testAttributes() @safe pure @nogc nothrow
{
    int a;
    string s = _d_assert_fail!"=="(a, 0);
    string s2 = _d_assert_fail!"!"(a);
}

// https://issues.dlang.org/show_bug.cgi?id=20066
void testVoidArray()()
{
    test!"!is"([], null, "[] is `null`");
    test!"!is"(null, null, "`null` is `null`");
    test([1], null, "[1] != `null`");
    test("s", null, "\"s\" != `null`");
    test(['c'], null, "\"c\" != `null`");
    test!"!="(null, null, "`null` == `null`");

    const void[] chunk = [byte(1), byte(2), byte(3)];
    test(chunk, null, "[1, 2, 3] != `null`");
}

void testTemporary()
{
    static struct Bad
    {
        ~this() @system {}
    }

    test!"!="(Bad(), Bad(), "Bad() == Bad()");
}

void testEnum()
{
    static struct UUID {
        union
        {
            ubyte[] data = [1];
        }
    }

    ubyte[] data;
    enum ctfe = UUID();
    test(_d_assert_fail!"=="(ctfe.data, data), "[1] != []");
}

void testUnary()
{
    test(_d_assert_fail!""(9), "9 != true");
    test(_d_assert_fail!"!"([1, 2, 3]), "[1, 2, 3] == true");
}

void main()
{
    testIntegers();
    testIntegerComparisons();
    testFloatingPoint();
    testPointers();
    testStrings();
    testToString();
    testArray();
    testStruct();
    testAA();
    testAttributes();
    testVoidArray();
    testTemporary();
    testEnum();
    testUnary();
    fprintf(stderr, "success.\n");
}
