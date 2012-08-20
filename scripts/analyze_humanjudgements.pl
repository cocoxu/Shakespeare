my $humanfile = "../eval/annotated.tsv";

open (MANFILE, $humanfile) || die "Can't open file $!.";
my @humanlines = <MANFILE>;
close(MANFILE);


	
my @scores = (4,3,2,1);
foreach my $stylescore (@scores) {	
	foreach my $humanline (@humanlines) {
		chomp $humanline;
		my @cols = split(/\t/, $humanline);
		
		my $original = $cols[0];
		my $modern   = $cols[1];
		my $moseout  = $cols[2];
		my $dictout  = $cols[3];
		my $mosesem  = $cols[4];
		my $mosedis  = $cols[5];
		my $mosesty  = $cols[6];
		my $moseall  = $cols[7];
		my $dictsem  = $cols[8];
		my $dictdis  = $cols[9];
		my $dictsty  = $cols[10];
		my $dictall  = $cols[11];
		
		if ($mosesty == $stylescore) {
			extratoken_analyse($original, $modern, $moseout, $stylescore);	
		} 
		
		if ($dictsty == $stylescore) {
			extratoken_analyse($original, $modern, $dictout, $stylescore);	
		} 
	}
}

sub extratoken_analyse {
		my $o = shift;
		my $m = shift;
		my $s = shift;
		my $score = shift;
		print "[O]".$o."\n";
		print "[M]".$m."\n";
		print "[S]".$s."\n";
		print "[".$score."] ";
		extratoken ($m, $s);
		print "\n\n";
}

sub extratoken {

	my $sysinput  = shift;
	my $sysoutput = shift;
	my @sysintokens  = split(/\s/, $sysinput);
	my @sysouttokens = split(/\s/, $sysoutput);
	
	foreach my $outtoken (@sysouttokens) {
		my $hit = 0;
		foreach my $intoken (@sysintokens) {
			if ($outtoken eq $intoken) {
				$hit = 1;
			}
		}
		if ($hit == 0) {
			print $outtoken." ";
		}
	}

}