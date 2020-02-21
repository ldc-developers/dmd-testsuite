/*
REQUIRED_ARGS: -HC -c -o-
PERMUTE_ARGS:
TEST_OUTPUT:
---
#pragma once

// Automatically generated by dmd -HC

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define _d_void void
#define _d_bool bool
#define _d_byte signed char
#define _d_ubyte unsigned char
#define _d_short short
#define _d_ushort unsigned short
#define _d_int int
#define _d_uint unsigned
#define _d_long $?:32=long long|64=long$
#define _d_ulong unsigned $?:32=long long|64=long$
#define _d_float float
#define _d_double double
#define _d_real long double
#define _d_char char
#define _d_wchar wchar_t
#define _d_dchar unsigned
typedef _d_long d_int64;

#define _d_null NULL


// Parsing module dtoh_unittest_block
---
*/

unittest
{
    extern (C++) int foo(int x)
    {
        return x * 42;
    }
}
