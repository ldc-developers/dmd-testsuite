import dshell;

int main()
{
    version (LDC)
    {
        if (Vars.BUILD_SHARED_LIBS == "OFF")
            return DISABLED;
    }
    else version (Windows) if (Vars.MODEL == "32omf") // Avoid optlink
        return DISABLED;

    Vars.set(`SRC`, `$EXTRA_FILES/dll`);
    Vars.set(`EXE_NAME`, `$OUTPUT_BASE/testdll$EXE`);
    Vars.set(`DLL`, `$OUTPUT_BASE/mydll$SOEXT`);

    version (Windows)
    {
        enum dllExtra = `$SRC/dllmain.d`;
        enum mainExtra = `$OUTPUT_BASE/mydll$LIBEXT`;
    }
    else
    {
        // Segfaults without PIC - using hardcoded -fPIC and not $PIC_FLAG as
        // the latter can be set to an empty string.
        enum dllExtra = `-fPIC`;
        version (LDC) // shared default libs for the executable too
            enum mainExtra = `-fPIC -L-L$OUTPUT_BASE -L$DLL -link-defaultlib-shared`;
        else
            enum mainExtra = `-fPIC -L-L$OUTPUT_BASE -L$DLL`;
    }

    run(`$DMD -m$MODEL -shared -od=$OUTPUT_BASE -of=$DLL $SRC/mydll.d ` ~ dllExtra);

    run(`$DMD -m$MODEL -I$SRC -od=$OUTPUT_BASE -of=$EXE_NAME $SRC/testdll.d ` ~ mainExtra);

    run(`$EXE_NAME`, stdout, stderr, [`LD_LIBRARY_PATH`: Vars.OUTPUT_BASE]);

    return 0;
}
