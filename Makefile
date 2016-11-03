CXX = g++
CXXFLAGS = -std=c++14 -ggdb -fopenmp -lpthread -fno-omit-frame-pointer -O3

SOURCES = $(wildcard src/*.cpp)
EXECUTABLES = $(SOURCES:.cpp=.out)

TIME_PROFILES = $(EXECUTABLES:.out=.csv)
PERF_PROFILES = $(EXECUTABLES:.out=.perf)
CALLGRAPHS = $(PERF_PROFILES:.perf=.callgraph.png)
FLAMEGRAPHS = $(PERF_PROFILES:.perf=.flamegraph.png)

REPORT = report/report.pdf
REPORT_SOURCE = report/report.tex report/report.bib
REPORT_IMAGES = src/main.flamegraph.png src/main.callgraph.png

all: profiling
profiling: $(CALLGRAPHS) $(FLAMEGRAPHS) $(TIME_PROFILES)

clean:
	rm -f src/*.out
	rm -f src/*.png
	rm -f src/*.csv
	rm -f src/*.svg
	rm -f src/*.perf
	rm -f report/*.log
	rm -f report/*.aux
	rm -f report/*.out
	rm -f report/*.toc
	rm -f report/*.pdf
	rm -f report/*.bbl
	rm -f report/*.blg

%.out: %.cpp
	$(CXX) $< $(CXXFLAGS) -o $@

%.perf: %.out
	perf record -g --output $@ -- ./$< > /dev/null

%.csv: %.out
	python src/timeprofile.py $< $@ 100

%.callgraph.png: %.perf
	perf script -i $< | c++filt | gprof2dot -f perf | dot -Tpng -o $@

%.flamegraph.png: %.perf
	perf script -i $< | stackcollapse-perf.pl | flamegraph.pl --cp --title=$< | convert svg:- $@

REPORT: $(REPORT_SOURCE) $(REPORT_IMAGES)
	pdflatex --output-directory=report $<
	export BIBINPUTS=report
	bibtex $(basename $<)
	pdflatex --output-directory=report $<
	pdflatex --output-directory=report $<

.PHONY: all profiling clean
.PRECIOUS: %.perf %.csv
