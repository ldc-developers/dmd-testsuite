public alias extern (C) void function(void*) Bar;

public interface Test
{
    public void foo(Bar bar)
    in
    {
        assert(bar);
    }
}

void main() {}
