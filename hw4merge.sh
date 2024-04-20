#!/bin/bash                                                                                       

# sort -m *.csv > all.csv

#cat *.csv | tail -n +2 | sort -m > all.csv

# tail -n +2 *.csv | sort --batch-size=1 -m > all.csv

# 创建一个临时文件用于存储合并后的内容
temp_file=$(mktemp)

# 遍历所有的csv文件
for file in *.csv; do
    # 跳过第一行，从第二行开始排序并追加到临时文件中
    tail -n +2 "$file" | sort -m  >> "$temp_file"
done

# 将临时文件中的内容重定向到all.csv
cat "$temp_file" > all.csv

cat all.csv | sort -t , -k2 -n | head -100 > hw4best100.csv

rm "$temp_file"
