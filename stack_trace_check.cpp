
extern "C" int stack_trace();

extern "C" void c_func()
{
	stack_trace();
}

int main()
{
	[]() { c_func();}();
}
