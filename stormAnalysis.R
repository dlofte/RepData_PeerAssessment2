setwd("~/R/reproResearch/RepData_PeerAssessment2")

library(dplyr)
library(ggplot2)

url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!"storm.csv.bz2" %in%){
    download.file(url, "storm.csv.bz2")}
stormData <- read.csv(bzfile("storm.csv.bz2"))

str(stormData)

names(stormData)
head(stormData,20)


health <- select(stormData, EVTYPE, FATALITIES, INJURIES)
str(health)

property <- select(stormData, EVTYPE, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP) 
str(property)

