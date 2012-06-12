#!/bin/bash

for m in 16and7plays_16LM 16and7plays_36LM 16plays_36LM
do
    cat ascii.romeojuliet_tokenized_lower_modern.1 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Translators/${m}/model/alan_moses.ini > ${m}.1 2> err.out
    cat ascii.romeojuliet_tokenized_lower_modern.1 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Translators/${m}/model/alan_moses_mert.ini > ${m}_mert.1 2> err.out
    cat ascii.romeojuliet_tokenized_lower_modern.2 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Translators/${m}/model/alan_moses.ini > ${m}.2 2> err.out
    cat ascii.romeojuliet_tokenized_lower_modern.2 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Translators/${m}/model/alan_moses_mert.ini > ${m}_mert.2 2> err.out

    echo ${m}.1
    ~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < ${m}.1
    echo ${m}_mert.1
    ~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < ${m}_mert.1
    echo ${m}.2
    ~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < ${m}.2
    echo ${m}_mert.2
    ~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < ${m}_mert.2
done

cat ascii.romeojuliet_tokenized_lower_modern.1 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword1/alan_moses.ini > singleword1.1 2> /dev/null
cat ascii.romeojuliet_tokenized_lower_modern.2 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword1/alan_moses.ini > singleword1.2 2> /dev/null

cat ascii.romeojuliet_tokenized_lower_modern.1 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword2/alan_moses1.ini > singleword2_1.1 2> /dev/null
cat ascii.romeojuliet_tokenized_lower_modern.2 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword2/alan_moses1.ini > singleword2_1.2 2> /dev/null

cat ascii.romeojuliet_tokenized_lower_modern.1 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword2/alan_moses2.ini > singleword2_2.1 2> /dev/null
cat ascii.romeojuliet_tokenized_lower_modern.2 | ~/mt/mosesdecoder/moses-cmd/src/moses -f ~/Shakespere/models/Lexicons/singleword2/alan_moses2.ini > singleword2_2.2 2> /dev/null

echo singleword1.1
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword1.1
echo singleword1.2
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword1.2

echo singleword2_1.1
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword2_1.1
echo singleword2_2.2
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword2_1.2

echo singleword2_1.1
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword2_2.1
echo singleword2_2.2
~/mt/mosesdecoder/scripts/generic/multi-bleu.perl ascii.romeojuliet_tokenized_lower_original < singleword2_2.2
