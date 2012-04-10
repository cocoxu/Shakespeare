mkdir -p plays/merged

for x in `cat plays_list`
do
    cat plays/$x-*_original.snt > plays/merged/${x}_original.snt
    cat plays/$x-*_modern.snt > plays/merged/${x}_modern.snt
done
