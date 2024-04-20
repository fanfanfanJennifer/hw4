#!/bin/bash                                                                                       

# sort -m *.csv > output.csv

#cat *.csv | tail -n +2 | sort -m > output.csv

# tail -n +2 *.csv | sort --batch-size=1 -m > all.csv

temp_file=$(mktemp)

for file in *.csv; do
    tail -n +2 "$file" | sort -m  >> "$temp_file"
done

cat "$temp_file" > output.csv

cat outpur.csv | sort -t , -k2 -n | head -100 > hw4best100.csv

rm "$temp_file"
