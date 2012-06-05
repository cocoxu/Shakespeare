mkdir -p align2

for file in `ls $1`
do
    out_file=`echo $file | sed 's/.htm//'`
    echo $out_file
    python scrapper_soupparser2.py $1/$file | grep '^\[O\]' | sed -e 's/^\[O\][^A-Za-z]*//' > align2/${out_file}_original.snt
    python scrapper_soupparser2.py $1/$file | grep '^\[M\]' | sed -e 's/^\[M\][^A-Za-z]*//' > align2/${out_file}_modern.snt
done
