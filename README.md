# Word Embeddings

This repository adapts the MXNet Gluon NLP tutorial "[Word Embeddings Training and Evaluation](https://gluon-nlp.mxnet.io/examples/word_embedding/word_embedding_training.html)," so that it can be used with data from other Wikipedias.  I have not modified the tutorial's scripts except to add a `nlp.data.TSVDataset(args.data)` to the `train` function of the `train_sg_cbow.py` script, so that users can pass their own input file to the script.

My contribution is to supply a few more tools.  In particular, I modified a script that [Matt Mahoney](http://mattmahoney.net/dc/textdata.html) wrote to convert Wikipedia XML dumps to "clean text."  That script, `clean-wiki.pl` script, generates a tab-delimited text file that we can use for model training.

Having generated the data file, we can then train a skipgram model by running:

`python3 train_sg_cbow.py --model skipgram --ngram-buckets 0 --data scnwiki-20190201.tsv`

With the trained model in hand, we can use the `ml-02_embed.py` script to retrieve the word vectors and cosine similarity matrix.  That matrix is very large, so I also wrote the `cossim.sh` shell script to access a particular element.  And I wrote the `cossim_slim.pl` script to retrieve the ten words that are most similar in context.

For more information, please see my notes at: [doviak.net](https://www.doviak.net/pages/ml-sicilian/ml-scn_p02.shtml). 
