systems = c('16plays_16LM', 'Dictionary', 'Video Baseline')
metrics = c('BLEU', 'PINC', 'Style-LR', 'Style-LM', 'Style-Cosine')
BLEU = c(27.79, 19.79, 24.23)
PINC = c(48.70, 39.94, 4.09)
sMaxEnt = c(71.99, 54.92, 44.02)
sCosine = c(48.30, 46.11, 44.04)
sLM = c(64.96, 33.59, 10.25)

pdf('shakespeare_to_modern.pdf', width=8, height=5)

barplot(
	t(rbind(BLEU, PINC, sMaxEnt, sLM, sCosine)),
	names.arg=metrics, beside=TRUE)
title("Automatic Evaluation of Paraphrasing Shakespeare's plays to Modern English")

#legend("topright", legend=c('BLEU', 'PINC', 'Style-MaxEnt', 'Style-Cosine'), fill=(gray.colors(n=4)))
legend("topright", legend=systems, fill=(gray.colors(n=3)))

dev.off()