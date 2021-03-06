#!/usr/bin/perl

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

##  NOTE:  This script was originally written by Matt Mahoney[1] who released it into
##  the public domain.  (See below).  I have modified it for Sicilian Wikipedia data.
##  Users will have to modify it for their own Wikipedia data.
##  
##  References:
##  [1] http://mattmahoney.net/dc/textdata.html
##  
##  below is Matt Mahoney's description and release: 
##  
##     Program to filter Wikipedia XML dumps to "clean" text consisting only of lowercase
##     letters (a-z, converted from A-Z), and spaces (never consecutive).  
##     All other characters are converted to spaces.  Only text which normally appears 
##     in the web browser is displayed.  Tables are removed.  Image captions are 
##     preserved.  Links are converted to normal text.  Digits are spelled out.
## 
##     Written by Matt Mahoney, June 10, 2006.  This program is released to the public domain.

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

use strict;
use warnings;

##my $infile = "scnwiki-20190201_head.xml";
my $infile = "scnwiki-20190201.xml";
my $otfile = "scnwiki-20190201.tsv";

open( my $infh , "<$infile" ) || die "could not open $infile";
open( my $otfh , ">$otfile" ) || die "could not overwrite $otfile";

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  "does it contain text?" holder
my $text = 0;

##  input record separator
$/=">";                     
while (my $line = <$infh>) {
    if ($line =~ /<text /) {$text=1;}      ## remove all but between <text> ... </text>
    if ($line =~ /#redirect/i) {$text=0;}  ## remove #REDIRECT

    if ($text > 0) {
	##  Remove any text not normally visible
	if ($line =~ /<\/text>/) {
	    $text=0;
	}
	#chomp $line;
	$line =~ s/<.*>//;               # remove xml tags
	$line =~ s/&amp;ndash/\-/g;      # make a dash
	$line =~ s/&amp;/&/g;            # decode URL encoded chars
	$line =~ s/&lt;/</g;
	$line =~ s/&gt;/>/g;
	$line =~ s/<ref[^<]*<\/ref>//g;  # remove references <ref...> ... </ref>
	$line =~ s/<[^>]*>//g;           # remove xhtml tags
	$line =~ s/\[http:[^] ]*/[/g;    # remove normal url, preserve visible text
	$line =~ s/\|thumb//ig;          # remove images links, preserve caption
	$line =~ s/\|left//ig;
	$line =~ s/\|right//ig;
	$line =~ s/\|\d+px//ig;
	$line =~ s/\[\[image:[^\[\]]*\|//ig;
	$line =~ s/\[\[category:([^|\]]*)[^]]*\]\]/[[$1]]/ig;  # show categories without markup
	$line =~ s/\[\[[a-z\-]*:[^\]]*\]\]//g;  # remove links to other languages
	$line =~ s/\[\[[^\|\]]*\|/[[/g;  # remove wiki url, preserve visible text
	$line =~ s/\{\{[^}]*\}\}//g;         # remove {{icons}} and {tables}
	$line =~ s/\{[^}]*\}//g;
	$line =~ s/\[//g;                # remove [ and ]
	$line =~ s/\]//g;
	$line =~ s/&[^;]*;/ /g;          # remove URL encoded chars
	

	##  remove more stuff
	$line =~ s/[\(\)\[\]\{\}\+\=\'\"\-\*\/\#\|\%\@\$_]/ /g;
	$line =~ s/\d+/ /g;
	$line =~ s/’/ /g;

	##  add a space between punctuation and words
	$line =~ s/([\;\:\.\!\?\,\-])/ $1/g;

	##  tack a space onto the end 
	$line =~ s/$/ /g;
	
	##  make lower case grave accents
	$line =~ s/\303\200/\303\240/g; 
	$line =~ s/\303\210/\303\250/g; 
	$line =~ s/\303\214/\303\254/g; 
	$line =~ s/\303\222/\303\262/g; 
	$line =~ s/\303\231/\303\271/g; 
	
	##  make lower case acute accents
	$line =~ s/\303\201/\303\241/g; 
	$line =~ s/\303\211/\303\251/g; 
	$line =~ s/\303\215/\303\255/g; 
	$line =~ s/\303\223/\303\263/g; 
	$line =~ s/\303\232/\303\272/g; 
	
	##  make lower case circumflex accents ... 
	##  even though we'll get rid of them later
	$line =~ s/\303\202/\303\242/g; 
	$line =~ s/\303\212/\303\252/g; 
	$line =~ s/\303\216/\303\256/g; 
	$line =~ s/\303\224/\303\264/g; 
	$line =~ s/\303\233/\303\273/g; 
	
	##  Ç = "\303\207"
	##  ç = "\303\247"
	$line =~ s/\303\207/\303\247/g; 
	
	##  convert everything else to lowercase letters
	$line =~ tr/A-Z/a-z/; 
	
	##  restrict the character set
	##  grave accents
	$line =~ s/\303\240/~GA~/g; 
	$line =~ s/\303\250/~GE~/g; 
	$line =~ s/\303\254/~GI~/g; 
	$line =~ s/\303\262/~GO~/g; 
	$line =~ s/\303\271/~GU~/g; 
    
	##  acute accents
	$line =~ s/\303\241/~AA~/g; 
	$line =~ s/\303\251/~AE~/g; 
	$line =~ s/\303\255/~AI~/g; 
	$line =~ s/\303\263/~AO~/g; 
	$line =~ s/\303\272/~AU~/g; 
	
	##  circumflex accents
	$line =~ s/\303\242/~CA~/g; 
	$line =~ s/\303\252/~CE~/g; 
	$line =~ s/\303\256/~CI~/g; 
	$line =~ s/\303\264/~CO~/g; 
	$line =~ s/\303\273/~CU~/g; 
	
	##  crazy c
	$line =~ s/\303\247/~CC~/g; 
    
	##  restrict the character set
	$line =~ s/[^a-zACEGIOU~\.\!\?]/ /g;
	
	##  revert the character set
	##  grave accents
	$line =~ s/~GA~/\303\240/g; 
	$line =~ s/~GE~/\303\250/g; 
	$line =~ s/~GI~/\303\254/g; 
	$line =~ s/~GO~/\303\262/g; 
	$line =~ s/~GU~/\303\271/g; 
	
	##  acute accents
	$line =~ s/~AA~/\303\241/g; 
	$line =~ s/~AE~/\303\251/g; 
	$line =~ s/~AI~/\303\255/g; 
	$line =~ s/~AO~/\303\263/g; 
	$line =~ s/~AU~/\303\272/g; 
	
	##  circumflex accents
	$line =~ s/~CA~/\303\242/g; 
	$line =~ s/~CE~/\303\252/g; 
	$line =~ s/~CI~/\303\256/g; 
	$line =~ s/~CO~/\303\264/g; 
	$line =~ s/~CU~/\303\273/g; 
  
	##  crazy c
	#$line =~ s/~CC~/\303\247/g; 
	$line =~ s/~CC~/c/g; 
	
	##  get rid of newlines and excess space
	$line =~ s/$/ /g;
	$line =~ s/\s+/ /g;

	##  add <BOS> and <EOS>
	$line =~ s/([\.\!\?])/$1 <EOS> <BOS>/g;
	$line =~ s/ <BOS>$//;
	$line =~ s/$/<EOS>/;
	$line =~ s/^/<BOS> /;
	$line =~ s/\s+/ /g;

	##  remove stopwords
	$line = rm_stopwords( $line );

	##  remove empty sequences
	$line =~ s/<BOS> <EOS>//g;
	$line =~ s/<BOS> \. <EOS>//g;
	$line =~ s/<BOS> \! <EOS>//g;
	$line =~ s/<BOS> \? <EOS>//g;
	$line =~ s/\s+/ /g;
	
	##  make sure there is one space at end of sequence
	$line =~ s/<EOS>$/<EOS> /g;
	$line =~ s/<BOS> ?/<BOS> /g;
	
	##  convert spaces to tabs
	$line =~ s/\s+/\t/g;
	
	##  print it out
	print $otfh $line ;
	
    }
}

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

close $otfh;
close $infh;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

sub rm_stopwords {

    my $line = $_[0];
    
    my @stops ;
    push( @stops , "a", "â", "ad", "al", "all", "and", "are", "args", "as", "at" );
    push( @stops , "b", "be", "by", "c", "ca", "câ", "can", "cc", "cci", "ccu", "ch", "che", "chi", "chî" );
    push( @stops , "chidda", "chiddi", "chiddu", "chissa","chissi","chissu", "chista", "chisti", "chistu" );
    push( @stops , "ci", "colspan", "com", "con", "cu", "cû", "cui", "d", "da", "dâ" );
    push( @stops , "dda", "ddi", "ddu", "de", "dê", "dei", "del", "della", "di", "dî", "do", "dô", "du", "dû" );
    push( @stops , "e", "ê", "ecc", "ed", "end", "èranu", "et", "ex", "f", "for", "from", "g", "h", "ha", "http" );
    push( @stops , "i", "idda", "iddi", "iddu", "if", "ii", "iii", "il", "in", "is", "it", "iv" );
    push( @stops , "j", "jpg", "ju", "k", "km", "l", "la", "le", "li", "lu" );
    push( @stops , "m", "ma", "may", "me", "metri", "mi", "mp", "msg" );
    push( @stops , "n", "na", "ni", "nn", "nna", "nnâ", "nni", "nnô", "nome", "nta", "ntâ", "ntê", "nti", "nto", "ntô" );
    push( @stops , "nu", "o", "ô", "of", "oi", "on", "or", "org" );
    push( @stops , "p", "pâ", "per", "pi", "pî", "png", "poi", "ppi", "pri", "pû", "px", "r", "ra", "ri", "ru" );
    push( @stops , "s", "se", "si", "sô", "ssa", "ssi", "ssu", "st", "sta", "sti", "stu", "su", "svg", "t", "te" );
    push( @stops , "that", "the", "then", "this", "ti", "top", "tra", "tu", "u", "un", "una", "utc" );
    push( @stops , "v", "vi", "vucali", "we", "will", "with", "www", "x", "you", "your", "z" );

    my $stopre = join( ' | ' , @stops ) ;
    $stopre = ' ' . $stopre . ' ' ;
    
    $line =~ s/$stopre/ /g;
    $line =~ s/\s+/ /g;
    $line =~ s/$stopre/ /g;
    
    return $line;
}
