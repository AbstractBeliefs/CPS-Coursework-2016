CXX = g++
CXXFLAGS = -std=c++14 -ggdb -fopenmp -lpthread -fno-omit-frame-pointer -O3

SOURCES = $(wildcard *.cpp)
EXECUTABLES = $(SOURCES:.cpp=.out)

TIME_PROFILES = $(EXECUTABLES:.out=.csv)
PERF_PROFILES = $(EXECUTABLES:.out=.perf)
CALLGRAPHS = $(PERF_PROFILES:.perf=.callgraph.png)

all: profiling
profiling: $(CALLGRAPHS) $(TIME_PROFILES)

clean:
	rm -f *.out
	rm -f *.png
	rm -f *.csv

%.out: %.cpp
	$(CXX) $< $(CXXFLAGS) -o $@

%.perf: %.out
	perf record -g --output $@ -- ./$< > /dev/null

%.csv: %.out
	python timeprofile.py $< $@ 15

%.callgraph.png: %.perf
	perf script -i $< | c++filt | gprof2dot -f perf | dot -Tpng -o $@

.PHONY: all profiling clean
