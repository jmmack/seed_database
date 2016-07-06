#!/usr/bin/env perl
use strict;

my %subsys4; my %counts; my %sample_list;
my $sample;

my $path = @ARGV[0];

#print $path;exit;
#print $path . "/" . "*_counts.txt";exit;

my @files = < $path/*_counts.txt>;
foreach my $file (@files) {
 # print $file . "\n";exit;
	open (my $IN, "<", $file) or die "$!\n";
		while( not eof $IN){
		my $l = <$IN>;
		chomp $l;

		my @split = split(/\t/, $l);

		if ($l =~ m/^subsys4/){
			$sample = $split[1];
			$sample_list{$sample} = 0 if !exists $sample_list{$sample}; #keep track of all samples for later
		}else{
# Hash of a hash
# This is the counts per sample per subsys4
			$counts{$split[0]}{$sample} = $split[1];
		}
	}close $IN;
}


## $s4 is subsys4, $sn is sample name

print "subsys4";
foreach my $sn (sort(keys %sample_list)) {							#Make the header
		print "\t$sn";
}
print "\n";

for my $s4 ( keys %counts ) {
	print "$s4";													#print the subsys4

	foreach my $sn (sort(keys %sample_list)) {							#for all the samples (sort to retain order)
##		print "$sn\n";
	    print "\t$counts{$s4}{$sn}" if exists $counts{$s4}{$sn};	#print the readcount for that sample for that subsys4
	    print "\t0" if !exists $counts{$s4}{$sn};					#when there is no count for that subsys4 in that sample

	}
 #   print "$s4\t$counts{$s4}{$sn}\n";
		print "\n";													#before going to the next subsys4, print a new line
}

#-----------------------------------------------------------------------------------------------
=testing
## $s4 is subsys4, $sn is sample name
# For each subsys4, print the count per sample

for my $s4 ( keys %counts ) {
    print "$s4\n";
    for my $sn ( keys %{ $counts{$s4} } ) {
         print "$sn=$counts{$s4}{$sn}\n";
    }
    print "\n";
}
=cut
