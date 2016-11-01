CXX = g++
CXXFLAGS = -std=c++14 -ggdb -fopenmp -lpthread -fno-omit-frame-pointer -O3

SOURCES = $(wildcard *.cpp)
EXECUTABLES = $(SOURCES:.cpp=.out)

PERF_PROFILES = $(EXECUTABLES:.out=.perf)
CALLGRAPHS = $(PERF_PROFILES:.perf=.callgraph.png)

all: $(CALLGRAPHS)

clean:
	rm -f *.out
	rm -f *.png

%.out: %.cpp
	$(CXX) $< $(CXXFLAGS) -o $@

%.perf: %.out
	perf record -g --output $@ -- ./$< > /dev/null

%.callgraph.png: %.perf
	perf script -i $< | c++filt | gprof2dot -f perf | dot -Tpng -o $@

.PHONY: all profiling clean
