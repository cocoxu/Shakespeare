#!c:/Perl/bin/perl

# (c) Microsoft Corporation. All rights reserved.

# This version lets align-sents-length-plus-words-multi-file2.pl
# handle the iteration over the sentence file pairs, so that the word
# translation file only needs to be loaded once.

use Cwd;

($dir,$threshold) = @ARGV;

if (!defined($threshold)) {
    $threshold = .50;
}

(opendir DIR, $dir) || die("Could not open directory $dir\n"); 
@all_snt_files = grep /\.snt$/, readdir DIR;
closedir(DIR);

$prog_dir = cwd();

chdir($dir);

print "program directory: $prog_dir\n";
print "data directory: $dir\n";

foreach $file_name (@all_snt_files) {
    $file_name =~ /.*_(.+?)\.snt$/;
    $language_tag{$1}++;
}

@languages = keys(%language_tag);

unless (@languages == 2) {
    die "not exactly two languages in directory: @languages\n";
}

($lang_1,$lang_2) = @languages;

if ($language_tag{$lang_1} != $language_tag{$lang_2}) {
    die "$language_tag{$lang_1} $lang_1 files, but $language_tag{$lang_2} $lang_2 files\n";
}

$file_index_limit = -1;
foreach $file_name (@all_snt_files) {
    $file_name =~ /(.*_)(.+?)\.snt$/;
    if ($2 eq $lang_1) {
	push(@sent_file_1_list,join('',$1,$lang_1,'.snt'));
	push(@sent_file_2_list,join('',$1,$lang_2,'.snt'));
	$file_index_limit++;
    }
}

print "\nFinding length-based alignments and filtering initial high-probability aligned sentences\n";

foreach $i (0..$file_index_limit) {
    $sent_file_1 = $sent_file_1_list[$i];
    $sent_file_2 = $sent_file_2_list[$i];
    system("perl $prog_dir/align-sents-dp-beam7.pl $sent_file_1 $sent_file_2");
    print "\n========================================================\n\n";
    system("perl $prog_dir/filter-initial-aligned-sents.pl $sent_file_1 $sent_file_2");
    print "\n========================================================\n";
}

print "\nConcatenating length-aligned sentence files\n";

$start_time = (times)[0];

open(OUT,"> all_$lang_1.snt.words");
foreach $i (0..$file_index_limit) {
    $sent_file_1 = $sent_file_1_list[$i];
    open(IN,"$sent_file_1.words");
    while ($line = <IN>) {
	print OUT $line;
    }
    close(IN);
}
close(OUT);

open(OUT,"> all_$lang_2.snt.words");
foreach $i (0..$file_index_limit) {
    $sent_file_2 = $sent_file_2_list[$i];
    open(IN,"$sent_file_2.words");
    while ($line = <IN>) {
	print OUT $line;
    }
    close(IN);
}
close(OUT);


$end_time = (times)[0];
$concat_time = $end_time - $start_time;
print "\n$concat_time seconds to concatenate files\n";

print "\n========================================================\n";
print "\nBuilding word association model\n";
system("perl $prog_dir/build-model-one-multi-file.pl all_$lang_1.snt all_$lang_2.snt");
print "\n========================================================\n";

print "\nFinding alignment based on word associations and lengths and filtering final high-probability aligned sentences\n";

open(OUT,"> sentence-file-pair-list");

foreach $i (0..$file_index_limit) {
    $sent_file_1 = $sent_file_1_list[$i];
    $sent_file_2 = $sent_file_2_list[$i];
    print OUT "$sent_file_1 $sent_file_2\n";
}

system("perl $prog_dir/align-sents-length-plus-words-multi-file2.pl");

foreach $i (0..$file_index_limit) {
    $sent_file_1 = $sent_file_1_list[$i];
    $sent_file_2 = $sent_file_2_list[$i];
    system("perl $prog_dir/filter-final-aligned-sents.pl $sent_file_1 $sent_file_2 $threshold");
    print "\n========================================================\n";
}

print "\n";
