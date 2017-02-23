#!/usr/bin/env perl -w
use strict;



my @files = <*/*out/*log.txt>;

my %values;
for my $file (@files){
		$file =~ /\/(.*?)_transposome_out/;
		my $name = $1;

		open my $tfile, "<", $file;
		while(<$tfile>){
			if(/Results/){

				if(/Repeat fraction from clusters:/){
					/Repeat fraction from clusters:\s+(.*?)$/;

					$values{$name}{Clusters}=$1;

				}
				if(/Singleton repeat fraction:/){
					/Singleton repeat fraction:\s+(.*?)$/;
                                       my $per;
					if(!$1 || $1 eq ''){
						$per ="0.00";
					}
					else{
						$per = $1;
					}
					$values{$name}{Singleton}=$per;

				}

				if(/Total repeat fraction:/){
					/Total repeat fraction:\s+(.*?)$/;

					$values{$name}{Total}=$1;
				}

				if(/Total repeat fraction from annotations:/){
					/Total repeat fraction from annotations:\s+(.*?)$/;

					$values{$name}{Annotations}=$1;
				}

			}
		}
}

open my $out, ">", "TE_results.txt";
print $out "Species\tClustered_Repeats\tSingleton_Repeats\tTotal_Repeats\tAnnotated_Repeats\n";
for my $id (sort keys %values){
		print "$id\n";
                if(!exists $values{$id}{Annotations}){
			$values{$id}{Annotations} = "NA";
		}
		print $out "$id\t$values{$id}{Clusters}\t$values{$id}{Singleton}\t$values{$id}{Total}\t$values{$id}{Annotations}\n";
}
