int dtor;

struct DestroyMe
{
    ~this() { ++dtor; }

    int opApply(in int delegate(int item) dg)
    {
        throw new Exception("Here we go!");
    }
}

void main()
{
    dtor = 0;
    try {
        foreach (item; DestroyMe()) {}
    } catch {}
    assert(dtor == 1);

    dtor = 0;
    try {
        auto lvalue = DestroyMe();
        foreach (item; lvalue) {}
    } catch {}
    assert(dtor == 1);
}