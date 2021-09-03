/**
  @file
  @brief Instrumental tracing utility.
  Copyright (C) 2021 Constantine Shulyupin

  */

#include <bits/stdc++.h>
#include <filesystem>
#include <cxxabi.h>
#include <dlfcn.h>


using namespace std;
using namespace filesystem;

/**

Usage.

Add to Makefile or equivalent:

CXXFLAGS+=-rdynamic -finstrument-functions -finstrument-functions-exclude-file-list=/usr/include/,instrument-tracer.cc -finstrument-functions-exclude-function-list=basic_regex
LDLIBS+=-ldl
instrument-tracer.o: CXXFLAGS+=-std=c++17

*/

__attribute__((no_instrument_function))
string demangle(const char * name)
{
	unique_ptr<char, decltype(free)*> cn{abi::__cxa_demangle(name, 0, 0, 0), free};

	if (!cn)
		return name;
	// truncate arguments and tags from signature
	*strchrnul(cn.get(), '(') = 0;
	*strchrnul(cn.get(), '[') = 0;
	return cn.get();
}

static thread_local atomic_int level;

__attribute__((no_instrument_function))
string addr2line(int addr)
{
	static map<int, string> cache;
	if (cache.count(addr))
		return cache[addr];

	char buf[200] = "";
	char * bufp = buf;

	stringstream hs;
	hs << hex << addr;
	string cmd = "addr2line -e " + canonical(program_invocation_name).string() + " " + hs.str();
	unique_ptr<FILE, decltype(pclose)*> f{popen(cmd.c_str(), "r"), pclose};

	if (!f)
		return "";

	auto s = fgets(buf, sizeof(buf), f.get());
	if (s) {
		s[strlen(s) - 1] = ':';
		// TODO: remove canonical(absolute(current_path()))
		if (strrchr(s, '/'))
			bufp = strrchr(s, '/') +1;
	}
	cache[addr] = bufp; // store even empty string
	return bufp;
}

__attribute__((no_instrument_function))
void trace_enter_exit(void *caller, char dir, void *func)
{
#if 0
	void *bt[4];
	backtrace(bt, 4);
	char **strings = backtrace_symbols(bt, 4);
	for (int i = 2; i < (int)4; i++)
		trvs(strings[i]);
	free(strings);
#endif
	Dl_info fi = {};
	dladdr(func, &fi);
	if (!fi.dli_sname)
		return;

	string n = demangle(fi.dli_sname);

	string line = addr2line((char*)fi.dli_saddr - (char*)fi.dli_fbase);
	stringstream out;
	auto tid = this_thread::get_id();
	static map <thread::id, int> threads;
	if (!threads.count(tid))
		threads[tid] = threads.size();

	static thread::id prev_tid;
	if (prev_tid != tid) {
		out << line << " thread " << threads[tid] << ":" << endl;
		prev_tid = tid;
	}
	out << line << ' ' << string(level, '\t') << n ;
	out << endl;
	cerr << out.str();
#if 0
	cerr << canonical(absolute(program_invocation_name)).string() << endl;
	trace();
	trace(canonical(program_invocation_name).string());
	trace(absolute(program_invocation_name).string());
	trace(canonical(absolute(program_invocation_name)).string());
	trace(canonical(absolute(current_path())).string());
	exit(0);
#endif
}

extern "C"
__attribute__((no_instrument_function))
void __cyg_profile_func_enter(void *func,  void *caller)
{
	trace_enter_exit(caller, '>', func);
	++level;
}

extern "C"
__attribute__((no_instrument_function))
void __cyg_profile_func_exit( void *func, void *caller )
{
	trace_enter_exit(caller, '<', func);
	--level;
}
