setwd("~/R/reproResearch/RepData_PeerAssessment2")

library(dplyr)
library(reshape2)
library(ggplot2)

url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
if (!"storm.csv.bz2" %in%dir()){
    download.file(url, "storm.csv.bz2")}
stormData <- read.csv(bzfile("storm.csv.bz2"))
str(stormData)


# Exploring where most of the observation occur
stormData$year <- as.numeric(format(as.Date(stormData$BGN_DATE, format = "%m/%d/%Y %H:%M:%S"), "%Y"))

hist(stormData$year, breaks = 30)
# The number of observations increases sharply after 1990ish, so we restrict our attention to dates after 1990
trimStorm <- stormData[stormData$year >= 1990,]

# We now separate the data into two different dataframes.
health <- select(trimStorm, EVTYPE, FATALITIES, INJURIES)


economic <- select(trimStorm, EVTYPE, PROPDMG, PROPDMGEXP, CROPDMG, CROPDMGEXP) 
head(economic)

# Convert propdmg and cropdmg to same units using the propdmgexp and cropdmgexp; K = 1000, M=1000000, B = 1000000000

replaced <- c("H",  "K",  "M",     "B",        "-", "+", "0", "1", "2", '3', '4', '5', '6', '7', '8', "", "?" )
replacer <- c( 100, 1000, 1000000, 1000000000, 0,   1,    10,  10,  10,  10,  10,  10,  10,  10,  10,  0,  0 )

replacement <- data.frame(cbind(replaced, replacer))

economic$PROPDMGEXP <- as.character(toupper(economic$PROPDMGEXP))
economic$CROPDMGEXP <- as.character(toupper(economic$CROPDMGEXP))


len <- length(replaced)

for (idx in 1:len){
    economic$PROPDMGEXP[economic$PROPDMGEXP == replaced[idx]] <-replacer[idx]
}

for (idx in 1:len){
    economic$CROPDMGEXP[economic$CROPDMGEXP == replaced[idx]] <- replacer[idx]
}
economic <- transform(economic, PROPDMGEXP =as.numeric(PROPDMGEXP), CROPDMGEXP = as.numeric(CROPDMGEXP))

economic <- mutate(economic, PROPDMG = PROPDMG*PROPDMGEXP, CROPDMGEXP = CROPDMG*CROPDMGEXP)


econo <- melt(economic,id.vars= "EVTYPE",measure.vars = c("PROPDMG","CROPDMG"),variable.name= "DamageType", value.name = "Cost")
head(econo)
damages<- aggregate(econo$Cost, list(EVTYPE = econo$EVTYPE, DamageType = econo$DamageType), mean)

damage <- head(arrange(damages, desc(x)),10,)

qplot(EVTYPE, x, data = damage, geom = "bar", stat = "identity", xlab = "", ylab = "Average Cost") +
theme(text = element_text(size= 15), axis.text.x = element_text(angle = 90, vjust = 0, hjust=1))
