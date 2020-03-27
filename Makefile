ifeq (Windows_NT,$(OS))
    ifeq ($(findstring WOW64, $(shell uname)),WOW64)
        OS:=windows
        MODEL:=64
    else
        OS:=windows
        MODEL:=32
    endif
endif
ifeq (Win_32,$(OS))
    OS:=windows
    MODEL:=32
endif
ifeq (Win_32_64,$(OS))
    OS:=windows
    MODEL:=64
endif
ifeq (Win_64,$(OS))
    OS:=windows
    MODEL:=64
endif

include ../src/osmodel.mak

export OS
BUILD=release

ifeq (freebsd,$(OS))
    SHELL=/usr/local/bin/bash
else ifeq (netbsd,$(OS))
    SHELL=/usr/pkg/bin/bash
else ifeq (dragonflybsd,$(OS))
    SHELL=/usr/local/bin/bash
else
    SHELL=/bin/bash
endif
QUIET=@
export RESULTS_DIR=test_results
export MODEL

ifeq ($(findstring win,$(OS)),win)
    export EXE=.exe

    PIC?=0

    DRUNTIME_PATH=..\..\druntime
    PHOBOS_PATH=..\..\phobos
    export DFLAGS=-I$(DRUNTIME_PATH)\import -I$(PHOBOS_PATH)
    export LIB=$(PHOBOS_PATH)

    # auto-tester might run the testsuite with a different $(MODEL) than DMD
    # has been compiled with. Hence we manually check which binary exists.
    # For windows the $(OS) during build is: `windows`
    ifeq (,$(wildcard ../generated/windows/$(BUILD)/64/dmd$(EXE)))
        DMD_MODEL=32
    else
        DMD_MODEL=64
    endif
    export DMD=../generated/windows/$(BUILD)/$(DMD_MODEL)/dmd$(EXE)

else
    export EXE=

    # auto-tester might run the testsuite with a different $(MODEL) than DMD
    # has been compiled with. Hence we manually check which binary exists.
    ifeq (,$(wildcard ../generated/$(OS)/$(BUILD)/64/dmd))
        DMD_MODEL=32
    else
        DMD_MODEL=64
    endif
    export DMD=../generated/$(OS)/$(BUILD)/$(DMD_MODEL)/dmd

    # default to PIC on x86_64, use PIC=1/0 to en-/disable PIC.
    # Note that shared libraries and C files are always compiled with PIC.
    ifeq ($(PIC),)
        ifeq ($(MODEL),64) # x86_64
            PIC:=1
        else
            PIC:=0
        endif
    endif
    ifeq ($(PIC),1)
        export PIC_FLAG:=-fPIC
    else
        export PIC_FLAG:=
    endif

    DRUNTIME_PATH=../../druntime
    PHOBOS_PATH=../../phobos
    # link against shared libraries (defaults to true on supported platforms, can be overridden w/ make SHARED=0)
    SHARED=$(if $(findstring $(OS),linux freebsd),1,)
    DFLAGS=-I$(DRUNTIME_PATH)/import -I$(PHOBOS_PATH) -L-L$(PHOBOS_PATH)/generated/$(OS)/$(BUILD)/$(MODEL)
    ifeq (1,$(SHARED))
        DFLAGS+=-defaultlib=libphobos2.so -L-rpath=$(PHOBOS_PATH)/generated/$(OS)/$(BUILD)/$(MODEL)
    endif
    export DFLAGS
endif

# Try to find a suitable dmd if HOST_DMD is missing
ifeq ($(HOST_DMD),)
    # Legacy support, some CI's use HOST_DC instead of HOST_DMD
    ifneq ($(HOST_DC),)
        $(warning Please use HOST_DMD instead of HOST_DC!)
        HOST_DMD = $(HOST_DC)
    else
        HOST_DMD = dmd
    endif
endif

# Required version for -lowmem
MIN_VERSION = v2.086.0
VERSION = $(filter v2.%, $(shell $(HOST_DMD) --version 2>/dev/null))


$(info VERSION = "$(VERSION)")

ifeq ($(VERSION),)
    # dmd was not found in $PATH
    USE_GENERATED=1
# Detect whether the host dmd satisfies MIN_VERSION
else ifneq ($(MIN_VERSION), $(firstword $(sort $(MIN_VERSION) $(VERSION))))
    # dmd found in $PATH is too old
    USE_GENERATED=1
endif

ifneq ($(USE_GENERATED),)
    # Use the generated dmd instead of the host compiler
    HOST_DMD=$(DMD)
    D=$(HOST_DMD) -conf=
else
    D = $(HOST_DMD)
endif

# Ensure valid paths on windows
export HOST_DMD:=$(subst \,/,$(HOST_DMD))

RUNNER:=$(RESULTS_DIR)/run$(EXE)
EXECUTE_RUNNER:=$(RUNNER) --environment

# N determines the amount of parallel jobs, see ci.sh
ifneq ($(N),)
    EXECUTE_RUNNER:=$(EXECUTE_RUNNER) --jobs=$N
endif

all: run_tests

quick: $(RUNNER)
	$(EXECUTE_RUNNER) $@

clean:
	@echo "Removing output directory: $(RESULTS_DIR)"
	$(QUIET)if [ -e $(RESULTS_DIR) ]; then rm -rf $(RESULTS_DIR); fi
	@echo "Remove coverage listing files: *.lst"
	$(QUIET)rm -rf *.lst
	@echo "Remove trace files: trace.def, trace.log"
	$(QUIET)rm -rf trace.log trace.def

$(RESULTS_DIR)/.created:
	@echo Creating output directory: $(RESULTS_DIR)
	$(QUIET)if [ ! -d $(RESULTS_DIR) ]; then mkdir $(RESULTS_DIR); fi
	$(QUIET)touch $(RESULTS_DIR)/.created

run_tests: run_all_tests

unit_tests: $(RUNNER)
	@echo "Running unit tests"
	$(EXECUTE_RUNNER) $@

run_runnable_tests: $(RUNNER)
	$(EXECUTE_RUNNER) $@

start_runnable_tests: $(RUNNER)
	@echo "Running runnable tests"
	$(EXECUTE_RUNNER) run_runnable_tests

run_runnable_cxx_tests: $(RUNNER)
	$(EXECUTE_RUNNER) $@

start_runnable_cxx_tests:
	@echo "Running runnable_cxx tests"
	$(QUIET)$(MAKE) $(DMD_TESTSUITE_MAKE_ARGS) --no-print-directory run_runnable_cxx_tests

run_compilable_tests: $(RUNNER)
	$(EXECUTE_RUNNER) $@

start_compilable_tests: $(RUNNER)
	@echo "Running compilable tests"
	$(EXECUTE_RUNNER) run_compilable_tests

run_fail_compilation_tests: $(RUNNER)
	$(EXECUTE_RUNNER) $@

start_fail_compilation_tests: $(RUNNER)
	@echo "Running fail compilation tests"
	$(EXECUTE_RUNNER) run_fail_compilation_tests

run_dshell_tests: $(RUNNER)
	$(EXECUTE_RUNNER) $@

start_dshell_tests: $(RUNNER)
	@echo "Running dshell tests"
	$(EXECUTE_RUNNER) run_dshell_tests

run_all_tests: $(RUNNER)
	$(EXECUTE_RUNNER)

start_all_tests: $(RUNNER)
	@echo "Running all tests"
	$(EXECUTE_RUNNER) all

# The auto-tester cannot run runnable_cxx as its compiler is too old
auto-tester-test: $(RUNNER)
	$(EXECUTE_RUNNER) runnable compilable fail_compilation dshell

$(RESULTS_DIR)/d_do_test$(EXE): tools/d_do_test.d tools/sanitize_json.d $(RESULTS_DIR)/.created
	@echo "Building d_do_test tool"
	@echo "OS: '$(OS)'"
	@echo "MODEL: '$(MODEL)'"
	@echo "PIC: '$(PIC_FLAG)'"
	$(D) $(MODEL_FLAG) $(PIC_FLAG) -g -lowmem -i -Itools -version=NoMain -unittest -run $<
	$(D) $(MODEL_FLAG) $(PIC_FLAG) -g -lowmem -i -Itools -version=NoMain -od$(RESULTS_DIR) -of$@ $<

# Build d_do_test here to run it's unittests
# TODO: Migrate this to run.d
$(RUNNER): run.d $(RESULTS_DIR)/d_do_test$(EXE)
	$(D) $(MODEL_FLAG) $(PIC_FLAG) -g -od$(RESULTS_DIR) -of$(RUNNER) -i -release $<

# run.d is not reentrant because each invocation might attempt to build the required tools
.NOTPARALLEL:
