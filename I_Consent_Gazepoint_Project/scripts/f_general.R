###
#####   R SCRIPT for Analysis of
###   
#####   1) MICROSACCADES
#####   >> amplitude
#####   >> rate = (microsaccade number / total fixation duration)
#####   .
#####   2) FIXATIONS
#####   >> number per trial
#####   >> duration
#####   .
#####   3) PUPIL DILATION
#####   >> pICA
###

# >> general preparations -------------------------------------------------------

#setwd("C:/Users/Nina/Desktop/svn/src/tutorial_etra18")

source('customFunc.R')
load.libraries(c('sciplot', 'afex', 'knitr', 'dplyr'))

pdf.options(family="NimbusSan", useDingbats=FALSE)





# 1) MICROSACCADES --------------------------------------------------------------------
# >> amplitude --------------------------------------------------------------------

###
###  MICROSACCADE AMPLITUDE - amp
###

df <- read.csv("msac.csv")
df <- filter(df, dur < 0.04 & amp < 2)
head(df)
str(df)

d <- aggregate(df[ ,8], by = list(df$subj, df$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "msamp")
head(d)

# plot
pdf("./figs/msamp.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, msamp, data=d, ylim=c(0,.3), main="Microsaccade Amplitude", legend=T, xlab="emotion category", ylab="[degree visual angle]")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on microsaccade amplitude
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'msamp', within = 'ttype')
kable(nice(a))

# => non-sign.




# >> rate = number / total fixation duration ---------------------------------------

###
###  MICROSACCADE RATE (/total fixation duration) - msrt
###

df <- read.csv("msrt.csv") # one line per fixation, msrt is for the whole trial -> same value for all fixations/rows in one trial
head(df)
str(df)

d1 <- aggregate(df[ ,13], by = list(df$subj, df$ttype, df$block, df$trial), FUN = mean)
head(d1)
names(d1) <- c("subj", "ttype", "block", "trial", "msrt")
head(d1)
#dim(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "msrt")
head(d)

# plot
pdf("./figs/msrt.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, msrt, data=d, ylim=c(0,4), main="Microsaccade rate", legend=T, xlab="emotion category", ylab="number / total fixation duration [Hz]")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on microsaccade rate
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'msrt', within = 'ttype')
kable(nice(a))

# => non-sign.






# 2) FIXATIONS -----------------------------------------------
# >> number per trial -----------------------------------------------

###
###  FIXATION NUMBER PER TRIAL
###

# use again "msrt.csv" (one line per fixation) or use "fxtn.csv"
df$ftnr <- 1

d1 <- aggregate(df[ ,14], by = list(df$subj, df$ttype, df$block, df$trial), FUN = sum)
head(d1)
names(d1) <- c("subj", "ttype", "block", "trial", "ftnr")
head(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "ftnr")
head(d)

# plot
pdf("./figs/fixation number per trial.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, ftnr, data=d, ylim=c(0,17), main="Fixation number per trial", legend=T, xlab="emotion category")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number per trial
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'ftnr', within = 'ttype')
kable(nice(a))

# => significant

# post-hoc
pairwise.t.test(d$ftnr, d$ttype, paired=T)


# >> duration -------------------------------------------------------


###
###  FIXATION DURATION
###

# use again "msrt.csv" (one line per fixation) or use "fxtn.csv"
d1 <- aggregate(df[ ,11], by = list(df$subj, df$ttype, df$block, df$trial), FUN = mean)
head(d1)
names(d1) <- c("subj", "ttype", "block", "trial", "ftdur")
head(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "ftdur")
head(d)

# plot
pdf("./figs/fixation duration.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, ftdur, data=d, ylim=c(0,.22), main="Mean fixation duration", ylab="[sec]", legend=T, xlab="emotion category")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on mean fixation duration
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'ftdur', within = 'ttype')
kable(nice(a))

# => significant


# post-hoc
pairwise.t.test(d$ftdur, d$ttype, paired=T)






# 3) PUPIL DILATION --------------------------------------------------------------------
# >> pICA --------------------------------------------------------------------

###
###  pICA
###

df <- read.csv("pICA.csv")
head(df)
str(df)

d1 <- aggregate(df[ ,8], by = list(df$subj, df$ttype, df$block, df$trial), FUN = mean)
head(d1)
names(d1) <- c("subj", "ttype", "block", "trial", "pICA")
head(d1)
d <- aggregate(d1[ ,5], by = list(d1$subj, d1$ttype), FUN = mean)
head(d)
names(d) <- c("subj", "ttype", "pICA")
head(d)

# plot
pdf("./figs/pICA.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, pICA, data=d, ylim=c(.8,1), main="pICA", legend=T, xlab="emotion category", ylab="[Hz]")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on pICA
#####.
a <- aov_ez(data = d, id = 'subj', dv = 'pICA', within = 'ttype')
kable(nice(a))

# => non-sign.


