// REQUIRED_ARGS: -o-

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(12): Error: cannot cast expression x of type short[2] to int[2]
---
*/
void test3133()
{
    short[2] x = [1, 2];
    auto y = cast(int[2])x;     // error
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(28): Error: cannot cast expression null of type typeof(null) to S1
fail_compilation/fail_casting.d(29): Error: cannot cast expression null of type typeof(null) to S2
fail_compilation/fail_casting.d(30): Error: cannot cast expression s1 of type S1 to typeof(null)
fail_compilation/fail_casting.d(31): Error: cannot cast expression s2 of type S2 to typeof(null)
---
*/
void test9904()
{
    static struct S1 { size_t m; }
    static struct S2 { size_t m; byte b; }
    { auto x = cast(S1)null; }
    { auto x = cast(S2)null; }
    { S1 s1; auto x = cast(typeof(null))s1; }
    { S2 s2; auto x = cast(typeof(null))s2; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(46): Error: cannot cast expression x of type Object[] to object.Object
fail_compilation/fail_casting.d(47): Error: cannot cast expression x of type Object[2] to object.Object
fail_compilation/fail_casting.d(49): Error: cannot cast expression x of type object.Object to Object[]
fail_compilation/fail_casting.d(50): Error: cannot cast expression x of type object.Object to Object[2]
---
*/
void test10646()
{
    // T[] or T[n] --> Tclass
    { Object[]  x; auto y = cast(Object)x; }
    { Object[2] x; auto y = cast(Object)x; }
    // T[] or T[n] <-- Tclass
    { Object x; auto y = cast(Object[] )x; }
    { Object x; auto y = cast(Object[2])x; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(69): Error: cannot cast expression x of type int[1] to int
fail_compilation/fail_casting.d(70): Error: cannot cast expression x of type int to int[1]
fail_compilation/fail_casting.d(71): Error: cannot cast expression x of type float[1] to int
fail_compilation/fail_casting.d(72): Error: cannot cast expression x of type int to float[1]
fail_compilation/fail_casting.d(75): Error: cannot cast expression x of type int[] to int
fail_compilation/fail_casting.d(76): Error: cannot cast expression x of type int to int[]
fail_compilation/fail_casting.d(77): Error: cannot cast expression x of type float[] to int
fail_compilation/fail_casting.d(78): Error: cannot cast expression x of type int to float[]
---
*/
void tst11484()
{
    // Tsarray <--> integer
    { int[1]   x; auto y = cast(int     ) x; }
    { int      x; auto y = cast(int[1]  ) x; }
    { float[1] x; auto y = cast(int     ) x; }
    { int      x; auto y = cast(float[1]) x; }

    // Tarray <--> integer
    { int[]   x; auto y = cast(int    ) x; }
    { int     x; auto y = cast(int[]  ) x; }
    { float[] x; auto y = cast(int    ) x; }
    { int     x; auto y = cast(float[]) x; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(97): Error: cannot cast expression x of type int to fail_casting.test11485.C
fail_compilation/fail_casting.d(98): Error: cannot cast expression x of type int to fail_casting.test11485.I
fail_compilation/fail_casting.d(101): Error: cannot cast expression x of type fail_casting.test11485.C to int
fail_compilation/fail_casting.d(102): Error: cannot cast expression x of type fail_casting.test11485.I to int
---
*/

void test11485()
{
    class C {}
    interface I {}

    // 11485 TypeBasic --> Tclass
    { int x; auto y = cast(C)x; }
    { int x; auto y = cast(I)x; }

    //  7472 TypeBasic <-- Tclass
    { C x; auto y = cast(int)x; }
    { I x; auto y = cast(int)x; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(114): Error: cannot cast expression x of type typeof(null) to int[2]
fail_compilation/fail_casting.d(115): Error: cannot cast expression x of type int[2] to typeof(null)
---
*/
void test8179()
{
    { typeof(null) x; auto y = cast(int[2])x; }
    { int[2] x;       auto y = cast(typeof(null))x; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(128): Error: cannot cast expression x of type S to int*
fail_compilation/fail_casting.d(130): Error: cannot cast expression x of type void* to S
---
*/
void test13959()
{
    struct S { int* p; }
    { S     x; auto y = cast(int*)x; }
    { int*  x; auto y = cast(S)x; }     // no error so it's rewritten as: S(x)
    { void* x; auto y = cast(S)x; }
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(144): Error: cannot cast expression mi.x of type int to MyUbyte14154
---
*/
struct MyUbyte14154 { ubyte x; alias x this; }
struct MyInt14154   {   int x; alias x this; }
void test14154()
{
    MyInt14154 mi;
    ubyte t = cast(MyUbyte14154)mi;
}

/*
TEST_OUTPUT:
---
fail_compilation/fail_casting.d(179): Error: cannot cast expression __tup3.__expand_field_0 of type int to object.Object
fail_compilation/fail_casting.d(179): Error: cannot cast expression __tup3.__expand_field_1 of type int to object.Object
---
*/
alias TypeTuple14093(T...) = T;
struct Tuple14093(T...)
{
    static if (T.length == 4)
    {
        alias Types = TypeTuple14093!(T[0], T[2]);

        Types expand;

        @property ref inout(Tuple14093!Types) _Tuple_super() inout @trusted
        {
            return *cast(typeof(return)*) &(expand[0]);
        }
        alias _Tuple_super this;
    }
    else
    {
        alias Types = T;
        Types expand;
        alias expand this;
    }
}
void test14093()
{
    Tuple14093!(int, "x", int, "y") point;
    auto newPoint = cast(Object)(point);
}
