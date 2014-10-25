// -c -m32 D:\OpenSource\ldc\ldc\tests\d2\dmd-testsuite\runnable\builtin.d
module ldc_intrinsics;

import ldc.intrinsics;

/*******************************************/
// Make sure that intrinsics do not interfere with C name mangling.

extern(C) uint bswap(uint x)
{
    return x;
}

void test1()
{
    enum v1 = bswap(0xdeadbeef);
    assert(v1 == 0xdeadbeef);

    enum v2 = llvm_bswap(0xcafebabe);
    assert(v2 == 0xbebafeca);
}

/*******************************************/
// Check runtime and compile time evaluation of llvm_bswap().

void test2()
{
    assert( llvm_bswap( cast(ushort)0 ) == 0);
    assert( llvm_bswap( cast(ushort)0x00FF ) == 0xFF00);
    assert( llvm_bswap( cast(ushort)0xAABB ) == 0xBBAA);
    assert( llvm_bswap( cast(uint)0x0000_00FF ) == 0xFF00_0000);
    assert( llvm_bswap( cast(uint)0x0000_FF00 ) == 0x00FF_0000);
    assert( llvm_bswap( cast(uint)0x00FF_0000 ) == 0x0000_FF00);
    assert( llvm_bswap( cast(uint)0xFF00_0000 ) == 0x0000_00FF);
    assert( llvm_bswap( cast(uint)0x00AA_BB00 ) == 0x00BB_AA00);
    assert( llvm_bswap( cast(ulong)0x00000000_000000FF ) == 0xFF000000_00000000);
    assert( llvm_bswap( cast(ulong)0x00000000_0000FF00 ) == 0x00FF0000_00000000);
    assert( llvm_bswap( cast(ulong)0x00000000_00FF0000 ) == 0x0000FF00_00000000);
    assert( llvm_bswap( cast(ulong)0x00000000_FF000000 ) == 0x000000FF_00000000);
    assert( llvm_bswap( cast(ulong)0x000000FF_00000000 ) == 0x00000000_FF000000);
    assert( llvm_bswap( cast(ulong)0x0000FF00_00000000 ) == 0x00000000_00FF0000);
    assert( llvm_bswap( cast(ulong)0x00FF0000_00000000 ) == 0x00000000_0000FF00);
    assert( llvm_bswap( cast(ulong)0xFF000000_00000000 ) == 0x00000000_000000FF);
    assert( llvm_bswap( cast(ulong)0x000000AA_BB000000 ) == 0x000000BB_AA000000);

    static assert( llvm_bswap( cast(ushort)0 ) == 0);
    static assert( llvm_bswap( cast(ushort)0x00FF ) == 0xFF00);
    static assert( llvm_bswap( cast(ushort)0xAABB ) == 0xBBAA);
    static assert( llvm_bswap( cast(uint)0x0000_00FF ) == 0xFF00_0000);
    static assert( llvm_bswap( cast(uint)0x0000_FF00 ) == 0x00FF_0000);
    static assert( llvm_bswap( cast(uint)0x00FF_0000 ) == 0x0000_FF00);
    static assert( llvm_bswap( cast(uint)0xFF00_0000 ) == 0x0000_00FF);
    static assert( llvm_bswap( cast(uint)0x00AA_BB00 ) == 0x00BB_AA00);
    static assert( llvm_bswap( cast(ulong)0x00000000_000000FF ) == 0xFF000000_00000000);
    static assert( llvm_bswap( cast(ulong)0x00000000_0000FF00 ) == 0x00FF0000_00000000);
    static assert( llvm_bswap( cast(ulong)0x00000000_00FF0000 ) == 0x0000FF00_00000000);
    static assert( llvm_bswap( cast(ulong)0x00000000_FF000000 ) == 0x000000FF_00000000);
    static assert( llvm_bswap( cast(ulong)0x000000FF_00000000 ) == 0x00000000_FF000000);
    static assert( llvm_bswap( cast(ulong)0x0000FF00_00000000 ) == 0x00000000_00FF0000);
    static assert( llvm_bswap( cast(ulong)0x00FF0000_00000000 ) == 0x00000000_0000FF00);
    static assert( llvm_bswap( cast(ulong)0xFF000000_00000000 ) == 0x00000000_000000FF);
    static assert( llvm_bswap( cast(ulong)0x000000AA_BB000000 ) == 0x000000BB_AA000000);
    static assert( llvm_bswap( cast(ulong)0x80000000_00000001 ) == 0x01000000_00000080);
}

/*******************************************/
// Check runtime and compile time evaluation of llvm_ctpop().

void test3()
{
    assert( llvm_ctpop( cast(ushort)0 ) == 0 );
    assert( llvm_ctpop( cast(ushort)7 ) == 3 );
    assert( llvm_ctpop( cast(ushort)0xAA )== 4);
    assert( llvm_ctpop( cast(ushort)0xFFFF ) == 16 );
    assert( llvm_ctpop( cast(ushort)0xCCCC ) == 8 );
    assert( llvm_ctpop( cast(ushort)0x7777 ) == 12 );
    assert( llvm_ctpop( cast(uint)0 ) == 0 );
    assert( llvm_ctpop( cast(uint)7 ) == 3 );
    assert( llvm_ctpop( cast(uint)0xAA )== 4);
    assert( llvm_ctpop( cast(uint)0x8421_1248 ) == 8 );
    assert( llvm_ctpop( cast(uint)0xFFFF_FFFF ) == 32 );
    assert( llvm_ctpop( cast(uint)0xCCCC_CCCC ) == 16 );
    assert( llvm_ctpop( cast(uint)0x7777_7777 ) == 24 );
    assert( llvm_ctpop( cast(ulong)0 ) == 0 );
    assert( llvm_ctpop( cast(ulong)7 ) == 3 );
    assert( llvm_ctpop( cast(ulong)0xAA )== 4);
    assert( llvm_ctpop( cast(ulong)0x8421_1248 ) == 8 );
    assert( llvm_ctpop( cast(ulong)0xFFFF_FFFF_FFFF_FFFF ) == 64 );
    assert( llvm_ctpop( cast(ulong)0xCCCC_CCCC_CCCC_CCCC ) == 32 );
    assert( llvm_ctpop( cast(ulong)0x7777_7777_7777_7777 ) == 48 );

    static assert( llvm_ctpop( cast(ushort)0 ) == 0 );
    static assert( llvm_ctpop( cast(ushort)7 ) == 3 );
    static assert( llvm_ctpop( cast(ushort)0xAA )== 4);
    static assert( llvm_ctpop( cast(ushort)0xFFFF ) == 16 );
    static assert( llvm_ctpop( cast(ushort)0xCCCC ) == 8 );
    static assert( llvm_ctpop( cast(ushort)0x7777 ) == 12 );
    static assert( llvm_ctpop( cast(uint)0 ) == 0 );
    static assert( llvm_ctpop( cast(uint)7 ) == 3 );
    static assert( llvm_ctpop( cast(uint)0xAA )== 4);
    static assert( llvm_ctpop( cast(uint)0x8421_1248 ) == 8 );
    static assert( llvm_ctpop( cast(uint)0xFFFF_FFFF ) == 32 );
    static assert( llvm_ctpop( cast(uint)0xCCCC_CCCC ) == 16 );
    static assert( llvm_ctpop( cast(uint)0x7777_7777 ) == 24 );
    static assert( llvm_ctpop( cast(ulong)0 ) == 0 );
    static assert( llvm_ctpop( cast(ulong)7 ) == 3 );
    static assert( llvm_ctpop( cast(ulong)0xAA )== 4);
    static assert( llvm_ctpop( cast(ulong)0x8421_1248 ) == 8 );
    static assert( llvm_ctpop( cast(ulong)0xFFFF_FFFF_FFFF_FFFF ) == 64 );
    static assert( llvm_ctpop( cast(ulong)0xCCCC_CCCC_CCCC_CCCC ) == 32 );
    static assert( llvm_ctpop( cast(ulong)0x7777_7777_7777_7777 ) == 48 );
}

/*******************************************/
// Check runtime and compile time evaluation of llvm_cttz()/llvm_ctlz().

void test4()
{
    int a = 0x80;
    int f = llvm_cttz(a, true);
    int r = llvm_ctlz(a, true);
    a = 0x22;
    assert(llvm_cttz(a, true)==1);
    assert(llvm_ctlz(a, true)==int.sizeof * 8 - 1 - 5);
    static assert(llvm_cttz(0x22, true)==1);
    static assert(llvm_ctlz(0x22, true)==int.sizeof * 8 - 1 - 5);
    a = 0x8000000;
    assert(llvm_cttz(a, true)==27);
    assert(llvm_ctlz(a, true)==int.sizeof * 8 - 1 - 27);
    static assert(llvm_cttz(0x8000000, true)==27);
    static assert(llvm_ctlz(0x8000000, true)==int.sizeof * 8 - 1 - 27);
    a = 0x13f562c0;
    assert(llvm_cttz(a, true) == 6);
    assert(llvm_ctlz(a, true) == int.sizeof * 8 - 1 - 28);
    static assert(llvm_cttz(0x13f562c0, true) == 6);
    static assert(llvm_ctlz(0x13f562c0, true) == int.sizeof * 8 - 1 - 28);
}

/*******************************************/

void test5()
{
    static if (__traits(compiles, llvm_fabs(3.14L)))
    {
        static assert( llvm_fabs( cast(float)-1.0 ) == 1.0 );
        static assert( llvm_fabs( cast(double)-1.0 ) == 1.0 );
        static assert( llvm_fabs( cast(real)-1.0 ) == 1.0 );
    }
}

/*******************************************/

void main()
{
    test1();
    test2();
    test3();
    test4();
    test5();
}
