###
#####   R SCRIPT for Analysis of
###   
#####   - TMs
#####   - transition entropy
###


# TM and transition entropy ------------------------------------------------------------

# >> general preparations -------------------------------------------------------
# setwd("~/Documents/Projekty/faces/src/tutorial_etra18")
source('customFunc.R') # load custom functions
source("lrheatmap.R") # load custom functions
source("TMSP.R") # load custom functions
load.libraries(c('sciplot', 'afex', 'knitr'))

pdf.options(family="NimbusSan", useDingbats=FALSE)

# Directory for transition matrices pictures
dir.create(file.path("./figs"), showWarnings = FALSE)
dir.create(file.path("./figs/TMS"), showWarnings = FALSE)

args <- commandArgs(trailingOnly = TRUE)
#print(args)

# naois <- as.integer(args[1])
naois <- 4
print(sprintf("naois = %d\n",naois))

df <- read.csv("fxtn-aois.csv") # open data
#str(df)

df$subj <- factor(df$subj)
df$ttype <- factor(df$ttype)
df$aoi_label <- factor(df$aoi_label)




# 1) calculations ------------------------------------------------------------


# select condition
ddf <- df
M <- zeroTM(naois)
M_0 <- TransMatrix(M,data=ddf,
                    AOInamesVar="aoi_label",
                    SubjectsVar="subj",
                    FixOrderVar="order")
M_0 <- M
TransPlot2(transMatrix=M_0,
           plotName="./figs/TMS/TM.pdf",
           plotColors=brewer.pal(9,"Oranges"),
           xLabels=c("leye","reye","nose","mouth"),
           yLabels=c("leye","reye","nose","mouth"),
           title="emotion categorization",
           margin=c(6,6),
           annCex=1.3,
           cexR=1.4,
           cexC=1.4,
           cexAxis=1.6,
           annColor='black')

dd <- data.frame()
for(i in unique(ddf$ttype)){
  # need to zero out TM every time
  M <- zeroTM(naois)
  d <- ddf[ddf$ttype == i, ]

  TransMatrix(M, data=d, AOInamesVar="aoi_label", SubjectsVar="subj", FixOrderVar="order")
  
  TransEntropy(M, data=d, AOInamesVar="aoi_label", SubjectsVar="subj", FixOrderVar="order",print=FALSE)

  TransPlot2(transMatrix=M,
             plotName=paste("./figs/TMS/TM_", i, ".pdf", sep = ""),
             plotColors=brewer.pal(9,"Oranges"),
             xLabels=c("leye","reye","nose","mouth"),
             yLabels=c("leye","reye","nose","mouth"),
             title=paste("emotion categorization, ttype: ",i, sep = ""),
             margin=c(6,6),
             annCex=1.3,
             cexR=1.4,
             cexC=1.4,
             cexAxis=1.6,
             annColor='black')
  dku <- TMentrop
  dku$ttype <- rep(i, length(dku$Entropy))
  dd <- rbind(dku, dd)
} 
dd$ttype <- factor(dd$ttype)
str(dd)


# 2) plots and stats ------------------------------------------------------------------------

# # boxplot
# pdf("./figs/boxplots_entropy.pdf", height=7,width=20)
# boxplot(dd$Entropy ~  dd$Subject, ylim=c(0,1), main="Transition Entropy")
# dev.off()

# plot
pdf("./figs/transition_entropy.pdf", height=7,width=9, points=14)
par(mar=c(5,5,4,1))
bargraph.CI(ttype, Entropy, data=dd, ylim=c(0,1), legend=T, main="Transition entropy", xlab="emotion category", cex.lab=1.5, cex.leg=1.3, cex.main=1.5, cex.names=1.1)
dev.off()


#####.
#####. ANOVA - Effect of ttype (emotion) on tranisiton entropy
#####.
a <- aov_ez(data = dd, id = 'Subject', dv = 'Entropy', within = 'ttype')
kable(nice(a))

# => effect of ttype non-sign.

