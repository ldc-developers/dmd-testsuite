alias __vector(float[4]) float4;

pragma(llvm_inline_ir)
    R inlineIR(string s, R, P...)(P);

alias inlineIR!(`
    %r = fadd <4 x float> %0, %1
    ret <4 x float> %r`, float4, float4, float4) foo;

alias inlineIR!(` store i32 %1, i32* %0`, void, int*, int) bar;
