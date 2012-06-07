#!/usr/bin/python

import sys
import codecs

for line in codecs.open(sys.argv[1], encoding='utf8'):
    line = line.strip()
    line = line.replace(u'\u2018', u'\'')
    line = line.replace(u'\u2019', u'\'')
    line = line.replace(u'\u201C', u'"')
    line = line.replace(u'\u201D', u'"')
    line = line.replace(u'\u2014', u'-')
    line = line.replace(u'\u2013', u'-')
    line = line.replace(u'\xe9', u'e')
    line = line.replace(u'\xe8', u'e')
    print line.encode('ascii', errors='replace')
