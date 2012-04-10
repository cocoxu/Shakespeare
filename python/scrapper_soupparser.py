import lxml.html.soupparser as soupparser
import lxml.html
import io
import sys
import re
import nltk

from django.utils.encoding import smart_str

file = open(sys.argv[1])
html = file.read()
file.close()

tree = soupparser.parse(io.BytesIO(html))

original = ""
modern = ""
for t in tree.xpath('//*[name()="div"]'):    
    if t.text is not None:
        if 'class' in t.attrib :
            if t.attrib['class'] == 'original-line' :
                oline = t.text.replace('\n', ' ')
                oline = smart_str(re.sub(r'\s+', ' ', oline))
                original += " " + oline

                
            elif t.attrib['class'] == 'modern-line' :
                mline = t.text.replace('\n', ' ')
                mline = smart_str(re.sub(r'\s+', ' ', mline))
                modern += " " + mline
                
oSentences = nltk.sent_tokenize(original)
for s in oSentences:
    print '[O]' + s

mSentences = nltk.sent_tokenize(modern)
for s in mSentences:
    print '[M]' + s
