// Additional testing beyond what cabi1.d does to exercise all the interesting
// cases for OS X 32-bit x86.
//
// EXTRA_CPP_SOURCES: ldc_github_1028c.cpp

// original case from issue #1028.
// This exact case is covered by cabi1.d S7, no need to re-test
version (none)
{
    struct NSPoint {
        float x;
        float y;
    }

    extern(C) NSPoint fun()
    {
        return NSPoint(1, 2);
    }
}

// cabi1 doesn't have 5 through 7 byte structs.  Do 4-8 to get a couple
// non-sret return types in the mix.
struct C4 { char[4] c;}
struct C5 { char[5] c;}
struct C6 { char[6] c;}
struct C7 { char[7] c;}
struct C8 { char[8] c;}

extern (C) C4 ctestc4();
extern (C) C5 ctestc5();
extern (C) C6 ctestc6();
extern (C) C7 ctestc7();
extern (C) C8 ctestc8();

int main()
{
    C4 c4 = ctestc4();
    assert(c4.c == "1234");
    C5 c5 = ctestc5();
    assert(c5.c == "12345");
    C6 c6 = ctestc6();
    assert(c6.c == "123456");
    C7 c7 = ctestc7();
    assert(c7.c == "1234567");
    C8 c8 = ctestc8();
    assert(c8.c == "12345678");

    return 0;
}
