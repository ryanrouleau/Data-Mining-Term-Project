#
#	Requires 2 command line arguments; source file name, destination file name.
#	Will take in chicago crime dataset and produce scrubbed csv output for our analysis.
#

#input csv fields:
# ID,Case Number,Date,Block,IUCR,Primary Type,Description,Location Description,Arrest,Domestic,Beat,District,Ward,Community Area,FBI Code,X Coordinate,Y Coordinate,Year,Updated On,Latitude,Longitude,Location
#Output fields:
# YEAR++MONTH, PRIMARY TYPE, LOCATION

import csv, sys, re

def main():
	fIn = open(sys.argv[1],'r', newline='')	#object file f, input csv for read. need to iterate manually to manage memory usage. (textfile, byte-oriented datastream)
	fOut = open(sys.argv[2], 'w')
	for row in csv.reader(iter(fIn.readline, '')):
		newRow = row[2][8:10] + row[2][0:2] + ',' + row[5] + ',' + row[21]
		print(newRow, file=fOut)

if __name__ == "__main__":
	main();