/*
REQUIRED_ARGS: -HC -c -o-
PERMUTE_ARGS:
TEST_OUTPUT:
---
// Automatically generated by Digital Mars D Compiler

#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <math.h>

#ifdef CUSTOM_D_ARRAY_TYPE
#define _d_dynamicArray CUSTOM_D_ARRAY_TYPE
#else
/// Represents a D [] array
template<typename T>
struct _d_dynamicArray final
{
    size_t length;
    T *ptr;

    _d_dynamicArray() : length(0), ptr(NULL) { }

    _d_dynamicArray(size_t length_in, T *ptr_in)
        : length(length_in), ptr(ptr_in) { }

    T& operator[](const size_t idx) {
        assert(idx < length);
        return ptr[idx];
    }

    const T& operator[](const size_t idx) const {
        assert(idx < length);
        return ptr[idx];
    }
};
#endif

typedef uint$?:32=32|64=64$_t size_t;

struct Outer final
{
    int32_t a;
    struct Member final
    {
        typedef int32_t Nested;
        Member()
        {
        }
    };

    Outer() :
        a()
    {
    }
    Outer(int32_t a) :
        a(a)
        {}
};

enum : int32_t { SomeOtherLength = 1 };

struct ActualBuffer final
{
    ActualBuffer()
    {
    }
};

template <typename T>
struct A final
{
    // Ignoring var x alignment 0
    T x;
    // Ignoring var Enum alignment 0
    enum : int32_t { Enum = 42 };

    // Ignoring var GsharedNum alignment 0
    static int32_t GsharedNum;
    // Ignoring var MemNum alignment 0
    const int32_t MemNum;
    void foo();
    A()
    {
    }
};

template <typename T>
struct NotInstantiated final
{
    // Ignoring var noInit alignment 0
    // Ignoring var missingSem alignment 0
    NotInstantiated()
    {
    }
};

struct B final
{
    A<int32_t > x;
    B() :
        x()
    {
    }
    B(A<int32_t > x) :
        x(x)
        {}
};

template <typename T>
struct Foo final
{
    // Ignoring var val alignment 0
    T val;
    Foo()
    {
    }
};

template <typename T>
struct Bar final
{
    // Ignoring var v alignment 0
    Foo<T > v;
    Bar()
    {
    }
};

template <typename T>
struct Array final
{
    typedef Array This;
    typedef typeof(1 + 2) Int;
    typedef typeof(T::a) IC;
    Array(size_t dim);
    ~Array();
    void get() const;
    template <typename T>
    bool opCast() const;
    // Ignoring var i alignment 0
    typename T::Member i;
    // Ignoring var j alignment 0
    typename Outer::Member::Nested j;
    void visit(typename T::Member::Nested i);
    Array()
    {
    }
};

template <typename T, typename U>
extern T foo(U u);

extern A<A<int32_t > > aaint;

template <typename T>
class Parent
{
    // Ignoring var parentMember alignment 0
public:
    T parentMember;
    void parentFinal();
    virtual void parentVirtual();
};

template <typename T>
class Child final : public Parent<T >
{
    // Ignoring var childMember alignment 0
public:
    T childMember;
    void parentVirtual();
    T childFinal();
};

extern void withDefTempl(A<int32_t > a = A<int32_t >(2, 13));

template <typename T>
extern void withDefTempl2(A<T > a = static_cast<A<T >>(A!T(2)));

class ChildInt : public Parent<int32_t >
{
};

struct HasMixins final
{
    void foo(int32_t t);
    HasMixins()
    {
    }
};

template <typename T>
struct HasMixinsTemplate final
{
    void foo(T t);
    HasMixinsTemplate()
    {
    }
};

extern HasMixinsTemplate<bool > hmti;

template <typename T>
struct NotAA final
{
    // Ignoring var length alignment 0
    enum : int32_t { length = 12 };

    // Ignoring var buffer alignment 0
    T buffer[length];
    // Ignoring var otherBuffer alignment 0
    T otherBuffer[SomeOtherLength];
    // Ignoring var calcBuffer alignment 0
    T calcBuffer[foo(1)];
    NotAA()
    {
    }
};

template <typename Buffer>
struct BufferTmpl final
{
    // Ignoring var buffer alignment 0
    Buffer buffer;
    // Ignoring var buffer2 alignment 0
    Buffer buffer2;
    BufferTmpl()
    {
    }
};

struct ImportedBuffer final
{
    typedef ActualBuffer Buffer;
    ActualBuffer buffer2;
    ImportedBuffer()
    {
    }
};
---
*/

extern (C++) struct A(T)
{
    T x;
    enum Enum = 42;
    __gshared GsharedNum = 43;
    immutable MemNum = 13;
    void foo() {}
}

// Invalid declarations accepted because it's not instantiated
extern (C++) struct NotInstantiated(T)
{
    enum T noInit;
    enum missingSem = T.init;
}

extern (C++) struct B
{
    A!int x;
}

// https://issues.dlang.org/show_bug.cgi?id=20604
extern(C++)
{
    struct Foo (T)
    {
        T val;
    }

    struct Bar (T)
    {
        Foo!T v;
    }
}

extern (C++) struct Array(T)
{
    alias This = typeof(this);
    alias Int = typeof(1 + 2);
    alias IC = typeof(T.a);

    this(size_t dim) pure nothrow {}
    @disable this(this);
    ~this() {}
    void get() const {}

    bool opCast(T)() const pure nothrow @nogc @safe
    if (is(T == bool))
    {
        return str.ptr !is null;
    }

    T.Member i;
    Outer.Member.Nested j;
    void visit(T.Member.Nested i) {}
}

struct Outer
{
    int a;
    static struct Member
    {
        alias Nested = int;
    }
}

// alias AO = Array!Outer;

extern(C++) T foo(T, U)(U u) { return T.init; }

extern(C++) __gshared A!(A!int) aaint;

extern(C++) class Parent(T)
{
    T parentMember;
    final void parentFinal() {}
    void parentVirtual() {}
}

extern(C++) final class Child(T) : Parent!T
{
    T childMember;
    override void parentVirtual() {}
    T childFinal() { return T.init; }
}

extern(C++) void withDefTempl(A!int a = A!int(2)) {}

extern(C++) void withDefTempl2(T)(A!T a = A!T(2)) {}

extern(C++) alias withDefTempl2Inst = withDefTempl2!int;

extern(C++) class ChildInt : Parent!int {}

/******************************************************
 * Mixins
 */

extern (C++):

mixin template MixinA(T)
{
    void foo(T t) {}
}

mixin template MixinB() {}

struct HasMixins
{
    mixin MixinA!int;
    mixin MixinB;
}

struct HasMixinsTemplate(T)
{
    mixin MixinA!T;
    mixin MixinB;
}

__gshared HasMixinsTemplate!bool hmti;

/// Declarations that look like associative arrays

extern(D) enum SomeOtherLength = 1;

struct NotAA(T)
{
    private:
    enum length = 12;
    public:
    T[length] buffer;
    T[SomeOtherLength] otherBuffer;
    T[foo(1)] calcBuffer;
}

// Same name but hidden by the template paramter
extern (D) struct Buffer {}
extern (D) struct ActualBuffer {}

struct BufferTmpl(Buffer)
{
    Buffer buffer;
    mixin BufferMixin!();
}

struct ImportedBuffer
{
    alias Buffer = ActualBuffer;
    mixin BufferMixin!();
}

mixin template BufferMixin()
{
    Buffer buffer2;
}
