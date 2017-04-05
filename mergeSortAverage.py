#! /usr/bin/python3

#   Merge Processed data file with severities
#   Sort processed data first by year/month (month not rn) then lat then long
#   combine matching lat-long per year and average severities at each location
#
#   3 command line args <mapping file> <processed crimes file> <output file>
#   e.g. ./mergeSortAverage.py mapping.csv street.csv ouput.csv
#
#   The averaging of severities for lat/long blocks is messy but it works.
#   I'll clean it up and make it easier to understand later

import sys,csv
import operator as op

def main():
    print("Loading input CSV...")
    # creating huge 2d array from input csv file
    # warning: uses over 3GB of memory at peak (sorting) w/ input of ProcessedCrimes.csv
    # it's super difficult to do this without loading entire file in memory
    fIn_matrix = []
    with open(sys.argv[2], 'r') as fIn:
        fIn_matrix = list(csv.reader(fIn))

    # creating dictionary containing IUCR codes and severity
    map_dict = {}
    with open(sys.argv[1], 'r') as fIn_map:
        map_matrix = list(csv.reader(fIn_map))
        for row in map_matrix:
            map_dict[row[0]] = row[1]

    # storing and removing header column names from matrix so we don't sort them
    col_headers = fIn_matrix[0:1][0]
    col_headers.append("AvgSeverity")
    fIn_matrix = fIn_matrix[1:]

    print("Merging files & casting year,month,lat,long to float...")
    for row in fIn_matrix:
        severity = -1
        if row[2] in map_dict:
            severity = map_dict[row[2]]
        row.append(severity)
        row[0] = int(row[0])
        row[1] = int(row[1])
        row[3] = float(row[3])
        row[4] = float(row[4])

    print("Sorting...")
    fIn_matrix.sort(key = op.itemgetter(1,0,3,4)) # sort by year, then month, then lat, then long

    print("Averaging & writing lat/long blocks to disk...")
    fOut = open(sys.argv[3], 'w')
    col_headers = col_headers[0:2] + col_headers[3:] # removing  IUCR col headers
    csv.writer(fOut).writerow(col_headers)
    currSectionAvg = [0.0,0]
    prevRowVals = [fIn_matrix[0][0], fIn_matrix[0][1], fIn_matrix[0][3], fIn_matrix[0][4]]
    for row in fIn_matrix:
        currRowVals = [row[0], row[1], row[3], row[4]]
        if row[5] != -1: # if there was a matching severity to ICUR in mapping file, otherwise we ignore it
            if prevRowVals == currRowVals:
                currSectionAvg[0] += float(row[5])
                currSectionAvg[1] += 1
            else: # new section
                prevRowVals.append(int(currSectionAvg[0]/currSectionAvg[1]))
                csv.writer(fOut).writerow(prevRowVals)
                currSectionAvg[0] = float(row[5])
                currSectionAvg[1] = 1
                prevRowVals = currRowVals

    fOut.close()

    print("Just gotta collect some garbage...")

if __name__ == "__main__":
    main()
    print("Woo! Finished!")
