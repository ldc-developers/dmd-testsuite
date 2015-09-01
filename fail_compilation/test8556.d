/*
TEST_OUTPUT:
---
fail_compilation/test8556.d(33): Error: circular initialization of isSliceable
fail_compilation/test8556.d(34): Error: circular initialization of isSliceable
fail_compilation/test8556.d(47): Error: template test8556.grabExactly cannot deduce function from argument types !()(Circle!(uint[])), candidates are:
fail_compilation/test8556.d(33):        test8556.grabExactly(R)(R range) if (!isSliceable!R)
fail_compilation/test8556.d(34):        test8556.grabExactly(R)(R range) if (isSliceable!R)
fail_compilation/test8556.d(22): Error: template instance test8556.isSliceable!(Circle!(uint[])) error instantiating
fail_compilation/test8556.d(27):        while looking for match for Grab!(Circle!(uint[]))
fail_compilation/test8556.d(58): Error: template instance test8556.grab!(Circle!(uint[])) error instantiating
fail_compilation/test8556.d(61): Error: no [] operator overload for type Circle!(uint[])
---
*/
extern(C) int printf(const char*, ...);

template isSliceable(R)
{
    enum bool isSliceable = is(typeof( R.init[1 .. 2] ));
}

struct Grab(Range) if (!isSliceable!Range)
{
    public Range source;
}

Grab!R grab(R)(R input)
{
    return Grab!R(input);
}

// 3. evaluate isSliceable in template constraint
auto grabExactly(R)(R range) if (!isSliceable!R) { return 0; }
auto grabExactly(R)(R range) if ( isSliceable!R) { return 0; }

struct Circle(Range)
{
    // 2. auto return opSlice
    auto opSlice(size_t i, size_t j)
    {
        //pragma(msg, typeof(opSlice)); // prints "fwdref err" with B, but doesn't with A

        printf("%d %d\n", i, j);
        assert(j >= i);

        // 1. grabExactly curcular refers this opSlice.
        return grabExactly(typeof(this)());     // broken execution with A
    }
}

Circle!R circle(R)()
{
    return Circle!R();
}

void main()
{
    auto t = grab(circle!(uint[])());

    auto cx = circle!(uint[])();
    auto slice = cx[23 .. 33];
}
