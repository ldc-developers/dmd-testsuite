// DISABLED: LDC_not_x86
// REQUIRED_ARGS: -m64
/*
LDC doesn't check the operand types, LLVM does later on => output adapted accordingly.
TEST_OUTPUT:
---
fail_compilation/fail15999b.d(15):1:7: error: invalid operand for instruction
        andq $-4294967296, %rax
             ^~~~~~~~~~~~
---
*/

void foo(ulong bar)
{
    asm { and RAX, 0xFFFFFFFF00000000; ret; }
}
