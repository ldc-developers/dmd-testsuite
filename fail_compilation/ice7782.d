/*
EXTRA_FILES: imports/ice7782algorithm.d imports/ice7782range.d
TRANSFORM_OUTPUT: remove_lines("^import path")
TEST_OUTPUT:
----
fail_compilation/ice7782.d(11): Error: module `ice7782math` is in file 'imports/ice7782range/imports/ice7782math.d' which cannot be read
----
*/

import imports.ice7782algorithm;
import imports.ice7782range. imports.ice7782math;

void main() {}
