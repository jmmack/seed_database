#!/usr/bin/env perl
use strict;

#28Jun2016 - JM
# Input: on a read diamond blast to the seed database (in m8 format)
# output: a counts table per subsys4
#		The top hit will be counted for each read as 1 count
#		This will print out all the unique subsys4 from the top hits
# Meant to be run with the bash wrapper: /Volumes/Data/Corn_metagenome_2016/seed_compare/get_counts.sh

my $blast = $ARGV[0];		#The file e.g. diamond_output/A2_S7_L001_R1_001.m8
my $sample_name = $ARGV[1];	#the sample basename e.g. A2_S7_L001_R1_001
my $path = @ARGV[2];		# Path for the counts tables output e.g. diamond_output/counts_tables/

my $seen = "NULL";
my %counts;
#my %subys4;

open (my $IN, "<", $blast) or die "$!\n";
while( not eof $IN){
    my $l = <$IN>;
    chomp $l;

my @split = split(/\t/, $l);
my @split2 = split(/\s\-\s/, $split[1]);
	if ($split[0] ne $seen){
		$seen = $split[0];
		$counts{$split2[-1]}++;
	}

}
close $IN;

my $file = "$sample_name" . "_" . "counts" . ".txt";

#counts_table was a directory already created
open (my $OUT, ">", $path . "/" . $file)  or die "$!\n";
print $OUT "subsys4\t$ARGV[1]\n";
foreach my $key (keys %counts){
	print $OUT "$key\t$counts{$key}\n";
}
close $OUT;
