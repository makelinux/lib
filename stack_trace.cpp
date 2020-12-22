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

extern "C" int stack_trace(void)
{
	size_t size;
	int i;
	void *bt[16];

	size = backtrace(bt, sizeof(bt)/sizeof(bt[0]));
	char **strings = backtrace_symbols(bt, size);
	basic_stringstream<char> buff;
	for (i = 0; i < size; i++)
		cerr << strings[i] << '\n';
	for (i = size - 1; i > -1; i--) {
		if (!bt[i])
			break;
		string s = strings[i];
		smatch m;
		if (!regex_match(s, m, regex(".*\\(([^+]+)\\+.*\\).*"))) {
			buff << "> … " ;
			continue;
		}
		char *demangled
			= abi::__cxa_demangle(m[1].str().c_str(), 0, 0, 0);
		if (demangled)
			*strchrnul(demangled, '(') = 0;
		else
			demangled = strdup(m[1].str().c_str());
		buff << "> " << (demangled?:m[1].str().c_str()) << " ";
		free(demangled);
	}
	buff << "\n";
	cerr << buff.str();
	free(strings);
	return 0;
}
