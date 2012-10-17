// PERMUTE_ARGS:

module testgc2;

import core.stdc.stdio;
import core.exception : OutOfMemoryError;

/*******************************************/

// Prevent dead store elimination of the allocations.
void[] dummy;

void test1()
{
    printf("This should not take a while\n");
    try
    {
        dummy = new long[ptrdiff_t.max];
        assert(0);
    }
    catch (OutOfMemoryError o)
    {
    }

    printf("This may take a while\n");
    try
    {
        dummy = new byte[size_t.max / 3];
        version (Windows)
            assert(0);
    }
    catch (OutOfMemoryError o)
    {
    }
}

/*******************************************/

void main()
{
    test1();

    printf("Success\n");
}


