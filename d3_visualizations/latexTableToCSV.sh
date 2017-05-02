#!/bin/bash

# takes files name as first command line arg in format of latex table, and changes it to cleaned CSV

echo $1
sed -i -e 's/&/,/g' $1
sed -i -e 's/ //g' $1
sed -i -e 's/hline//g' $1
sed -i -e 's/\\//g' $1
rm $1-e
