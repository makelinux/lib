/* S PDX-License-Identifier: Apache-2.0
 * Copyright (C) 2019 Constantine Shulyupin
 * Original: https://gitlab.com/makelinux/lib/blob/master/tracer.hpp
 */
#pragma once
#include <string>
#include <sstream>
#include <chrono>
#include <iostream>

#include <string.h>

/** \cond */

#ifndef __file__
#define ctracer_cut_path(fn) (fn[0] != '/' ? fn : (strrchr(fn, '/') + 1))
#define __file__	ctracer_cut_path(__FILE__)
#endif

#define file_line() (string(__file__) + ":" + std::to_string(__LINE__) + ":" + __func__ +" ")

namespace tracer
{

static inline const std::string to_string() {return "";}
static inline const std::string to_string(const std::string &s) {return '"' + s + '"';}

// for char *
static inline const std::string to_string(const char * c) {return '"' + std::string(c) + '"';}

// for const char x[]
static inline const std::string to_string(char * const c) {return '"' + std::string(c) + '"';}

template <typename T>
static inline const std::string to_string(const T &s) {return std::to_string(s);}

#ifndef log_str
#define log_str(a) do { std::cerr << a << std::endl; } while (0)
#endif

#ifdef __cpp_if_constexpr
#define _IF(x) if constexpr (x)
#else
#define _IF(x) if (x)
#endif


// prints name=value or just raw value for literal strings
#define _v(var) (strlen(#var) ? \
		 (tracer::to_string(var) == #var)? \
		 std::string(#var).substr(1, std::string(#var).length() - 2) + " " \
		 : std::string(#var) + "=" + tracer::to_string(var) + " " : "")

#define trv(a) do { std::stringstream log; log << file_line() << _v(a); log_str(log.str()); } while (0)
#define _trace2(s, a, args...) do { s << _v(a); _IF (strlen(#args)) s << _v(args); } while (0)
#define _trace3(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace2(s, args); } while (0)
#define _trace4(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace3(s, args); } while (0)
#define _trace5(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace4(s, args); } while (0)
#define _trace6(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace5(s, args); } while (0)
#define _trace7(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace6(s, args); } while (0)
#define _trace8(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace7(s, args); } while (0)
#define _trace9(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace8(s, args); } while (0)
#define _traceA(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _trace9(s, args); } while (0)
#define _traceB(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _traceA(s, args); } while (0)
#define _traceC(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _traceB(s, args); } while (0)
#define _traceD(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _traceC(s, args); } while (0)
#define _traceE(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _traceD(s, args); } while (0)
#define _traceF(s, a, args...) do { s << _v(a); _IF (strlen(#args)) _traceE(s, args); } while (0)

/**  \endcond */

/**
  * \brief Universal tracing function
  *
  * Accepts from none to 16 artuments.
  * Prints file and line number, arguments names and values.
  */

#define trace(a, args...) \
do { std::stringstream log; \
	log << file_line() << _v(a); \
	_IF(strlen(#args)) \
		_traceF(log, args); \
	log_str(log.str()); \
} while (0)

static inline double duration(std::chrono::time_point<std::chrono::steady_clock> start)
{
	return std::chrono::duration<double> {std::chrono::steady_clock::now() - start}.count();
}

struct _duration {
	std::chrono::time_point<std::chrono::steady_clock> start;
	std::string file_line;
	explicit _duration(std::string fl) { file_line = fl; start = std::chrono::steady_clock::now(); }
	~_duration() {log_str(file_line + "duration = " + to_string(duration(start)));}
};

#define measure_block_duration() tracer::_duration _block_duration(file_line());
} // namespace tracer
