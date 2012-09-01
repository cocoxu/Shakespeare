import re
import urllib
import string
import time

urlhead = "http://www.william-shakespeare.info/william-shakespeare-dictionary-"
urltail = ".htm"

for c in string.lowercase:
    url = urlhead + c + urltail
    print url
    urlobject = urllib.urlopen(url)
    lines = urllib.urlopen(url).readlines()
    
    
    fOut = open('../dictionary/word_%s.htm' % c , 'w')
    fOut.write("\n".join(lines))
    fOut.close()
    time.sleep(1)    