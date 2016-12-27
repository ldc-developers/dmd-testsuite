// REQUIRED_ARGS: -o- -d

struct S1 { int v; }
struct S2 { int* p; }
class C { int v; }

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(32): Error: escaping reference to local variable x
fail_compilation/fail13902.d(33): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(38): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(39): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(40): Error: escaping reference to local variable x
fail_compilation/fail13902.d(41): Error: escaping reference to local variable x
fail_compilation/fail13902.d(42): Error: escaping reference to local variable x
fail_compilation/fail13902.d(45): Error: escaping reference to local variable y
---
*/
int* testEscape1()
{
    int x, y;
    int[] da1;
    int[][] da2;
    int[1] sa1;
    int[1][1] sa2;
    int* ptr;
    S1 s1;
    S2 s2;
    C  c;

    if (0) return &x;               // VarExp
    if (0) return &s1.v;            // DotVarExp
    if (0) return s2.p;             // no error
    if (0) return &c.v;             // no error
    if (0) return &da1[0];          // no error
    if (0) return &da2[0][0];       // no error
    if (0) return &sa1[0];          // IndexExp
    if (0) return &sa2[0][0];       // IndexExp
    if (0) return &x;
    if (0) return &x + 1;           // optimized to SymOffExp == (& x+4)
    if (0) return &x + x;
  //if (0) return ptr += &x + 1;    // semantic error
    if (0)        ptr -= &x - &y;   // no error
    if (0) return (&x, &y);         // CommaExp

    return null;    // ok
}

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(75): Error: escaping reference to local variable x
fail_compilation/fail13902.d(76): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(81): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(82): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(83): Error: escaping reference to local variable x
fail_compilation/fail13902.d(84): Error: escaping reference to local variable x
fail_compilation/fail13902.d(85): Error: escaping reference to local variable x
fail_compilation/fail13902.d(88): Error: escaping reference to local variable y
---
*/
int* testEscape2(
    int x, int y,
    int[] da1,
    int[][] da2,
    int[1] sa1,
    int[1][1] sa2,
    int* ptr,
    S1 s1,
    S2 s2,
    C  c,
)
{
    if (0) return &x;               // VarExp
    if (0) return &s1.v;            // DotVarExp
    if (0) return s2.p;             // no error
    if (0) return &c.v;             // no error
    if (0) return &da1[0];          // no error
    if (0) return &da2[0][0];       // no error
    if (0) return &sa1[0];          // IndexExp
    if (0) return &sa2[0][0];       // IndexExp
    if (0) return &x;
    if (0) return &x + 1;           // optimized to SymOffExp == (& x+4)
    if (0) return  &x + x;
  //if (0) return ptr += &x + 1;    // semantic error
    if (0)        ptr -= &x - &y;   // no error
    if (0) return (&x, &y);         // CommaExp

    return null;    // ok
}

/*
TEST_OUTPUT:
---
---
*/
int* testEscape3(
    ref int x, ref int y,
    ref int[] da1,
    ref int[][] da2,
    ref int[1] sa1,
    ref int[1][1] sa2,
    ref int* ptr,
    ref S1 s1,
    ref S2 s2,
    ref C  c,
)
{
    if (0) return &x;               // VarExp
    if (0) return &s1.v;            // DotVarExp
    if (0) return s2.p;             // no error
    if (0) return &c.v;             // no error
    if (0) return &da1[0];          // no error
    if (0) return &da2[0][0];       // no error
    if (0) return &sa1[0];          // IndexExp
    if (0) return &sa2[0][0];       // IndexExp
    if (0) return ptr = &x;
    if (0) return ptr = &x + 1;     // optimized to SymOffExp == (& x+4)
    if (0) return ptr = &x + x;
  //if (0) return ptr += &x + 1;    // semantic error
    if (0) return ptr -= &x - &y;   // no error
    if (0) return (&x, &y);         // CommaExp

    return null;    // ok
}

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(150): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(151): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(152): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(155): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(156): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(157): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(161): Error: escaping reference to local variable s
fail_compilation/fail13902.d(162): Error: escaping reference to local variable s
fail_compilation/fail13902.d(163): Error: escaping reference to local variable s
fail_compilation/fail13902.d(166): Error: escaping reference to stack allocated value returned by makeSA()
fail_compilation/fail13902.d(167): Error: escaping reference to stack allocated value returned by makeSA()
fail_compilation/fail13902.d(168): Error: escaping reference to stack allocated value returned by makeSA()
fail_compilation/fail13902.d(171): Error: escaping reference to stack allocated value returned by makeS()
fail_compilation/fail13902.d(172): Error: escaping reference to stack allocated value returned by makeS()
fail_compilation/fail13902.d(173): Error: escaping reference to stack allocated value returned by makeS()
---
*/
int[] testEscape4(int[3] sa1)       // Bugzilla 9279
{
    if (0) return sa1;                      // error <- no error
    if (0) return cast(int[])sa1;           // error <- no error
    if (0) return sa1[];                    // error

    int[3] sa2;
    if (0) return sa2;                      // error
    if (0) return cast(int[])sa2;           // error
    if (0) return sa2[];                    // error

    struct S { int[3] sa; }
    S s;
    if (0) return s.sa;                     // error <- no error
    if (0) return cast(int[])s.sa;          // error <- no error
    if (0) return s.sa[];                   // error

    int[3] makeSA() { int[3] ret; return ret; }
    if (0) return makeSA();                 // error <- no error
    if (0) return cast(int[])makeSA();      // error <- no error
    if (0) return makeSA()[];               // error <- no error

    S makeS() { S s; return s; }
    if (0) return makeS().sa;               // error <- no error
    if (0) return cast(int[])makeS().sa;    // error <- no error
    if (0) return makeS().sa[];             // error <- no error

    return null;
}

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(201): Error: escaping reference to local variable x
fail_compilation/fail13902.d(202): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(206): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(207): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(208): Error: escaping reference to local variable x
fail_compilation/fail13902.d(209): Error: escaping reference to local variable x
fail_compilation/fail13902.d(210): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(211): Error: escaping reference to local variable s1
---
*/
ref int testEscapeRef1()
{
    int x;
    int[] da1;
    int[][] da2;
    int[1] sa1;
    int[1][1] sa2;
    S1 s1;
    C  c;

    if (0) return x;            // VarExp
    if (0) return s1.v;         // DotVarExp
    if (0) return c.v;          // no error
    if (0) return da1[0];       // no error
    if (0) return da2[0][0];    // no error
    if (0) return sa1[0];       // IndexExp
    if (0) return sa2[0][0];    // IndexExp
    if (0) return x = 1;        // AssignExp
    if (0) return x += 1;       // BinAssignExp
    if (0) return s1.v = 1;     // AssignExp (e1 is DotVarExp)
    if (0) return s1.v += 1;    // BinAssignExp (e1 is DotVarExp)

    static int g;
    return g;       // ok
}

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(240): Error: escaping reference to local variable x
fail_compilation/fail13902.d(241): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(245): Error: escaping reference to local variable sa1
fail_compilation/fail13902.d(246): Error: escaping reference to local variable sa2
fail_compilation/fail13902.d(247): Error: escaping reference to local variable x
fail_compilation/fail13902.d(248): Error: escaping reference to local variable x
fail_compilation/fail13902.d(249): Error: escaping reference to local variable s1
fail_compilation/fail13902.d(250): Error: escaping reference to local variable s1
---
*/
ref int testEscapeRef2(
    int x,
    int[] da1,
    int[][] da2,
    int[1] sa1,
    int[1][1] sa2,
    S1 s1,
    C  c,
)
{
    if (0) return x;            // VarExp
    if (0) return s1.v;         // DotVarExp
    if (0) return c.v;          // no error
    if (0) return da1[0];       // no error
    if (0) return da2[0][0];    // no error
    if (0) return sa1[0];       // IndexExp
    if (0) return sa2[0][0];    // IndexExp
    if (0) return x = 1;        // AssignExp
    if (0) return x += 1;       // BinAssignExp
    if (0) return s1.v = 1;     // AssignExp (e1 is DotVarExp)
    if (0) return s1.v += 1;    // BinAssignExp (e1 is DotVarExp)

    static int g;
    return g;       // ok
}

/*
TEST_OUTPUT:
---
---
*/
ref int testEscapeRef2(
    ref int x,
    ref int[] da1,
    ref int[][] da2,
    ref int[1] sa1,
    ref int[1][1] sa2,
    ref S1 s1,
    ref C  c,
)
{
    if (0) return x;            // VarExp
    if (0) return s1.v;         // DotVarExp
    if (0) return c.v;          // no error
    if (0) return da1[0];       // no error
    if (0) return da2[0][0];    // no error
    if (0) return sa1[0];       // IndexExp
    if (0) return sa2[0][0];    // IndexExp
    if (0) return x = 1;        // AssignExp
    if (0) return x += 1;       // BinAssignExp
    if (0) return s1.v = 1;     // AssignExp (e1 is DotVarExp)
    if (0) return s1.v += 1;    // BinAssignExp (e1 is DotVarExp)

    static int g;
    return g;       // ok
}

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(294): Error: escaping reference to local variable x
fail_compilation/fail13902.d(295): Error: escaping reference to local variable x
---
*/
int*[]  testArrayLiteral1() { int x; return [&x]; }
int*[1] testArrayLiteral2() { int x; return [&x]; }

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(304): Error: escaping reference to local variable x
fail_compilation/fail13902.d(305): Error: escaping reference to local variable x
---
*/
S2  testStructLiteral1() { int x; return     S2(&x); }
S2* testStructLiteral2() { int x; return new S2(&x); }

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(314): Error: escaping reference to local variable sa
fail_compilation/fail13902.d(315): Error: escaping reference to local variable sa
---
*/
int[] testSlice1() { int[3] sa; return sa[]; }
int[] testSlice2() { int[3] sa; int n; return sa[n..2][1..2]; }

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(324): Error: escaping reference to local variable vda
fail_compilation/fail13902.d(325): Error: escaping reference to variadic parameter vda
---
*/
ref int testDynamicArrayVariadic1(int[] vda...) { return vda[0]; }
int[]   testDynamicArrayVariadic2(int[] vda...) { return vda[]; }
int[3]  testDynamicArrayVariadic3(int[] vda...) { return vda[0..3]; }   // no error

/*
TEST_OUTPUT:
---
fail_compilation/fail13902.d(335): Error: escaping reference to local variable vsa
fail_compilation/fail13902.d(336): Error: escaping reference to variadic parameter vsa
---
*/
ref int testStaticArrayVariadic1(int[3] vsa...) { return vsa[0]; }
int[]   testStaticArrayVariadic2(int[3] vsa...) { return vsa[]; }
int[3]  testStaticArrayVariadic3(int[3] vsa...) { return vsa[0..3]; }   // no error
