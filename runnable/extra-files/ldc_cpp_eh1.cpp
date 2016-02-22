#include "dexcept.h"
#include <string.h>
#include <assert.h>

void throwException();

bool test_eh()
{
	try
	{
		throwException();
	}
	catch (D::Exception* excpt)
	{
		D::string s = excpt->toString();
		assert(memcmp(s.ptr + s.length - 9, "Hello C++", 9) == 0);
		return true;
	}
	catch(...)
	{
		assert(false);
	}
	return false;
}
