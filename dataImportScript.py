#
#	Requires 2 command line arguments; source file name, destination file name.
#   Optional (3rd) command line arg: 'verbose' to print lines as being written to file
#	Will take in chicago crime dataset and produce scrubbed csv output for our analysis.
#

#input csv fields:
# ID,Case Number,Date,Block,IUCR,Primary Type,Description,Location Description,Arrest,Domestic,Beat,District,Ward,Community Area,FBI Code,X Coordinate,Y Coordinate,Year,Updated On,Latitude,Longitude,Location
#Output fields:
# YEAR++MONTH, PRIMARY TYPE, DESCRIPTION, LAT, LON


import csv, sys, re

def main():
  if len(sys.argv) == 3 or len(sys.argv) == 4:
    fIn = open(sys.argv[1],'r', newline='')	#object file f, input csv for read. need to iterate manually to manage memory usage. (textfile, byte-oriented datastream)
    fOut = open(sys.argv[2], 'w')
    firstRowFlag = True
    for row in csv.reader(iter(fIn.readline, '')):
      if not firstRowFlag:
        if(row[5] != "OTHER OFFENSE"):   ##filter out other offense
          lat = row[19]
          lon = row[20]
          try:
            x=abs(float(lat)-41.8)
            y=abs(float(lon)+87.7)
          except ValueError:
            x=1
            y=1
          if x+y < 1: ##verify in chicago
            description = row[7]
            ##commas messed with year category
            if(description=="SCHOOL, PUBLIC, GROUNDS" or description == "SCHOOL, PUBLIC, BUILDING"):
              description = "SCHOOL PUBLIC GROUNDS"
            elif(description=="SCHOOL, PRIVATE, GROUNDS" or description == "SCHOOL, PRIVATE, BUILDING"):
              description = "SCHOOL PRIVATE GROUNDS"

            newRow = row[2][0:2] + ','+row[17]+',' + row[4] + ',' + str(round(float(lat),2)) + ',' + str(round(float(lon),2)) + ',' +description
            if len(sys.argv) == 4 and sys.argv[3] == "verbose":
                print(newRow)
            print(newRow, file=fOut)
      else:
          newRow = "Month,Year,IUCR,Lat,Lon,Description"
          print(newRow,file=fOut)
          firstRowFlag = False
  else:
    print("please give args <filename> <inFile name> <outFile name> <(optional)'verbose")

if __name__ == "__main__":
  main();
