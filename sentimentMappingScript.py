#! /usr/bin/python3


#     PRELIMINARY SENTIMENT MAPPING
#     Requires input of IUCR code file and mapping file (args 1 and 2 respectively) and output file
#     Outputs file with IUCR codes and mappings combined.

#### DOES NOT ACCOUNT FOR CRIMES NOT IN SEVERITIES FILE ######
#### COULD BE MORE EFFICIENT BY NOT LOOPING THROUGH SEVERITY FILE AT EACH RUN #####
#### NEEDS TO END LOOP AND ASSIGN RANDOM VALUE ON NON-EXISTANT CRIMES ####
#### NEED TO MESS WITH SEVERITIES AND IUCR CODES TO FORCE MATCHING ####
#### SOMEONE NEEDS TO DO THIS SO THAT I CAN START WITH STATISTICS ####

import csv,sys,re

def main():
  if len(sys.argv) == 4:
    fIn_code = open(sys.argv[1],'r', newline='')
    fOut = open(sys.argv[3], 'w')
    firstRowFlag = True
    for row in csv.reader(iter(fIn_code.readline, '')):  ##read lines in code file
      if not firstRowFlag:
        fIn_map = open(sys.argv[2],'r',newline='')
        for element in csv.reader(iter(fIn_map.readline, '')):
          print(element[0])
          if(element[0] == row[1]):
            print("MATCH")
            val = element[1]
        fIn_map.close()
        newRow = row[0] + ','+val
        print(newRow, file=fOut)
      else:
        firstRowFlag = False  
  else:
    print("please give args <filename> <inFile name> <inFile name > <outFile name>")



if __name__=="__main__":
  main();
