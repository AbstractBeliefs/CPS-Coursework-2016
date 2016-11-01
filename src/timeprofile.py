import sys
import subprocess
import re
import csv

# time -f "%E" ./main.out > /dev/null 2>time.txt
print "Executable:", sys.argv[-3]
print "CSV:", sys.argv[-2]
iterations = int(sys.argv[-1])

execution_lengths = []

print "Running", iterations, "iterations:",
for i in range(1, iterations+1):
    print i,
    sys.stdout.flush()

    p = subprocess.Popen(["time", "-f", "'%E'", "./"+sys.argv[-3]], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    p.wait()
    
    iteration_time = p.communicate()[-1]
    
    # "'0:05.10'\n"
    iteration_time = re.findall("(\d+):(\d+\.\d+)", iteration_time)
    if iteration_time:
        iteration_time = int(iteration_time[0][0])*60 + float(iteration_time[0][1])
        execution_lengths.append(iteration_time)
    else:
        print "panic!"

with open(sys.argv[-2], 'w') as csvfile:
    writer = csv.writer(csvfile)
    for idx, value in enumerate(execution_lengths):
        writer.writerow([idx, value])

    execution_lengths.sort()
    execution_lengths = execution_lengths[5:-5]     # trim outliers
    average_time = sum(execution_lengths)/len(execution_lengths)

    writer.writerow(["Average", average_time])
