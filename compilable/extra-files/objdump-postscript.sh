#!/usr/bin/env bash

source tools/common_funcs.sh

expect_file=${EXTRA_FILES}/${TEST_NAME}.out
obj_file=${OUTPUT_BASE}_0.o

echo Creating objdump
objdump --disassemble --disassembler-options=intel-mnemonic "${obj_file}" > "${obj_file}.dump"

echo SANITIZING Objdump...
< "${obj_file}.dump" \
    tail -n+3 > "${obj_file}.dump.sanitized"

diff -pu --strip-trailing-cr "${expect_file}" "${obj_file}.dump.sanitized"

rm_retry "${OUTPUT_BASE}.o"{,.dump,.dump,.sanitized}
