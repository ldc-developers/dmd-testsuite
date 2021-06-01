// check the expression parser

_Static_assert(0 == 0, "ok");
_Static_assert(0 != 1, "ok");
_Static_assert(1 + 2 == 3, "ok");
_Static_assert(1 - 2 == -1, "ok");
_Static_assert(3 * 4 == 12, "ok");
_Static_assert(10 / 2 == 5, "ok");
_Static_assert(10 % 3 == 1, "ok");
_Static_assert(2 << 3 == 16, "ok");
_Static_assert(16 >> 3 == 2, "ok");
_Static_assert((2 | 1) == 3, "ok");
_Static_assert((3 & 1) == 1, "ok");
_Static_assert((3 ^ 1) == 2, "ok");
_Static_assert(-(3 ^ 1) == -+2, "ok");
_Static_assert(~1 == 0xFFFFFFFE, "ok");
_Static_assert(!3 == 0, "ok");
_Static_assert(!0 == 1, "ok");

_Static_assert(sizeof(char) == 1, "ok");
_Static_assert(sizeof(char signed) == 1, "ok");
_Static_assert(sizeof(unsigned char) == 1, "ok");

_Static_assert(sizeof(short) == 2, "ok");
_Static_assert(sizeof(int short) == 2, "ok");
_Static_assert(sizeof(signed short) == 2, "ok");
_Static_assert(sizeof(signed short int) == 2, "ok");

_Static_assert(sizeof(short unsigned) == 2, "ok");
_Static_assert(sizeof(unsigned short int) == 2, "ok");

_Static_assert(sizeof(int) == 4, "ok");
_Static_assert(sizeof(signed) == 4, "ok");
_Static_assert(sizeof(signed int) == 4, "ok");

_Static_assert(sizeof(int unsigned) == 4, "ok");
_Static_assert(sizeof(unsigned) == 4, "ok");

_Static_assert(sizeof(long) >= 4, "ok");
_Static_assert(sizeof(signed long) >= 4, "ok");
_Static_assert(sizeof(int long) <= 8, "ok");
_Static_assert(sizeof(long signed int) <= 8, "ok");

_Static_assert(sizeof(int unsigned long) >= 4, "ok");
_Static_assert(sizeof(long unsigned) <= 8, "ok");

_Static_assert(sizeof(long long) == 8, "ok");
_Static_assert(sizeof(int long long) == 8, "ok");
_Static_assert(sizeof(long signed long) == 8, "ok");
_Static_assert(sizeof(long long signed int) == 8, "ok");

_Static_assert(sizeof(unsigned long long) == 8, "ok");
_Static_assert(sizeof(int long unsigned long) == 8, "ok");

_Static_assert(sizeof(float) == 4, "ok");
_Static_assert(sizeof(double) == 8, "ok");
//_Static_assert(sizeof(long double) == 8 || sizeof(long double) == 10 || sizeof(long double) == 16, "ok");

_Static_assert(sizeof(const restrict volatile char volatile restrict const) == 1, "ok");

_Static_assert(sizeof(int*) == 8 || 4 == sizeof(char*), "ok");

_Static_assert(sizeof(int[10][20]) == 20 * (10 * 4), "ok");

/**********************************************/

_Static_assert(07 == 7, "ok");
_Static_assert(071 == 57, "ok");
_Static_assert(0 == 0, "ok");

_Static_assert(1u == 1l, "ok");
_Static_assert(1U == 1L, "ok");
_Static_assert(1Ul == 1L, "ok");

_Static_assert(1ull == 1LL, "ok");
_Static_assert(1llu == 1ull, "ok");

_Static_assert(sizeof(1) == 4, "ok");
_Static_assert(sizeof(0x1) == 4, "ok");
_Static_assert(sizeof(1u) == 4, "ok");
_Static_assert(sizeof(0x1u) == 4, "ok");
_Static_assert(sizeof(1l) == 4  || sizeof(1l) == 8, "ok");
_Static_assert(sizeof(1ul) == 4 || sizeof(1ul) == 8, "ok");
_Static_assert(sizeof(0x1l) == 4  || sizeof(0x1L) == 8, "ok");
_Static_assert(sizeof(0x1ul) == 4 || sizeof(0x1UL) == 8, "ok");
_Static_assert(sizeof(1ll) == 8, "ok");
_Static_assert(sizeof(1ull) == 8, "ok");
_Static_assert(sizeof(0x1ull) == 8, "ok");

_Static_assert(sizeof(0x8000000000000000LL) == 8, "ok");
_Static_assert(sizeof(0x1LL) == 8, "ok");
_Static_assert(sizeof(0x8000000000000000) == 8, "ok");
_Static_assert(sizeof(0x7FFFFFFF00000000) == 8, "ok");
_Static_assert(sizeof(9223372036854775808) == 8, "ok");
_Static_assert(sizeof(9223372032559808512) == 8, "ok");
_Static_assert(sizeof(0xFFFFFFFF00000000U) == 8, "ok");

_Static_assert(sizeof(0x8000000000000000L) == 8, "ok");

/**********************************************/

int f1(i, j)
int i;
int j;
{
    return i + 3;
}

_Static_assert(f1(4, 2) == 7, "ok");

/**********************************************/

enum E1 { M1, M2, M3, M4 = 7, M5, };
enum E2 { M6 };

_Static_assert(M3 == 2, "ok");
_Static_assert(M5 == 8, "ok");

/**********************************************/

int s1(int i)
{
    while (i < 10) ++i;
    return i;
}

_Static_assert(s1(3) == 10, "s1(3) == 10");

int s2(int i)
{
    for (; i < 10; ++i);
    return i;
}

_Static_assert(s2(3) == 10, "s2(3) == 10");

int s3(int i)
{
    do
    {
        ++i;
    } while (i < 10);
    return i;
}

_Static_assert(s3(3) == 10, "s3(3) == 10");

int s4(int i)
{
    switch (i)
    {
        case 1: break;
        case 2+1: i = 10; break;
        default: i = 11; break;
    }
    return i;
}

_Static_assert(s4(1) ==  1, "s4(1) == 1");
_Static_assert(s4(3) == 10, "s4(3) == 10");
_Static_assert(s4(5) == 11, "s4(5) == 11");

int s5(int i)
{
    if (i == 3)
        return 4;
    else
        return 5;
}

_Static_assert(s5(3) == 4, "s5(3) == 4");
_Static_assert(s5(4) == 5, "s5(4) == 5");

/********************************/

void tokens()
<%
    char c = 'c';
    unsigned short w = L'w';
    //unsigned short* ws = L"wstring";
    int LLL1[1];
    int LLL2<:1:>;
%>

/********************************/

void test__func__()
{
    _Static_assert((sizeof __func__) == 13, "ok");
}

/********************************/

struct SA { int a, b, *const c, d[50]; };

int test1(int i)
{
  L1:
    ++i;
  L2:
    { --i; }
    return i;
}

_Static_assert(test1(5) == 5, "ok");

void test2()
{
    int;
    int (*xi);
    int (*fp)(void);
    int (* const volatile restrict fp2)(void);
    void* pv;
    char c, d;
    short sh;
    int j;
    long l;
    signed s;
    unsigned u;
    //_Complex double co;
    _Bool b;
    typedef int TI;
    //extern int ei;
    static int si;
    _Thread_local int tli;
    auto int ai;
    register int reg;
    const int ci;
    volatile int vi;
    restrict int ri;

//    _Atomic(int) ai;
//    _Alignas(c) ac;

    void * const volatile restrict q;

    inline int f();
    _Noreturn void g();

    _Static_assert(1, "ok");
}

void test3(int i)
{
    for (i = 0; ;)
    {
    }
    for (int j = 0; ;)
    {
        continue;
    }
    if (i == 3)
        i = 4;
    else
        i = 5;
    if (i == 4)
        i = 6;
    goto L1;
  L1: ;
    { L2: }
}

void test4(int i)
{
    i = 4, i = 5;
    float f = 1.0f + 3;
    double d = 1.0 + 4;
    char c = 'c';
    //char* s = __func__;
    int* p = &i;
    i = *p;
    _Static_assert(sizeof 3 == 4, "ok");
    _Static_assert(sizeof(3) == 4, "ok");
    _Static_assert(_Alignof(int) == 4, "ok");
    _Static_assert((int)3 == 3, "ok");
    _Static_assert(sizeof p[0] == 4, "ok");
    _Static_assert(1 && 2, "ok");
    _Static_assert((1 ? 2 : 3) == 2, "ok");
    _Static_assert((0 ? 2 : 3) == 3, "ok");

    i += 2;
    i -= 2;
    i *= 2;
    i /= 2;
    i %= 2;
    i &= 2;
    i |= 2;
    i ^= 2;
    i <<= 2;
    i >>= 2;
    i++;
    i--;
    p[0]++;
    *p = 3;
    (++i);
    long long ll = 12L;
    ll = 12UL;
    long double ld = 1.0L;
    const char* s = "hello" "betty";
}

/********************************/

struct SS { int a; };

int tests1()
{
    struct SS s;
    return s.a;
}

int tests2()
{
    struct T { int a; };
    struct T t;
    return t.a;
}

void* tests3()
{
    struct T1 *p;
    return p;
}

int tests4()
{
    struct S { int b; } a, *p;
    a.b = 3;
    p = &a;
    return p->b;
}

int test5()
{
    struct { };
    struct S
    {
        int a;
        struct { int b, c; };
    } s;
    return s.a + s.b + s.c;
}

/********************************/

int printf(const char*, ...);

int main()
{
    printf("hello world\n");
}

#line 1000
%:line 1010


