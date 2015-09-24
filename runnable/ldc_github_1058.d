align(1) struct vec3
{
    float x, y, z;
}

interface I
{
    abstract void interfaceFun();
}

class A : I
{
    override void interfaceFun()
    {
    }
    bool b;
    vec3 v;
}

pragma(msg, A.v.offsetof);

void main(string[]args)
{
    I a = new A();
    a.interfaceFun(); // crash in a's invariant here, cannot find the TypeInfo
}
