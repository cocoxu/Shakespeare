#!/usr/bin/python

import sys

from scipy.stats.stats import pearsonr

from PINC_BLEU import *
from style_metric import *
from lm_score import *

def corelation_human_human (filename1, filename2):

    _16plays36_semantic_list_1 = []
    _16plays36_dissim_list_1 = []
    _16plays36_style_list_1 = []
    _16plays36_overall_list_1 = []
    phrase_semantic_list_1 = []
    phrase_dissim_list_1 = []
    phrase_style_list_1 = []
    phrase_overall_list_1 = []
    video_semantic_list_1 = []
    video_dissim_list_1 = []
    video_style_list_1 = []
    video_overall_list_1 = []
    
    
    _16plays36_semantic_list_2 = []
    _16plays36_dissim_list_2 = []
    _16plays36_style_list_2 = []
    _16plays36_overall_list_2 = []
    phrase_semantic_list_2 = []
    phrase_dissim_list_2 = []
    phrase_style_list_2 = []
    phrase_overall_list_2 = []
    video_semantic_list_2 = []
    video_dissim_list_2 = []
    video_style_list_2 = []
    video_overall_list_2 = []

    i = 0
    for line in open(filename1):
        line = line.strip()
        if len(line.split('\t')) < 12 or i == 0:
            i += 1
            continue
        (original, modern, _16plays36, phrase, video, _16plays36_semantic, _16plays36_dissim, _16plays36_style, _16plays36_overall, phrase_semantic, phrase_dissim, phrase_style, phrase_overall, video_semantic, video_dissim, video_style, video_overall) = line.split('\t')
        _16plays36_semantic_list_1.append(float(_16plays36_semantic))
        _16plays36_dissim_list_1.append(float(_16plays36_dissim))
        _16plays36_style_list_1.append(float(_16plays36_style))
        _16plays36_overall_list_1.append(float(_16plays36_overall))
        phrase_semantic_list_1.append(float(phrase_semantic))
        phrase_dissim_list_1.append(float(phrase_dissim))
        phrase_style_list_1.append(float(phrase_style))
        phrase_overall_list_1.append(float(phrase_overall))
        video_semantic_list_1.append(float(video_semantic))
        video_dissim_list_1.append(float(video_dissim))
        video_style_list_1.append(float(video_style))
        video_overall_list_1.append(float(video_overall))
        i += 1

    i = 0
    for line in open(filename2):
        line = line.strip()
        if len(line.split('\t')) < 12 or i == 0:
            i += 1
            continue
        (original, modern, _16plays36, phrase, video, _16plays36_semantic, _16plays36_dissim, _16plays36_style, _16plays36_overall, phrase_semantic, phrase_dissim, phrase_style, phrase_overall, video_semantic, video_dissim, video_style, video_overall) = line.split('\t')
        _16plays36_semantic_list_2.append(float(_16plays36_semantic))
        _16plays36_dissim_list_2.append(float(_16plays36_dissim))
        _16plays36_style_list_2.append(float(_16plays36_style))
        _16plays36_overall_list_2.append(float(_16plays36_overall))
        phrase_semantic_list_2.append(float(phrase_semantic))
        phrase_dissim_list_2.append(float(phrase_dissim))
        phrase_style_list_2.append(float(phrase_style))
        phrase_overall_list_2.append(float(phrase_overall))
        video_semantic_list_2.append(float(video_semantic))
        video_dissim_list_2.append(float(video_dissim))
        video_style_list_2.append(float(video_style))
        video_overall_list_2.append(float(video_overall))
        i += 1       
        
    print "16plays36:"
    print "sematnic\t" + str(pearsonr(_16plays36_semantic_list_1, _16plays36_semantic_list_2))
    print "dissim\t" + str(pearsonr(_16plays36_dissim_list_1, _16plays36_dissim_list_2))
    print "style\t" + str(pearsonr(_16plays36_style_list_1, _16plays36_style_list_2))
    print "overall\t" + str(pearsonr(_16plays36_overall_list_1, _16plays36_overall_list_2))
           
    print "phrase2:"
    print "semantic\t" + str(pearsonr(phrase_semantic_list_1, phrase_semantic_list_2))
    print "dissim\t" + str(pearsonr(phrase_dissim_list_1, phrase_dissim_list_2))
    print "style\t" + str(pearsonr(phrase_style_list_1, phrase_style_list_2))
    print "overall\t" + str(pearsonr(phrase_overall_list_1, phrase_overall_list_2))

    print "video2:"
    print "semantic\t" + str(pearsonr(video_semantic_list_1, video_semantic_list_2))
    print "dissim\t" + str(pearsonr(video_dissim_list_1, video_dissim_list_2))
    print "style\t" + str(pearsonr(video_style_list_1, video_style_list_2))
    print "overall\t" + str(pearsonr(video_overall_list_1, video_overall_list_2))

    print "all:"
    print "sematnic\t" + str(pearsonr(_16plays36_semantic_list_1 + phrase_semantic_list_1 + video_semantic_list_1, _16plays36_semantic_list_2 + phrase_semantic_list_2 + video_semantic_list_2))
    print "dissim\t" + str(pearsonr(_16plays36_dissim_list_1 + phrase_dissim_list_1 + video_dissim_list_1, _16plays36_dissim_list_2 + phrase_dissim_list_2 + video_dissim_list_2))
    print "style\t" + str(pearsonr(_16plays36_style_list_1 + phrase_style_list_1 + video_style_list_1, _16plays36_style_list_2 + phrase_style_list_2 + video_style_list_2))
    print "overall\t" + str(pearsonr(_16plays36_overall_list_1 + phrase_overall_list_1 + video_overall_list_1, _16plays36_overall_list_2 + phrase_overall_list_2 + video_overall_list_2))
         
    return

	


def corelation_auto_human (filename):

    _16plays36_bleu_list = []
    _16plays36_pinc_list = []
    _16plays36_csim_list = []
    _16plays36_cmaxent_list = []
    _16plays36_lmdiff_list = []
    _16plays36_lmdiff2_list = []
    _16plays36_lmdiff3_list = []
    phrase_bleu_list = []
    phrase_pinc_list = []
    phrase_csim_list = []
    phrase_cmaxent_list = []
    phrase_lmdiff_list = []
    phrase_lmdiff2_list = []
    phrase_lmdiff3_list = []
    video_bleu_list = []
    video_pinc_list = []
    video_csim_list = []
    video_cmaxent_list = []
    video_lmdiff_list = []
    video_lmdiff2_list = []
    video_lmdiff3_list = []
    
    _16plays36_semantic_list = []
    _16plays36_dissim_list = []
    _16plays36_style_list = []
    phrase_semantic_list = []
    phrase_dissim_list = []
    phrase_style_list = []
    video_semantic_list = []
    video_dissim_list = []
    video_style_list = []

    sm = StyleMetric('../models/Translators/16plays_36LM/data/train_plays_lowercased.modern', '../models/Translators/16plays_36LM/data/train_plays_lowercased.original')


    i = 0
    for line in open(filename):
        line = line.strip()
        if len(line.split('\t')) < 12 or i == 0:
            i += 1
            continue
        (original, modern, _16plays36, phrase, video, _16plays36_semantic, _16plays36_dissim, _16plays36_style, _16plays36_overall, phrase_semantic, phrase_dissim, phrase_style, phrase_overall, video_semantic, video_dissim, video_style, video_overall) = line.split('\t')
        _16plays36_semantic_list.append(float(_16plays36_semantic))
        _16plays36_dissim_list.append(float(_16plays36_dissim))
        _16plays36_style_list.append(float(_16plays36_style))
        phrase_semantic_list.append(float(phrase_semantic))
        phrase_dissim_list.append(float(phrase_dissim))
        phrase_style_list.append(float(phrase_style))
        video_semantic_list.append(float(video_semantic))
        video_dissim_list.append(float(video_dissim))
        video_style_list.append(float(video_style))
    
        #print "\t".join([str(x) for x in [line, simple_bleu(_16plays36, original), pinc(_16plays36, modern), sm.ScoreSim(_16plays36), sm.ScoreMaxEnt(_16plays36), simple_bleu(phrase, original), pinc(phrase, modern), sm.ScoreSim(phrase), sm.ScoreMaxEnt(phrase)]])
        _16plays36_bleu_list.append(simple_bleu(_16plays36, original))
        _16plays36_pinc_list.append(pinc(_16plays36, modern))
        _16plays36_csim_list.append(sm.ScoreSim(_16plays36))
        _16plays36_cmaxent_list.append(sm.ScoreMaxEnt(_16plays36))
        _16plays36_lmdiff_list.append(LMdiff(_16plays36))
        _16plays36_lmdiff2_list.append(LMdiff2(_16plays36, modern))
        _16plays36_lmdiff3_list.append(LMdiff3(_16plays36))

        phrase_bleu_list.append(simple_bleu(phrase, original))
        phrase_pinc_list.append(pinc(phrase, modern))
        phrase_csim_list.append(sm.ScoreSim(phrase))
        phrase_cmaxent_list.append(sm.ScoreMaxEnt(phrase))
        phrase_lmdiff_list.append(LMdiff(phrase))
        phrase_lmdiff2_list.append(LMdiff2(phrase, modern))
        phrase_lmdiff3_list.append(LMdiff3(phrase))

        video_bleu_list.append(simple_bleu(video, original))
        video_pinc_list.append(pinc(video, modern))
        video_csim_list.append(sm.ScoreSim(video))
        video_cmaxent_list.append(sm.ScoreMaxEnt(video))
        video_lmdiff_list.append(LMdiff(video))
        video_lmdiff2_list.append(LMdiff2(video, modern))
        video_lmdiff3_list.append(LMdiff3(video))
       
        i += 1


    print "16plays36:"
    print "sematnic-bleu\t" + str(pearsonr(_16plays36_semantic_list, _16plays36_bleu_list))
    print "dissim-pinc\t" + str(pearsonr(_16plays36_dissim_list, _16plays36_pinc_list))
    print "style-bleu\t" + str(pearsonr(_16plays36_style_list, _16plays36_bleu_list))
    print "style-pinc\t" + str(pearsonr(_16plays36_style_list, _16plays36_pinc_list))
    print "style-csim\t" + str(pearsonr(_16plays36_style_list, _16plays36_csim_list))
    print "style-cmaxent\t" + str(pearsonr(_16plays36_style_list, _16plays36_cmaxent_list))
    print "style-lmdiff\t" + str(pearsonr(_16plays36_style_list, _16plays36_lmdiff_list))
    print "style-lmdiff2\t" + str(pearsonr(_16plays36_style_list, _16plays36_lmdiff2_list))
    print "style-lmdiff3\t" + str(pearsonr(_16plays36_style_list, _16plays36_lmdiff3_list))

    print "phrase2:"
    print "semantic-bleu\t" + str(pearsonr(phrase_semantic_list, phrase_bleu_list))
    print "dissim-pinc\t" + str(pearsonr(phrase_dissim_list, phrase_pinc_list))
    print "style-bleu\t" + str(pearsonr(phrase_style_list, phrase_bleu_list))
    print "style-pinc\t" + str(pearsonr(phrase_style_list, phrase_pinc_list))
    print "style-csim\t" + str(pearsonr(phrase_style_list, phrase_csim_list))
    print "style-cmaxent\t" + str(pearsonr(phrase_style_list, phrase_cmaxent_list))
    print "style-lmdiff\t" + str(pearsonr(phrase_style_list, phrase_lmdiff_list))
    print "style-lmdiff2\t" + str(pearsonr(phrase_style_list, phrase_lmdiff2_list))
    print "style-lmdiff3\t" + str(pearsonr(phrase_style_list, phrase_lmdiff3_list))

    print "video2:"
    print "semantic-bleu\t" + str(pearsonr(video_semantic_list, video_bleu_list))
    print "dissim-pinc\t" + str(pearsonr(video_dissim_list, video_pinc_list))
    print "style-bleu\t" + str(pearsonr(video_style_list, video_bleu_list))
    print "style-pinc\t" + str(pearsonr(video_style_list, video_pinc_list))
    print "style-csim\t" + str(pearsonr(video_style_list, video_csim_list))
    print "style-cmaxent\t" + str(pearsonr(video_style_list, video_cmaxent_list))
    print "style-lmdiff\t" + str(pearsonr(video_style_list, video_lmdiff_list))
    print "style-lmdiff2\t" + str(pearsonr(video_style_list, video_lmdiff2_list))
    print "style-lmdiff3\t" + str(pearsonr(video_style_list, video_lmdiff3_list))

    print "all:"
    print "sematnic-bleu\t" + str(pearsonr(_16plays36_semantic_list + phrase_semantic_list + video_semantic_list, _16plays36_bleu_list + phrase_bleu_list + video_bleu_list))
    print "dissim-pinc\t" + str(pearsonr(_16plays36_dissim_list + phrase_dissim_list + video_dissim_list, _16plays36_pinc_list + phrase_pinc_list + video_pinc_list))
    print "style-bleu\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_bleu_list + phrase_bleu_list + video_bleu_list))
    print "style-pinc\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_pinc_list + phrase_pinc_list + video_pinc_list))
    print "style-csim\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_csim_list + phrase_csim_list + video_csim_list))
    print "style-cmaxent\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_cmaxent_list + phrase_cmaxent_list + video_cmaxent_list))
    print "style-lmdiff\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_lmdiff_list + phrase_lmdiff_list + video_lmdiff_list))
    print "style-lmdiff2\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_lmdiff2_list + phrase_lmdiff2_list + video_lmdiff2_list))
    print "style-lmdiff3\t" + str(pearsonr(_16plays36_style_list + phrase_style_list + video_style_list, _16plays36_lmdiff3_list + phrase_lmdiff3_list + video_lmdiff3_list))

    return

print "=ALAN vs. WEI================================================="
corelation_human_human(sys.argv[1], sys.argv[2])

    
print "\n\n=ALAN========================================================="
corelation_auto_human(sys.argv[1])

print "\n\n=WEI=========================================================="
corelation_auto_human(sys.argv[2])
