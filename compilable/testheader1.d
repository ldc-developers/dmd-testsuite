// EXTRA_SOURCES: extra-files/header1.d
// REQUIRED_ARGS: -o- -H -H${RESULTS_DIR}/compilable
// PERMUTE_ARGS: -d -dw
// POST_SCRIPT: compilable/extra-files/header-postscript.sh header1

void main() {}
