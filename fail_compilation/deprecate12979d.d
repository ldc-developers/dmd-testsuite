// PERMUTE_ARGS:

/* DISABLED: LDC_not_x86
TEST_OUTPUT:
---
fail_compilation/deprecate12979d.d(12): Error: `asm` statement is assumed to be `@system` - mark it with `@trusted` if it is not
---
*/

void foo() @safe
{
    asm
    {
        ret;
    }
}
