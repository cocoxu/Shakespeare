data = read.csv('bleupinc.csv', sep="\t", header=TRUE)
data = data[data$corpus == 1,]

pdf('bleupinc1.pdf', width=6, height=6)

plot(data$PINC, data$BLEU, pch=1:dim(data)[1], xlab='PINC', ylab='BLEU')
title("Corpus 1")
legend("bottomleft", legend=data$system, pch=1:dim(data)[1])

dev.off()

data = read.csv('bleupinc.csv', sep="\t", header=TRUE)
data = data[data$corpus == 2,]

pdf('bleupinc2.pdf', width=6, height=6)

plot(data$PINC, data$BLEU, pch=1:dim(data)[1], xlab='PINC', ylab='BLEU')
title("Corpus 2")
legend("bottomleft", legend=data$system, pch=1:dim(data)[1])

dev.off()
