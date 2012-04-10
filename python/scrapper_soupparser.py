import lxml.html.soupparser as soupparser
import lxml.html
import io
import sys
import re

from django.utils.encoding import smart_str

#from lxml.html.soupparser import fromstring


#file = open("twelfthnight_page_84.html")
file = open(sys.argv[1])
html = file.read()
file.close()

tree = soupparser.parse(io.BytesIO(html))

for t in tree.xpath('//*[name()="div"]'):    
    if t.text is not None:
        if 'class' in t.attrib :
            #print t.attrib
            if t.attrib['class'] == 'original-line' :
                #print "tag: " + t.tag + ",  text: '" + t.text + "'"
                oline = t.text.replace('\n', ' ')
                print smart_str('[O]' + re.sub(r'\s+', ' ', oline))
            elif t.attrib['class'] == 'modern-line' :
                #print "tag: " + t.tag + ",  text: '" + t.text + "'"
                mline = t.text.replace('\n', ' ')
                print smart_str('[M]' + re.sub(r'\s+', ' ', mline))
