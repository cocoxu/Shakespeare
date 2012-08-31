import subprocess
import re
import math

lmoriginal2 = "/Users/weixu/Work/Shakespere/Shakespere/models/LMs/36plays_tokenized_lowercased.original.lm"    
lmoriginal = "/Users/weixu/Work/Shakespere/Shakespere/models/LMs/16plays_tokenized_lowercased.original.lm"    
lmmodern = "/Users/weixu/Work/Shakespere/Shakespere/models2/LM/16plays_tokenized_lowercased.modern.lm"    

def logexpsum(logprobs):
    m = max(logprobs)
    return(m + math.log(sum([math.exp(x - m) for x in logprobs])))

def sent_logprob (sent, lmfile) :
    f = open('tmp_sent', 'w')
    f.write(sent)
    f.close()
    p = subprocess.Popen(["/Users/weixu/Work/Shakespere/tools/srilm/lm/bin/macosx/ngram", "-lm" , lmfile, "-ppl" ,"tmp_sent"], shell=False, stderr=subprocess.PIPE, stdout=subprocess.PIPE).communicate()
    output = p[0]
    sentlen = re.search(r', (.*)words', output).group(1)
    logprob = re.search(r'logprob= (.*) ppl=', output).group(1)
    return {'sentlen':float(sentlen), 'logprob':float(logprob)}    
    
    
def LMdiff (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    diff = logprob_lmoriginal - logprob_lmmodern
    return diff

def LMdiff2 (osent, msent) :
    logprob_lmoriginal_o = sent_logprob (osent, lmoriginal) ['logprob']
    logprob_lmoriginal_m = sent_logprob (msent, lmoriginal) ['logprob']
    diff = logprob_lmoriginal_o - logprob_lmoriginal_m
    return diff
    
    
def LMdiff3 (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    #diff = log10 ( 1 / (1 + pow(10,logprob_lmoriginal - logprob_lmmodern)) )
    diff = pow(10, logprob_lmoriginal) / (pow(10, logprob_lmoriginal) + pow(10,logprob_lmmodern))
    return diff

def LMdiff4 (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    diff = logprob_lmoriginal - logexpsum([logprob_lmoriginal, logprob_lmmodern])
    return diff

def LMdiff5 (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    diff = logprob_lmoriginal - logexpsum([logprob_lmoriginal, logprob_lmmodern])
    diff = pow(10, diff)
    return diff
    
def LMdiff6 (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal2) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    diff = logprob_lmoriginal - logexpsum([logprob_lmoriginal, logprob_lmmodern])
    return diff

def LMdiff7 (sent) :
    logprob_lmoriginal = sent_logprob (sent, lmoriginal2) ['logprob']
    logprob_lmmodern   = sent_logprob (sent, lmmodern) ['logprob']
    diff = logprob_lmoriginal - logexpsum([logprob_lmoriginal, logprob_lmmodern])
    diff = pow(10, diff)
    return diff
    
#sentence = "wilt thou take them ?"
sentence = "do you need my help ?"
#print sent_logprob (sentence, lmoriginal)
#print sent_logprob (sentence, lmmodern)

#print LMdiff3(sentence)
#print LMdiff5(sentence)
#print LMdiff4(sentence)
#print LMdiff6(sentence)
