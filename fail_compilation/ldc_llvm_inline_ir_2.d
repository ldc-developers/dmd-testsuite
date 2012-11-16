pragma(llvm_inline_ir)
    R inlineIR(string s, R, P...)();


alias inlineIR!(``, void, 1, 2, 3) foo;
