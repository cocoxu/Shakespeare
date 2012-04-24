#!/usr/local/bin/perl

##########################################
# Find meaningful tweets to Shakesperian #  
##########################################



########################################
## read in Michael's vocabulary
########################################


my $dictfilename = "./vocabulary.txt";
open (DICTFILE, "$dictfilename") || die "Cannot open file $dictfilename\n";
my @dictlines = <DICTFILE>;
close (DICTFILE);

%is_in_dict = ();

foreach my $dictline (@dictlines) {
	chomp ($dictline);
	$is_in_dict{$dictline} = 1;
}

########################################
## read in Adam's Stemmer Dictionary
########################################


my $morphfilename = "./morph-base-mapping";
open(MORPHFILE, "$morphfilename") || die "Cannot open file $morphfilename";
my @morphlines = <MORPHFILE>;
close(MORPHFILE);

my %morph_base_mapping = ();

foreach my $morphline (@morphlines) {
        if($morphline =~ m/^\("(.+?)" "(.+?)"/) {
                #print $1."\t".$2."\n";
                $morph_base_mapping{$1} = $2;
                $is_in_dict{$1} = 1
        }
}

########################################
## read Freebase name tokens
########################################


my $freebasefilename = "./freebase_name_token.txt";
open (FBFILE, "$freebasefilename") || die "Cannot open file $freebasefilename\n";
my @fblines = <FBFILE>;
close (FBFILE);

%is_in_freebase = ();
foreach my $fbline (@fblines) {
	chomp ($fbline);
	$fbline = lc($fbline);
	$is_in_freebase{$fbline} = 1;
}



my $wcfilename = "/proteus1/xuwei/Twitter/tokenized";
open (WCFILE, "$wcfilename") || die "Cannot open file $wcfilename\n";

while (my $wcline = <WCFILE>) {
	chomp ($wcline);

	$wcline =~ s/RT //g;
	$wcline =~ s/: //g;
	$wcline =~ s/:\)//g; 
	$wcline =~ s/:\(//g;
	$wcline =~ s/;\)//g;
	$wcline =~ s/:\-.+//g;
	$wcline =~ s/:p//g;
	$wcline =~ s/:P//g;
	$wcline =~ s/\?+/?/g;
	$wcline =~ s/\.+/./g;
	$wcline =~ s/!+/!/g;
	$wcline =~ s/\(.*\)//g;

	my @tokens = split (/ /, $wcline);
	

	my $oov = 0;
	my $tweet = "";

	foreach my $otoken (@tokens) {

		$token = lc($otoken);

		if ($token =~ m/^@/ || $token =~ m/^#/ || $token =~ m/^\*/ || $token =~ m/^&/ || $token =~ m/^http/ ) {
			next; 	
		} elsif ($token =~ /^[a-z0-9]+$/) {

			 if ( (! exists $is_in_dict{$token} ) && (! exists $is_in_freebase{$token} ) ) {

				if($token !~ /^[0-9]+$/ && $token !~ /^[0-9]+th$/ && $token !~ /^[0-9]+st$/ && $token !~ /^[0-9]+pm$/ && $token !~ /^[0-9]+am$/) {
					$oov = 1;
					next; 
				}  
			}	


		}	

	
		$tweet .= $otoken." ";

	}


	if ($tweet =~ m/^[0-9A-Z]$/) { next; } 

	my @ttokens = split (/ /, $tweet);
	if (scalar(@ttokens) <= 3) { next; }

	$count_freebase = 0;
	$count_word = 0;
	$count_othertoken = 0;
	$count_upperword = 0;

	foreach my $ttoken (@ttokens) {
		if($ttoken =~ m/^[A-Z]/) { $count_upperword ++; }		

		$ttoken = lc($ttoken);

		if ($ttoken =~ m/[0-9]/) { 
			$count_othertoken ++; 
		}			
		elsif (exists $is_in_dict{$ttoken}) { 
			$count_word ++; 
			#print "DC ".$ttoken."\n"; 
		}
		elsif (exists $is_in_freebase{$ttoken}) { 
			$count_freebase ++; 
			#print "FB ".$ttoken."\n"; 
		}
		else { 
			$count_othertoken ++; 
		}
	}

	if( $count_word < $count_upperword + $count_freebase + $count_othertoken) {
		next;
	}

	my @characters = split (//, $tweet);
	my $count_uppercase = 0; 
	my $count_lowercase = 0;
	my $count_otherchar = 0;

	foreach my $character (@characters) {
		if ($character =~ m/[A-Z]/) { $count_uppercase ++; }
		elsif ($character =~ m/[a-z]/) { $count_lowercase ++; }
		else { $count_otherchar ++; }
	}

	if ( $count_lowercase < $count_uppercase + $count_otherchar ) {
		next;
	}

	if ($oov == 0) {
 		print $tweet."\n";
	}
}


close (WCFILE);
