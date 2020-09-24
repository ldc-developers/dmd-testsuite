// https://issues.dlang.org/show_bug.cgi?id=21091

/*
TRANSFORM_OUTPUT: remove_lines("^import path")
TEST_OUTPUT:
----
fail_compilation/fail21091a.d(13): Error: module `Ternary` is in file 'Ternary.d' which cannot be read
----
*/

struct NullAllocator
{
    import Ternary;
    Ternary owns() { }
}
