/*
TRANSFORM_OUTPUT: remove_lines("^import path")
TEST_OUTPUT:
---
fail_compilation/diag10327.d(9): Error: module `test10327` is in file 'imports/test10327.d' which cannot be read
---
*/

import imports.test10327;  // package.d missing
