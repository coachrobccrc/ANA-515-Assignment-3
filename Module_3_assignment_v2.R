# Getting and Cleaning Data/Module 3 Assignment
# Script by Rob Brown, ANA-515
#
# Downloading data from NOAA's Storm Events Database for 1973. 
# I'll list the bulleted items as a way of documenting my steps and keeping me
# on track of what I need to do. 
# 
# Bullet #1: Go to the given link and download the bulk storm details data for 1973. 
download.file(url="https://www1.ncdc.noaa.gov/pub/data/swdi/stormevents/csvfiles/StormEvents_details-ftp_v1.0_d1973_c20160223.csv.gz", destfile = "storm_data_1973.csv")

# Bullet #2: Move this into a good local directory for your current working directory and read it in to R using read_csv from the tidyverse/readr package. 
#install.packages("tidyverse")
library(tidyverse)

# Bullet #2: Move this into a good local directory for your current working directory and read it in to R using read_csv from the readr package. 
storm_data_1973 <- read.csv("storm_data_1973.csv")
storm_data_1973
# Borrowing a page from the last assignment, let's look at the first 10 rows of data
head(storm_data_1973,10)
# Likewise, let's list the column names as the next bullet goes into columns we want to keep, or conversely, 
# columns we want to delete. 
colnames(storm_data_1973)

# Bullet #3: Limit the dataframe to: beginning and ending dates and times, the episode ID, the event ID, the state name and FIPS,
# the "CZ" name, type, and FIPS, the event type, the source, and the beginning latitude and longitude and ending latitude
# and longitude for 10 points. 
# select variables
myvars <- c("BEGIN_DATE_TIME", "END_DATE_TIME",
  "EPISODE_ID", "EVENT_ID", "STATE", "STATE_FIPS", "CZ_TYPE", "CZ_FIPS", "CZ_NAME",
  "EVENT_TYPE", "SOURCE","BEGIN_LAT", "BEGIN_LON", "END_LAT", "END_LON")
newdata<-storm_data_1973[myvars]
head(newdata)

# Bullet #4: Convert the beginning and ending dates to a "date-time" class. 
# Using the PowerPoint and the information in the discussion board date/time question thread, I did the commands below. 
# ************This does not seem to put the dates into dmy_hms format.  *******************
#install.packages("lubridate")
library(lubridate)
#install.packages("dplyr")
library(dplyr)
newdata<-mutate(newdata, BEGIN_DATE_TIME= dmy_hms(BEGIN_DATE_TIME), END_DATE_TIME = dmy_hms(END_DATE_TIME))
head(newdata)


# Bullet #5: Change state and county names to title case.
newdata <- mutate(newdata, STATE = str_to_title(STATE))

newdata<-mutate(newdata, CZ_NAME = str_to_title(CZ_NAME))

newdata

# Bullet #6: Limit the events listed by county FIPS (CZ_TYPE of "C") and then remove the CZ_TYPE column.
# It should be noted that the only value in my CZ_TYPE is "C"; I checked my original storm_data_1973 data frame and this is true. 
# I learned I can assign NULL to a column and this eliminates it. colnames verifies that CZ_TYPE has been eliminated. 
newdata_filtered <- filter(newdata, CZ_TYPE=="C")
newdata_filtered$CZ_TYPE<-NULL
colnames(newdata_filtered)


# Bullet #7 
# Pad the state and county FIPS with a "0" at the beginning with a fcn from stringr and then unite the two columns
# to make one fips column with the 5-digit county FIPS code. 
# *** Some of my CZ_FIPS already had a 3 digit value in them. Won't this make a 6-digit number instead of a 5 digit number? 
newdata_filtered <- mutate(newdata_filtered, STATE_FIPS = str_pad(newdata_filtered$STATE_FIPS, width=3, side="left", pad="0"))
newdata_filtered <- mutate(newdata_filtered, CZ_FIPS = str_pad(newdata_filtered$CZ_FIPS, width=3, side="left", pad="0"))

newdata_filtered <- unite(newdata_filtered, FIPS, STATE_FIPS, CZ_FIPS, remove = TRUE, sep="")


# Bullet #8
# Change all the column names to lower case. Try the rename_all functions? 
newdata_filtered <- rename_all(newdata_filtered, tolower)

# Bullet #9
# There is data that comes with R on U.S. states. Use that to create a dataframe with the state name, area, and region. 
us_state_info <- data.frame(state=state.name, region=state.region, area=state.area)

# Bullet #10
# Create a dataframe with the number of events per state in the year of your birth. 
state_freq_events <- data.frame(table(newdata_filtered$state))
# Merge in the state information dataframe you just created. Remove any states that are not in the state information database. 
# Rename the column called Var1 in state_freq_events to be state.
state_freq_events <- rename(state_freq_events,c('state'='Var1'))
merged <- merge(x=state_freq_events, y = us_state_info, by.x = "state", by.y = "state")
View(merged)

# Bullet 11
# Use the supplied code to generate a plot using ggplot2 package.
library(ggplot2)
storm_plot <- ggplot(merged, aes(x=area, y=Freq))+ geom_point(aes(color=region)) + labs(x = 'Land area (square miles)', y = "# of storm events in 1973")
storm_plot




