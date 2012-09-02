import io

words = []
contents = []
translations = []

word = ""
content = ""
    
for dictentry in open('../data/shakespere.dict'):
    
    dictentry = dictentry.rstrip()
    
    columns = dictentry.split("\t")

    if len(columns) == 2 :
        if word != "" : 
            words.append ( word )
            contents.append (content)
            content = ""
        word = columns[0][:-2]
    	content = columns[1][:-2] 
    elif len(columns) == 1 :
		content += columns[0][:-2]
    else :
        print "***ERROR***"
 

for w, c in zip ( words, contents) :
    print "# " + w + " " + c
    
    roughtrans = [] 
    
    cols_semicolon = c.split(";")
    if len(cols_semicolon) > 1 :
        for w1 in cols_semicolon :
            w1 = w1.strip(" ")
            roughtrans.append (w1)
    else :
        cols_comma = c.split(",")
        if len(cols_comma) > 1 :
            for w2 in cols_comma :
                w2 = w2.strip(" ")
                roughtrans.append (w2)
        else :
            roughtrans.append (c)
    
    for roughtran in roughtrans :
        if roughtran.startswith("to ") or roughtran.startswith("or "):
            roughtran = roughtran[3:]
        print "* " + w + "\t" + roughtran
    