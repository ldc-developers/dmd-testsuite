// DISABLED: LDC_win // Visual C++ runtime apparently doesn't like stdout output in crt_destructor
// REQUIRED_ARGS: -betterC
// POST_SCRIPT: runnable/extra-files/test17868-postscript.sh
import core.stdc.stdio;

extern(C):

pragma(crt_constructor)
void init()
{
    puts("init");
}

pragma(crt_destructor)
void fini2()
{
    puts("fini");
}

pragma(crt_constructor)
void foo()
{
    puts("init");
}

pragma(crt_destructor)
void bar()
{
    puts("fini");
}

int main()
{
    puts("main");
    return 0;
}
