// PERMUTE_ARGS:
// POST_SCRIPT: compilable/extra-files/test11237.sh
// DISABLED: LDC // this covers an optimization LLVM chooses not to do, see https://github.com/ldc-developers/ldc/issues/679
struct Buffer { ubyte[64 * 1024] buffer; }
