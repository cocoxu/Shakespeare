import lxml.html.soupparser as soupparser
from lxml.etree import tostring
import lxml.html
import io
import sys
import re
import nltk

from django.utils.encoding import smart_str

#file = open('./webpages/romeo_juliet.html')
file = open(sys.argv[1])
html = file.read()
file.close()

tree = soupparser.parse(io.BytesIO(html))

fulltext = ""


for a in tree.xpath('//*[name()="a"]'):   
    if a.text is not None: 
        if 'name' in a.attrib :
            fulltext += " " + a.text
            #print a.attrib['name'] + a.text

oSentences = nltk.sent_tokenize(fulltext)
for s in oSentences:
     s = smart_str(re.sub(r'\s+', ' ', s))
     s = re.sub(r'^\s', '', s)
     print s

