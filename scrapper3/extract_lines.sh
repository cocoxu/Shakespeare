mkdir -p plays3

for file in `ls $1`
do
    out_file=`echo $file | sed 's/.html//'`
    echo $out_file
    python scrapper_soupparser3.py $1/$file > plays3/merged/${out_file}_original.snt
done
