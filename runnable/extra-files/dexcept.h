// D exceptions to be caught by C++

#pragma once

namespace D {

struct string
{
    size_t length;
    const char* ptr;
};

class Object;

extern "C" {
    string _d_toString(Object* o);
}

class Object
{
    void* __monitor;

    virtual void _classinfo_data() = 0;

protected:
    // don't call directly, ABI mismatch
    virtual string _toString();
    virtual size_t _toHash();
    virtual int _opCmp(Object* o);
    virtual bool _opEquals(Object* o);

public:
    string toString() { return _d_toString(this); }
};

class Throwable : public Object
{
public:
    string      msg;    /// A message describing the error.

    /**
     * The _file name and line number of the D source code corresponding with
     * where the error was thrown from.
     */
    string      file;
    size_t      line;   /// ditto

    void*       info;
    Throwable*  next;

    virtual string _toString();
};

class Exception : public Throwable
{
};

class Error : public Throwable
{
    Throwable* bypassedException;
};

} // namespace D
