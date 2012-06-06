#!/usr/bin/python

import sys
import re
import nltk

currentLine = None
for line in sys.stdin:
    line = line.strip()
    m = re.search('^\s*[_\.]+([^_]*)[_\.]+\s*(.*)', line)
    if not m:
        m = re.search('^\s*[_\.]+([^_]*)[_\.]+', line)
    if not m:
        m = re.search('^\s*(\w*):+', line)
    if not m:
        m = re.search('^\s*(\w*):+\s*(.*)', line)
    if not m:
        m = re.search('^\s*([A-Z]*)\.\s*(.*)', line)

    if m:
        if currentLine and len(currentLine) < 1000:
            #print m.group(1)
            print " ".join(nltk.word_tokenize(re.sub('_', '', re.sub('\s+', ' ', currentLine))))
        if len(m.groups()) > 1:
            currentLine = m.group(2)
        else:
            currentLine = ""
    elif currentLine != None:
        currentLine += line
