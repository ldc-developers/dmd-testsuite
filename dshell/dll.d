import dshell;

int main()
{
    version (Windows) if (Vars.MODEL == "32") // Avoid optlink
        return DISABLED;

    version (Posix) if (Vars.PIC_FLAG == "") // Segfaults without PIC
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
        enum dllExtra = `$PIC_FLAG`;
        enum mainExtra = `$PIC_FLAG -L-L$OUTPUT_BASE -L$DLL`;
    }

    run(`$DMD -m$MODEL -shared -od=$OUTPUT_BASE -of=$DLL $SRC/mydll.d ` ~ dllExtra);

    run(`$DMD -m$MODEL -I$SRC -od=$OUTPUT_BASE -of=$EXE_NAME $SRC/testdll.d ` ~ mainExtra);

    run(`$EXE_NAME`, stdout, stderr, [`LD_LIBRARY_PATH`: Vars.OUTPUT_BASE]);

    return 0;
}
