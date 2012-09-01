#!/usr/bin/python

import nltk
#nltk.config_megam('/home/aritter/local/bin/megam')
nltk.config_megam('/usr/local/bin/megam')

import sys
import math
import random

MAX_NGRAM=6

class StyleMetric:
    source_vector = {}
    target_vector = {}

    training = []

    def __init__(self, corpus_source, corpus_target):
        #Read in Source Corpus
        nlines = 0
        for line in open(corpus_source):
            #TODO: can use more data for training maxent model if more memory is available
            line = line.strip()
            words = nltk.word_tokenize(line)
            sentenceDict = {}
            for gram in range(1,MAX_NGRAM):
                for i in range(len(words)-gram+1):
                    ngram = " ".join(words[i:i+gram])
                    self.source_vector[ngram] = 1
                    #self.source_vector[ngram] = self.source_vector.get(ngram, 0) + 1
                    sentenceDict[ngram] = 1
                    #sentenceDict[ngram] = sentenceDict.get(ngram, 0) + 1.0
            self.training.append((sentenceDict, 'source'))
            nlines += 1

        #Read in Target Corpus
        nlines = 0
        for line in open(corpus_target):
            line = line.strip()
            words = nltk.word_tokenize(line)
            sentenceDict = {}
            for gram in range(1,MAX_NGRAM):
                for i in range(len(words)-gram+1):
                    ngram = " ".join(words[i:i+gram])
                    self.target_vector[ngram] = 1
                    #self.target_vector[ngram] = self.target_vector.get(ngram, 0) + 1
                    sentenceDict[ngram] = 1
                    #sentenceDict[ngram] = sentenceDict.get(ngram, 0) + 1
            self.training.append((sentenceDict, 'target'))
            nlines += 1

        #self.training = random.sample(self.training, 100)
            
#        for i in range(len(self.training)):
#            t = {}
#            for k in self.source_vector.keys() + self.target_vector.keys():
#                #t[k] = self.training[i][0].get(k, 0.0)
#                if self.training[i][0].has_key(k):
#                    t[k] = 1
#                else:
#                    t[k] = 0
#            self.training[i] = (t, self.training[i][1])

        #Train Maxent model
        #self.maxEntModel = nltk.classify.MaxentClassifier.train(self.training, nltk.classify.MaxentClassifier.ALGORITHMS[0], count_cutoff=1, sparse=True, max_iter=10)
        #self.maxEntModel = nltk.classify.MaxentClassifier.train(self.training, 'GIS', count_cutoff=1, sparse=True, max_iter=100)
        #self.maxEntModel = nltk.MaxentClassifier.train(self.training, 'megam', count_cutoff=1, sparse=True, max_iter=100)
        #self.maxEntModel = nltk.MaxentClassifier.train(self.training, 'megam')
        #self.maxEntModel = nltk.classify.maxent.train_maxent_classifier_with_megam(self.training, gaussian_prior_sigma=10, bernoulli=True)
        
        nltk.classify.maxent.train_maxent_classifier_with_megam_writemodeltofile(self.training, gaussian_prior_sigma=10, model_file='megam_model',bernoulli=True)
        self.maxEntModel = nltk.classify.maxent.readin_maxent_classifier_with_megam(self.training, model_file='megam_model')
 
    def ScoreSim(self, sentence):
        sentence_vector = {}
        words = nltk.word_tokenize(sentence)
        for gram in range(1,MAX_NGRAM):
            for i in range(len(words)-gram+1):
                ngram = " ".join(words[i:i+gram])
                sentence_vector[ngram] = sentence_vector.get(ngram, 0.0) + 1.0
        source_sim = self.CosineSim(sentence_vector, self.source_vector)
        target_sim = self.CosineSim(sentence_vector, self.target_vector)
        return target_sim / (target_sim + source_sim)

    def ScoreMaxEnt(self, sentence):
        sentence_vector = {}
        words = nltk.word_tokenize(sentence)
        for gram in range(1,MAX_NGRAM):
            for i in range(len(words)-gram+1):
                ngram = " ".join(words[i:i+gram])
                sentence_vector[ngram] = 1
                #sentence_vector[ngram] = sentence_vector.get(ngram, 0) + 1
        return self.maxEntModel.prob_classify(sentence_vector).prob('target')
        
    #def ScoreDiffMaxEnt(self, sentence1, sentence2)


    def CosineSim(self, v1, v2):
        cSum = 0.0
        for k in v1.keys():
            cSum += v1.get(k, 0.0) * v2.get(k, 0.0)
        v1Sum = 0.0
        for k in v1.keys():
            v1Sum += v1.get(k, 0.0) * v1.get(k, 0.0)
        v2Sum = 0.0
        for k in v2.keys():
            v2Sum += v2.get(k, 0.0) * v2.get(k, 0.0)
        return cSum / (math.sqrt(v1Sum) * math.sqrt(v2Sum))

if __name__ == "__main__":
    sm = StyleMetric(sys.argv[1], sys.argv[2])
    print sm.ScoreSim("Give yourself to the dark side")
    print sm.ScoreMaxEnt("Give yourself to the dark side")
    print sm.ScoreSim("Give thee to the dark side")
    print sm.ScoreMaxEnt("Give thee to the dark side")
