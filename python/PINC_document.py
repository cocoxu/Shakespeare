from __future__ import division
from collections import *

import io
import sys

def intersect (list1, list2) :
    cnt1 = Counter()
    cnt2 = Counter()
    for tk1 in list1:
        cnt1[tk1] += 1
    for tk2 in list2:
        cnt2[tk2] += 1    
    inter = cnt1 & cnt2
    return len(list(inter.elements()))

def pinc ( ssent, csent) :
    s1grams = ssent.split(" ")
    c1grams = cline.split(" ")
    
    s2grams = []
    c2grams = []
    s3grams = []
    c3grams = []
    s4grams = []
    c4grams = []
        
    for i in range(0, len(s1grams)-1) :
        if i < len(s1grams) - 1:
            s2gram = s1grams[i] + " " + s1grams[i+1]
            s2grams.append(s2gram)
        if i < len(s1grams)-2:
            s3gram = s1grams[i] + " " + s1grams[i+1] + " " + s1grams[i+2]
            s3grams.append(s3gram)
        if i < len(s1grams)-3:
            s4gram = s1grams[i] + " " + s1grams[i+1] + " " + s1grams[i+2] + " " + s1grams[i+3]
            s4grams.append(s4gram)
            
    for i in range(0, len(c1grams)-1) :
        if i < len(c1grams) - 1:
            c2gram = c1grams[i] + " " + c1grams[i+1]
            c2grams.append(c2gram)
        if i < len(c1grams)-2:
            c3gram = c1grams[i] + " " + c1grams[i+1] + " " + c1grams[i+2]
            c3grams.append(c3gram)
        if i < len(c1grams)-3:
            c4gram = c1grams[i] + " " + c1grams[i+1] + " " + c1grams[i+2] + " " + c1grams[i+3]
            c4grams.append(c4gram)

    if len(c1grams) > 0 :
        score  = 1 - intersect(s1grams, c1grams) / len(c1grams)
        #print "score1", score
    if len(c2grams) > 0 :
        score += 1 - intersect(s2grams, c2grams) / len(c2grams)
        #print "score2", score
    if len(c3grams) > 0 :
        score += 1 - intersect(s3grams, c3grams) / len(c3grams)
        #print "score3", score   
    if len(c4grams) > 0 :
        score += 1 - intersect(s4grams, c4grams) / len(c4grams)
        #print "score4", score
    return score/4


sentcount = 0
pincscore = 0.0

sfile = open(sys.argv[1])
cfile = open(sys.argv[2])

sline = sfile.readline()
cline = cfile.readline()

while sline and cline:
    sentcount += 1
    
    sline = sline.strip()
    cline = cline.strip()
    #print sline
    #print cline
           
    sentscore = pinc (sline, cline)       
    pincscore += sentscore


    #print sentscore
    #print len(sline)
    #print len(cline)
    #print "\n\n"
    sline = sfile.readline()
    cline = cfile.readline()



pincscore = pincscore / sentcount

print pincscore

