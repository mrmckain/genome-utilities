#/usr/bin/perl -w
use strict;

my @directories = </home/mmckain/Sequence_Vault/Andropogoneae_GSS/*>;

for my $dir (@directories){
	$dir =~ /\/home\/mmckain\/Sequence_Vault\/Andropogoneae_GSS\/(.+)/;
	my @tempdir;
	push(@tempdir,$dir);
	my $sub_dir_name=$1;
	`mkdir $sub_dir_name`;
	 my @true_files;
	my %seen;
	while(my $pwd = shift @tempdir){
	opendir(DIR,$pwd);
	
        my @files=readdir(DIR);
	closedir(DIR);
        for my $file (@files){
		if( $file eq ".." || $file eq "."){
			next;
		}
		my $standindir = $pwd . "/" . $file;
                if (-d $standindir && !$seen{$file}){
			$seen{$file}=1;
			my $newdir=$pwd . "/" . $file;
			push(@tempdir, $newdir);
                }
                else{
				if($file =~ /fq|fastq/i){
					my $nfile = $pwd . "/" . $file;
                                push(@true_files, $nfile);
                }}

        }}
	
	chdir $sub_dir_name;
	
	my @read1 = grep(/R1/, @true_files);
	if(@read1 == 0){
		my $seqs = join(',', @true_files);
		my $array_size = @true_files;
		for (my $i=0; $i<$array_size; $i++){
			my $suffix = $sub_dir_name . "_singleend_" . $i;
			`sh /home/kzudock/forRepeatExplorer/Trim_Bowtie_SE.sh $true_files[$i] $suffix`;
			`cat no_organ_map_hits_single.fq >> no_organ_map_hits_single_$sub_dir_name\.fq`;
		}
		`perl /home/kzudock/forRepeatExplorer/fastq2fasta_no_length_adjustment.pl -f no_organ_map_hits_single_$sub_dir_name\.fq -n $sub_dir_name`;
	}
	else{
		my @read2 = grep(/R2/, @true_files);
		
		my @sort_reads1 = sort @read1;
		my @sort_reads2 = sort @read2;
		
		my $paired1 = join(',',@sort_reads1);
		my $paired2 = join(',',@sort_reads2);
		my $array_size = @sort_reads1;
                for (my $i=0; $i<$array_size; $i++){
                        my $suffix = $sub_dir_name . "_pairedend_" . $i;
                        `sh /home/kzudock/forRepeatExplorer/Trim_Bowtie_PE.sh $sort_reads1[$i] $sort_reads2[$i] $suffix`;
                        `cat no_organ_map_hits.fq >> no_organ_map_hits_$sub_dir_name\.fq`;
			`cat  no_organ_map_pair_hits.1.fq >>  no_organ_map_pair_hits_$sub_dir_name.1.fq`;
			`cat  no_organ_map_pair_hits.2.fq >>  no_organ_map_pair_hits_$sub_dir_name.2.fq`;


                }

	#	`sh /home/kzudock/forRepeatExplorer/Trim_Bowtie_PE.sh $paired1 $paired2 $sub_dir_name`;
		
		my @single = grep (!/R1|R2/, @true_files);
		if (@single > 0){
			
			my $seqs = join(',', @single);
			my $array_size = @single;
                	for (my $i=0; $i<$array_size; $i++){
                        	my $suffix = $sub_dir_name . "_singleend_" . $i;
                        	`sh /home/kzudock/forRepeatExplorer/Trim_Bowtie_SE.sh $single[$i] $suffix`;
                        	`cat no_organ_map_hits_single.fq >> no_organ_map_hits_single_$sub_dir_name\.fq`;
                	}

			#`sh /home/kzudock/forRepeatExplorer/Trim_Bowtie_SE.sh $seqs $sub_dir_name`;
		}
		 `perl /home/kzudock/forRepeatExplorer/fastq2fasta_no_length_adjustment.pl -f no_organ_map_hits_$sub_dir_name.fq,no_organ_map_hits_single_$sub_dir_name.fq -n $sub_dir_name\_single`;
		 `perl /home/kzudock/forRepeatExplorer/fastq2fasta_no_length_adjustment.pl -f no_organ_map_pair_hits_$sub_dir_name.1.fq,no_organ_map_pair_hits_$sub_dir_name.2.fq -n $sub_dir_name\_paired --paired`;
	}
	`cat *.fasta > $sub_dir_name\_RepeatExplorer_Ready.fasta`;
	`rm *fq *sam *end.fasta`;
	chdir ("../");
}	
