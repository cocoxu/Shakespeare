sub matchlines;

my $interfilename = "romeojuliet_original.12intersection.snt.aligned.sorted";
open(INTERFILE, "$interfilename") || die "Cannot open file $!";
my @interlines = <INTERFILE>;
close(INTERFILE);

my %interlineset = ();

#print scalar(@interlines)."\n";

foreach my $interline (@interlines) {
	chomp ($interline);
	$interlineset{$interline} = 1;
}

my $size = scalar(keys %interlineset);

print "Read in intersected lines: ".$size."\n";

my $modern1filename = "romeojuliet_modern.1.snt.aligned";
my $original1filename = "romeojuliet_original.1.snt.aligned";

my $modern2filename = "romeojuliet_modern.2.snt.aligned";
my $original2filename = "romeojuliet_original.2.snt.aligned";

my %interlineshash1 = matchlines($original1filename, $modern1filename);
#print "Read in version1 lines: ".scalar(keys %interlineshash1)."\n";

my %interlineshash2 = matchlines($original2filename, $modern2filename);
#print "Read in version2 lines: ".scalar(keys %interlineshash2)."\n";

my $moderntestfile = "test.romeojuliet_original.snt.aligned";
my $originaltestfile1 = "test.romeojuliet_modern.1.snt.aligned";
my $originaltestfile2 = "test.romeojuliet_modern.2.snt.aligned";

open(OTESTFILE, ">$moderntestfile") || die "Cannot open file $!";
open(MTESTFILE1, ">$originaltestfile1") || die "Cannot open file $!";
open(MTESTFILE2, ">$originaltestfile2") || die "Cannot open file $!";

foreach $keyline (keys %interlineshash1) {
	print OTESTFILE $keyline."\n";
	print MTESTFILE1 $interlineshash1{$keyline}."\n";
	print MTESTFILE2 $interlineshash2{$keyline}."\n";
}

close(OTESTFILE);
close(MTESTFILE1);
close(MTESTFILE2);


sub matchlines {
	my $infilename1 = shift;
	my $infilename2 = shift;
	
	print $infilename1."\n";
	print $infilename2."\n";
	
	open(INFILE1, "$infilename1") || die "Cannot open file $!";
	my @inlines1 = <INFILE1>;
	close(INFILE1);
	
#	print "Read in original1 lines: ".scalar(@inlines1)."\n";
	
	open(INFILE2, "$infilename2") || die "Cannot open file $!";
	my @inlines2 = <INFILE2>;
	close(INFILE2);	
	
	my %matches = ();
	
	my $testfilename1 = "dev.".$infilename1;
	my $testfilename2 = "dev.".$infilename2;
	
	print $testfilename1;
	print $testfilename2;
	
	open(DEVFILE1, ">$testfilename1") || die "Cannot open file $!";
	open(DEVFILE2, ">$testfilename2") || die "Cannot open file $!";
	
	
		
	for (my $i = 0; $i < scalar(@inlines1); $i++) {
		my $line1 = $inlines1[$i];
		my $line2 = $inlines2[$i];
		chomp($line1);
		chomp($line2);
		if(exists $interlineset{$line1}) {
			$matches{$line1} = $line2;
			#print $line1."\n";
		} else {
			#print $line1."\n";
			print DEVFILE1 $line1."\n";
			print DEVFILE2 $line2."\n";
		}
	}
	
	close(DEVFILE1);
	close(DEVFILE2);

	return %matches;
}


