# Execute the dmd test suite
#
# Targets:
#
#    default | all:      run all unit tests that haven't been run yet
#
#    run_tests:          run all tests
#    run_runnable_tests:         run just the runnable tests
#    run_compilable_tests:       run just the compilable tests
#    run_fail_compilation_tests: run just the fail compilation tests
#
#    quick:              run all tests with no default permuted args
#                        (individual test specified options still honored)
#
#    clean:              remove all temporary or result files from prevous runs
#
#
# In-test variables:
#
#   COMPILE_SEPARATELY:  if present, forces each .d file to compile separately and linked
#                        together in an extra setp.
#                        default: (none, aka compile/link all in one step)
#
#   EXECUTE_ARGS:        parameters to add to the execution of the test
#                        default: (none)
#
#   EXTRA_SOURCES:       list of extra files to build and link along with the test
#                        default: (none)
#
#   EXTRA_OBJC_SOURCES:  list of extra Objective-C files to build and link along with the test
#                        default: (none). Test files with this variable will be ignored unless
#                        the D_OBJC environment variable is set to "1"
#
#   PERMUTE_ARGS:        the set of arguments to permute in multiple $(DMD) invocations.
#                        An empty set means only one permutation with no arguments.
#                        default: the make variable ARGS (see below)
#
#   TEST_OUTPUT:         the output is expected from the compilation (if the
#                        output of the compilation doesn't match, the test
#                        fails). You can use the this format for multi-line
#                        output:
#                        TEST_OUTPUT:
#                        ---
#                        Some
#                        Output
#                        ---
#
#   POST_SCRIPT:         name of script to execute after test run
#                        note: arguments to the script may be included after the name.
#                              additionally, the name of the file that contains the output
#                              of the compile/link/run steps is added as the last parameter.
#                        default: (none)
#
#   REQUIRED_ARGS:       arguments to add to the $(DMD) command line
#                        default: (none)
#                        note: the make variable REQUIRED_ARGS is also added to the $(DMD)
#                              command line (see below)
#
#   DISABLED:            text describing why the test is disabled (if empty, the test is
#                        considered to be enabled).
#                        default: (none, enabled)
#
#   GDB_FLAGS:           flags to enable gdb tests:
#                        OFF - disables gdb tests
#                        NOTLS - disables tests that fail for gdb < 7.6.1 that fixed TLS issues

ifeq (Windows_NT,$(OS))
    ifeq ($(findstring WOW64, $(shell uname)),WOW64)
	OS:=win64
	MODEL:=64
    else
	OS:=win32
	MODEL:=32
    endif
endif
ifeq (Win_32,$(OS))
    OS:=win32
    MODEL:=32
endif
ifeq (Win_64,$(OS))
    OS:=win64
    MODEL:=64
endif

include ../src/osmodel.mak

export OS

ifeq (freebsd,$(OS))
    SHELL=/usr/local/bin/bash
else
    SHELL=/bin/bash
endif
QUIET=@
BASH_RESULTS_DIR=$(RESULTS_DIR)
export RESULTS_DIR=test_results
export MODEL
export REQUIRED_ARGS=

ifeq ($(findstring win,$(OS)),win)
SHELL=bash.exe
BASH_RESULTS_DIR=$(subst /,\\\\,$(RESULTS_DIR))
export ARGS=-inline -release -g -O
export DMD=../src/dmd.exe
export EXE=.exe
export OBJ=.obj
export DSEP=\\
export SEP=$(subst /,\,/)

DRUNTIME_PATH=..\..\druntime
PHOBOS_PATH=..\..\phobos
export DFLAGS=-I$(DRUNTIME_PATH)\import -I$(PHOBOS_PATH)
else
export ARGS=-inline -release -g -O -fPIC
export DMD=../src/dmd
export EXE=
export OBJ=.o
export DSEP=/
export SEP=/

DRUNTIME_PATH=../../druntime
PHOBOS_PATH=../../phobos
# link against shared libraries (defaults to true on supported platforms, can be overriden w/ make SHARED=0)
SHARED=$(if $(findstring $(OS),linux freebsd),1,)
DFLAGS=-I$(DRUNTIME_PATH)/import -I$(PHOBOS_PATH) -L-L$(PHOBOS_PATH)/generated/$(OS)/release/$(MODEL)
ifeq (1,$(SHARED))
DFLAGS+=-defaultlib=libphobos2.so -L-rpath=$(PHOBOS_PATH)/generated/$(OS)/release/$(MODEL)
endif
export DFLAGS
endif

ifeq ($(OS),osx)
ifeq ($(MODEL),64)
export D_OBJC=1
endif
endif

####

# LDC: Support Objective-C tests on 32-bit too
ifeq ($(OS),osx)
ifeq ($(MODEL),32)
export D_OBJC=1
endif
endif

ifeq ($(findstring OFF,$(GDB_FLAGS)),OFF)
DISABLED_TESTS += gdb1
DISABLED_TESTS += gdb4149
DISABLED_TESTS += gdb4181
DISABLED_TESTS += gdb14225
DISABLED_TESTS += gdb14276
DISABLED_TESTS += gdb14313
DISABLED_TESTS += gdb14330
DISABLED_SH_TESTS += gdb15729
else
ifeq ($(findstring NOTLS,$(GDB_FLAGS)),NOTLS)
# LDC: travis has only gdb 7.4, but TLS was fixed in 7.6.1
DISABLED_TESTS += gdb4181
endif
endif
# LDC: even without optimizations "x optimized-out"
DISABLED_TESTS += gdb10311

# LDC_FIXME: pragma(inline) is not currently implemented.
DISABLED_FAIL_TESTS += pragmainline2

# LDC_FIXME: We don't report the failure here, probably because the called
# nested function does not actually need a context.
DISABLED_FAIL_TESTS += fail39

# LDC: We don't have the arraysize limit that DMD imposes to work around an
#      optlink bug (https://issues.dlang.org/show_bug.cgi?id=14859)
DISABLED_FAIL_TESTS += fail4611

# LDC_FIXME: We display a different error message, but never ICE'd. Our message
# is worse, but the proper resolution of this depends on a regression/change
# discussed at DMD GitHub pull request #5390.
DISABLED_FAIL_TESTS += ice15239

# LDC: Disable -profile tests.
DISABLED_TESTS += hello-profile
DISABLED_TESTS += testprofile
DISABLED_COMPILE_TESTS += diag11066

# LDC: This test checks for a number of error messages, of which we only report
# the first one. Not a bug.
DISABLED_FAIL_TESTS += fail9418

# LDC: These tests fail due to a slight difference in the reported error message
# caused by the different contract invocation scheme used in LDC.
DISABLED_FAIL_TESTS += fail9414a
DISABLED_FAIL_TESTS += fail9414b

# LDC_FIXME: Don't disable whole asm tests, only DMD-specific parts.
DISABLED_TESTS += iasm
DISABLED_TESTS += iasm64

# LDC_FIXME: This covers an optimization LLVM chooses not to do, see GitHub #679.
DISABLED_COMPILE_TESTS += test11237

# LDC_FIXME: We ICE here due to DMD issue 15650. Enable again after 15650 is fixed.
DISABLED_COMPILE_TESTS += test10981

# LDC: Our ASM diagnostics are different, might be worth revisiting at some point.
DISABLED_FAIL_TESTS += diag6717
DISABLED_FAIL_TESTS += fail152
DISABLED_FAIL_TESTS += fail14009

# LDC: This tests a glue layer error message, where DMD emits two but we exit
# after the first one. Not a bug.
DISABLED_FAIL_TESTS += fail120

# LDC: Our error messages are slightly different, but equally informative.
DISABLED_FAIL_TESTS += fail274

# LDC: This is an error in the DMD glue code (e2ir). We can emit the array cast
# correctly, with the expected result.
DISABLED_FAIL_TESTS += fail8179b

# LDC: These inline asm tests fail to fail, that is, the code works as expected
DISABLED_FAIL_TESTS += fail13938
DISABLED_FAIL_TESTS += fail13939

# LDC: The error message is generated by dmd backend after constant propagation
DISABLED_FAIL_TESTS += fail5908

# LDC: Not all error messages are trure for ldc. Replaced by ldc_diag8425.
DISABLED_FAIL_TESTS += diag8425

# LDC: Binary size test. LDC's output exceeds the limits.
DISABLED_TESTS += test13117b
DISABLED_TESTS += test13117

# LDC: tests requiring -dwarfeh, a temporary switch in DMD 2.071 which should 
# not have made into the release
DISABLED_FAIL_TESTS += cppeh1
DISABLED_FAIL_TESTS += cppeh2

# LDC: tests requiring -gx, unlikely to be supported soon
DISABLED_TESTS += test15779

# LDC: broken in dmd, too: https://issues.dlang.org/show_bug.cgi?id=15943
DISABLED_COMPILE_TESTS += test15578

# LDC: dmd bug caught early: https://issues.dlang.org/show_bug.cgi?id=13353
DISABLED_TESTS += testclass

# LDC: Test specific to DMD's library names.
DISABLED_SH_TESTS += test_shared

# LDC: OS X ld needs extra options, but not needed so do not bother
#      not supported for MSVC either
ifeq ($(OS),osx)
DISABLED_TESTS += ldc_extern_weak
endif
ifeq ($(findstring win,$(OS)),win)
DISABLED_TESTS += ldc_extern_weak
endif

# LDC doesn't enforce any hardcoded limit for static array sizes
DISABLED_FAIL_TESTS += staticarrayoverflow

# LDC: disable DMD-specific core.simd.__simd tests
DISABLED_FAIL_TESTS += test12430

# disable tests based on arch
ifeq ($(OS),linux)
  ARCH:=$(shell uname -m)

  # disable invalid tests on arm, aarch64, mips, ppc
  ifneq (,$(filter arm% aarch64% mips% ppc%,$(ARCH)))
    DISABLED_COMPILE_TESTS += deprecate12979a # dmd inline asm
    DISABLED_COMPILE_TESTS += ldc_github_791  # dmd inline asm
    DISABLED_COMPILE_TESTS += ldc_github_1292 # dmd inline asm
    DISABLED_COMPILE_TESTS += test11471       # dmd inline asm
    DISABLED_COMPILE_TESTS += test12979b      # dmd inline asm
    DISABLED_FAIL_TESTS += deprecate12979a    # dmd inline asm
    DISABLED_FAIL_TESTS += deprecate12979b    # dmd inline asm
    DISABLED_FAIL_TESTS += deprecate12979c    # dmd inline asm
    DISABLED_FAIL_TESTS += deprecate12979d    # dmd inline asm
    DISABLED_FAIL_TESTS += fail12635          # dmd inline asm
    DISABLED_FAIL_TESTS += fail13434_m64      # no -m64
    DISABLED_FAIL_TESTS += fail14009          # dmd inline asm
    DISABLED_FAIL_TESTS += fail2350           # dmd inline asm
    DISABLED_FAIL_TESTS += fail238_m64        # no -m64
    DISABLED_FAIL_TESTS += fail327            # dmd inline asm
    DISABLED_FAIL_TESTS += fail37_m64         # no -m64
    DISABLED_FAIL_TESTS += fail80_m64         # no -m64
    DISABLED_FAIL_TESTS += ldc_diag8425       # no -m64
    DISABLED_TESTS += test36                  # dmd inline asm/Windows
  endif

  ifneq (,$(filter arm% aarch64% ppc64le%,$(ARCH)))
    # tell d_do_test.d to ignore MODEL
    export NO_ARCH_VARIANT=1
  endif
endif

####

ifeq ($(OS),win64)
# LDC: no reason to disable
# DISABLED_TESTS += testxmm
# LDC: already disabled for all above
# DISABLED_FAIL_TESTS += fail13939
endif

ifeq ($(OS),osx)
ifeq ($(MODEL),64)
DISABLED_TESTS += test6423
endif
endif

export DMD_TEST_COVERAGE=

runnable_tests=$(wildcard runnable/*.d) $(wildcard runnable/*.sh)
runnable_test_results=$(addsuffix .out,$(addprefix $(RESULTS_DIR)/,$(runnable_tests)))

compilable_tests=$(wildcard compilable/*.d) $(wildcard compilable/*.sh)
compilable_test_results=$(addsuffix .out,$(addprefix $(RESULTS_DIR)/,$(compilable_tests)))

fail_compilation_tests=$(wildcard fail_compilation/*.d) $(wildcard fail_compilation/*.html)
fail_compilation_test_results=$(addsuffix .out,$(addprefix $(RESULTS_DIR)/,$(fail_compilation_tests)))

all: run_tests

$(addsuffix .d.out,$(addprefix $(RESULTS_DIR)/runnable/,$(DISABLED_TESTS))): $(RESULTS_DIR)/.created
	$(QUIET) echo " ... $@ - disabled"

$(addsuffix .sh.out,$(addprefix $(RESULTS_DIR)/runnable/,$(DISABLED_SH_TESTS))): $(RESULTS_DIR)/.created
	$(QUIET) echo " ... $@ - disabled"

$(RESULTS_DIR)/runnable/%.d.out: runnable/%.d $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) $(RESULTS_DIR)/d_do_test $(<D) $* d

$(RESULTS_DIR)/runnable/%.sh.out: runnable/%.sh $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) echo " ... $(<D)/$*.sh"
	$(QUIET) RESULTS_DIR=$(BASH_RESULTS_DIR) ./$(<D)/$*.sh

$(addsuffix .d.out,$(addprefix $(RESULTS_DIR)/compilable/,$(DISABLED_COMPILE_TESTS))): $(RESULTS_DIR)/.created
	$(QUIET) echo " ... $@ - disabled"

$(RESULTS_DIR)/compilable/%.d.out: compilable/%.d $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) $(RESULTS_DIR)/d_do_test $(<D) $* d

$(RESULTS_DIR)/compilable/%.sh.out: compilable/%.sh $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) echo " ... $(<D)/$*.sh"
	$(QUIET) RESULTS_DIR=$(BASH_RESULTS_DIR) ./$(<D)/$*.sh

$(addsuffix .d.out,$(addprefix $(RESULTS_DIR)/fail_compilation/,$(DISABLED_FAIL_TESTS))): $(RESULTS_DIR)/.created
	$(QUIET) echo " ... $@ - disabled"

$(RESULTS_DIR)/fail_compilation/%.d.out: fail_compilation/%.d $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) $(RESULTS_DIR)/d_do_test $(<D) $* d

$(RESULTS_DIR)/fail_compilation/%.html.out: fail_compilation/%.html $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) $(RESULTS_DIR)/d_do_test $(<D) $* html

quick:
	$(MAKE) ARGS="" run_tests

clean:
	@echo "Removing output directory: $(RESULTS_DIR)"
	$(QUIET)if [ -e $(RESULTS_DIR) ]; then rm -rf $(RESULTS_DIR); fi

$(RESULTS_DIR)/.created:
	@echo Creating output directory: $(RESULTS_DIR)
	$(QUIET)if [ ! -d $(RESULTS_DIR) ]; then mkdir $(RESULTS_DIR); fi
	$(QUIET)if [ ! -d $(RESULTS_DIR)/runnable ]; then mkdir $(RESULTS_DIR)/runnable; fi
	$(QUIET)if [ ! -d $(RESULTS_DIR)/compilable ]; then mkdir $(RESULTS_DIR)/compilable; fi
	$(QUIET)if [ ! -d $(RESULTS_DIR)/fail_compilation ]; then mkdir $(RESULTS_DIR)/fail_compilation; fi
	$(QUIET)touch $(RESULTS_DIR)/.created

run_tests: start_runnable_tests start_compilable_tests start_fail_compilation_tests

# LDC: Try to test long-running runnable/xtest46.d as soon as possible for better parallelization
run_runnable_tests: $(RESULTS_DIR)/runnable/xtest46.d.out $(runnable_test_results)

start_runnable_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running runnable tests"
	$(QUIET)$(MAKE) $(DMD_TESTSUITE_MAKE_ARGS) --no-print-directory run_runnable_tests

run_compilable_tests: $(compilable_test_results)

start_compilable_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running compilable tests"
	$(QUIET)$(MAKE) $(DMD_TESTSUITE_MAKE_ARGS) --no-print-directory run_compilable_tests

run_fail_compilation_tests: $(fail_compilation_test_results)

start_fail_compilation_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running fail compilation tests"
	$(QUIET)$(MAKE) $(DMD_TESTSUITE_MAKE_ARGS) --no-print-directory run_fail_compilation_tests

$(RESULTS_DIR)/d_do_test$(EXE): d_do_test.d $(RESULTS_DIR)/.created
	@echo "Building d_do_test tool"
	@echo "OS: $(OS)"
	$(QUIET)$(DMD) -conf= $(MODEL_FLAG) -unittest -run d_do_test.d -unittest
	$(QUIET)$(DMD) -conf= $(MODEL_FLAG) -od$(RESULTS_DIR) -of$(RESULTS_DIR)$(DSEP)d_do_test$(EXE) d_do_test.d

