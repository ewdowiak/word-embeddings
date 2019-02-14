#!/bin/bash

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

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  define usage
USAGE="\n\tusage:  $0  {cbow|skip} {word one} {word two}\n\n"

##  which model CBOW or skipgram?
case $1 in
    CBOW|cbow)
	MODEL="cossim_cbow.csv.gz";;
    skip|skipgram)
	MODEL="cossim_skip.csv.gz";;
    *)
        printf "${USAGE}"; exit;;
esac

##  get word one
case $2 in
    "")
        printf "${USAGE}"; exit;;
    *)
	WONE=$2;;
esac

##  get word two
case $3 in
    "")
        printf "${USAGE}"; exit;;
    *)
	WTWO=$3;;
esac


##  get the position of word two
PTWO=$( zgrep -i -m 2 -n "${WTWO}," $MODEL | tail -n1 | awk -F ',' '{print $1}' | awk -F ':' '{print $1}' )

##  write the awk program
PROG="{print \$$PTWO}"

##  capture the cosine measure
COSM=$( zgrep -i -m 2 -n "${WONE}," $MODEL | tail -n1 | awk -F ',' "$PROG" )

##  print the similarity
printf "\n\tcosine similarity between \"%s\" and \"%s\":\n" $WONE $WTWO
printf "\t%.4f\n\n" $COSM

##  that's all, folks!
exit
