/* TEST_OUTPUT:
---
fail_compilation/goto5.d(19): Error: the label `L1` does not exist
---
*/

struct S
{
    static int opApply(int delegate(ref int) dg)
    {
        return 0;
    }
}

void main()
{
    foreach(f; S)
    {
        asm
        {
            jmp L1;
        }
        goto L1;
    }
    L1:;
}
