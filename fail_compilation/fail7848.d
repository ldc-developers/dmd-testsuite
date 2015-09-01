// REQUIRED_ARGS: -unittest

/*
TEST_OUTPUT:
---
fail_compilation/fail7848.d(35): Error: pure function 'fail7848.C.__unittestL33_1' cannot call impure function 'fail7848.func'
fail_compilation/fail7848.d(35): Error: safe function 'fail7848.C.__unittestL33_1' cannot call system function 'fail7848.func'
fail_compilation/fail7848.d(35): Error: @nogc function 'fail7848.C.__unittestL33_1' cannot call non-@nogc function 'fail7848.func'
fail_compilation/fail7848.d(35): Error: 'fail7848.func' is not nothrow
fail_compilation/fail7848.d(33): Error: function 'fail7848.C.__unittestL33_1' is nothrow yet may throw
fail_compilation/fail7848.d(40): Error: pure function 'fail7848.C.__invariant2' cannot call impure function 'fail7848.func'
fail_compilation/fail7848.d(40): Error: safe function 'fail7848.C.__invariant2' cannot call system function 'fail7848.func'
fail_compilation/fail7848.d(40): Error: @nogc function 'fail7848.C.__invariant2' cannot call non-@nogc function 'fail7848.func'
fail_compilation/fail7848.d(40): Error: 'fail7848.func' is not nothrow
fail_compilation/fail7848.d(38): Error: function 'fail7848.C.__invariant2' is nothrow yet may throw
fail_compilation/fail7848.d(45): Error: pure function 'fail7848.C.new' cannot call impure function 'fail7848.func'
fail_compilation/fail7848.d(45): Error: safe function 'fail7848.C.new' cannot call system function 'fail7848.func'
fail_compilation/fail7848.d(45): Error: @nogc function 'fail7848.C.new' cannot call non-@nogc function 'fail7848.func'
fail_compilation/fail7848.d(45): Error: 'fail7848.func' is not nothrow
fail_compilation/fail7848.d(43): Error: allocator 'fail7848.C.new' is nothrow yet may throw
fail_compilation/fail7848.d(51): Error: pure function 'fail7848.C.delete' cannot call impure function 'fail7848.func'
fail_compilation/fail7848.d(51): Error: safe function 'fail7848.C.delete' cannot call system function 'fail7848.func'
fail_compilation/fail7848.d(51): Error: @nogc function 'fail7848.C.delete' cannot call non-@nogc function 'fail7848.func'
fail_compilation/fail7848.d(51): Error: 'fail7848.func' is not nothrow
fail_compilation/fail7848.d(49): Error: deallocator 'fail7848.C.delete' is nothrow yet may throw
---
*/

void func() {}

class C
{
    @safe pure nothrow @nogc unittest
    {
        func();
    }

    @safe pure nothrow @nogc invariant
    {
        func();
    }

    @safe pure nothrow @nogc new (size_t sz)
    {
        func();
        return null;
    }

    @safe pure nothrow @nogc delete (void* p)
    {
        func();
    }
}
