mkdir -p merged2

for x in `cat plays_list.txt`
do
    cat align2/$x-*_original.snt > merged2/${x}_original.snt
    cat align2/$x-*_modern.snt > merged2/${x}_modern.snt
done
