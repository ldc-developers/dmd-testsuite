#!/usr/bin/env bash

dir=${RESULTS_DIR}/compilable
output_file=${dir}/ldc_output_filenames.sh.out

rm -f ${output_file}

function bailout {
    cat ${output_file}
    rm -f ${output_file}
    exit 1
}

# 3 object files, 2 with same name

# -of (implying -singleobj); additionally make sure object file extension is NOT enforced
$DMD -m${MODEL} -Icompilable/extra-files/ldc_output_filenames -of${dir}/myObj.myExt -c compilable/extra-files/ldc_output_filenames/{main.d,foo.d,imp/foo.d} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;
rm ${dir}/myObj.myExt >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;

# -op
$DMD -m${MODEL} -Icompilable/extra-files/ldc_output_filenames -od${dir} -c -op compilable/extra-files/ldc_output_filenames/{main.d,foo.d,imp/foo.d} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;
rm ${dir}/compilable/extra-files/ldc_output_filenames/{main${OBJ},foo${OBJ},imp/foo${OBJ}} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;

# -oq
$DMD -m${MODEL} -Icompilable/extra-files/ldc_output_filenames -od${dir} -c -oq compilable/extra-files/ldc_output_filenames/{main.d,foo.d,imp/foo.d} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;
rm ${dir}/{ldc_output_filenames${OBJ},foo${OBJ},imp.foo${OBJ}} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;

# -o-
$DMD -m${MODEL} -Icompilable/extra-files/ldc_output_filenames -o- compilable/extra-files/ldc_output_filenames/{main.d,foo.d,imp/foo.d} >> ${output_file}
if [ $? -ne 0 ]; then bailout; fi;
