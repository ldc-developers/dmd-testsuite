void fooNormal()() {
    asm {
        jmp Llabel;
Llabel:
        nop;
    }
}

void fooNaked()() {
    asm {
        naked;
        jmp Llabel;
Llabel:
        ret;
    }
}

void main() {
    fooNormal();
    fooNaked();
}
