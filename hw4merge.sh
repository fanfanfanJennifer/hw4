
#!/bin/bash

sort -r -m *.csv > all.csv
echo "distance,spectrumID,i" > hw4best100.csv
uniq all.csv > cleaned.csv

sort -r -n -t, -k1 cleaned.csv | head -100 >> hw4best100.csv

