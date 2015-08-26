# Execute the dmd test suite
#
# Targets:
#
#    default | all:      run all unit tests that haven't been run yet
#
#    run_tests:          run all tests
#    run_runnable_tests:         run just the runnable tests
#    run_compilable_tests:       run just the runnable tests
#    run_fail_compilation_tests: run just the runnable tests
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
#   PERMUTE_ARGS:        the set of arguments to permute in multiple $(DMD) invocations
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
export RESULTS_DIR=test_results
export MODEL
export REQUIRED_ARGS=

ifeq ($(findstring win,$(OS)),win)
export ARGS=-inline -release -g -O -unittest
export DMD=../src/dmd.exe
export EXE=.exe
export OBJ=.obj
export DSEP=\\
export SEP=$(subst /,\,/)

DRUNTIME_PATH=..\..\druntime
PHOBOS_PATH=..\..\phobos
export DFLAGS=-I$(DRUNTIME_PATH)\import -I$(PHOBOS_PATH)
export LIB=$(PHOBOS_PATH)
else
export ARGS=-inline -release -gc -O -unittest -fPIC
export DMD=../src/dmd
export EXE=
export OBJ=.o
export DSEP=/
export SEP=/

DRUNTIME_PATH=../../druntime
PHOBOS_PATH=../../phobos
export DFLAGS=-I$(DRUNTIME_PATH)/import -I$(PHOBOS_PATH) -L-L$(PHOBOS_PATH)/generated/$(OS)/release/$(MODEL)
endif

ifeq ($(OS),osx)
ifeq ($(MODEL),64)
export D_OBJC=1
endif
endif

ifeq ($(OS),freebsd)
DISABLED_TESTS += dhry
# runnable/dhry.d(488): Error: undefined identifier dtime
endif

ifeq ($(OS),solaris)
DISABLED_TESTS += dhry
# runnable/dhry.d(488): Error: undefined identifier dtime
endif

ifeq ($(OS),win32)
DISABLED_FAIL_TESTS += fail13939
endif

####
# LDC: Disable -profile tests.
DISABLED_TESTS += hello-profile
DISABLED_TESTS += testprofile
DISABLED_COMPILE_TESTS += diag11066

# LDC: Disable gdb tests. Problems are the implicit return and
# variables optimized out by the compiler.
DISABLED_TESTS += gdb1
DISABLED_TESTS += gdb10311
DISABLED_TESTS += gdb14225
DISABLED_TESTS += gdb4181

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

# LDC_FIXME: Name object files the same as DMD for LDMD compatibility (->Github #171)
DISABLED_SH_TESTS += test44

# LDC_FIXME: We currently don't support gotos into try blocks, see GitHub #676.
DISABLED_COMPILE_TESTS += ice11925

# LDC_FIXME: This covers an optimization LLVM chooses not to do, see GitHub #679.
DISABLED_COMPILE_TESTS += test11237

# LDC: -transition/-vtls not supported yet.
DISABLED_COMPILE_TESTS += sw_transition_field
DISABLED_COMPILE_TESTS += sw_transition_tls

# LDC: Our ASM diagnostics are different, might be worth revisiting at some point.
DISABLED_FAIL_TESTS += diag6717
DISABLED_FAIL_TESTS += fail152

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

# LDC: dmd bug caught early: https://issues.dlang.org/show_bug.cgi?id=13353
DISABLED_TESTS += testclass

####

ifeq ($(OS),win64)
DISABLED_TESTS += testxmm
DISABLED_FAIL_TESTS += fail13939
endif

ifeq ($(OS),osx)
ifeq ($(MODEL),64)
DISABLED_TESTS += test6423
endif
endif

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
	$(QUIET) ./$(<D)/$*.sh

$(addsuffix .d.out,$(addprefix $(RESULTS_DIR)/compilable/,$(DISABLED_COMPILE_TESTS))): $(RESULTS_DIR)/.created
	$(QUIET) echo " ... $@ - disabled"

$(RESULTS_DIR)/compilable/%.d.out: compilable/%.d $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) $(RESULTS_DIR)/d_do_test $(<D) $* d

$(RESULTS_DIR)/compilable/%.sh.out: compilable/%.sh $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE) $(DMD)
	$(QUIET) echo " ... $(<D)/$*.sh"
	$(QUIET) ./$(<D)/$*.sh

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

run_runnable_tests: $(runnable_test_results)

start_runnable_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running runnable tests"
	$(QUIET)$(MAKE) --no-print-directory run_runnable_tests

run_compilable_tests: $(compilable_test_results)

start_compilable_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running compilable tests"
	$(QUIET)$(MAKE) --no-print-directory run_compilable_tests

run_fail_compilation_tests: $(fail_compilation_test_results)

start_fail_compilation_tests: $(RESULTS_DIR)/.created $(RESULTS_DIR)/d_do_test$(EXE)
	@echo "Running fail compilation tests"
	$(QUIET)$(MAKE) --no-print-directory run_fail_compilation_tests

$(RESULTS_DIR)/d_do_test$(EXE): d_do_test.d $(RESULTS_DIR)/.created
	@echo "Building d_do_test tool"
	@echo "OS: $(OS)"
	$(QUIET)$(DMD) -conf= $(MODEL_FLAG) -unittest -run d_do_test.d -unittest
	$(QUIET)$(DMD) -conf= $(MODEL_FLAG) -od$(RESULTS_DIR) -of$(RESULTS_DIR)$(DSEP)d_do_test$(EXE) d_do_test.d

