data = read.csv('../../eval/annotated.csv', sep="\t", header=TRUE)
data = data[1:99,]

x16plays_36LM_semantic_equiv = data$semantic.equiv
x16plays_36LM_dissimilarity = data$dissimilarity
x16plays_36LM_style = data$style
x16plays_36LM_overall = data$overall

Dictionary_semantic_equiv = data$semantic.equiv.1
Dictionary_dissimilarity = data$dissimilarity.1
Dictionary_style = data$style.1
Dictionary_overall = data$overall.1

video_baseline_semantic_equiv = data$semantic.equiv.2
video_baseline_dissimilarity = data$dissimilarity.2
video_baseline_style = data$style.2
video_baseline_overall = data$overall.2

pdf('human_judgements.pdf', width=6, height=6)

barplot(
	rbind(
		c(mean(x16plays_36LM_semantic_equiv), mean(x16plays_36LM_dissimilarity), mean(x16plays_36LM_style), mean(x16plays_36LM_overall)), 
		c(mean(Dictionary_semantic_equiv), mean(Dictionary_dissimilarity), mean(Dictionary_style), mean(Dictionary_overall)),
		c(mean(video_baseline_semantic_equiv), mean(video_baseline_dissimilarity), mean(video_baseline_style), mean(video_baseline_overall))),
	names.arg=c('semantic adequacy', 'dissimilarity', 'style', 'overall'), beside=TRUE)
title("Average Human Judgements")

legend("topright", legend=c('16plays_36LM', 'Dictionary', 'Video Baseline'), fill=(gray.colors(n=5)))

dev.off()