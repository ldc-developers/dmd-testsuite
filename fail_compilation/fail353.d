// DISABLED: LDC // DMD assembler restriction test - not clear how this applies to LDC.

void foo()
{
    enum NOP = 0x9090_9090_9090_9090;

    asm
    {
    L1:
        dq NOP,NOP,NOP,NOP;    //  32
        dq NOP,NOP,NOP,NOP;    //  64
        dq NOP,NOP,NOP,NOP;    //  96
        dq NOP,NOP,NOP,NOP;    // 128
        // unnoticed signed underflow of rel8 with DMD2.056
        loop L1;
    }
}
