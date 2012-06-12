
my $rawdict = "../dictionary/shakespeareswords.raw";
#my $rawdict = "../dictionary/shakespeareswords.exception";

open(RAWDICT, $rawdict) || die "Can't open file $!.";
my @rawdictlines = <RAWDICT>;
close(RAWDICT);

foreach my $rawdictline (@rawdictlines) {
	chomp ($rawdictline);
	
	$rawdictline =~ s/\[[^\[\]]*\]//g;
	
	
	my $original_entry;
	my $modern_entry;
	
	if ($rawdictline =~ m/^(.+)\s\([^()]+\.\)\s[0-9]*(.+)\s\([^()]+\.\)\s[0-9]*(.+)$/) {
		$original_entry = $1;
		$modern_entry = $2;	
	} elsif ($rawdictline =~ m/^(.+)\s\([^()]+\.\)\s[0-9]*(.+)$/) {
		$original_entry = $1;
		$modern_entry = $2;
	}
	

	
	
	
	my @originalwords = split(/,/, $original_entry);
	my @modernwords = split(/[,;]/, $modern_entry);
	
	foreach my $originalword (@originalwords) {
		$originalword =~ s/^\s+//g;
		$originalword =~ s/\s+$//g;
	

		foreach my $modernword (@modernwords) {

			$modernword =~ s/or://g;
			$modernword =~ s/also://g;
			$modernword =~ s/also: //g;
			$modernword =~ s/so://g;
			$modernword =~ s/\(plural\)//g;
			$modernword =~ s/^\s+//g;
			$modernword =~ s/\s+$//g;
			
			if($modernword =~ m/‘(.+)’.+‘(.+)’/) {
				print $originalword."\t".$1."\n";
				print $originalword."\t".$2."\n";
			} elsif($modernword =~ m/‘(.+)’/) {
				print $originalword."\t".$1."\n";
			} elsif($modernword !~ m/^[a-zA-Z '-]+$/) {
				#print $originalword."\t".$modernword."\n";
			} elsif($modernword !~ m/^[a-zA-Z '-]+$/) {
				#print $originalword."\t".$modernword."\n";
			} else {
				print $originalword."\t".$modernword."\n";
			}
			
			
		}
	}
	
	#print $originalwords."\t".$modernwords."\n";

}

