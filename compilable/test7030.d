extern(C++)
{
    struct S
    {
        void foo(int) const;
        void bar(int);
        static __gshared int boo;
    }
}

// DMD adds the extra underscore that is required for platform ABI compliance
// to the mangleof string, see https://issues.dlang.org/show_bug.cgi?id=8207 and
// LDC GitHub issue #114.
version (DigitalMars) version (OSX) version = DMD_OSX;

version (DMD_OSX)
{
    static assert(S.foo.mangleof == "__ZNK1S3fooEi");
    static assert(S.bar.mangleof == "__ZN1S3barEi");
    static assert(S.boo.mangleof == "__ZN1S3booE");
}
else version (Posix)
{
    static assert(S.foo.mangleof == "_ZNK1S3fooEi");
    static assert(S.bar.mangleof == "_ZN1S3barEi");
    static assert(S.boo.mangleof == "_ZN1S3booE");
}
