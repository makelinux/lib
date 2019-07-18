// make -B tracer-hpp-test CXXFLAGS=--std=c++17

#include "tracer.hpp"
#include <thread>

using std::string;
using namespace std::literals::chrono_literals;

int main()
{
	measure_block_duration();
	int i = -123;
	double d = 123.456;
	string s = "string value";
	char ca[] = "char array";
	const char * cp = "char pointer";
	void * p = &i;
	int * ip = &i;

	std::this_thread::sleep_for(100ms);
	trace(); // prints only file name and line
	trace("error:", s); // prints literal message
	trace(p);
	trace(ip);
	trace(cp);
	trace(ca);
	trace(i, d);
	trace(i, d, s);
	trace(i, d, s, cp);
	trace(i, d, s, cp, ca);
	trace(i, d, s, cp, ca, i);
	trace(i, d, s, cp, ca, i, d);
	trace(i, d, s, cp, ca, i, d, s);
	// up to 16 variables
	trace(i, d, s, cp, ca, i, d, s, i, d, s, cp, ca, i, d, s);
	trace(tracer::duration(_block_duration.start));
}
