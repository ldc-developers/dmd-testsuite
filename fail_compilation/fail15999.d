// REQUIRED_ARGS: -m64
/*
LDC doesn't check the operand types, LLVM does later on => output adapted accordingly.
TEST_OUTPUT:
---
fail_compilation/fail15999.d(14):1:7: error: invalid operand for instruction
        andq $4294967295, %rax
             ^~~~~~~~~~~
---
*/

void foo(ulong bar)
{
    asm { and RAX, 0x00000000FFFFFFFF; ret; }
}
