pragma(llvm_inline_ir)
    R inlineIR(string s, R, P...)(P);

alias inlineIR!(`ret i32 %0`, float, int) foo;
