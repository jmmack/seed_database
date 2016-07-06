#!/usr/bin/env bash

#24Jun2016 - JM
# Use diamond to compare all read files to the SEED fig.peg database

#--------------------------------------------------------------------------------------------------
# Setup
# This script should be in your working directory. Within your working directory should be the .gz
#	sequence files.
#--------------
# Paths to change:

DIAMOND="/Volumes/data/diamond/diamond"			#diamond install location
DB="SEED_database/subsys4.dmnd"	#database of SEED fig.pegs
BIN="bin" #This is where blast_to_counts.pl and merge_counts.pl are

#output paths
PATH1="diamond_output"
PATH2="diamond_output/counts_tables"
#--------------------------------------------------------------------------------------------------
# Output
# There will be 1 output directory:
#	diamond_output will contain the diamond blast output (in .daa compressed format AND
#		decompressed to BLAST m8 format). Only one hit is retained per sequence by default.
#		Additionally, a single tab-delimited counts table will be built containing all samples:
#		all_counts.txt
#--------------------------------------------------------------------------------------------------

#----------------
# Part 1 - Use DIAMOND to compare reads per sample to the SEED database
#----------------

#make output directory if it doesn't already exist
mkdir -p diamond_output
echo -e "WARNING: output will be overwritten if files already exist\n"

for f in *.gz; do	# e.g. F12_S17_L004_R2_001.fastq.gz

# Split on . and get the first field
	B=`basename $f`
	NAME=`echo $B | cut -d "." -f1`

#	echo $B
#	echo $NAME
#	exit

#e.g. $DIAMOND blastx -d $DB -q ../data/sequence_files/F12_S17_L004_R2_001.fastq.gz -a diamond_output/F12_S17_L004_R2_001 --salltitles -k 3
# -k is the number of hits to report
# --salltitles will print the full subject headers

	$DIAMOND blastx -d $DB -q ${f} -a ${PATH1}/${NAME} --salltitles -k 1
# Convert diamond output to blast tab-delimited format
	$DIAMOND view -a ${PATH1}/${NAME}.daa -o ${PATH1}/${NAME}.m8

done

#----------------
# Part 2 - From DIAMOND output, make counts tables
#----------------

# from DIAMOND output, make counts tables
# This is a per-file basis
# This will take a WHILE because Perl has to read line by line
#		Would have been smarter to do multiple files at a time - next time!

mkdir -p ${PATH1}/counts_tables	# Temporary directory to hold the individual counts tables

for f in ${PATH1}/*.m8; do

# Split on - and get the first field
	B=`basename $f`
	NAME=`echo $B | cut -d "." -f1`

#	echo $f
#	echo $NAME
# 	echo $PATH2
#	exit

	$BIN/blast_to_counts.pl $f $NAME $PATH2

done

# Merge all the counts tables into one
# Remove the individual tables when complete

	$BIN/merge_counts.pl $PATH2 > all_counts.txt

#echo $PATH2;exit

minsize=100
actualsize=$(wc -c <"all_counts.txt")

#Check the file is written (greater than 100kb) before deleting intermediary files
	if [[ $actualsize -gt $minsize ]]; then
		rm ${PATH2}/*_counts.txt
		rmdir $PATH2
		echo "output to all_counts.txt"
	else
		echo "all_counts.txt is empty. Please check individual counts tables and upstream scripts"
	fi

#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
#Future:

## Add checks before continuing
# Are there .gz files in the working dir
# Does the database exist
# Does diamond exist
# Are the perl scripts there
# Do not run diamond if output already exists
