CXXFLAGS+=-rdynamic

check: stack_trace_check tracer-hpp-test ctracer-check
	./stack_trace_check
	./tracer-hpp-test

stack_trace_check: stack_trace.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build

obj-m=ctracer-test.o

ctracer-check:
	$(MAKE) -B ctracer-test && ./ctracer-test
	make -B -C ${KERNELDIR} modules M=$$PWD && \
		  sudo insmod ./ctracer-test.ko && sudo rmmod ctracer-test && dmesg;
	$(MAKE) -B ctracer-testpp && ./ctracer-testpp

clean:
	make -B -C ${KERNELDIR} clean M=$$PWD
	rm -f stack_trace_check ctracer-test ctracer-testpp tracer-hpp-test
