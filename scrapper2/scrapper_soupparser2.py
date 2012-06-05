import lxml.html.soupparser as soupparser
from lxml.etree import tostring
import lxml.html
import io
import sys
import re
import nltk

from django.utils.encoding import smart_str

#file = open('./plays2/romeo-and-juliet-act-i-scene-i.htm')
file = open(sys.argv[1])
html = file.read()
file.close()

tree = soupparser.parse(io.BytesIO(html))

original = ""
modern = ""

#for table in tree.xpath('//*//[name()="table"]'):    
    #for td in table.xpath('//*[name()="td"]'):   
for dd in tree.xpath('//*[name()="dd"]'):   
    #if dd.text is not None: 
    mline = tostring(dd, encoding="utf-8")
    if "<span" in mline: continue
    mline = mline.replace('\n', ' ')
    mline = smart_str(re.sub(r'\s+', ' ', mline))
    mline = re.sub(r'<[^>]+>\(\d+\)<[^>]+>', '', mline)
    mline = re.sub(r'<[^>]+>', '', mline)
    if  mline != ' ' :
        modern += " " + mline
        #print '[M]' + mline

for span in tree.xpath('//*[name()="span"]'):  
    #if span.text is not None:
        
    oline = tostring(span, encoding="utf-8")
    oline = oline.replace('\n', ' ')
    oline = smart_str(re.sub(r'\s+', ' ', oline))
    oline = re.sub(r'<[^>]+>\(\d+\)<[^>]+>', '', oline)
    oline = re.sub(r'<[^>]+>', '', oline)
        
    if  oline != ' ' :
        original += " " + oline
        #print '[O]' + oline


oSentences = nltk.sent_tokenize(original)
for s in oSentences:
    s = smart_str(re.sub(r'\s+', ' ', s))
    s = re.sub(r'^\s', '', s)
    print '[O]' + s

mSentences = nltk.sent_tokenize(modern)
for s in mSentences:
    s = smart_str(re.sub(r'\s+', ' ', s))
    s = re.sub(r'^\s', '', s)
    print '[M]' + s
