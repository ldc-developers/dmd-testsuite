module imports.template13478a;

bool foo(T)() {
    // Make sure this is not inlined so template13478.o actually
    // needs to reference it.
    version (LDC)
    {
        pragma(LDC_never_inline)
        return false;
    }
    else
    {
    asm { nop; }
    return false;
    }
}
