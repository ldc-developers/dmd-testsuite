struct Foo {
    this(int a) {}
}

void test() {
    auto a = cast(void*)(new Foo(1));
}
