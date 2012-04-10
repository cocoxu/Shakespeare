BILINGUAL SENTENCE ALIGNER

(c) Microsoft Corporation. All rights reserved.

Your use of the Microsoft software ("Software") described herein is
governed by the Microsoft Corporation Software License Agreement
("License") in the accompanying file "license-agreement.txt".  Your
use of the Software constitutes acceptance of this License.

This directory contains Perl programs for finding bilingual sentence
alignments.  The code implements the method described in the paper
"Fast and Accurate Sentence Alignment of Bilingual Corpora," published
in "Machine Translation: From Research to Real Users," the proceedings
of the 5th conference of the Association for Machine Translation in
the Americas.  The paper can also be downloaded from
http://www.research.microsoft.com/pubs/.

To adapt to different installations, the initial #! line beginning
each file may need to be changed to point to the location of the Perl
executable.

There are two version of the code.  Each version has a top-level
script that invokes several other Perl program files.  These have to
be in the current working directory, or they won't be found.

The sentences to be aligned need to be in paired files with one
sentence per line and spaces between words.  The sentence files do not
have to be in the same directory as the code files.

The sentence aligner assumes that the alignable sentences in each file
are in the same order, but that not all sentences align 1-to-1.
Sentences that might be aligned 1-to-1, but which are out of order
with respect to the majority of other alignable sentences will not be
identified as alignable.

The simpler version of the code is invoked by

    align-sents-all.pl <lang_1_file> <lang_2_file> <threshold>

which outputs into files named

    <lang_1_file>.aligned
    <lang_2_file>.aligned

all the sentences from <lang_1_file> and <lang_2_file> that align
1-to-1 with probability greater than <threshold> according to a
statistical model computed by the aligner.  <threshold> may be
omitted, in which case a probability threshold of 0.5 is used.

This version of the code requires a pair of sentence files to have
enough data to reliably estimate a statistical word-translation model.
It has been determined that 10,000 sentence pairs should be adequate
for this purpose.  Fewer sentence pairs may be sufficient, but this
has not been tested.

The second version of the code,

   align-sents-all-multi-file.pl <directory> <threshold>

looks for any number of paired sentence files in the folder
<directory>, which should be given by a pathname relative to the
current working directory.  The code assumes that paired sentence
files have names of the form

   <prefix>_<language>.snt

where <language> can be any string not containing "_".  The code
checks that that there are exactly two <language> strings used in the
entire directory, and that there are the same number of files
containing each of these strings.  For each different <prefix> it
assumes that there are two files with names of the form

   <prefix>_<language1>.snt
   <prefix>_<language2>.snt

It does not check this initially, but if the assumption is false then
some later part of the process may die (with results that have not
been investigated).

Output files are generated in <directory> with the same naming
convention as the two-file version of the code; that is, by appending
".aligned" to the input file names.

This version of the code also requires enough data to reliably
estimate a statistical word-translation model, but it pools the data
from all the files being aligned to build this model.  So, the
individual sentence files can be small, but it is desirable to have at
least 10,000 sentence pairs in total.
