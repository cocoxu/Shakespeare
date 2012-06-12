
#
# Only consider single word pairs, other than phrases
#
# Use 37plays_tokenized_lowercased.original.lm for ngram counts
#

my $unigram = "../models/LMs/36plays_tokenized_lowercased.original.lm";

open (UNIGRAM, $unigram) || die "Can't open file $!.";
my @unigramlines = <UNIGRAM>;
close(UNIGRAM);

my %unigrams = ();

foreach my $unigramline (@unigramlines) {
	chomp $unigramline;
	my @cols = split(/\t/, $unigramline);
	
	my $ncol = scalar (@cols);
	
	if ($ncol == 2 or $ncol == 3) {
		my $oword = $cols[1];
		my $prob = $cols[0];
		
		$oword =~ s/^\s+//g;
		$oword =~ s/\s+$//g;
			
		$prob = 10 ** $prob;
	
		$unigrams{$oword} = $prob;
	}
	#if($oword eq 'brooks') {
	#print $oword."\t".$prob."\n";
	#}
}


######################################################

my $indict = "../dictionary/shakespeareswords.cleaned";

open(INDICT, $indict) || die "Can't open file $!.";
my @indictlines = <INDICT>;
close(INDICT);

my %MtoOmapping = ();

foreach my $indictline (@indictlines) {
	chomp $indictline;
	my @cols = split(/\t/, $indictline);
	my $modernword = lc($cols[1]);
	$modernword =~ s/^\s+//g;
	$modernword =~ s/\s+$//g;
				
	my $originalword = lc($cols[0]);
	$originalword =~ s/^\s+//g;
	$originalword =~ s/\s+$//g;

	my @tokens = split(/ /, $modernword);
	
	if(scalar(@tokens) == 1) {
		if(exists $unigrams{$modernword}) {
			$MtoOmapping{$modernword}{$modernword} = 1;
		}		
		if(exists $unigrams{$originalword}) {
			$MtoOmapping{$modernword}{$originalword} = 1;
		}
		
		if(exists $unigrams{$modernword."s"}) {
			$MtoOmapping{$modernword."s"}{$modernword."s"} = 1;
		}
		if(exists $unigrams{$originalword."s"}) {
			$MtoOmapping{$modernword."s"}{$originalword."s"} = 1;
		}
		
		if(exists $unigrams{$modernword."ed"}) {
			$MtoOmapping{$modernword."ed"}{$modernword."ed"} = 1;
		}
		if(exists $unigrams{$originalword."ed"}) {
			$MtoOmapping{$modernword."ed"}{$originalword."ed"} = 1;
		}
	} else {
		if(exists $unigrams{$modernword}) {
			$MtoOmapping{$modernword}{$modernword} = 1;
		}		
		if(exists $unigrams{$originalword}) {
			$MtoOmapping{$modernword}{$originalword} = 1;
		}
	}
	
}


foreach my $keym (sort (keys %MtoOmapping)) {
	#print $keym."\t";
	
	my $sumprob = 0;
	foreach my $keyo1 (keys %{$MtoOmapping{$keym}}) {
		$sumprob += $unigrams{$keyo1};
	}

	foreach my $keyo2 (keys %{$MtoOmapping{$keym}}) {
		my $cprob = $unigrams{$keyo2}/$sumprob;
		if( $keym ne $keyo2 || $cprob != 1) {
			print $keym." ||| ".$keyo2." ||| ".$cprob."\n";
		
		}
		#print $keyo2."(".$cprob.")"."\t";
		#print $keyo2."\t";
	}
		
	#print "\n";
}