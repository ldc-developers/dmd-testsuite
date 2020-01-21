/* DISABLED: LDC_not_x86 LDC // differing output
TEST_OUTPUT:
---
fail_compilation/fail274.d(10): Error: expression expected not `;`
---
*/

void main()
{
    asm { inc [; }
}
