// make -B tracer-hpp-test CXXFLAGS=--std=c++17

#include "tracer.hpp"
#if __cplusplus > 201103
#include <thread>
#endif

using std::string;

#if __cplusplus >= 201402L
using namespace std::literals::chrono_literals;
#endif

int main()
{
#if __cplusplus >= 201103
	measure_block_duration();
#endif
	int i = -123;
	double d = 123.456;
	string s = "string value";
	char ca[] = "char array";
	const char * cp = "char pointer";
	void * p = &i;
	int * ip = &i;

#if __cplusplus >= 201402L
	std::this_thread::sleep_for(100ms);
#endif
	trace(); // prints only file name and line
	trace("error:", s); // prints literal message
	trace(p);
	trace(ip);
	trace(cp);
	trace(ca);
	trace(i, d);
	trace(i, s);
	trace(i, d, s);
	trace(i, d, s, cp);
	trace(i, d, s, cp, ca);
	trace(i, d, s, cp, ca, i);
	trace(i, d, s, cp, ca, i, d);
	trace(i, d, s, cp, ca, i, d, s);
	// up to 16 variables
	trace(i, d, s, cp, ca, i, d, s, i, d, s, cp, ca, i, d, s);
	trace(tracer::duration(_block_duration.start));
	trace(s, i);
}
