/* DISABLED: LDC_not_x86 LDC // differing output; proper resolution depends on a regression/change discussed at https://github.com/dlang/dmd/pull/5390
TEST_OUTPUT:
---
fail_compilation/ice15239.d(21): Error: cannot interpret `opDispatch!"foo"` at compile time
fail_compilation/ice15239.d(21): Error: bad type/size of operands `__error`
---
*/

struct T
{
    template opDispatch(string Name, P...)
    {
        static void opDispatch(P) {}
    }
}

void main()
{
    asm
    {
        call T.foo;
    }
}
