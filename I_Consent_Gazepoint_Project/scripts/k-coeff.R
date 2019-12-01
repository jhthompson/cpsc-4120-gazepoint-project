rm(list=ls())

#library(devtools)
#library(slide)
library(tidyverse)

files <- list.files(path="./data", pattern = "-amfo.dat")#[1:3]

std <- function(x) sd(x)/sqrt(length(x))

#data <- read.table("./data/c1_User 2_page1-amfo.dat", sep = "", col.names = c("time", 'K'))
#file <- files[1]
for(file in files) {
  file.info <- strsplit(file, "_")
  condition <- file.info[[1]][1]
  user <- file.info[[1]][2]
  image <- file.info[[1]][3]
  
  file.to.write <- paste("./plots/k-coeff/", condition, user, image, "K-coeff-graph.pdf", sep="_")
  #print(file)
  
  curr.second <- 1
  k.sums <- list()
  curr.list <- list()
  
  data <- read.table(paste("./data/",file, sep=""), sep = "", col.names = c("time", 'K'))
  
  if(is.data.frame(data) && nrow(data)>0) {
    print(paste("./data/",file, sep=""))
    for(i in 1:nrow(data)) {
      row <- data[i,]
      time <- row[1]$time
      K <- row[2]$K
      
      #print(time)
      # if still part of current second, stack all Ks until next second time is reached
      if (time < curr.second) {
        #print(curr.second)
        curr.list <- append(curr.list, K)
      } else {
        #print("prev second")
        #print(curr.second)
        #print("curr time")
        #print(time)
        k.sums[[curr.second]] <- curr.list
        curr.second <- floor(time) + 1 # curr.second + 1 
        curr.list <- list()
      }
    }
    
    # go through each list (which each represent a second of data)
    # and get mean and std error of each list
    
    formatted.data <- data.frame(matrix(ncol=3, nrow=0))
    names(formatted.data)<-c("index", "mean", "stderror")
    #x <- 
    
    for(i in 1:length(k.sums)) {
      row <- k.sums[i]
      #print("mean:")
      #print(mean(unlist(k.sums[i])))
      #print("std error:")
      #print(std(unlist(k.sums[i])))
      
      new.row <- data.frame(i, mean(unlist(k.sums[i])), std(unlist(k.sums[i])))
      names(new.row) <- c("index", "mean", "stderror")
      formatted.data <- rbind(formatted.data, new.row)
    }
    
    
    ggplot(data=formatted.data, aes(x=index, y=mean, group=1)) +
      xlab("Time (second)")+
      ylab("K (mean)")+
      geom_line()+
      geom_point()+
      geom_errorbar(aes(ymin=mean-stderror, ymax=mean+stderror), colour = "gray")
    
    ggsave(filename = file.to.write)
  }
  
}
