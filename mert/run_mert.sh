#!/bin/bash

~/mt/mosesdecoder/scripts/training/mert-moses.pl --mertdir=~/mt/mosesdecoder/mert ~/Shakespere/mert/ascii.tokenized.modern ~/Shakespere/mert/ascii.tokenized.original ~/mt/mosesdecoder/moses-cmd/src/moses $1
