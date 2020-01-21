/* DISABLED: LDC // this tests a glue layer error message, where DMD emits two but we exit after the first one; not a bug
TEST_OUTPUT:
---
fail_compilation/fail120.d(12): Error: need `this` for `nodes` of type `int[2]`
fail_compilation/fail120.d(13): Error: need `this` for `nodes` of type `int[2]`
---
*/

class Foo
{
    int[2] nodes;
    auto left = (){ return nodes[0]; };
    auto right = (){ return nodes[1]; };
}
