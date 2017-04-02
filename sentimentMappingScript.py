#! /usr/bin/python3

#     PRELIMINARY SENTIMENT MAPPING
#     Requires input of IUCR code file, mapping file, ouyput file (args 1, 2, and 3 respectively)
#     Optional 4th arg ("verbose") if user wants each line being written to the file also printed to console
#     Outputs file with IUCR codes and mappings combined.

#### DOES NOT ACCOUNT FOR CRIMES NOT IN SEVERITIES FILE ###### <- now assigns random severity (0-1000)
##I think it makes more sense to remove the crime than assign a random severity...data processing, am I right?
#### COULD BE MORE EFFICIENT BY NOT LOOPING THROUGH SEVERITY FILE AT EACH RUN ##### <- done
#### NEEDS TO END LOOP AND ASSIGN RANDOM VALUE ON NON-EXISTENT CRIMES #### <- done
  ## Random severities generated don't match severity frequqency in data
#### NEED TO MESS WITH SEVERITIES AND IUCR CODES TO FORCE MATCHING ####
#### SOMEONE NEEDS TO DO THIS SO THAT I CAN START WITH STATISTICS ####

import csv,sys,re,random

def main():
  if len(sys.argv) == 4 or len(sys.argv) == 5:
    fIn_code = open(sys.argv[1],'r', newline='')
    fIn_map = open(sys.argv[2],'r',newline='')
    fOut = open(sys.argv[3], 'w')

    # converting csv's to 2d arrays
    fIn_code_matrix = list(csv.reader(iter(fIn_code.readline, '')))
    fIn_map_matrix = list(csv.reader(iter(fIn_map.readline, '')))

    for row in fIn_code_matrix[1:]:  # read lines in IUCR_Codes.csv, skipping first row w/ column titles
      val = getMatchingSeverity(fIn_map_matrix, row)
      if val: # if match is found
        newRow = row[0] + ',' + val
        print(newRow, file=fOut)
      if len(sys.argv) == 5 and sys.argv[4] == "verbose":
        print(newRow)

    # close ur files kylee, geez
    fIn_map.close()
    fIn_code.close()
    fOut.close()
  else:
    print("please give args <filename> <inFile name> <inFile name> <outFile name> <(optional)'verbose'>")

# matching logic now in a function so we can stop searching elegantly once match is found
def getMatchingSeverity(map_matrix, row):
  for element in map_matrix: # read lines in severities.csv
    if element[0] == row[1]:
      return element[1]
  return 0 # if not found in severities.csv, dont add crime to file


if __name__ == "__main__":
  main();
