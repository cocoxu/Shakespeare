#!c:/Perl/bin/perl

# (c) Microsoft Corporation. All rights reserved.

# Builds IBM model 1, word alignment model, to be used in sentence
# alignment.

$start_time = (times)[0];

($sent_file_1,$sent_file_2,$em_iterations,$lex_size_cutoff) = @ARGV;

if (!defined($em_iterations)) {
    $em_iterations = 4;
}

if (!defined($lex_size_cutoff)) {
    $lex_size_cutoff = 5000;
}

open(IN,"$sent_file_1.words") ||
    die("cannot open data file $sent_file_1.words\n");

$total_count = 0;
$sent_cnt_1 = 0;
while ($line = <IN>) {
    $sent_cnt_1++;
    @tokens = split(' ',$line);
    foreach $token (@tokens) {
	$token_1_cnt{$token}++;
	$total_count++;
    }
}

$total_type_count = keys(%token_1_cnt);
$high_prob_type_count = 0;
$token_count = 0;
$cumlative_count = 0;
foreach $token (sort {$token_1_cnt{$b} <=> $token_1_cnt{$a}} keys(%token_1_cnt)) {
    $prev_count = $token_count;
    $token_count = $token_1_cnt{$token};
    if ((($high_prob_type_count >= $lex_size_cutoff) && ($token_count < $prev_count)) ||
	($token_count == 1)) {
	last;
    }
    $high_prob_type_count++;
    $cumlative_count += $token_count;
    $cumulative_freq = $cumlative_count/$total_count;
}
close(IN);

print "\nUsing $high_prob_type_count tokens out of $total_type_count from $sent_file_1 with $prev_count or more occurrences, representing $cumulative_freq of corpus\n";

$count_limit_1 = $prev_count;

$other_count = 0;
while (($token,$count) = each %token_1_cnt) {
    if ($count < $count_limit_1) {
	$other_count += $count;
	delete($token_1_cnt{$token});
    }
}
$token_1_cnt{'(other)'} = $other_count;

open(IN,"$sent_file_2.words") ||
    die("cannot open data file $sent_file_2.words\n");

$total_count = 0;
$sent_cnt_2 = 0;
while ($line = <IN>) {
    $sent_cnt_2++;
    @tokens = split(' ',$line);
    foreach $token (@tokens) {
	$token_2_cnt{$token}++;
	$total_count++;
    }
}

if ($sent_cnt_1 != $sent_cnt_2) {
    die("ERROR: $sent_cnt_1 sentences in $sent_file_1.words and $sent_cnt_2 sentences in $sent_file_2.words\n");
}

$total_type_count = keys(%token_2_cnt);
$high_prob_type_count = 0;
$token_count = 0;
$cumlative_count = 0;
foreach $token (sort {$token_2_cnt{$b} <=> $token_2_cnt{$a}} keys(%token_2_cnt)) {
    $prev_count = $token_count;
    $token_count = $token_2_cnt{$token};
    if ((($high_prob_type_count >= $lex_size_cutoff) && ($token_count < $prev_count)) ||
	($token_count == 1)) {
	last;
    }
    $high_prob_type_count++;
    $cumlative_count += $token_count;
    $cumulative_freq = $cumlative_count/$total_count;
}
close(IN);

print "\nUsing $high_prob_type_count tokens out of $total_type_count from $sent_file_2 with $prev_count or more occurrences, representing $cumulative_freq of corpus\n\n";

$count_limit_2 = $prev_count;

$other_count = 0;
while (($token,$count) = each %token_2_cnt) {
    if ($count < $count_limit_2) {
	$other_count += $count;
	delete($token_2_cnt{$token});
    }
}
$token_2_cnt{'(other)'} = $other_count;

%trans_count = ();
%trans_count_sum = ();
open(IN1,"$sent_file_1.words");
open(IN2,"$sent_file_2.words");
open(TRAIN1,">$sent_file_1.words.train");
open(TRAIN2,">$sent_file_2.words.train");
$sent_ctr = 0;
$print_ctr = 0;
print "Iteration 1\n";
while (($line_1 = <IN1>) && ($line_2 = <IN2>)) {
    $sent_ctr++;
    $print_ctr++;
    if ($print_ctr == 100) {
	print "\r$sent_ctr sentence pairs";
	$print_ctr = 0;
    }
    @tokens_1 = split(' ',$line_1);
    foreach $token (@tokens_1) {
	if (!exists($token_1_cnt{$token})) {
	    $token = '(other)';
	}
    }
    push(@tokens_1,'(empty)');
    @tokens_2 = split(' ',$line_2);
    foreach $token (@tokens_2) {
	if (!exists($token_2_cnt{$token})) {
	    $token = '(other)';
	}
    }
    print TRAIN1 "@tokens_1\n";
    print TRAIN2 "@tokens_2\n";
    $fract_count = 1/@tokens_1;
    foreach $token_2 (@tokens_2) {
	foreach $token_1 (@tokens_1) {
	    $trans_count{$token_1}{$token_2} += $fract_count;
	    $trans_count_sum{$token_1} += $fract_count;
	}
    }
}
close(TRAIN1);
close(TRAIN2);
print "\r$sent_ctr sentence pairs\n";

$num_probs = 0;
$trans_prob = {};
while (($token_1,$ref) = each %trans_count) {
    $count_sum = $trans_count_sum{$token_1};
    while (($token_2,$count) = each %$ref) {
	$$trans_prob{$token_1}{$token_2} = $count/$count_sum;
	$num_probs++;
    }
}
print "$num_probs probabilities in model\n\n";

$iteration_count = 1;
foreach $i (1..($em_iterations-1)) {
    $iteration_count++;
    print "Iteration $iteration_count\n";
    %trans_count = ();
    %trans_count_sum = ();
    open(IN1,"$sent_file_1.words.train");
    open(IN2,"$sent_file_2.words.train");
    $sent_ctr = 0;
    $print_ctr = 0;
    $score_sum = 0;
    while (($line_1 = <IN1>) && ($line_2 = <IN2>)) {
	$sent_ctr++;
	$print_ctr++;
	if ($print_ctr == 100) {
	    print "\r$sent_ctr sentence pairs";
	    $print_ctr = 0;
	}
	@tokens_1 = split(' ',$line_1);
	@tokens_2 = split(' ',$line_2);
	$fract_count_limit = 1/@tokens_1;
	foreach $token_2 (@tokens_2) {
	    $trans_prob_sum = 0;
	    foreach $token_1 (@tokens_1) {
		$trans_prob_sum += $$trans_prob{$token_1}{$token_2};
	    }
	    $score_sum -= log($trans_prob_sum);
	    foreach $token_1 (@tokens_1) {
		$fract_count = $$trans_prob{$token_1}{$token_2}/$trans_prob_sum;
		if ($fract_count > $fract_count_limit) {
		    $trans_count{$token_1}{$token_2} += $fract_count;
		    $trans_count_sum{$token_1} += $fract_count;
		}
		else {
		    $trans_count{'(empty)'}{$token_2} += $fract_count;
		    $trans_count_sum{'(empty)'} += $fract_count;
		}
	    }
	}
    }
    close(IN1);
    close(IN2);
    print "\r$sent_ctr sentence pairs\n";
    $trans_prob = {};
    $num_probs = 0;
    while (($token_1,$ref) = each %trans_count) {
	$count_sum = $trans_count_sum{$token_1};
	while (($token_2,$count) = each %$ref) {
	    $$trans_prob{$token_1}{$token_2} = $count/$count_sum;
	    $num_probs++;
	}
    }
    print "$num_probs probabilities in model\n";
    print "total training score: $score_sum\n\n";
}

open(OUT,">model-one");
while (($token_1,$ref) = each %$trans_prob) {
    while (($token_2,$prob) = each %$ref) {
	print OUT "$prob $token_1 $token_2\n";
    }
}
close(OUT);

$final_time = (times)[0];
$total_time = $final_time - $start_time;
print "$total_time seconds total time\n";
