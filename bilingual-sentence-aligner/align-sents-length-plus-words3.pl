#!c:/Perl/bin/perl

# (c) Microsoft Corporation. All rights reserved.

# Aligns parallel corpora using sentence lengths, using both sentence
# lengths and word associations.  The idea is to first align on the
# basis of sentence lengths; use the highest probability matches to
# generate word association probabilities, (using IBM model 1), and
# then re-align using the word association probabilities.  The
# word-based alignment is much slower that the length-based alignment,
# but we limit the application of the word-based model to plausible
# alignments produced by the length-based method, so in practice it
# doesn't take that much longer.

$start_time = (times)[0];

($sent_file_1,$sent_file_2,$init_search_deviation,$min_beam_margin) = @ARGV;

$sent_file_2_mod = $sent_file_2;
$sent_file_2_mod =~ tr/\/\\/--/;

$smooth_flag = 0;
$iterate_flag = 0;
$increment_ratio = 1.5;
$high_prob_threshold = 0.99;
$log_high_prob_threshold = log($high_prob_threshold);
$conf_threshold = -20;
$conf_threshold_prob = exp($conf_threshold);
$log_one_half = log(0.5);
$bead_type_diff_threshold = 0.0001;

open(MODEL,"$sent_file_1.$sent_file_2_mod.model-one") ||
    die("cannot open data file $sent_file_1.$sent_file_2_mod.model-one\n");

print "\nReading $sent_file_1.$sent_file_2_mod.model-one\n";

$word_assoc_cnt = 0;
while ($line = <MODEL>) {
    ($prob,$token_1,$token_2) = split(' ',$line);
    $trans_prob{$token_1}{$token_2} = $prob;
    $type_1{$token_1} = 1;
    $type_2{$token_2} = 1;
    $word_assoc_cnt++;
}
print "     $word_assoc_cnt word associations\n";

if (!defined($init_search_deviation)) {
    $init_search_deviation = 20;
}

if (!defined($min_beam_margin)) {
    $min_beam_margin = $init_search_deviation/4;
}

open(IN,"$sent_file_1") ||
    die("cannot open data file $sent_file_1\n");

print "Reading $sent_file_1\n";

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
    @words = grep($_,split(/\s+\(?|\(|-|_/,$line));
    $num_words = @words;
    if ($num_words) {
	$word_cnt_1 += $num_words;
	$length_cnt_1{$num_words}++;
	$sent_length_1{$sent_cnt_1} = $num_words;
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
	    if (!exists($type_1{$word})) {
		$word = '(other)';
	    }
	    $token_cnt_1{$word}++;
	    $total_cnt_1++;
	}
	$words_1{$sent_cnt_1} = [@words];
	$sent_cnt_1++;
    }
    else {
	$skipped_lines_1++;
    }
}
close(IN);

print "     $sent_cnt_1 good lines, $skipped_lines_1 lines skipped\n";

while (($word,$count) = each %token_cnt_1) {
    $token_score_1{$word} = -log($count/$total_cnt_1);
}
undef(%token_cnt_1);

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
    @words = grep($_,split(/\s+\(?|\(|-|_/,$line));
    $num_words = @words;
    if ($num_words) {
	$word_cnt_2 += $num_words;
	$length_cnt_2{$num_words}++;
	$sent_length_2{$sent_cnt_2} = $num_words;
	if ($sent_cnt_2 > 0 && $prev_length > 0 && $num_words > 0) {
	    $target_pair_2_neg_log_prob{$prev_length}{$num_words} = undef;
	}
	$prev_length = $num_words;
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
	    if (!exists($type_2{$word})) {
		$word = '(other)';
	    }
	    $token_cnt_2{$word}++;
	    $total_cnt_2++;
	}
	$words_2{$sent_cnt_2} = [@words];
	$sent_cnt_2++;
    }
    else {
	$skipped_lines_2++;
    }
}
close(IN);

print "     $sent_cnt_2 good lines, $skipped_lines_2 lines skipped\n";

while (($word,$count) = each %token_cnt_2) {
    $token_score_2{$word} = -log($count/$total_cnt_2);
}
undef(%token_cnt_2);

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
	if (($score_1 = $length_neg_log_prob_2{$i}) && ($score_2 = $length_neg_log_prob_2{$j})) {
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

$node_count = 0;
if (open(NODES,"$sent_file_1.$sent_file_2_mod.search-nodes")) {
    $align_by_length = 0;
    print "Reading $sent_file_1.$sent_file_2_mod.search-nodes\n";
    while ($line = <NODES>) {
	($pos_1,$pos_2) = split(' ',$line);
	    $length_backward_log_prob{$pos_1}{$pos_2} = 1;
	    $node_count++;
    }
    close(NODES);
    print "     $node_count search nodes\n";
}
else {
   $align_by_length = 1;
}

$intermed_time_1 = (times)[0];
$init_time = $intermed_time_1 - $start_time;
print "$init_time seconds initialization time\n";

if ($align_by_length) {
    print "\nALIGNING SENTENCES BY LENGTH\n";
    
    # Forward pass
    
    print "\nForward pass of forward-backward algorithm\n\n";
    
    $alignment_diffs = $sent_cnt_1;
    $backtrace = {};
    $max_path_deviation = $init_search_deviation / $increment_ratio;
    $search_deviation = 0;
    $iteration = 0;
    while (($max_path_deviation + $min_beam_margin) > $search_deviation) {
	$intermed_time_1 = (times)[0];
	$search_deviation = $max_path_deviation * $increment_ratio;
	$margin_limit = $max_path_deviation + $min_beam_margin;
	if ($margin_limit > $search_deviation) {
	    $search_deviation = $margin_limit;
	}
	$iteration++;
	print "Iteration $iteration with search deviation $search_deviation\n\n";
	%forward_log_prob = ();
	$old_backtrace = $backtrace;
	$backtrace = {};
	$forward_prob_cnt = 1;
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
	print "$pass_time seconds forward pass time\n";
    }
    
# Backward pass
    
    print "\nBackward pass of forward-backward algorithm\n\n";
    
    $total_bead_cnt = 0;
    %bead_type_cnt = ();
    $high_prob_match_cnt = 0;
    %length_backward_log_prob = ();
    $backward_prob_cnt = 1;
    $saved_backward_prob_cnt = 1;
    $length_backward_log_prob{$sent_cnt_1}{$sent_cnt_2} = 0;
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
	if ($print_ctr == 100) {
	    print "\rposition $pos_1, $lower_limit-$upper_limit         ";
	    $print_ctr = 0;
	}
	$print_ctr++;
	$pos_1_plus_1 = $pos_1+1;
	$pos_1_plus_2 = $pos_1+2;
	$length_pos_1 = $sent_length_1{$pos_1};
	$length_pos_1_plus_1 = $sent_length_1{$pos_1_plus_1};
	$length_pair_1 = $length_pos_1 + $length_pos_1_plus_1;
	for ($pos_2 = $upper_limit; $pos_2 >= $lower_limit; $pos_2--) {
	    $norm_forward_log_prob = $forward_log_prob{$pos_1}{$pos_2} - $total_observation_log_prob;
	    $pos_2_plus_1 = $pos_2+1;
	    $length_pos_2 = $sent_length_2{$pos_2};
	    $length_pos_2_plus_1 = $sent_length_2{$pos_2_plus_1};
	    @length_backward_log_probs = ();
	    $backtrace_cnt = 0;
	    if (defined($length_backward_log_prob = $length_backward_log_prob{$pos_1_plus_1}{$pos_2})) {
		$new_bead_score = $delete_score_base +
		    $length_neg_log_prob_1{$length_pos_1};
		$bead_length_backward_log_prob = $length_backward_log_prob - $new_bead_score;
		$bead_total_log_prob = $bead_length_backward_log_prob + $norm_forward_log_prob;
		if ($bead_total_log_prob > $log_one_half) {
		    $backtrace_cnt++;
		    $bead_type_cnt{'delete'}++;
		    $total_bead_cnt++;
		}
		push(@length_backward_log_probs,$bead_length_backward_log_prob);
	    }
	    if (defined($length_backward_log_prob = $length_backward_log_prob{$pos_1}{$pos_2_plus_1})) {
		$new_bead_score = $insert_score_base +
		    $length_neg_log_prob_2{$length_pos_2};
		$bead_length_backward_log_prob = $length_backward_log_prob - $new_bead_score;
		$bead_total_log_prob = $bead_length_backward_log_prob + $norm_forward_log_prob;
		if ($bead_total_log_prob > $log_one_half) {
		    $backtrace_cnt++;
		    $bead_type_cnt{'insert'}++;
		    $total_bead_cnt++;
		}
		push(@length_backward_log_probs,$bead_length_backward_log_prob);
	    }
	    if (defined($length_backward_log_prob = $length_backward_log_prob{$pos_1_plus_1}{$pos_2_plus_1})) {
		$new_bead_score = $match_score_base +
		    $length_neg_log_prob_1{$length_pos_1} +
			&length_neg_log_cond_prob_2($length_pos_1,$length_pos_2);
		$bead_length_backward_log_prob = $length_backward_log_prob - $new_bead_score;
		$bead_total_log_prob = $bead_length_backward_log_prob + $norm_forward_log_prob;
		if ($bead_total_log_prob > $log_one_half) {
		    $backtrace_cnt++;
		    $bead_type_cnt{'match'}++;
		    $total_bead_cnt++;
		    if ($bead_total_log_prob > $log_high_prob_threshold) {
			$high_prob_match_cnt++;
		    }
		}
		push(@length_backward_log_probs,$bead_length_backward_log_prob);
	    }
	    if (defined($length_backward_log_prob = $length_backward_log_prob{$pos_1_plus_2}{$pos_2_plus_1})) {
		$new_bead_score = $contract_score_base +
		    $length_neg_log_prob_1{$length_pos_1} + 
			$length_neg_log_prob_1{$length_pos_1_plus_1} + 
			    &length_neg_log_cond_prob_2($length_pair_1,$length_pos_2);
		$bead_length_backward_log_prob = $length_backward_log_prob - $new_bead_score;
		$bead_total_log_prob = $bead_length_backward_log_prob + $norm_forward_log_prob;
		if ($bead_total_log_prob > $log_one_half) {
		    $backtrace_cnt++;
		    $bead_type_cnt{'contract'}++;
		    $total_bead_cnt++;
		}
		push(@length_backward_log_probs,$bead_length_backward_log_prob);
	    }
	    if (defined($length_backward_log_prob = $length_backward_log_prob{$pos_1_plus_1}{$pos_2+2})) {
		$new_bead_score = $expand_score_base +
		    $length_neg_log_prob_1{$length_pos_1} +
			$target_pair_2_neg_log_prob{$length_pos_2}{$length_pos_2_plus_1} +
			    &length_neg_log_cond_prob_2($length_pos_1,$length_pos_2 + $length_pos_2_plus_1);
		$bead_length_backward_log_prob = $length_backward_log_prob - $new_bead_score;
		$bead_total_log_prob = $bead_length_backward_log_prob + $norm_forward_log_prob;
		if ($bead_total_log_prob > $log_one_half) {
		    $backtrace_cnt++;
		    $bead_type_cnt{'expand'}++;
		    $total_bead_cnt++;
		}
		push(@length_backward_log_probs,$bead_length_backward_log_prob);
	    }
	    
	    
	    if ($backtrace_cnt > 1) {
		print "\nERROR: more than one backtrace bead at $pos_1, $pos_2\n";
		<STDIN>;
	    }
	    if (@length_backward_log_probs > 0) {
		$backward_prob_cnt++;
		$length_backward_log_prob = &log_add_list(@length_backward_log_probs);
		if (($length_backward_log_prob + $norm_forward_log_prob) > $conf_threshold) {
		    $saved_backward_prob_cnt++;
		    $length_backward_log_prob{$pos_1}{$pos_2} = $length_backward_log_prob;
		}
	    }
	}
    }
    print "\rposition $pos_1, $lower_limit-$upper_limit         \n";
    
    print "Backward probs computed: $backward_prob_cnt\n";
    print "Backward probs saved: $saved_backward_prob_cnt\n";
    print "End to end backward score: $length_backward_log_prob{0}{0}\n";
    
    print "\n$total_bead_cnt total beads:\n";
    while (($bead,$count) = each %bead_type_cnt) {
	print "  $count $bead\n";
    }
    print "$high_prob_match_cnt high prob matches\n";
    
    $intermed_time_3 = (times)[0];
    $pass_time = $intermed_time_3 - $intermed_time_2;
    print "$pass_time seconds backward pass time\n";
}

print "\nALIGNING SENTENCES BY LENGTH AND WORD ASSOCIATION\n";

%inside_bead_score = ();
$bead_type_total_score = 0;
$iteration = 1;
while ($iteration) {
    $intermed_time_3 = (times)[0];

    print "\nForward pass of forward-backward algorithm\n";
    if ($iterate_flag) {
	print "Iteration $iteration\n\n";
    }
    else {
	print "\n";
    }

    $forward_prob_cnt = 1;
    %forward_log_prob = ();
    $forward_log_prob{0}{0} = 0;
    $pos_1 = 0;
    $print_ctr = 0;
    while ($pos_1 <= $sent_cnt_1) {
	if ($print_ctr == 100) {
	    print "\rposition $pos_1";
	    $print_ctr = 0;
	}
	$pos_1_minus_1 = $pos_1-1;
	$pos_1_minus_2 = $pos_1-2;
	$length_pos_1_minus_1 = $sent_length_1{$pos_1_minus_1};
	$length_pos_1_minus_2 = $sent_length_1{$pos_1_minus_2};
	$length_pair_1 = $length_pos_1_minus_1 + $length_pos_1_minus_2;
	$length_neg_log_prob_pos_1_minus_1  = $length_neg_log_prob_1{$length_pos_1_minus_1};
	$length_neg_log_prob_pos_1_minus_2  = $length_neg_log_prob_1{$length_pos_1_minus_2};
	$words_pos_1_minus_1 = $words_1{$pos_1_minus_1};
	$words_pos_1_minus_2 = $words_1{$pos_1_minus_2};
	$words_pair_1 = [@$words_pos_1_minus_2,@$words_pos_1_minus_1];
	$word_seq_score_pos_1_minus_1 = &word_seq_score_1(@$words_pos_1_minus_1);
	$word_seq_score_pos_1_minus_2 = &word_seq_score_1(@$words_pos_1_minus_2);
	foreach $pos_2 (sort {$a <=> $b} keys(%{$length_backward_log_prob{$pos_1}})) {
	    $pos_2_minus_1 = $pos_2-1;
	    $pos_2_minus_2 = $pos_2-2;
	    $length_pos_2_minus_1 = $sent_length_2{$pos_2_minus_1};
	    $length_pos_2_minus_2 = $sent_length_2{$pos_2_minus_2};
	    $words_pos_2_minus_1 = $words_2{$pos_2_minus_1};
	    $words_pos_2_minus_2 = $words_2{$pos_2_minus_2};
	    @forward_log_probs = ();
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2})) {
		if (!defined($new_bead_score = $bead_score{$pos_1}{$pos_2}{'delete'})) {
		    $new_bead_score =
			$word_seq_score_pos_1_minus_1 +
			    $length_neg_log_prob_pos_1_minus_1;
		    $bead_score{$pos_1}{$pos_2}{'delete'} = $new_bead_score;
		}
		push(@forward_log_probs,$forward_log_prob-$new_bead_score-$delete_score_base);
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1}{$pos_2_minus_1})) {
		if (!defined($new_bead_score = $bead_score{$pos_1}{$pos_2}{'insert'})) {
		    $new_bead_score =
			&word_seq_score_2(@$words_pos_2_minus_1) +
			    $length_neg_log_prob_2{$length_pos_2_minus_1};
		    $bead_score{$pos_1}{$pos_2}{'insert'} = $new_bead_score;
		}
		push(@forward_log_probs,$forward_log_prob-$new_bead_score-$insert_score_base);
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2_minus_1})) {
		if (!defined($new_bead_score = $bead_score{$pos_1}{$pos_2}{'match'})) {
		    $new_bead_score =
			$word_seq_score_pos_1_minus_1 +
			    $length_neg_log_prob_pos_1_minus_1 +
				&word_seq_trans_score($words_pos_1_minus_1,$words_pos_2_minus_1) +
				    &length_neg_log_cond_prob_2($length_pos_1_minus_1,$length_pos_2_minus_1);
		    $bead_score{$pos_1}{$pos_2}{'match'} = $new_bead_score;
		}
		push(@forward_log_probs,$forward_log_prob-$new_bead_score-$match_score_base);
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_2}{$pos_2_minus_1})) {
		if (!defined($new_bead_score = $bead_score{$pos_1}{$pos_2}{'contract'})) {
		    $new_bead_score =
			$word_seq_score_pos_1_minus_1 +
			    $length_neg_log_prob_pos_1_minus_1 +
				$word_seq_score_pos_1_minus_2 +
				    $length_neg_log_prob_pos_1_minus_2 +
					&word_seq_trans_score($words_pair_1,$words_pos_2_minus_1) +
					    &length_neg_log_cond_prob_2($length_pair_1,$length_pos_2_minus_1);
		    $bead_score{$pos_1}{$pos_2}{'contract'} = $new_bead_score;
		}
		push(@forward_log_probs,$forward_log_prob-$new_bead_score-$contract_score_base);
	    }
	    if (defined($forward_log_prob = $forward_log_prob{$pos_1_minus_1}{$pos_2_minus_2})) {
		if (!defined($target_pair_2_neg_log_prob{$length_pos_2_minus_2}{$length_pos_2_minus_1})) {
		    print "ERROR: no normalization for expand pair\n";
		}
		if (!defined($new_bead_score = $bead_score{$pos_1}{$pos_2}{'expand'})) {
		    $new_bead_score =
			$word_seq_score_pos_1_minus_1 +
			    $length_neg_log_prob_1{$length_pos_1_minus_1} +
				$target_pair_2_neg_log_prob{$length_pos_2_minus_2}{$length_pos_2_minus_1} +
				    &word_seq_trans_score($words_pos_1_minus_1,[@$words_pos_2_minus_2,@$words_pos_2_minus_1]) +
					&length_neg_log_cond_prob_2($length_pos_1_minus_1,$length_pos_2_minus_1 + $length_pos_2_minus_2);
		    $bead_score{$pos_1}{$pos_2}{'expand'} = $new_bead_score;
		}
		push(@forward_log_probs,$forward_log_prob-$new_bead_score-$expand_score_base);
	    }
	    if (@forward_log_probs) {
		$forward_log_prob{$pos_1}{$pos_2} = &log_add_list(@forward_log_probs);
		$forward_prob_cnt++;
	    }
	}
	$pos_1++;
	$print_ctr++;
    }
    print "\rposition $pos_1\n";
    
    $total_observation_log_prob = $forward_log_prob{$sent_cnt_1}{$sent_cnt_2};
    print "Forward probs computed: $forward_prob_cnt\n";
    print "End to end forward score: $total_observation_log_prob\n";
    
    $intermed_time_4 = (times)[0];
    $pass_time = $intermed_time_4 - $intermed_time_3;
    print "$pass_time seconds forward pass time\n";
    
# Backward pass
    
    print "\nBackward pass of forward-backward algorithm\n\n";
    
    @backtrace_list = ();
    %bead_type_cnt = ();
    $total_bead_cnt = 0;
    $high_prob_match_cnt = 0;
    $backward_prob_cnt = 1;
    $saved_backward_prob_cnt = 1;
    %backward_log_prob = ();
    $backward_log_prob{$sent_cnt_1}{$sent_cnt_2} = 0;
    $pos_1 = $sent_cnt_1 + 1;
    $print_ctr = 0;
    while ($pos_1 > 0) {
	$pos_1--;
	if ($print_ctr == 100) {
	    print "\rposition $pos_1       ";
	    $print_ctr = 0;
	}
	$print_ctr++;
	$pos_1_plus_1 = $pos_1+1;
	$pos_1_plus_2 = $pos_1+2;
	foreach $pos_2 (sort {$b <=> $a} keys(%{$forward_log_prob{$pos_1}})) {
	    $norm_forward_log_prob = $forward_log_prob{$pos_1}{$pos_2} - $total_observation_log_prob;
	    $pos_2_plus_1 = $pos_2+1;
	    $pos_2_plus_2 = $pos_2+2;
	    $backtrace_cnt = 0;
	    @backward_log_probs = ();
	    if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2})) {
		$bead_backward_log_prob = $backward_log_prob - $delete_score_base - $bead_score{$pos_1_plus_1}{$pos_2}{'delete'};
		$bead_total_prob = exp($bead_backward_log_prob + $norm_forward_log_prob);
		if ($bead_total_prob > 0.5) {
		    push(@backtrace_list,[$pos_1,$pos_2,'delete',$bead_total_prob]);
		    $backtrace_cnt++;
		}
		$bead_type_cnt{'delete'} += $bead_total_prob;
		$total_bead_cnt += $bead_total_prob;
		push(@backward_log_probs,$bead_backward_log_prob);
	    }
	    if (defined($backward_log_prob = $backward_log_prob{$pos_1}{$pos_2_plus_1})) {
		$bead_backward_log_prob = $backward_log_prob - $insert_score_base - $bead_score{$pos_1}{$pos_2_plus_1}{'insert'};
		$bead_total_prob = exp($bead_backward_log_prob + $norm_forward_log_prob);
		if ($bead_total_prob > 0.5) {
		    push(@backtrace_list,[$pos_1,$pos_2,'insert',$bead_total_prob]);
		    $backtrace_cnt++;
		}
		$bead_type_cnt{'insert'} += $bead_total_prob;
		$total_bead_cnt += $bead_total_prob;
		push(@backward_log_probs,$bead_backward_log_prob);
	    }
	    if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2_plus_1})) {
		$bead_backward_log_prob = $backward_log_prob - $match_score_base - $bead_score{$pos_1_plus_1}{$pos_2_plus_1}{'match'};
		$bead_total_prob = exp($bead_backward_log_prob + $norm_forward_log_prob);
		if ($bead_total_prob > 0.5) {
		    push(@backtrace_list,[$pos_1,$pos_2,'match',$bead_total_prob]);
		    $backtrace_cnt++;
		    if ($bead_total_prob > $high_prob_threshold) {
			$high_prob_match_cnt++;
		    }
		}
		$bead_type_cnt{'match'} += $bead_total_prob;
		$total_bead_cnt += $bead_total_prob;
		push(@backward_log_probs,$bead_backward_log_prob);
	    }
	    if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_2}{$pos_2_plus_1})) {
		$bead_backward_log_prob = $backward_log_prob - $contract_score_base - $bead_score{$pos_1_plus_2}{$pos_2_plus_1}{'contract'};
		$bead_total_prob = exp($bead_backward_log_prob + $norm_forward_log_prob);
		if ($bead_total_prob > 0.5) {
		    push(@backtrace_list,[$pos_1,$pos_2,'contract',$bead_total_prob]);
		    $backtrace_cnt++;
		}
		$bead_type_cnt{'contract'} += $bead_total_prob;
		$total_bead_cnt += $bead_total_prob;
		push(@backward_log_probs,$bead_backward_log_prob);
	    }
	    if (defined($backward_log_prob = $backward_log_prob{$pos_1_plus_1}{$pos_2_plus_2})) {
		$bead_backward_log_prob = $backward_log_prob - $expand_score_base - $bead_score{$pos_1_plus_1}{$pos_2_plus_2}{'expand'};
		$bead_total_prob = exp($bead_backward_log_prob + $norm_forward_log_prob);
		if ($bead_total_prob > 0.5) {
		    push(@backtrace_list,[$pos_1,$pos_2,'expand',$bead_total_prob]);
		    $backtrace_cnt++;
		}
		$bead_type_cnt{'expand'} += $bead_total_prob;
		$total_bead_cnt += $bead_total_prob;
		push(@backward_log_probs,$bead_backward_log_prob);
	    }
	    if ($backtrace_cnt > 1) {
	    }
	    if (@backward_log_probs > 0) {
		$backward_prob_cnt++;
		$backward_log_prob = &log_add_list(@backward_log_probs);
		if (($backward_log_prob + $norm_forward_log_prob) > $conf_threshold) {
		    $saved_backward_prob_cnt++;
		    $backward_log_prob{$pos_1}{$pos_2} = $backward_log_prob;
		}
	    }
	}
    }
    print "\rposition $pos_1        \n";
    
    print "Backward probs computed: $backward_prob_cnt\n";
    print "Backward probs saved: $saved_backward_prob_cnt\n";
    print "End to end backward score: $backward_log_prob{0}{0}\n";
    
    print "\n$total_bead_cnt total beads:\n";
    while (($bead,$count) = each %bead_type_cnt) {
	print "  $count $bead\n";
    }
    print "$high_prob_match_cnt high prob matches\n";

    if ($iterate_flag) {
	if ($smooth_flag) {
	    $total_bead_cnt += 1000;
	    $match_score_base = -log(($bead_type_cnt{'match'}+940)/$total_bead_cnt);         # 1-1
	    $contract_score_base = -log(($bead_type_cnt{'contract'}+20)/$total_bead_cnt);   # 2-1
	    $expand_score_base = -log(($bead_type_cnt{'expand'}+20)/$total_bead_cnt);       # 1-2
	    $delete_score_base = -log(($bead_type_cnt{'delete'}+10)/$total_bead_cnt);       # 1-0
	    $insert_score_base = -log(($bead_type_cnt{'insert'}+10)/$total_bead_cnt);       # 0-1
	}
	else {
	    foreach $bead_type (keys(%bead_type_count)) {
		$bead_type_cnt{$bead_type} += $conf_threshold_prob;
		$total_bead_cnt += $conf_threshold_prob;
	    }
	    $match_score_base = -log($bead_type_cnt{'match'}/$total_bead_cnt);         # 1-1
	    $contract_score_base = -log($bead_type_cnt{'contract'}/$total_bead_cnt);   # 2-1
	    $expand_score_base = -log($bead_type_cnt{'expand'}/$total_bead_cnt);       # 1-2
	    $delete_score_base = -log($bead_type_cnt{'delete'}/$total_bead_cnt);       # 1-0
	    $insert_score_base = -log($bead_type_cnt{'insert'}/$total_bead_cnt);       # 0-1
	}
	$old_bead_type_total_score = $bead_type_total_score;
	$bead_type_total_score =
	    ($match_score_base * $bead_type_cnt{'match'}) +
		($contract_score_base * $bead_type_cnt{'match'}) +
		    ($expand_score_base * $bead_type_cnt{'match'}) +
			($delete_score_base * $bead_type_cnt{'match'}) +
			    ($insert_score_base * $bead_type_cnt{'match'});
	print "Total bead type score: $bead_type_total_score\n";
	if (abs(($old_bead_type_total_score-$bead_type_total_score) /
		$bead_type_total_score) > $bead_type_diff_threshold) {
	    $iteration++;
	}
	else {
	    $iteration = 0;
	}
    }
    else {
	$iteration = 0;
    }
    
    $intermed_time_5 = (times)[0];
    $pass_time = $intermed_time_5 - $intermed_time_4;
    print "$pass_time seconds backward pass time\n";
}

open(OUT,">$sent_file_1.$sent_file_2_mod.backtrace");
while (@backtrace_list) {
    ($pos_1,$pos_2,$bead,$prob) = @{pop(@backtrace_list)};
    printf OUT "%6d %6d %-8s %10.8f\n",$pos_1,$pos_2,$bead,$prob;
}
close(OUT);

$final_time = (times)[0];
$total_time = $final_time - $start_time;
print "\n$total_time seconds total time\n\n";

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

sub word_seq_trans_score {
    my ($ref_1,$ref_2) = @_;
    my ($token_1,$token_2,$trans_prob_sum,$score_sum,);
    $score_sum = -log(1/(@$ref_1 + 1)) * @$ref_2;  # normalizes over all possible alignment patterns
    foreach $token_2 (@$ref_2) {
	$trans_prob_sum = 0;
	foreach $token_1 ('(empty)',@$ref_1) {
	    $trans_prob_sum += $trans_prob{$token_1}{$token_2};
	}
	$score_sum -= log($trans_prob_sum);
    }
    return($score_sum);
}

sub word_seq_score_1 {
    my ($token_1,$score_sum);
    foreach $token_1 (@_) {
	$score_sum += $token_score_1{$token_1};
    }
    return($score_sum);
}

sub word_seq_score_2 {
    my ($token_2,$score_sum);
    foreach $token_2 (@_) {
	$score_sum += $token_score_2{$token_2};
    }
    return($score_sum);
}
