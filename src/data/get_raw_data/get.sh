mins=$1
[ -z $mins ] && mins=1

echo "Minutes to query: $mins"

python3 pyget.py $mins

es2csv -u vinyas:9200 -i `cat index` -r -q @query.json -o ../../../data/raw/raw.csv
