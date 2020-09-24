// https://issues.dlang.org/show_bug.cgi?id=21091

/*
TRANSFORM_OUTPUT: remove_lines("^import path")
TEST_OUTPUT:
----
fail_compilation/fail21091b.d(13): Error: module `Tid` is in file 'Tid.d' which cannot be read
----
*/

class Logger
{
    import Tid;
    Tid threadId;
}
