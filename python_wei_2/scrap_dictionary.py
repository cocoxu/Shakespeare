import lxml.html.soupparser as soupparser
import lxml.html
import io
import sys
import re
import string

from lxml.html.soupparser import fromstring
from lxml.etree import tostring
from django.utils.encoding import smart_str

for c in string.lowercase:
#for c in ('a'):
    filename = '../dictionary/word_' + c + '.htm'
    file = open(filename)
    html = file.read()
    file.close()

    stringbuf = ""
	
    tree = soupparser.parse(io.BytesIO(html))
    

    for t in tree.xpath('//*[name()="font"]'):  
        if t.text is not None:
            if 'color' in t.attrib and 'size' not in t.attrib:
                if t.attrib['color'] == '#E0E3EF' and (t.text.find(' ') < 0):
                    line = t.text
                    line = line.replace('\n', '') 
                    stringbuf += line
                    if line.isupper() :
                        stringbuf += "\t"
                    if not line.isupper() and not line.isspace() and len(line) > 1:
                        stringbuf += "\n"
                    #print tostring(t, pretty_print=True, encoding=unicode)
                    for b in t:
                        line = tostring(b, pretty_print=True, encoding=unicode)
                        line = line.replace('\n', '') 
                        line = re.sub(r'<br/>', '', line)
                        stringbuf += line
                        if line.isupper() :
                            stringbuf += "\t"
                        if not line.isupper() and not line.isspace():
                            stringbuf += "\n"                      
    line = line.replace(' \t', '') 
    print smart_str(stringbuf)
    #break