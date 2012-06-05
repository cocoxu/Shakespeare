import lxml.html.soupparser as soupparser
import lxml.html
import io
import sys
import re
import string
import urllib
import time

from lxml.html.soupparser import fromstring
from lxml.etree import tostring
from django.utils.encoding import smart_str

for filename in open('urls.txt') :

    #filename = './memupages/romeo-and-juliet-text.htm'
    filename = './memupages/' + filename.rstrip('\n')
    file = open(filename)
    html = file.read()
    file.close()

    tree = soupparser.parse(io.BytesIO(html))

    for t in tree.xpath('//*[name()="a"]'):  
        #if t.text is not None:
            #print t.text
        if 'href' in t.attrib and 'class' not in t.attrib:
            link = t.attrib['href'] 
            pagename = link[link.rfind("/")+1:len(link)];
            if pagename.find('prologue') > 0 or pagename.find('scene') > 0:
                url = 'http://www.enotes.com' + link
                print url
                urlobject = urllib.urlopen(url)
                print urlobject.code
                lines = urllib.urlopen(url).readlines()                

                outfilename = './plays2/' + link.split('/')[-2].replace('text','') + link.split('/')[-1] + '.htm'
                print outfilename
                fOut = open(outfilename, 'w')
                fOut.write("\n".join(lines))
                fOut.close()
                time.sleep(1)
                        
            #print link        
            #print pagename        

        #link = t.attrib['href']
        #if link is not None:
            #print link