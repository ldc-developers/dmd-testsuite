module object;

private alias extern(C) int function(char[][] args) MainFunc;
private extern (C) int _d_run_main(int argc, char** argv, void* _mainFunc)
{
    auto mainFunc = cast(MainFunc) _mainFunc;
    return mainFunc(null);
}
