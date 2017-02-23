#!/usr/bin/perl -w
use strict;

open my $file, "<", $ARGV[0];

while(<$file>){
	chomp;
	my @tarray=split/\s+/;
       	my $tfile;
	my $dir = "/home/mmckain/Transposome/Prepped_Data/" . $tarray[0] . "/";
	opendir(DH, "$dir");
	while(my $dfile=readdir(DH)){
		if($dfile =~ /Ready.fasta/){
			print "$dfile\n";
			$tfile=$dir . $dfile;
		}
	}
	#my $tfile = <"/home/kzudock/forRepeatExplorer/TrimWithNEBAdapters/$tarray[0]/*_singleend.fasta">;
        print "$tarray[0]\n";
	#my $file1;
	#my $file2;
	#for my $tfile (@files){
	#	if($tfile =~ /R1/){
	#		$file1=$tfile;
	#	}
	#	else{
	#		$file2=$tfile;
	#	}
	#}
	`mkdir $tarray[0]`;
	chdir("$tarray[0]");
	my $total_pairs = `grep ">" -c $tfile`;
	`head -n 200000 $tfile > $tarray[0]_downsample.fasta`;
	`cp ../transposome_scratch_submit_BASE transposome_condor_submit_$tarray[0]`;
	`cp ../BASE_transposome.yml $tarray[0]_transposome.yml`;
	my $sample_file = $tarray[0] . "_downsample.fasta";
	my $filePath=$tfile;
	$filePath =~ s/\//\\\//g;
	`perl -pi -e "s/FILE/$sample_file/" $tarray[0]_transposome.yml`;
	my $pwd = `pwd`;
	chomp ($pwd);
	$pwd = $tarray[0] . "_transposome\_out";
	$pwd =~ s/\//\\\//g;
	`perl -pi -e "s/OUTPUT/$pwd/" $tarray[0]_transposome.yml`;
	`perl -pi -e "s/SAMPLE/$tarray[0]/" $tarray[0]_transposome.yml`;
	my $config = `pwd`;
	chomp ($config);
	$config .= "/" . $tarray[0] . "_transposome.yml";
	$config =~ s/\//\\\//g;
	`perl -pi -e "s/FILE/$sample_file/" transposome_condor_submit_$tarray[0]`;
	`perl -pi -e "s/CONFIG/$config/" transposome_condor_submit_$tarray[0]`;
	`perl -pi -e "s/SAMPLE/$tarray[0]/" transposome_condor_submit_$tarray[0]`;
	`condor_submit transposome_condor_submit_$tarray[0]`;
	#`rm map* *sam *trimmed*`;}
	chdir("../");
}	
		
