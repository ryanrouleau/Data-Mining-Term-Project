## Crime in Chicago 2001 - 2017
### Kylee Budai and Ryan Rouleau

This project looks at crime in Chicago both spatially and temporally.  It begins by mapping crimes to severity levels and then models average severity and counts of crimes at different locations as a function of time.  After making decent predictions, it generates heat maps that predict the general trends across the Chicago area.  These predictions account for monthly variablility and attempt to predict the counts of crime and average severity of crime (in neighborhoods around points) for each month in the next year (2017).  Since there is data available for January, February, and March of this year, we were able to test those predictions against truth.

#### Questions this project aimed to answer
1. How much future crime will there be in Chicago ?
2. Where is the most crime in Chicago ?
3. How do the severities of crime in Chicago change over time ?
4. How do severities of crimes spatially correlate ?
5. Where will severe crimes occur in the future in Chicago ?

#### Application of results
Being able to predict where more severe crimes occur in the future will allow law enforcment to more efficiently allocate theire limited enforcement resources.  Overall, hopefully the results can be further studied to come up with solutions to the problem of high crime in the chicago area.

#### To run analysis
* Download the dataset and lists of IUCR codes from the link below
* Preprocess data: `python3 dataImportScriptFull.py DATASET.csv ProcessedCrimes.csv`
* Generate severity mapping and binning by running the command with MAPPINGFILE.csv as severities.csv and bins.csv: `python3 sentimentMappingScript.py IUCR_Codes.csv MAPPINGFILE.csv OUTPUTMAPPINGFILE.csv`
* use `dataMerging.R` file to merge larger dataframe with severities and binnings and separate dataframe into arrest and no arrest data.  This file also generates matrices that track counts and average severities of crime at a different number of locations.  Read comments while running code
* Use `NaturalSplines.R` and `LinearRegression.R` to generate spline and linear fits respectively.  See instructions at top of each file for what you need to have generated prior to running
* Use `quiltPlot.R` to generate severity heat maps

#### Application
The results from this project can be used in many different scenarios varying from a better allocation of police resources to residents looking to stay safe in the city.  The predictive maps are interesting in that they can extrapolate known data and accurately predict severity trends.  

##### https://drive.google.com/open?id=0B2JmhxMUj9HfZlBRS19UNHFUZEU (Project Video)
##### https://www.sharelatex.com/project/58b761e1806c810d675b44d3 (Project Writeup)

