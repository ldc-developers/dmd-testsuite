extern(C) int printf(const char*, ...);

void test14040()
{
    uint[] values = [0, 1, 2, 3, 4, 5, 6, 7];
    uint offset = 0;

    auto a1 = values[offset .. offset += 2];
    if (a1 != [0, 1] || offset != 2)
        assert(0);

    uint[] fun()
    {
        offset += 2;
        return values;
    }
    auto a2 = fun()[offset .. offset += 2];
    if (a2 != [4, 5] || offset != 6)
        assert(0);
}

/******************************************/

__gshared int step;
__gshared int[] globalArray;

ref int[] getBase() { assert(step == 0); ++step; return globalArray; }
int getLowerBound() { assert(step == 1); ++step; return 1; }
int getUpperBound() { assert(step == 2); ++step; globalArray = [ 1, 2, 3 ]; return cast(int)globalArray.length; }

// LDC issue #1433
void evaluateBasePointerAfterBounds()
{
    step = 0;
    auto r = getBase()[getLowerBound() .. getUpperBound()];
    assert(r == [ 2, 3 ]);
}

/******************************************/

// LDC issue #1327
void binops_loadImmediatelyFromLValue()
{
    int v = 3;
    static int inc(ref int v) { ++v; return 10; }

    int r = v + inc(v);
    assert(v == 4);
    assert(r == 13);
}

/******************************************/

int main()
{
    test14040();
    evaluateBasePointerAfterBounds();
    binops_loadImmediatelyFromLValue();

    printf("Success\n");
    return 0;
}
