#!/usr/bin/python

import sys

from scipy.stats.stats import pearsonr

from PINC_BLEU import *
from style_metric import *

_16plays36_bleu_list = []
_16plays36_pinc_list = []
_16plays36_csim_list = []
_16plays36_cmaxent_list = []
phrase_bleu_list = []
phrase_pinc_list = []
phrase_csim_list = []
phrase_cmaxent_list = []

_16plays36_semantic_list = []
_16plays36_dissim_list = []
_16plays36_style_list = []
phrase_semantic_list = []
phrase_dissim_list = []
phrase_style_list = []

sm = StyleMetric('models/Translators/16plays_36LM/data/train_plays_lowercased.modern', 'models/Translators/16plays_36LM/data/train_plays_lowercased.original')

i = 0
for line in open(sys.argv[1]):
    line = line.strip()
    if len(line.split('\t')) < 12 or i == 0:
        i += 1
        continue
    (original, modern, _16plays36, phrase, _16plays36_semantic, _16plays36_dissim, _16plays36_style, _16plays36_overall, phrase_semantic, phrase_dissim, phrase_style, phrase_overall) = line.split('\t')
    _16plays36_semantic_list.append(float(_16plays36_semantic))
    _16plays36_dissim_list.append(float(_16plays36_dissim))
    _16plays36_style_list.append(float(_16plays36_style))
    phrase_semantic_list.append(float(phrase_semantic))
    phrase_dissim_list.append(float(phrase_dissim))
    phrase_style_list.append(float(phrase_style))
    
    print "\t".join([str(x) for x in [line, simple_bleu(_16plays36, original), pinc(_16plays36, modern), sm.ScoreSim(_16plays36), sm.ScoreMaxEnt(_16plays36), simple_bleu(phrase, original), pinc(phrase, modern), sm.ScoreSim(phrase), sm.ScoreMaxEnt(phrase)]])
    _16plays36_bleu_list.append(simple_bleu(_16plays36, original))
    _16plays36_pinc_list.append(pinc(_16plays36, modern))
    _16plays36_csim_list.append(sm.ScoreSim(_16plays36))
    _16plays36_cmaxent_list.append(sm.ScoreMaxEnt(_16plays36))
    phrase_bleu_list.append(simple_bleu(phrase, original))
    phrase_pinc_list.append(pinc(phrase, modern))
    phrase_csim_list.append(sm.ScoreSim(phrase))
    phrase_cmaxent_list.append(sm.ScoreMaxEnt(phrase))
    i += 1

print "16plays36:"
print "sematnic-bleu\t" + str(pearsonr(_16plays36_semantic_list, _16plays36_bleu_list))
print "dissim-pinc\t" + str(pearsonr(_16plays36_dissim_list, _16plays36_pinc_list))
print "style-bleu\t" + str(pearsonr(_16plays36_style_list, _16plays36_bleu_list))
print "style-pinc\t" + str(pearsonr(_16plays36_style_list, _16plays36_pinc_list))
print "style-csim\t" + str(pearsonr(_16plays36_style_list, _16plays36_csim_list))
print "style-cmaxent\t" + str(pearsonr(_16plays36_style_list, _16plays36_cmaxent_list))

print "phrase2:"
print "semantic-bleu\t" + str(pearsonr(phrase_semantic_list, phrase_bleu_list))
print "dissim-pinc\t" + str(pearsonr(phrase_dissim_list, phrase_pinc_list))
print "style-bleu\t" + str(pearsonr(phrase_style_list, phrase_bleu_list))
print "style-pinc\t" + str(pearsonr(phrase_style_list, phrase_pinc_list))
print "style-csim\t" + str(pearsonr(phrase_style_list, phrase_csim_list))
print "style-cmaxent\t" + str(pearsonr(phrase_style_list, phrase_cmaxent_list))

print "both:"
print "sematnic-bleu\t" + str(pearsonr(_16plays36_semantic_list + phrase_semantic_list, _16plays36_bleu_list + phrase_bleu_list))
print "dissim-pinc\t" + str(pearsonr(_16plays36_dissim_list + phrase_dissim_list, _16plays36_pinc_list + phrase_pinc_list))
print "style-bleu\t" + str(pearsonr(_16plays36_style_list + phrase_style_list, _16plays36_bleu_list + phrase_bleu_list))
print "style-pinc\t" + str(pearsonr(_16plays36_style_list + phrase_style_list, _16plays36_pinc_list + phrase_pinc_list))
print "style-csim\t" + str(pearsonr(_16plays36_style_list + phrase_style_list, _16plays36_csim_list + phrase_csim_list))
print "style-cmaxent\t" + str(pearsonr(_16plays36_style_list + phrase_style_list, _16plays36_cmaxent_list + phrase_cmaxent_list))
