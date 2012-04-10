#!c:/Perl/bin/perl

# (c) Microsoft Corporation. All rights reserved.

# Aligns parallel corpora using sentence lengths.  Approach is similar
# to IBM, except that pure empirical probabilities are used to
# estimate priors on sentence lengths, and a simple poisson
# distribution is used to estimate the probability of the length of a
# sentence based on the length of its translation. Paragraph breaks
# are ignored, and no anchor points are assumed.

# The search is an iterative, beam-pruned DP.  DP search is performed
# along the main diagonal of the alignment space, within the beam
# width.  The search is iteratively repeated, maintaining a fixed
# margin around the main diagonal, until the best path falls within a
# set bound of the margin everywhere.  Depending on a flag, bead
# probabilities are also re-estimated with each iteration, and
# iteration continues until bead probabilities converge.

# Confidence probabilities are computed for best path alignment using
# forward-backward algorithm.

$start_time = (times)[0];

$smooth_flag = 0;
$iterate_flag = 0;
$search_increment_ratio = 1.5;
$high_prob_threshold = log(0.99);
$conf_threshold = -20;
$conf_increment_ratio = 1.15;
$log_one_half = log(0.5);

($sent_file_1,$sent_file_2,$init_search_deviation,$min_beam_margin) = @ARGV;

$sent_file_2_mod = $sent_file_2;
$sent_file_2_mod =~ tr/\/\\/--/;

if (!defined($init_search_deviation)) {
    $init_search_deviation = 20;
}

if (!defined($min_beam_margin)) {
    $min_beam_margin = $init_search_deviation/4;
}

open(IN,"$sent_file_1") ||
    die("cannot open data file $sent_file_1\n");

print "\nReading $sent_file_1\n";

$sent_cnt_1 = 0;
$skipped_lines_1 = 0;
$skipping = 0;
while ($line = <IN>) {
    chomp($line);
    if ($line eq '*|*|*') {
	if ($skipping) {
	    $skipping = 0;
	}
	else {
	  $skipping = 1;
	}
	next;
    }
    elsif ($skipping) {
	next;
    }
    $num_words = grep($_,split(/\s+\(?|\(|-|_/,$line));
    if ($num_words) {
	$word_cnt_1 += $num_words;
	$length_cnt_1{$num_words}++;
	$sent_length_1{$sent_cnt_1} = $num_words;
	$sent_cnt_1++;
    }
    else {
	$skipped_lines_1++;
    }
}
close(IN);

print "     $sent_cnt_1 good lines, $skipped_lines_1 lines skipped\n";

while (($length,$count) = each %length_cnt_1) {
    $current_length_score_1 =  -log($count/$sent_cnt_1);
    $length_neg_log_prob_1{$length} = $current_length_score_1;
}

open(IN,"$sent_file_2") ||
    die("cannot open data file $sent_file_2\n");

print "Reading $sent_file_2\n";

$sent_cnt_2 = 0;
$skipped_lines_2 = 0;
$skipping = 0;
while ($line = <IN>) {
    chomp($line);
    if ($line eq '*|*|*') {
	if ($skipping) {
	    $skipping = 0;
	}
	else {
	  $skipping = 1;
	}
	next;
    }
    elsif ($skipping) {
	next;
    }
    $num_words = grep($_,split(/\s+\(?|\(|-|_/,$line));
    if ($num_words) {
	$word_cnt_2 += $num_words;
	$length_cnt_2{$num_words}++;
	$sent_length_2{$sent_cnt_2} = $num_words;
	if ($sent_cnt_2 > 0 && $prev_length > 0 && $num_words > 0) {
	    $target_pair_2_neg_log_prob{$prev_length}{$num_words} = undef;
	}
	$prev_length = $num_words;
	$sent_cnt_2++;
    }
    else {
	$skipped_lines_2++;
    }
}
close(IN);

print "     $sent_cnt_2 good lines, $skipped_lines_2 lines skipped\n";

while (($length,$count) = each %length_cnt_2) {
    $current_length_score_2 =  -log($count/$sent_cnt_2);
    $length_neg_log_prob_2{$length} = $current_length_score_2;
}

while (($first_length,$ref) = each %target_pair_2_neg_log_prob) {
    foreach $second_length (keys(%$ref)) {
	$score_sum = $length_neg_log_prob_2{$first_length} + $length_neg_log_prob_2{$second_length};
	$normalizing_score{$first_length+$second_length} = undef;
	$target_pair_2_neg_log_prob{$first_length}{$second_length} = $score_sum;
    }
}

foreach $length_sum (keys(%normalizing_score)) {
    for ($i = 1; $i < $length_sum; $i++) {
	$j = $length_sum - $i;
	if (defined($score_1 = $length_neg_log_prob_2{$i}) &&
	    defined($score_2 = $length_neg_log_prob_2{$j})) {
	    $normalizing_score{$length_sum} += exp(-($score_1+$score_2));
	}
    }
}

foreach $length_sum (keys(%normalizing_score)) {
    $normalizing_score{$length_sum} = -log($normalizing_score{$length_sum});
}

while (($first_length,$ref) = each %target_pair_2_neg_log_prob) {
    foreach $second_length (keys(%$ref)) {
	$target_pair_2_neg_log_prob{$first_length}{$second_length} -=
	    $normalizing_score{$first_length+$second_length};
    }
}

$mean_bead_length_ratio = ($word_cnt_2/$sent_cnt_2)/($word_cnt_1/$sent_cnt_1);

sub length_neg_log_cond_prob_2 {
    local $length1;
    my $length2;
    ($length1,$length2) = @_;
    if ($result = $cache{$length1}{$length2}) {
	return($result);
    }
    $mean = $length1 * $mean_bead_length_ratio;
    $log_mean = log($mean);
    return(&neg_log_poisson($length2));
}

sub neg_log_poisson {
    my ($length2) = @_;
    my $result;
    if ($length2 == 0) {
	return($mean);
    }
    elsif (defined($result = $cache{$length1}{$length2})) {
	return($result);
    }
    else {
	$result = &neg_log_poisson($length2-1) + log($length2) - $log_mean;
	$cache{$length1}{$length2} = $result;
	return($result);
    }
}

$match_score_base = -log(.94);      # 1-1
$contract_score_base = -log(.02);   # 2-1
$expand_score_base = -log(.02);     # 1-2
$delete_score_base = -log(.01);     # 1-0
$insert_score_base = -log(.01);     # 0-1

$sent_cnt_ratio = $sent_cnt_2/$sent_cnt_1;

$alignment_diffs = $sent_cnt_1;
$backtrace = {};
$max_path_deviation = $init_search_deviation / $search_increment_ratio;
$conf_threshold /= $conf_increment_ratio;
$search_deviation = 0;

$intermed_time_1 = (times)[0];
$init_time = $intermed_time_1 - $start_time;
print "$init_time seconds initialization time\n";

print "\nAligning sentences by length\n";

# Forward pass

print "\nForward pass of forward-backward algorithm\n\n";

$iteration = 0;
while (($alignment_diffs && $iterate_flag) ||
       (($max_path_deviation + $min_beam_margin) > $search_deviation)) {
    $intermed_time_1 = (times)[0];
    $search_deviation = $max_path_deviation * $search_increment_ratio;
    $conf_threshold *= $conf_increment_ratio;
    $margin_limit = $max_path_deviation + $min_beam_margin;
    if ($margin_limit > $search_deviation) {
	$search_deviation = $margin_limit;
    }
    $iteration++;
    print "Iteration $iteration with search deviation $search_deviation\n\n";
    %forward_log_prob = ();
    $forward_prob_cnt = 0;
    $old_backtrace = $backtrace;
    $backtrace = {};
    $forward_log_prob{0}{0} = 0;
    $pos_1 = 0;
    $print_ctr = 0;
    while ($pos_1 <= $sent_cnt_1) {
	$diagonal_pos = int(($sent_cnt_ratio * $pos_1) + 0.000001);
	$lower_limit = int($diagonal_pos - $search_deviation);
	if ($lower_limit < 0) {
	    $lower_limit = 0;
	}
	$upper_limit = int($diagonal_pos + $search_deviation);
	if ($upper_limit > $sent_cnt_2) {
	    $upper_limit = $sent_cnt_2;
	}
	if ($print_ctr == 100) {
	    print "\rposition $pos_1, $lower_limit-$upper_limit";
	    $print_ctr = 0;
	}
	$pos_1_minus_1 = $pos_1-1;
	$pos_1_minus_2 = $pos_1-2;
	$length_pos_1_minus_1 = $sent_length_1{$pos_1_minus_1};
	$length_pos_1_minus_2 = $sent_length_1{$pos_1_minus_2};
	$length_pair_1 = $length_pos_1_minus_1 + $length_pos_1_minus_2;
	$length_neg_log_prob_pos_1_minus_1  = $length_neg_log_prob_1{$length_pos_1_minus_1};
	$length_neg_log_prob_pos_1_minus_2  = $length_neg_log_prob_1{$length_pos_1_minus_2};
	for ($pos_2 = $lower_limit; $pos_2 <= $upper_limit; $pos_2++) {
	    $pos_2_minus_1 = $pos_2-1;
	    $pos_2_minus_2 = $pos_2-2;
	    $length_pos_2_minus_1 = $sent_length_2{$pos_2_minus_1};
	    $length_pos_2_minus_2 = $sent_length_2{$pos_2_minus_2};
	    @forward_log_probs = ();
	    $best_score = undef;
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2})) {
		$new_bead_score = $delete_score_base +
		    $length_neg_log_prob_pos_1_minus_1;
		$new_score = $new_bead_score - $forward_log_prob;
		push(@forward_log_probs,-$new_score);
		if(!defined($best_score) || ($new_score < $best_score)) {
		    $best_score = $new_score;
		    $best_bead_score = $new_bead_score;
		    $best_bead = 'delete';
		}
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1}{$pos_2_minus_1})) {
		$new_bead_score = $insert_score_base +
			$length_neg_log_prob_2{$length_pos_2_minus_1};
		$new_score = $new_bead_score - $forward_log_prob;
		push(@forward_log_probs,-$new_score);
		if(!defined($best_score) || ($new_score < $best_score)) {
		    $best_score = $new_score;
		    $best_bead_score = $new_bead_score;
		    $best_bead = 'insert';
		}
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2_minus_1})) {
		$new_bead_score = $match_score_base +
		    $length_neg_log_prob_pos_1_minus_1 +
			&length_neg_log_cond_prob_2($length_pos_1_minus_1,$length_pos_2_minus_1);
		$new_score = $new_bead_score - $forward_log_prob;
		push(@forward_log_probs,-$new_score);
		if(!defined($best_score) || ($new_score < $best_score)) {
		    $best_score = $new_score;
		    $best_bead_score = $new_bead_score;
		    $best_bead = 'match';
		}
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_2}{$pos_2_minus_1})) {
		$new_bead_score = $contract_score_base +
		    $length_neg_log_prob_pos_1_minus_1 +
			$length_neg_log_prob_pos_1_minus_2 +
			    &length_neg_log_cond_prob_2($length_pair_1,$length_pos_2_minus_1);
		$new_score = $new_bead_score - $forward_log_prob;
		push(@forward_log_probs,-$new_score);
		if(!defined($best_score) || ($new_score < $best_score)) {
		    $best_score = $new_score;
		    $best_bead_score = $new_bead_score;
		    $best_bead = 'contract';
		}
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2_minus_2})) {
		if (!defined($target_pair_2_neg_log_prob{$length_pos_2_minus_2}{$length_pos_2_minus_1})) {
		    print "ERROR: no normalization for expand pair\n";
		}
		$new_bead_score = $expand_score_base +
		    $length_neg_log_prob_1{$length_pos_1_minus_1} +
			$target_pair_2_neg_log_prob{$length_pos_2_minus_2}{$length_pos_2_minus_1} +
			    &length_neg_log_cond_prob_2($length_pos_1_minus_1,$length_pos_2_minus_1 + $length_pos_2_minus_2);
		$new_score = $new_bead_score - $forward_log_prob;
		push(@forward_log_probs,-$new_score);
		if(!defined($best_score) || ($new_score < $best_score)) {
		    $best_score = $new_score;
		    $best_bead_score = $new_bead_score;
		    $best_bead = 'expand';
		}
	    }
	    if (defined($best_score)) {
		$forward_log_prob{$pos_1}{$pos_2} = &log_add_list(@forward_log_probs);
		$forward_prob_cnt++;
		$$backtrace{$pos_1}{$pos_2} = $best_bead;
	    }
	}
	$pos_1++;
	$print_ctr++;
    }
    print "\rposition $pos_1, $lower_limit-$upper_limit\n";
    $total_observation_log_prob = $forward_log_prob{$sent_cnt_1}{$sent_cnt_2};
    print "Forward probs computed: $forward_prob_cnt\n";
    print "End to end forward score: $total_observation_log_prob\n";
    %bead_type_cnt = ();
    if ($smooth_flag) {
	$total_bead_cnt = 1000;  # smoothing by adding 1000 counts in original distribution
    }
    else {
	$total_bead_cnt = 5;  # add-one smoothing for 5 bead types
    }
    $max_path_deviation = 0;
    $pos_1 = $sent_cnt_1;
    $pos_2 = $sent_cnt_2;
    $alignment_diffs = 0;
    until (($pos_1 == 0) && ($pos_2 == 0)) {
	$deviation = abs(int(($sent_cnt_ratio * $pos_1) + 0.000001) - $pos_2);
	if ($deviation > $max_path_deviation) {
	    $max_path_deviation = $deviation;
	}
	$bead = $$backtrace{$pos_1}{$pos_2};
	if ($bead ne $$old_backtrace{$pos_1}{$pos_2}) {
	    $alignment_diffs++;
	}
	$bead_type_cnt{$bead}++;
	$total_bead_cnt++;
	if ($bead eq 'match') {
	    $pos_1--;
	    $pos_2--;
	}
	elsif ($bead eq 'contract') {
	    $pos_1 -= 2;
	    $pos_2--;
	}
	elsif ($bead eq 'expand') {
	    $pos_1--;
	    $pos_2 -= 2;
	}
	elsif ($bead eq 'delete') {
	    $pos_1--;
	}
	elsif ($bead eq 'insert') {
	    $pos_2--;
	}
	else {
	    die "ERROR: Bead |$bead| unrecognized at $pos_1,$pos_2\n";
	}
    }
    print "max deviation: $max_path_deviation\n";
    print "$alignment_diffs alignment differences\n";
    print "\n$total_bead_cnt total beads:\n";
    while (($bead,$count) = each %bead_type_cnt) {
	print "  $count $bead\n";
    }
    $intermed_time_2 = (times)[0];
    $pass_time = $intermed_time_2 - $intermed_time_1;
    print "$pass_time seconds forward pass time\n\n";
    if ($iterate_flag) {
	if ($smooth_flag) {
	    $match_score_base = -log(($bead_type_cnt{'match'}+940)/$total_bead_cnt);         # 1-1
	    $contract_score_base = -log(($bead_type_cnt{'contract'}+20)/$total_bead_cnt);   # 2-1
	    $expand_score_base = -log(($bead_type_cnt{'expand'}+20)/$total_bead_cnt);       # 1-2
	    $delete_score_base = -log(($bead_type_cnt{'delete'}+10)/$total_bead_cnt);       # 1-0
	    $insert_score_base = -log(($bead_type_cnt{'insert'}+10)/$total_bead_cnt);       # 0-1
	}
	else {
	    $match_score_base = -log(($bead_type_cnt{'match'}+1)/$total_bead_cnt);         # 1-1
	    $contract_score_base = -log(($bead_type_cnt{'contract'}+1)/$total_bead_cnt);   # 2-1
	    $expand_score_base = -log(($bead_type_cnt{'expand'}+1)/$total_bead_cnt);       # 1-2
	    $delete_score_base = -log(($bead_type_cnt{'delete'}+1)/$total_bead_cnt);       # 1-0
	    $insert_score_base = -log(($bead_type_cnt{'insert'}+1)/$total_bead_cnt);       # 0-1
	}
    }
}

# Backward pass
    
print "Backward pass of forward-backward algorithm with $conf_threshold pruning threshold\n\n";

$total_bead_cnt = 0;
%bead_type_cnt = ();
$high_prob_match_cnt = 0;
%backward_log_prob = ();
@backtrace_list = ();
$backward_prob_cnt = 0;
$saved_backward_prob_cnt = 0;
$backward_log_prob{$sent_cnt_1}{$sent_cnt_2} = 0;
$pos_1 =  $sent_cnt_1 + 1;
$print_ctr = 0;
while ($pos_1 > 0) {
    $pos_1--;
    $diagonal_pos = int(($sent_cnt_ratio * $pos_1) + 0.000001);
    $lower_limit = int($diagonal_pos - $search_deviation);
    if ($lower_limit < 0) {
	$lower_limit = 0;
    }
    $upper_limit = int($diagonal_pos + $search_deviation);
    if ($upper_limit > $sent_cnt_2) {
	$upper_limit = $sent_cnt_2;
    }
    $backward_prob_cnt_diff = $backward_prob_cnt - $old_backward_prob_cnt;
    if ($print_ctr == 100) {
	print "\rposition $pos_1, $lower_limit-$upper_limit, $backward_prob_cnt_diff         ";
	$print_ctr = 0;
    }
    $old_backward_prob_cnt = $backward_prob_cnt;
    $print_ctr++;
    $pos_1_plus_1 = $pos_1+1;
    $pos_1_plus_2 = $pos_1+2;
    $length_pos_1 = $sent_length_1{$pos_1};
    $length_pos_1_plus_1 = $sent_length_1{$pos_1_plus_1};
    $length_pair_1 = $length_pos_1 + $length_pos_1_plus_1;
    $length_neg_log_prob_pos_1 = $length_neg_log_prob_1{$length_pos_1};
    $length_neg_log_prob_pos_1_plus_1 = $length_neg_log_prob_1{$length_pos_1_plus_1};
    for ($pos_2 = $upper_limit; $pos_2 >= $lower_limit; $pos_2--) {
	$norm_forward_log_prob = $forward_log_prob{$pos_1}{$pos_2} - $total_observation_log_prob;
	$pos_2_plus_1 = $pos_2+1;
	$length_pos_2 = $sent_length_2{$pos_2};
	$length_pos_2_plus_1 = $sent_length_2{$pos_2_plus_1};
	@backward_log_probs = ();
	if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2})) {
	    $new_bead_score = $delete_score_base +
		$length_neg_log_prob_pos_1;
	    $bead_backward_log_prob = $backward_log_prob - $new_bead_score;
	    $bead_total_log_prob = $bead_backward_log_prob + $norm_forward_log_prob;
	    if ($bead_total_log_prob > $log_one_half) {
		push(@backtrace_list,[$pos_1,$pos_2,'delete',exp($bead_total_log_prob)]);
		$bead_type_cnt{'delete'}++;
		$total_bead_cnt++;
	    }
	    push(@backward_log_probs,$bead_backward_log_prob);
	}
	if (defined($backward_log_prob = $backward_log_prob{$pos_1}{$pos_2_plus_1})) {
	    $new_bead_score = $insert_score_base +
		$length_neg_log_prob_2{$length_pos_2};
	    $bead_backward_log_prob = $backward_log_prob - $new_bead_score;
	    $bead_total_log_prob = $bead_backward_log_prob + $norm_forward_log_prob;
	    if ($bead_total_log_prob > $log_one_half) {
		push(@backtrace_list,[$pos_1,$pos_2,'insert',exp($bead_total_log_prob)]);
		$bead_type_cnt{'insert'}++;
		$total_bead_cnt++;
	    }
	    push(@backward_log_probs,$bead_backward_log_prob);
	}
	if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2_plus_1})) {
	    $new_bead_score = $match_score_base +
		$length_neg_log_prob_pos_1 +
		    &length_neg_log_cond_prob_2($length_pos_1,$length_pos_2);
	    $bead_backward_log_prob = $backward_log_prob - $new_bead_score;
	    $bead_total_log_prob = $bead_backward_log_prob + $norm_forward_log_prob;
	    if ($bead_total_log_prob > $log_one_half) {
		push(@backtrace_list,[$pos_1,$pos_2,'match',exp($bead_total_log_prob)]);
		$bead_type_cnt{'match'}++;
		$total_bead_cnt++;
		if ($bead_total_log_prob > $high_prob_threshold) {
		    $high_prob_match_cnt++;
		}
	    }
	    push(@backward_log_probs,$bead_backward_log_prob);
	}
	if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_2}{$pos_2_plus_1})) {
	    $new_bead_score = $contract_score_base +
		$length_neg_log_prob_pos_1 + 
		    $length_neg_log_prob_pos_1_plus_1 + 
			&length_neg_log_cond_prob_2($length_pair_1,$length_pos_2);
	    $bead_backward_log_prob = $backward_log_prob - $new_bead_score;
	    $bead_total_log_prob = $bead_backward_log_prob + $norm_forward_log_prob;
	    if ($bead_total_log_prob > $log_one_half) {
		push(@backtrace_list,[$pos_1,$pos_2,'contract',exp($bead_total_log_prob)]);
		$bead_type_cnt{'contract'}++;
		$total_bead_cnt++;
	    }
	    push(@backward_log_probs,$bead_backward_log_prob);
	}
	if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2+2})) {
	    $new_bead_score = $expand_score_base +
		$length_neg_log_prob_pos_1 +
		    $target_pair_2_neg_log_prob{$length_pos_2}{$length_pos_2_plus_1} +
			&length_neg_log_cond_prob_2($length_pos_1,$length_pos_2 + $length_pos_2_plus_1);
	    $bead_backward_log_prob = $backward_log_prob - $new_bead_score;
	    $bead_total_log_prob = $bead_backward_log_prob + $norm_forward_log_prob;
	    if ($bead_total_log_prob > $log_one_half) {
		push(@backtrace_list,[$pos_1,$pos_2,'expand',exp($bead_total_log_prob)]);
		$bead_type_cnt{'expand'}++;
		$total_bead_cnt++;
	    }
	    push(@backward_log_probs,$bead_backward_log_prob);
	}
	if (@backward_log_probs > 0) {
	    $backward_prob_cnt++;
	    $backward_log_prob = &log_add_list(@backward_log_probs);
	    $total_log_prob = $backward_log_prob + $norm_forward_log_prob;
	    if ($total_log_prob > $conf_threshold) {
		$saved_backward_prob_cnt++;
		$backward_log_prob{$pos_1}{$pos_2} = $backward_log_prob;
	    }
	}
    }
}
print "\rposition $pos_1, $lower_limit-$upper_limit         \n";

print "Backward probs computed: $backward_prob_cnt\n";
print "Backward probs saved: $saved_backward_prob_cnt\n";
print "End to end backward score: $backward_log_prob{0}{0}\n";

print "\n$total_bead_cnt total beads:\n";
while (($bead,$count) = each %bead_type_cnt) {
    print "  $count $bead\n";
}
print "$high_prob_match_cnt high prob matches\n";

$intermed_time_3 = (times)[0];
$pass_time = $intermed_time_3 - $intermed_time_2;
print "$pass_time seconds backward pass time\n";

open(OUT,">$sent_file_1.$sent_file_2_mod.length-backtrace");
while (@backtrace_list) {
    ($pos_1,$pos_2,$bead,$prob) = @{pop(@backtrace_list)};
    printf OUT "%6d %6d %-8s %10.8f\n",$pos_1,$pos_2,$bead,$prob;
}
close(OUT);

open(SEARCH,">$sent_file_1.$sent_file_2_mod.search-nodes");
while (($pos_1,$ref) = each %backward_log_prob) {
    foreach $pos_2 (keys(%$ref)) {
	print SEARCH "$pos_1 $pos_2\n";
    }
}
close(SEARCH);

$final_time = (times)[0];
$total_time = $final_time - $start_time;
print "\n$total_time seconds total time\n";

sub log_add_list {
    my ($log_y,@log_x_list) = @_;
    my ($log_x,@new_log_x_list,$x_div_y_sum);
    if (!defined($log_y)) {
	return(undef);
    }
    elsif (@log_x_list == 0) {
	return($log_y);
    }
    else {
	@new_log_x_list = ();
	foreach $log_x (@log_x_list) {
	    if ($log_x > $log_y) {
		push(@new_log_x_list,$log_y);
		$log_y = $log_x;
	    }
	    else {
		push(@new_log_x_list,$log_x);
	    }
	}
	$x_div_y_sum_plus_1 = 1;
	foreach $log_x (@new_log_x_list) {
	    $x_div_y_sum_plus_1 += exp($log_x-$log_y);
	}
	return($log_y + log($x_div_y_sum_plus_1));
    }
}
