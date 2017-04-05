#! /usr/bin/python3

#   Merge Processed data file with severities
#   Sort processed data first by year/month (month not rn) then lat then long
#   combine matching lat-long per year and average severities at each location

import sys,csv
import operator as op

def main():
    print("Loading input CSV...")
    # creating huge 2d array from input csv file
    # warning: uses over 3GB of memory at peak (sorting) w/ input of ProcessedCrimes.csv
    # it's super difficult to do this without loading entire file in memory
    fIn_matrix = []
    with open(sys.argv[1], 'r') as fIn:
        fIn_matrix = list(csv.reader(fIn))

    # storing and removing header column names from matrix so we don't sort them
    col_headers = fIn_matrix[0:1]
    fIn_matrix = fIn_matrix[1:]

    print("Casting year,lat,long to float...")
    for row in fIn_matrix:
        row[1] = int(row[1])
        row[3] = float(row[3])
        row[4] = float(row[4])

    print("Sorting...")
    fIn_matrix.sort(key = op.itemgetter(1,3,4)) # sort by year, then lat, then long

    print("Writing to disk...")
    with open(sys.argv[2], 'w') as fOut:
        writer = csv.writer(fOut)
        writer.writerow(col_headers[0])
        writer.writerows(fIn_matrix)

    print("Just gotta collect some garbage...")

if __name__ == "__main__":
    main()
    print("Woo! Finished!")
