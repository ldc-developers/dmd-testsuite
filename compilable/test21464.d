// https://issues.dlang.org/show_bug.cgi?id=21464
void foo() pure
{
    import imports.test21464a : Mallocator;
    auto a = Mallocator.instance; // mutable static, but empty struct
}
