###
#####   R SCRIPT for Analysis of
###   
#####   1) FIXATION COUNT on AOIs (especially EYES)
#####   2) DWELL TIME on AOIs (especially EYES)
#####   3) FREQUENCY OF INITIAL FIXATION after stimulus onset on AOIs (especially EYES)
#####   4) NUMBER OF TRANSITIONS BETWEEN AOIs
#####   >> checking proportion of fixations within AOIs
###


# >> general preparations -------------------------------------------------------

# setwd("~/Documents/Projekty/faces/src/tutorial_etra18")
source('customFunc.R') # load custom functions
source("lrheatmap.R") # load custom functions
load.libraries(c('sciplot', 'afex', 'knitr'))

pdf.options(family="NimbusSan", useDingbats=FALSE)

# Directory for figures
dir.create(file.path("./figs"), showWarnings = FALSE)


# open data
df <- read.csv("fxtn-aois.csv") # open data
head(df)
str(df)

df$subj <- factor(df$subj)
df$ttype <- factor(df$ttype)
df$aoi_label <- factor(df$aoi_label, label=c("left_eye","right_eye","nose","mouth"))
df$block <- factor(df$block)
df$trial <- factor(df$trial)
str(df)


# preparations for nr of fixations in general
df2 <- read.csv("fxtn.csv") # open data

df2$subj <- factor(df2$subj)
# exclude first fixation that is still on fixation cross on the left or right side of the stimulus
df2 <- subset(df2, x>231) # only fixations within stimulus - left boarder
df2 <- subset(df2, x<793) # only fixations within stimulus - right boarder






# 1) fixation count - AOI ------------------------------------------------------------

# >> calculations ------------------------------------------------------------
# aggregate fixation count for each trial * AOI * subject
df$fixCount <- 1
dat <- aggregate(fixCount ~ subj + aoi_label + ttype + block + trial, df, sum)

# adding rows with fixation count = 0 for the missing AOIs that haven't been fixated in each trial
dim(dat)
for (vp in levels(df$subj)){
  print(vp)
  for(bl in levels(df$block)){
    for(tr in levels(df$trial)){
      for (aoi in levels(df$aoi_label)){
        if (dim(subset(dat, subj==vp&aoi_label==aoi&block==bl&trial==tr))[1]==0){
          dat <- rbind(dat, c(vp, aoi, as.character(dat$ttype[dat$subj==vp&dat$block==bl&dat$trial==tr][1]), bl, tr, 0))
        }
      }
    }
  }
  #print(dim(subset(dat, subj==vp)))
}
dim(dat) # should be = 24 (number of subjects) * 7 (ttype=emotion) * 4 (AOI) * 16 (repetitions) = 10752
dat$fixCount <- as.numeric(dat$fixCount)
dat <- dat[order(dat$subj, dat$aoi_label, dat$block, dat$trial),]
# aggregate fixation count
dat <- aggregate(fixCount ~ subj + aoi_label + ttype, dat, mean)

# AOI dataframes
dat_leye <- subset(dat,aoi_label=="left_eye")
dat_reye <- subset(dat,aoi_label=="right_eye")
dat_nose <- subset(dat,aoi_label=="nose")
dat_mouth <- subset(dat,aoi_label=="mouth")
dat_eyes <- subset(dat,aoi_label=="left_eye")
dat_eyes$fixCount <- dat_leye$fixCount+dat_reye$fixCount
dat_eyes$aoi_label <- "eyes"


# >> plot and statistics ------------------------------------------------------------
# plot
plotName = "./figs/fixationCount_AOI.pdf"
pdf(plotName, height=14, width=14, points=14)
par(mfrow=c(2,2))
bargraph.CI(ttype, fixCount, data=dat_leye, legend=T, ylim=c(0,6), main="Left Eye", ylab="fixation count", xlab="emotion category")
bargraph.CI(ttype, fixCount, data=dat_reye, legend=T, ylim=c(0,6), main="Right Eye", ylab="fixation count", xlab="emotion category")
bargraph.CI(ttype, fixCount, data=dat_nose, legend=T, ylim=c(0,6), main="Nose", ylab="fixation count", xlab="emotion category")
bargraph.CI(ttype, fixCount, data=dat_mouth, legend=T, ylim=c(0,6), main="Mouth", ylab="fixation count", xlab="emotion category")
dev.off()

pdf("./figs/fixationCount_EYES.pdf", height=7,width=8, points=14)
bargraph.CI(ttype, fixCount, data=dat_eyes, legend=T, ylim=c(0,12), main="Fixation count on the eyes", xlab="emotion category")
dev.off()

#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number on AOI "left eye"
#####.
a <- aov_ez(data = dat_leye, id = 'subj', dv = 'fixCount', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number on AOI "right eye"
#####.
a <- aov_ez(data = dat_reye, id = 'subj', dv = 'fixCount', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number on AOI "nose"
#####.
a <- aov_ez(data = dat_nose, id = 'subj', dv = 'fixCount', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number on AOI "mouth"
#####.
a <- aov_ez(data = dat_mouth, id = 'subj', dv = 'fixCount', within = 'ttype')
kable(nice(a))
# => sign.

#####.
#####. ANOVA - Effect of ttype (emotion) on fixation number on AOI "BOTH EYES"
#####.
a <- aov_ez(data = dat_eyes, id = 'subj', dv = 'fixCount', within = 'ttype')
kable(nice(a))
# => sign.
pairwise.t.test(dat_eyes$fixCount, dat_eyes$ttype, paired=T)






# 2) dwell time - AOI ------------------------------------------------------------

# >> calculations ------------------------------------------------------------
# add up duration of fixations for each trial * AOI * subject
df$dwelltime <- 1
dat2 <- aggregate(duration ~ subj + aoi_label + ttype, df, sum)
names(dat2)[4]<-"dwelltime"
dat2$dwelltime <- dat2$dwelltime/16 # (I don't add missing rows for each trial like for fixation count. That's not necessary here because we calculate the sum and not the mean)

# adding rows with dwell time = 0 for the missing AOIs that haven't been fixated
dim(dat2)
for (vp in levels(df$subj)){
  for (aoi in levels(df$aoi_label)){
    for (emo in levels(df$ttype)){
      if (dim(subset(dat2, subj==vp&aoi_label==aoi&ttype==emo))[1]==0){
        dat2 <- rbind(dat2, c(vp, aoi, emo, 0))
      }
    }
  }
}
dim(dat2) # should be = 24 (number of subjects) * 7 (ttype=emotion) * 4 (AOI) = 672
dat2$dwelltime <- as.numeric(dat2$dwelltime)
dat2 <- dat2[order(dat2$subj, dat2$aoi_label, dat2$ttype),]

# AOI dataframes
dat2_leye <- subset(dat2,aoi_label=="left_eye")
dat2_reye <- subset(dat2,aoi_label=="right_eye")
dat2_nose <- subset(dat2,aoi_label=="nose")
dat2_mouth <- subset(dat2,aoi_label=="mouth")
dat2_eyes <- subset(dat2,aoi_label=="left_eye")
dat2_eyes$dwelltime <- dat2_leye$dwelltime+dat2_reye$dwelltime
dat2_eyes$aoi_label <- "eyes"


# >> plots and stats ------------------------------------------------------------
# plot
pdf("./figs/dwelltime_AOI.pdf", height=14,width=14, points=14)
par(mfrow=c(2,2))
bargraph.CI(ttype, dwelltime, data=dat2_leye, legend=T, ylim=c(0,1), main="Left Eye", ylab="Dwell Time [sec]", xlab="emotion category")
bargraph.CI(ttype, dwelltime, data=dat2_reye, legend=T, ylim=c(0,1), main="Right Eye", ylab="Dwell Time [sec]", xlab="emotion category")
bargraph.CI(ttype, dwelltime, data=dat2_nose, legend=T, ylim=c(0,1), main="Nose", ylab="Dwell Time [sec]", xlab="emotion category")
bargraph.CI(ttype, dwelltime, data=dat2_mouth, legend=T, ylim=c(0,1), main="Mouth", ylab="Dwell Time [sec]", xlab="emotion category")
dev.off()

# plot
plotName = "./figs/dwelltime_EYES.pdf"
pdf(plotName, height=7,width=9, points=14)
par(mar=c(4.5,5,2,1))
bargraph.CI(ttype, dwelltime, data=dat2_eyes, legend=T, ylim=c(0,2.5), main="Dwell Time on the eyes", ylab="[sec]", xlab="emotion category", cex.lab=1.4, cex.leg=1.3, cex.main=1.5, cex.names=1.15, cex.axis=1.15)
dev.off()



#####.
#####. ANOVA - Effect of ttype (emotion) on absolute dwell time on AOI "left eye"
#####.
a <- aov_ez(data = dat2_leye, id = 'subj', dv = 'dwelltime', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on absolute dwell time on AOI "right eye"
#####.
a <- aov_ez(data = dat2_reye, id = 'subj', dv = 'dwelltime', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on absolute dwell time on AOI "nose"
#####.
a <- aov_ez(data = dat2_nose, id = 'subj', dv = 'dwelltime', within = 'ttype')
kable(nice(a))
# => sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on absolute dwell time on AOI "mouth"
#####.
a <- aov_ez(data = dat2_mouth, id = 'subj', dv = 'dwelltime', within = 'ttype')
kable(nice(a))
# => sign.

#####.
#####. ANOVA - Effect of ttype (emotion) on absolute dwell time on AOI "BOTH EYES"
#####.
a <- aov_ez(data = dat2_eyes, id = 'subj', dv = 'dwelltime', within = 'ttype')
kable(nice(a))
# => sign.
pairwise.t.test(dat2_eyes$dwelltime, dat2_eyes$ttype, paired=T)






# 3) Initial fixation after stimulus onset (frequency) - AOI ------------------------------------------------------------

# >> calculations ------------------------------------------------------------
# calculate fixation number of fixations in AOIs
# --> we want only the first fixation for each trial
df$fixnr <- NA
fnr <- 0
trialnr <- -99
for (i in 1:dim(df)[1]){
  # counter
  fnr <- fnr+1
  # start counting again with 1 when trialnr changes
  if (df$trial[i]!=trialnr){fnr <- 1}
  trialnr <- df$trial[i]
  
  df$fixnr[i] <- fnr
}
head(df,20)


# >> prepare data frame for 1st fixation for all emotions 
dFF <- subset(df,fixnr==1)
dFF2 <- dFF[0,]
dim(dFF)

# check if there are other fixations on the stimulus outside of the AOIs before the first fixation within AOIs
for (i in 1:dim(dFF)[1]){
  s <- dFF$subj[i]
  bl <- dFF$block[i]
  tr <- dFF$trial[i]
  time <- dFF$timestamp[i]
  
  if(subset(df2, subj==s&block==bl&trial==tr)[1,]$timestamp==time){
    # only safe fixation in dFF2 if there is no other fixation within the stimulus outside of the AOIs
    dFF2 <- rbind(dFF2, subset(dFF, subj==s&block==bl&trial==tr))
    
    #print(as.character(s))
    #print(bl)
    #print(tr)
    #print(c(subset(df2, subj==s&block==bl&trial==tr)[1,]$x,subset(df2, subj==s&block==bl&trial==tr)[1,]$y))
  }
}
dim(dFF)
dim(dFF2) # dFF2 does not have a row for each participant in each trial.
# Rows are missing, if the first fixation in not within one of the AOIs but somewhere else on the stimulus.
# Now, dFF2 is the dataframe that contains only the correct first fixations within the AOIs and should be used afterwards.


xtabs(dFF2$fixnr ~ dFF2$subj + dFF2$aoi_label)

# aggregate sum of first fixations
fix1 <- aggregate(fixnr ~ subj + aoi_label + ttype, dFF2, sum)

# adding rows with Nr of First Fixations = 0 for the missing AOIs in each condition*subj
dim(fix1)
for (vp in levels(df$subj)){
  for (aoi in levels(df$aoi_label)){
    for(emo in levels(df$ttype)){
      if (dim(subset(dFF2, subj==vp&aoi_label==aoi&ttype==emo))[1]==0){
        fix1 <- rbind(fix1, c(vp,aoi,emo,0))
      }
    }
  }
}
dim(fix1) # should be 672 = 24 (number of subjects) * 7 (ttype=emotion) * 4 (AOI)
fix1 <- fix1[order(fix1$subj, fix1$ttype, fix1$aoi_label),]
fix1$fixnr <- as.numeric(fix1$fixnr)
# save as "dat"
dat <- fix1
# calculate in % of trials - Frequency of Initial Fixation
dat$fixnr <- dat$fixnr/16*100 # 16 because we have 16 trials per condition
names(dat)[4] <- "FIF" # Frequency of Initial Fixation

# AOI dataframes
dat_leye <- aggregate(FIF ~  subj + ttype, subset(dat,aoi_label=="left_eye"), sum)
dat_reye <- aggregate(FIF ~  subj + ttype, subset(dat,aoi_label=="right_eye"), sum)
dat_nose <- aggregate(FIF ~  subj + ttype, subset(dat,aoi_label=="nose"), sum)
dat_mouth <- aggregate(FIF ~  subj + ttype, subset(dat,aoi_label=="mouth"), sum)

# add frequency of first fixations on both eyes
dat_eyes <- aggregate(FIF ~  subj + ttype, subset(dat,aoi_label=="left_eye"|aoi_label=="right_eye"), sum)
dat_eyes_agg <- aggregate(FIF ~  subj, subset(dat,aoi_label=="left_eye"|aoi_label=="right_eye"), sum)
str(dat_eyes)


# >> plots and stats ------------------------------------------------------------

# plot
plotName = "./figs/initialFixation_AOI.pdf"
pdf(plotName, height=14, width=14, points=14)
par(mfrow=c(2,2))
bargraph.CI(ttype, FIF, data=dat_leye, legend=T, ylim=c(0,100), main="Left Eye", ylab="proportion of initial fixations [%]", xlab="emotion category")
bargraph.CI(ttype, FIF, data=dat_reye, legend=T, ylim=c(0,100), main="Right Eye", ylab="proportion of initial fixations [%]", xlab="emotion category")
bargraph.CI(ttype, FIF, data=dat_nose, legend=T, ylim=c(0,100), main="Nose", ylab="proportion of initial fixations [%]", xlab="emotion category")
bargraph.CI(ttype, FIF, data=dat_mouth, legend=T, ylim=c(0,100), main="Mouth", ylab="proportion of initial fixations [%]", xlab="emotion category")
dev.off()

# plot
plotName = "./figs/initialFixation_EYES.pdf"
pdf(plotName, height=7,width=9, points=14)
par(mar=c(4.5,5,2.5,1))
bargraph.CI(ttype, FIF, data=dat_eyes, legend=T, ylim=c(0,110), main="Frequency of initial fixations on the eyes", ylab="Proportion [%]", xlab="emotion category", cex.lab=1.4, cex.leg=1.3, cex.main=1.5, cex.names=1.15, cex.axis=1.15)
dev.off()


#####.
#####. ANOVA - Effect of ttype (emotion) on frequency of initial fixation after stimulus onset on AOI "left eye"
#####.
a <- aov_ez(data = dat_leye, id = 'subj', dv = 'FIF', within = 'ttype')
kable(nice(a))
# => non-sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on frequency of initial fixation after stimulus onset on AOI "right eye"
#####.
a <- aov_ez(data = dat_reye, id = 'subj', dv = 'FIF', within = 'ttype')
kable(nice(a))
# => non-sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on frequency of initial fixation after stimulus onset on AOI "nose"
#####.
a <- aov_ez(data = dat_nose, id = 'subj', dv = 'FIF', within = 'ttype')
kable(nice(a))
# => non-sign.
#####.
#####. ANOVA - Effect of ttype (emotion) on frequency of initial fixation after stimulus onset on AOI "mouth"
#####.
a <- aov_ez(data = dat_mouth, id = 'subj', dv = 'FIF', within = 'ttype')
kable(nice(a))
# => non-sign.


#####.
#####. ANOVA - Effect of ttype (emotion) on frequency of initial fixation after stimulus onset on AOI "BOTH EYES"
#####.
a <- aov_ez(data = dat_eyes, id = 'subj', dv = 'FIF', within = 'ttype')
kable(nice(a))

#post-hoc
pairwise.t.test(dat_eyes$FIF, dat_eyes$ttype, paired=T)






# 4) AOI transitions ------------------------------------------------------------


# >> checking relevant fixations ------------------------------------------------------------

# compare nr of fixations on defined AOIs with nr of fixations on the stimulus area in general

# nr of fixations in general
df2$NR <- 1
datNR2 <- aggregate(NR ~ subj+ttype+block+trial, df2, sum)

# nr of fixations in AOIs
df$NR <- 1
datNR <- aggregate(NR ~ subj+ttype+block+trial, df, sum)

dim(datNR)
dim(datNR2)

head(datNR,10)
head(datNR2,10)


# result
sum(datNR$NR)
sum(datNR2$NR)
sum(datNR$NR)/sum(datNR2$NR)
#97.76%



dat <- data.frame(levels(df$subj))
dat$AOIfix <- NA
# for all subjects
counter <- 0
for (vp in levels(df$subj)){
  counter <- counter + 1
  print(vp)
  print(sum(datNR$NR[datNR$subj==vp])/sum(datNR2$NR[datNR2$subj==vp]))
  dat$AOIfix[counter] <- sum(datNR$NR[datNR$subj==vp])/sum(datNR2$NR[datNR2$subj==vp])
}
str(dat)



# >> calculations ------------------------------------------------------------

# add variable "transition" (= 1 when the previous AOI was different, = 0 when the previous AOI is the same)
df$transition <- 0
for (i in 1:dim(df)[1]){
  if (df$fixnr[i]!=1){
    if(df$aoi_label[i]!=df$aoi_label[i-1]){df$transition[i] <- 1}
  }
}
head(df,20)

trans_dat <- aggregate(transition ~ subj+ ttype, df, sum)
trans_dat$transition <- trans_dat$transition/16
dim(trans_dat) # = 168 = 24 (number of subjects) * 7 (ttype) --> no missing row!


# >> plots and stats ------------------------------------------------------------

# plot
plotName = "./figs/transitionCount.pdf"
pdf(plotName, height=7,width=9, points=14)
bargraph.CI(ttype, transition, data=trans_dat, ylim=c(0,8), main="Number of transitions between AOIs", legend=T, xlab="emotion category", cex.lab=1.4, cex.leg=1.3, cex.main=1.5, cex.names=1.15, cex.axis=1.15)
dev.off()


#####.
#####. ANOVA - Effect of ttype (emotion) on number of transitions between AOIs
#####.
a <- aov_ez(data = trans_dat, id = 'subj', dv = 'transition', within = 'ttype')
kable(nice(a))
# => significant

# post-hoc
pairwise.t.test(trans_dat$transition, trans_dat$ttype, paired=T)



