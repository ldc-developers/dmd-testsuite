/* REQUIRED_ARGS: -preview=dip1000
TEST_OUTPUT:
---
fail_compilation/fail20183.d(1016): Error: cannot modify constant expression `S(0).i`
fail_compilation/fail20183.d(1017): Error: address of struct temporary returned by `s()` assigned to longer lived variable `q`
---
 */

#line 1000

// https://issues.dlang.org/show_bug.cgi?id=20183

@safe:

int* addr(return ref int b) { return &b; }

struct S
{
    int i;
}

S s() { return S(); }

void test()
{
    int* p = addr(S().i);  // struct literal
    int* q = addr(s().i);  // struct temporary
}
