CXXFLAGS+=-rdynamic

stack_trace_check: stack_trace.o

check: stack_trace_check tracer-hpp-test
	./stack_trace_check
	./tracer-hpp-test
