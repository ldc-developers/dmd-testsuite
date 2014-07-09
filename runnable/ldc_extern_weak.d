extern __gshared pragma(LDC_extern_weak) int nonExistent;

bool doesNonExistentExist() {
    return &nonExistent !is null;
}

void main() {
    // Make sure that the frontend does not statically fold the address check
    // to 'true' for weak symbols.
    assert(!doesNonExistentExist());
}
