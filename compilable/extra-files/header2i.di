class C
{
}
void foo(const C c, const(char)[] s, const int* q, const(int*) p)
{
}
void bar(in void* p)
{
}
void f(void function() f2);
class C2;
void foo2(const C2 c);
struct Foo3
{
	int k;
	~this()
	{
		k = 1;
	}
	this(this)
	{
		k = 2;
	}
}
class C3
{
	@property int get()
	{
		return 0;
	}
}
T foo3(T)()
{
}
struct S4A(T)
{
	T x;
}
struct S4B(T) if (1)
{
	T x;
}
union U4A(T)
{
	T x;
}
union U4B(T) if (2 * 4 == 8)
{
	T x;
}
class C4A(T)
{
	T x;
}
class C4B(T) if (true)
{
	T x;
}
class C4C(T) if (!false) : C4A!int
{
	T x;
}
class C4D(T) if (!false) : C4B!long, C4C!(int[])
{
	T x;
}
interface I4(T) if ((int[1]).length == 1)
{
	T x;
}
template MyClass4(T) if (is(typeof(T.subtype)))
{
	alias HelperSymbol = T.subtype;
	class MyClass4
	{
	}
}
auto flit = 3 / 2.00000;
void foo11217()(const int[] arr)
{
}
void foo11217()(immutable int[] arr)
{
}
void foo11217()(ref int[] arr)
{
}
void foo11217()(lazy int[] arr)
{
}
void foo11217()(auto ref int[] arr)
{
}
void foo11217()(scope int[] arr)
{
}
void foo11217()(in int[] arr)
{
}
void foo11217()(inout int[] arr)
{
}
void test13275()
{
	if (auto n = 1)
	{
	}
	if (const n = 1)
	{
	}
	if (immutable n = 1)
	{
	}
	if (shared n = 1)
	{
	}
	if (const shared n = 1)
	{
	}
	if (int n = 1)
	{
	}
	if (const int n = 1)
	{
	}
	if (immutable int n = 1)
	{
	}
	if (shared int n = 1)
	{
	}
	if (const shared int n = 1)
	{
	}
	if (const(int) n = 1)
	{
	}
	if (immutable(int) n = 1)
	{
	}
	if (shared(int) n = 1)
	{
	}
	if (shared const(int) n = 1)
	{
	}
	foreach (e; [1, 2])
	{
	}
	foreach (const e; [1, 2])
	{
	}
	foreach (immutable e; [1, 2])
	{
	}
	foreach (shared e; [1, 2])
	{
	}
	foreach (const shared e; [1, 2])
	{
	}
	foreach (int e; [1, 2])
	{
	}
	foreach (const int e; [1, 2])
	{
	}
	foreach (immutable int e; [1, 2])
	{
	}
	foreach (shared int e; [1, 2])
	{
	}
	foreach (const shared int e; [1, 2])
	{
	}
	foreach (int e; [1, 2])
	{
	}
	foreach (const(int) e; [1, 2])
	{
	}
	foreach (immutable(int) e; [1, 2])
	{
	}
	foreach (shared(int) e; [1, 2])
	{
	}
	foreach (shared const(int) e; [1, 2])
	{
	}
}
