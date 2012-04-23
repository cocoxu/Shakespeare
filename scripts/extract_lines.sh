mkdir -p data/align/$1

for file in `ls $1`
do
    out_file=`echo $file | sed 's/_/-/g' | sed 's/.html//'`
    echo $out_file
    python python/scrapper_soupparser.py $1/$file | grep '^\[O\]' | sed -e 's/^\[O\][^A-Za-z]*//' > data/align/$1/${out_file}_original.snt
    python python/scrapper_soupparser.py $1/$file | grep '^\[M\]' | sed -e 's/^\[M\][^A-Za-z]*//' > data/align/$1/${out_file}_modern.snt
done
