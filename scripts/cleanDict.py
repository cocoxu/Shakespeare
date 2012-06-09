#!/usr/bin/python

import sys
import re

for line in open(sys.argv[1]):
    fields = line.strip().split('\t')
    #print "\t".join(fields)
    if len(fields) != 2:
        continue
    (word, definition) = fields
    word = word.rstrip('?')
    
    #definition = re.sub('^(a kind of|a|to|an) ', '', definition)
    definitions = [x.strip() for x in re.split(r'[,;]', definition)]
    definitions = [re.sub('^(.* kind of|a|to|an|or) ', '', x) for x in definitions]
    definitions = [re.sub('^(.* kind of|a|to|an|or) ', '', x) for x in definitions]

    for d in definitions:
        print "%s\t%s" % (word, d)
