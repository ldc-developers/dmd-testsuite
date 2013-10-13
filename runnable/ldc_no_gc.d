// REQUIRED_ARGS: -noruntime -release

// None of the below array literals should be allocated on the GC heap.
void arrayLiterals() {
    int[3] x = [1, 2, 3];
    if (x[2] != 3) assert(0);

    auto a = 4;
    int[3] y = [1, 2, a];
    if (y[2] != 4) assert(0);

    immutable int[] z = [1, 2, 3];
    if (z[2] != 3) assert(0);
}

void main() {
    arrayLiterals();
}
