// EXTRA_CPP_SOURCES: ldc_cpp_eh1.cpp 

extern(C++) bool test_eh();

extern(C++)
void throwException()
{
	throw new Exception("Hello C++");
}

void main()
{
	bool rc = test_eh();
	assert(rc);
}
