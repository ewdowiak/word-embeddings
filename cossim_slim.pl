#!/usr/bin/env perl

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

use strict;
use warnings;

##  input and output files
my $infile = $ARGV[0];
( my $otfile = $infile ) =~ s/\.csv/_slim.csv/;
if ( $infile eq "" ) {
    die "no input file";
} elsif ( $infile eq $otfile ) {
    die "input file, $infile, would be same as output file";
}

##  number of values to return
my $topten = 10;

##  get the header
open( INFILE , $infile ) || die "could not open $infile";
chomp( my $header = <INFILE> ) ;
close INFILE ;

## split the header for use as column names
my @colnames = split( /,/ , $header ) ;

##  now get the data
open( OTFILE , ">$otfile" ) || die "could not overwrite $otfile";
open( INFILE , $infile ) || die "could not open $infile";
<INFILE> while $. < 1 ;
while(<INFILE>){
    chomp;
    my $line = $_ ;
    my @cols = split(/,/, $line);
    my $word = $cols[0];
    
    ##  get the indices of the sorted values
    my @idxsim = idxsort(@cols[1..$#cols]);

    ##  get the top ten words and their cossim measures, 
    ##  dropping the first which is "1.00"
    my $otline = $word .',';    
    foreach my $idx (@idxsim[1..$topten]) {
	##  because of row names, we must ADD ONE to each returned index value
	my $simword = $colnames[$idx+1];
	my $cossval = sprintf("%.2f", $cols[$idx+1]);
	$otline .= '"'. $simword . ' ('. $cossval .')",';
    }
    $otline =~ s/,$//;
    print OTFILE $otline ."\n";
}

close INFILE;
close OTFILE;

##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##
##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##  ##

##  SUBROUTINES
##  ===========

##  get the indices of the sorted values
sub idxsort {
    my @vals = @_ ;
    my @idx = 0..$#vals;
    my @idxsorted = sort {$vals[$b] <=> $vals[$a]} @idx ;
    return @idxsorted;
}

