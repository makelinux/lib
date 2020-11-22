#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <memory>
#include <cxxabi.h>
#include <execinfo.h>
#include <regex>
#include <iostream>
#include <string.h>

using namespace std;

#ifndef ARRAY_SIZE
#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
#endif

extern "C" {                                                                                                            

int stack_trace(void)
{
	size_t size;
	size_t i;
	void *bt[32];

	size = backtrace(bt, sizeof(bt)/sizeof(bt[0]));
	char **strings = backtrace_symbols(bt, size);

	for (i = size - 1; i > 0; i--) {
		if (!bt[i])
			break;
		smatch m;
		string s = strings[i];
		if (!regex_match(s, m, regex(".*\\(([^+]+)\\+.*\\).*")))
			return -1;
		char *demangled
			= abi::__cxa_demangle(m[1].str().c_str(), 0, 0, 0);

		if (demangled)
			*strchrnul(demangled, '(') = 0;
		cerr << " > " << (demangled?:m[1].str().c_str()) ;
		free(demangled);
	}
	cerr << "\n";
	free(strings);
	return 0;
}

}
