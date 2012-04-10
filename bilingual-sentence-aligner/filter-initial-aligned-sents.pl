#!c:/Perl/bin/perl

# (c) Microsoft Corporation. All rights reserved.

$start_time = (times)[0];

($sent_file_1,$sent_file_2,$threshold) = @ARGV;

$sent_file_2_mod = $sent_file_2;
$sent_file_2_mod =~ tr/\/\\/--/;

if (!defined($threshold)) {
    $threshold = .99;
}

open(IN1,$sent_file_1) ||
    die("cannot open data file $sent_file_1\n");
open(OUT1,">$sent_file_1.words");

open(IN2,$sent_file_2) ||
    die("cannot open data file $sent_file_2\n");
open(OUT2,">$sent_file_2.words");

open(ALIGN,"$sent_file_1.$sent_file_2_mod.length-backtrace") ||
    die("cannot open data file $sent_file_1.$sent_file_2_mod.length-backtrace\n");

$file_1_pos = 0;
$file_2_pos = 0;
$matched_line_cnt = 0;
while ($bead_line = <ALIGN>) {
    ($bead_pos_1,$bead_pos_2,$bead,$prob) = split(' ',$bead_line);
    if (($bead eq 'match') && ($prob > $threshold)) {
	$matched_line_cnt++;
	until ($file_1_pos > $bead_pos_1) {
	    $line = <IN1>;
	    @words = grep($_,split(/\s+\(?|\(|-|_/,$line));
	    if (@words) {
		$file_1_pos++;
	    }
	}
	foreach $word (@words) {
	    if ($word =~ /\w/) {
		$word =~ /\W*(\w.*\w|\w)/;
		$word = lc($1);
	    }
	    else {
		$word =~ /(^[^\)]*)/;
		$word = $1;
		if ($word eq '') {
		    $word = '(null)';
		}
	    }
	}
	print OUT1 "@words\n";
	until ($file_2_pos > $bead_pos_2) {
	    $line = <IN2>;
	    @words = grep($_,split(/\s+\(?|\(|-|_/,$line));
	    if (@words) {
		$file_2_pos++;
	    }
	}
	foreach $word (@words) {
	    if ($word =~ /\w/) {
		$word =~ /\W*(\w.*\w|\w)/;
		$word = lc($1);
	    }
	    else {
		$word =~ /(^[^\)]*)/;
		$word = $1;
		if ($word eq '') {
		    $word = '(null)';
		}
	    }
	}
	print OUT2 "@words \n";
    }
}

close(IN1);
close(OUT1);

close(IN2);
close(OUT2);

print "$matched_line_cnt high prob matched lines\n";

$final_time = (times)[0];
$total_time = $final_time - $start_time;
print "$total_time seconds total time\n";
