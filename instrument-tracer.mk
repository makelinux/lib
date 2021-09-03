CXXFLAGS+=-rdynamic -finstrument-functions -finstrument-functions-exclude-file-list=/usr/include/,instrument-tracer.cc
instrument-tracer.o: CXXFLAGS+=-std=c++17
LDLIBS+=-ldl
