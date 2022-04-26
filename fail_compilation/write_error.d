/++
https://issues.dlang.org/show_bug.cgi?id=23019

ARG_SETS: -of=fail_compilation
TEST_OUTPUT:
---
Error: cannot write file 'fail_compilation': Is a directory
---
++/

void main() {}
