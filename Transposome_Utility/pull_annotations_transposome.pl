#!/usr/bin/env perl -w
use strict;



my @files = <*/*out/*report_annotations_summary.tsv>;

my %values;
my %types;
for my $file (@files){
		$file =~ /\/(.*?)_transposome_out/;
		my $name = $1;

		open my $tfile, "<", $file;
		while(<$tfile>){
			chomp;
			if(/ReadNum/){
				next;
			}
			my @tarray=split/\s+/;
			$values{$name}{$tarray[1]}+=$tarray[3];
			$types{$tarray[1]}=1;
		}

}

open my $out, ">", "TE_annotation_results.txt";
print $out "Species";
for my $id(sort keys %types){
	print $out "\t$id";
}
print $out "\n";
for my $id (sort keys %values){
		print "$id\n";
		print $out "$id\t";
		for my $fam (sort keys %types){ 
                if(!exists $values{$id}{$fam}){
			print $out "0\t";;
		}
		else{
			print $out "$values{$id}{$fam}\t";
		}
		}
		print $out "\n";
}
