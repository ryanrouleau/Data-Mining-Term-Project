## Crime in Chicago 2001 - 2017
#Kylee Budai and Ryan Rouleau

This project looks at crime in Chicago both spatially and temporally.  It begins by mapping crimes to severity levels and then models average severity and counts of crimes in different locations as a function of time.  It accounts for monthly variablility and attempts to predict the counts of crime and average severity of crime (in neighborhoods around points) for each month in the next year (2017).  Since there is data available for January, February, and March of this year, we were able to test those predictions against truth.

The question this project aims to answer is what the general trends of counts of crimes and severity levels of crimes have been.

Hopefully the results can be further studied to come up with solutions to the problem of high crime in the chicago area.

####To run analysis
*Download the dataset and lists of IUCR codes from the link below
*Preprocess data: `python3 dataImportScriptFull.py DATASET.csv ProcessedCrimes.csv`
*Generate severity mapping and binning by running the command with MAPPINGFILE.csv as severities.csv and bins.csv: `python3 IUCR_Codes.csv MAPPINGFILE.csv OUTPUTMAPPINGFILE.csv`
*use `dataMerging.R` file to merge larger dataframe with severities and binnings and separate dataframe into arrest and no arrest data.  This file also generates matrices that track counts and average severities of crime at a different number of locations.  Read comments while running code

#### Dataset Links
##### https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2/data (main)
##### http://www.statcan.gc.ca/pub/85-004-x/2009001/t001-eng.htm#T001FN1 (severity index)
#### Project Part Links
##### https://www.sharelatex.com/project/58acbc7628f1491b754c2185  (Project Proposal Presentation)
##### https://www.sharelatex.com/project/58b761e1806c810d675b44d3 (Project Writeup)
