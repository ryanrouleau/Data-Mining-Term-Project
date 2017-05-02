#! /usr/bin/python3

#   Merge Processed data file with severities
#   Sort processed data first by year/month (month not rn) then lat then long
#   combine matching lat-long per year and average severities at each location
#
#   4 command line args <severity mapping file> <bin mapping file> <processed crimes file> <output file>
#   e.g. ./mergeSortAverage.py mapping.csv binning.csv street.csv ouput.csv
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
    with open(sys.argv[3], 'r') as fIn:
        fIn_matrix = list(csv.reader(fIn))

    # creating dictionary containing IUCR codes and severity.
    # the key is IUCR, value is corresponding severity
    sev_dict = {}
    with open(sys.argv[1], 'r') as fIn_sev_map:
        sev_map_matrix = list(csv.reader(fIn_sev_map))
        for row in sev_map_matrix:
            sev_dict[row[0]] = row[1]

    # creating dictionary containing IUCR codes and bin number
    # the key is IUCR, value is corresponding bin number
    bin_dict = {}
    with open(sys.argv[2], 'r') as fIn_sev_bin:
        bin_map_matrix = list(csv.reader(fIn_sev_bin))
        for row in bin_map_matrix:
            bin_dict[row[0]] = row[1]

    # storing and removing header column names from matrix so we don't sort them
    col_headers = fIn_matrix[0]
    fIn_matrix = fIn_matrix[1:] # removing column headers from array for sorting

    print("Merging files & casting year,month,lat,long to float...")
    for row in fIn_matrix:
        # by default, the merged severity is -1
        # then if there is a matching severity for the IUCR code of the row, we overwrite that severity
        severity = -1
        # row[2] is IUCR code in input file
        if row[2] in sev_dict:
            severity = sev_dict[row[2]]
        if row[2] in bin_dict:
            binNum = bin_dict[row[2]]
        # appending severity to fIn_matrix
        row.append(binNum)
        row.append(severity)
        # casting from strings to numerical vals for sorting and average computation
        row[0] = int(row[0]) # month
        row[1] = int(row[1]) # year
        row[3] = float(row[3]) # lat
        row[4] = float(row[4]) # long
        row[5] = int(row[5]) # arrest
        row[6] = int(row[6]) # bin
        row[7] = float(row[7]) # severity

    print("Sorting...")
    # e.g. to sort by 2nd col then 3rd then 1st: op.itemgetter(1,2,0)
    #fIn_matrix.sort(key = op.itemgetter(1,0,3,4)) # sort by year, then month, then lat, then long
    fIn_matrix.sort(key = op.itemgetter(5,6,1,0,3,4)) # sort by arrest/no arrest, bin number, year, month

    """
    Ok so everything below here is calculating the severity averages for blocks
    of same month, year, lat, and long and writing to output file.  It's a bit
    weird but it's the most efficient way of doing it -> it loops through entire
    file only once and uses O(1) space.

    CALL ME IF YOU'RE CONFUSED

    Vocab:
        block = consecutive rows with the same month,year,lat,long

    General Idea:
        We loop through each row in sorted fIn_matrix summing the severities for
        the current block.  When we hit a new block, we calculate the avg severity
        from the stored sum and number of rows in the previous block, create an array w/
        this avg severity and corresponding month,year,lat,long from the previous row
        for the block and write this row to the output file.

    Determining when we are in a new block when looping through rows in input file:
        The idea is that we have two arrays (prevRowVals and currRowVals):
            - prevRowVals holds the month,year,lat,long for the previous row in the loop
            - currRowVals holds the month,year,lat,long for the current row in the loop

        if prevRowVals does not have the same values as currRowVals, then the current
        row starts a new block.  The previous row was then the last row in the last block

    When prevRowVals == currRowVals:
        We add the current row's severity to blockSeveritySum
        We increment blockSeverityNum by 1

    When prevRowVals != currRowVals:
        We calculate the average severity from the sum of severities and number of
        rows in the block that just ended. (i.e. blockSeveritySum/blockSeverityNum)
        We append this to the prevRowVals array so now we have an array of form:
            newRow = [month, year, lat, long, avg severity for corresponding block]

    """

    print("Averaging & writing lat/long blocks to disk...")
    fOut = open(sys.argv[4], 'w')
    col_headers = col_headers[0:2] + col_headers[3:] # removing  IUCR col headers
    col_headers.append("Bin")
    col_headers.append("AvgSeverity") # appending column header for average severities
    # writing column headers to ouput file
    # csv.writer.writerow(i) converts array to csv format and writes to file
    csv.writer(fOut).writerow(col_headers)

    blockSeveritySum = 0.0 # sum of severities for block
    blockSeverityNum = 0 # number of severities added for each block

    # setting prevRowVals to be first row initially
    prevRowVals = [fIn_matrix[0][0], fIn_matrix[0][1], fIn_matrix[0][3], fIn_matrix[0][4], fIn_matrix[0][5], fIn_matrix[0][6]]

    for row in fIn_matrix:
        currRowVals = [row[0], row[1], row[3], row[4], row[5], row[6]]
        if row[7] != -1: # if there was a matching severity to ICUR in mapping file, otherwise we ignore it
            if prevRowVals == currRowVals: # we're in same block as previous iteration
                blockSeveritySum += row[7] # adding severity
                blockSeverityNum += 1 # incrementing number of severities added
            else: # we've hit a new block
                # calculating average severity for block just finished
                # newRow = [month, year, lat, long, avg severity for corresponding block]
                newRow = prevRowVals + [int(blockSeveritySum/blockSeverityNum)]
                # writing that row to output file
                csv.writer(fOut).writerow(newRow)

                # resetting blockSeveritySum/Num for new block
                blockSeveritySum = float(row[7])
                blockSeverityNum = 1
                # updating prevRowVals to be currRowVals for new block
                prevRowVals = currRowVals

    fOut.close()

    print("Just gotta collect some garbage...")

if __name__ == "__main__":
    main()
    print("Woo! Finished!")
