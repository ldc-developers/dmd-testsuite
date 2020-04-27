// LDC: exclude `-i=` (equivalent to `-i` for LDC), which links fine
// arg_sets: -i=,
// ARG_SETS: -i=imports.pkgmod313,
// ARG_SETS: -i=,imports.pkgmod313
// ARG_SETS: -i=imports.pkgmod313,-imports.pkgmod313.mod
// ARG_SETS: -i=imports.pkgmod313.package,-imports.pkgmod313.mod
// REQUIRED_ARGS: -Icompilable
// PERMUTE_ARGS:
// LINK:
/*
Can't really check for the missing function bar here because the error message
varies A LOT between different linkers. Assume that there is no other cause
of linking failure because then other tests would fail as well. Hence search
for the linker failure message issued by DMD:

LDC: additionally remove expected error line with variable linker/cc
TRANSFORM_OUTPUT: remove_lines("^((?!Error:)|Error: .+ failed with status: )")
TEST_OUTPUT:
----
----
*/
import imports.pkgmod313.mod;
void main()
{
    bar();
}
