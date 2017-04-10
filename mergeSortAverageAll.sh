#!/bin/bash

printf "~~~ Residences ~~~\n"
python3 mergeSortAverage.py mapping.csv binning.csv residence.csv residenceAvg.csv
printf "\n~~~ Alleys ~~~\n"
python3 mergeSortAverage.py mapping.csv binning.csv alley.csv alleyAvg.csv
printf "\n~~~ Apartments ~~~\n"
python3 mergeSortAverage.py mapping.csv binning.csv apartment.csv apartmentAvg.csv
printf "\n~~~ Sidewalks ~~~\n"
python3 mergeSortAverage.py mapping.csv binning.csv sidewalk.csv sidewalkAvg.csv
printf "\n~~~ Streets ~~~\n"
python3 mergeSortAverage.py mapping.csv binning.csv sidewalk.csv sidewalkAvg.csv
