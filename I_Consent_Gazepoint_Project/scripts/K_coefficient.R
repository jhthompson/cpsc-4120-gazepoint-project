###
#####   R SCRIPT for Analysis of
###   
#####   - K coefficient
#####   => ambient/focal
###



# >> general preparations -------------------------------------------------------
source('customFunc.R')
load.libraries(c('afex','sciplot','knitr'))

pdf.options(family="NimbusSan",useDingbats=FALSE)



# 1) mean K coefficient (effect of ttype) ----------------------------------------------------------------

df <- read.csv("amfo.csv") # open data
head(df)
str(df)
# boxplot(df$K ~ df$subj)
# boxplot(df$K ~ df$ttype)

d1 <- aggregate(df[ ,9], by = list(df$subj, df$ttype, df$block, df$trial), FUN = mean)
head(d1)
names(d1) <- c("subj", "ttype", "block", "trial", "K")
head(d1)
#dim(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "K")
head(d)

# plot
pdf("./figs/K_coefficient.pdf", height=7,width=8,points=14)
bargraph.CI(ttype, K, data=d, ylim=c(-.2,.2), main="K Coefficient", legend=T, xlab="emotion category")
abline(0,0)
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on K coefficient
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'K', within = 'ttype')
kable(nice(a))

# => non-sign.



# 2) K coefficient for 5 time intervals of 500 ms -----------------------------------------------------------

df2 <- data.frame()
for (i in unique(df$subj)){
  d <- df[df$subj == i, ]
  d$timecut.5 <- cut(d$timestamp, 5, labels = c("P1", "P2", "P3", "P4", "P5"))
  df2 <- rbind(df2, d)
}
str(df2)
head(df2)

d1 <- aggregate(df2[ ,9], by = list(df2$subj, df2$block, df2$trial, df2$timecut.5), FUN = mean)
head(d1)
names(d1) <- c("subj", "block", "trial", "timecut.5", "K")
head(d1)
#dim(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$timecut.5), FUN = mean)
head(d)
names(d) <- c("subj", "timecut.5", "K")
head(d)

# plot
pdf("./figs/K_coefficient_timecut5.pdf", height=6,width=6, points=14)
bargraph.CI(timecut.5, K, data=d, ylim=c(-1,1), main="K Coefficient", legend=T, xlab="500 ms time intervals")
abline(0,0)
dev.off()

#####.
#####. ANOVA - Effect of time interval (5 * 500 ms) on K coefficient
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'K', within = 'timecut.5')
kable(nice(a))

# => significant
