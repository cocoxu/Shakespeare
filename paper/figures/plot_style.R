#16plays36:
#average-csim	0.512979241631
#average-cmaxent	0.701862536235
#phrase2:
#average-csim	0.491599098577
#average-cmaxent	0.50375691204
#video2:
#average-csim	0.480059827357
#average-cmaxent	0.456308085791

pdf('style_metrics.pdf', width=8, height=5)

barplot(rbind(
	c(0.512979241631, 0.491599098577, 0.480059827357),
	c(0.701862536235, 0.50375691204, 0.456308085791)),
	names.arg=c('16plays36LM', 'Dictionary', 'Video Baseline'), beside=TRUE)

title("Average Style Metrics")

legend("topright", legend=c('Cosine Similarity', 'Maximum Entropy'), fill=(gray.colors(n=2)))

dev.off()