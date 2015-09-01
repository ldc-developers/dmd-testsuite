extern __gshared pragma(LDC_extern_weak) int nonExistent;

bool doesNonExistentExist() {
    return &nonExistent !is null;
}

void main() {
    // Make sure that the frontend does not statically fold the address check
    // to 'true' for weak symbols.
    assert(!doesNonExistentExist());
}

// OS X note: ld complains extern_weak symbols are undefined unless ld options
// -undefined dynamic_lookup or -U __D15ldc_extern_weak11nonExistenti are
// provided.  extern_weak not really needed on OS X though.
