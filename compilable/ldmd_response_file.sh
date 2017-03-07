#!/usr/bin/env bash

# Make sure LDMD forwards a huge command line correctly to LDC.

dir=${RESULTS_DIR}/compilable

rsp_file=${dir}/ldmd_response_file.rsp
rm -f ${rsp_file}

# generate a ~100K response file for LDMD
for i in {0..1000}
do
   echo "-I=Some/lengthy/string/Some/lengthy/string/Some/lengthy/string/Some/lengthy/string/Some/lengthy/string/" >> ${rsp_file}
done

src_file=${dir}/ldmd_response_file.d
echo "void main() {}" > ${src_file}

# LDMD errors if there's no source file.
$DMD @${rsp_file} -c -o- ${src_file}
if [ $? -ne 0 ]; then exit 1; fi;
