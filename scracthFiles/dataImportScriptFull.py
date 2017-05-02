#
#	Requires 1 command line arguments; source file name
# Outputs 5 files depending on description.  Files titled after description.
# Should significantly reduce runtime of sorting/merging algorithm.
#   Optional (3rd) command line arg: 'verbose' to print lines as being written to file
#	Will take in chicago crime dataset and produce scrubbed csv output for our analysis.
#

#input csv fields:
# ID,Case Number,Date,Block,IUCR,Primary Type,Description,Location Description,Arrest,Domestic,Beat,District,Ward,Community Area,FBI Code,X Coordinate,Y Coordinate,Year,Updated On,Latitude,Longitude,Location
#Output fields:
# YEAR++MONTH, PRIMARY TYPE, DESCRIPTION, LAT, LON

# Filter out all location descriptions besides STREET, SIDEWALK, ALLEY, APARTMENT, RESIDENCE

import csv, sys, re

def main():
  if len(sys.argv) == 2 or len(sys.argv) == 3:
    fIn = open(sys.argv[1],'r', newline='')	#object file f, input csv for read. need to iterate manually to manage memory usage. (textfile, byte-oriented datastream)
    #fOut_a = open("./data/ArrestCrimes.csv", 'w')
    #fOut_na = open("./data/NoArrestCrimes.csv",'w')
    fOut = open(sys.argv[2],'w')
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
            newRow = row[2][0:2] + ','+row[17]+',' + row[4] + ',' + str(round(float(lat),3)) + ',' + str(round(float(lon),3))
            if(row[8]=="true"):  ##SEPARATE BY ARREST/NO ARREST
            #  print(newRow,file=fOut_a)
              arrest="1"
            else:
              arrest ="0"
            if(row[13]=="NA"):
              print("NA")
            #  print(newRow,file=fOut_na)
            newRow = newRow +  ',' + arrest
            print(newRow,file=fOut) ## WHOLE DF
      else:
          print(row[8])
          newRow = "Month,Year,IUCR,Lat,Lon"
          #print(newRow,file=fOut_a)
          #print(newRow,file=fOut_na)
          newRow = newRow + ",Arrest"
          print(newRow,file=fOut)
          firstRowFlag = False
  else:
    print("please give args <filename> <inFile name> <outFile name> <(optional)'verbose")

if __name__ == "__main__":
  main();
