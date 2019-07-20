#!/usr/bin/python3

##  Copyright 2019 Eryk Wdowiak
##  
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##  
##      http://www.apache.org/licenses/LICENSE-2.0
##  
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

import itertools
import numpy as np
import csv

import mxnet as mx
from mxnet import gluon
from mxnet import nd
import gluonnlp as nlp

from data import transform_data_word2vec, preprocess_dataset
from model import SG, CBOW
from utils import print_time

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

context = mx.cpu()
datafile = 'scnwiki-20190201.tsv'

model = SG
parmfile = './logs/scnwiki-skip_2019-07-18.params'
otcsv = './logs/cossim_scnwiki-skip.csv'
#model = CBOW
#parmfile = './logs/scnwiki-cbow_2019-07-18.params'
#otcsv = './logs/cossim_scnwiki-cbow.csv'

output_dim = 300
batch_size = 1024
num_negatives = 5
subword_function = None
window = 5
frequent_token_subsampling = 1E-4

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  

##  load the data
data = nlp.data.TSVDataset(datafile)
data, vocab, idx_to_counts = preprocess_dataset( data ) 

##  load the model
embedding = model(token_to_idx=vocab.token_to_idx, output_dim=output_dim,
                  batch_size=batch_size, num_negatives=num_negatives,
                  negatives_weights=mx.nd.array(idx_to_counts))
embedding.load_parameters(parmfile)

##  get the word vectors
wvecs = embedding.embedding_out.weight.data()

##  "short vectors" -- only the words with at least 100 appearances
slimit = len( np.array(idx_to_counts)[ np.array(idx_to_counts)>=100 ] )
svecs = wvecs[:slimit,]

##  >>> len(vocab)
##  39010

##  >>> slimit
##  5026
##  >>> idx_to_counts[5025:5027]
##  [50, 49]

##  >>> slimit
##  2603
##  >>> idx_to_counts[2602:2604]
##  [100, 99]

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  get pairwise cosine similarity
def cos_sim(wordx, wordy):
    xx = wvecs[vocab.token_to_idx[wordx],]
    yy = wvecs[vocab.token_to_idx[wordy],]
    return nd.dot(xx, yy) / (nd.norm(xx) * nd.norm(yy))

##  get full matrix of cosine similarity
def cos_mat( vecs ):
    ##  dot product divided by the norms
    xtx = nd.dot( vecs , vecs.T)
    nmx = nd.sqrt( nd.diag(xtx) ).reshape((-1,1))
    cnm = nd.dot( nmx , nmx.T )
    return xtx / cnm

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  manipulate prices
print('cos_sim(\'manipulari\', \'prezzi\')')
print(cos_sim('manipulari', 'prezzi'))

## cos_sim('manipulari', 'prezzi')
## 
## [0.5213489]
## <NDArray 1 @cpu(0)>

##  get full cosine matrix of SHORT vectors
cosmat = cos_mat( svecs )

##  and write it to file
otfile = open(otcsv, 'w')
otfile.write(',')

with open(otcsv, 'a') as otfile:
   writer = csv.writer(otfile)
   writer.writerow(vocab.idx_to_token[:slimit])
   for rowname, rowdata in zip(vocab.idx_to_token, cosmat.asnumpy()):
      writer.writerow([rowname] + rowdata.tolist())

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
