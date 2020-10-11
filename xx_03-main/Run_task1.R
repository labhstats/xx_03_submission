library(data.table)

# You will need to change your working directory
base_wd_path = "C:/Users/----------------------/xx_03_submission/xx_03-main"
setwd(base_wd_path)

fileSources = file.path("code_task1", list.files("code_task1", pattern = "*.[rR]$"))
sapply(fileSources, source, .GlobalEnv)

# code goes here
#CreateFakeData()


### 5.
# Just load
d <- readRDS("data_raw/individual_level_data.RDS")
head(d)
dim(d)

any(is.na(d))

### 6.
# Long to wide data transform

library(reshape2)

#d_wide = dcast(data = d_wide,formula = location_code + date ~ value)
d_wide = dcast(data = d,formula = location_code + date ~ value,fun.aggregate = length, fill = 0)

head(d_wide) #Looks ok.
dim(d_wide)

### 7.
# Check if adhering at all to empty case

library(dplyr)
library(tidyr)
library(lubridate)

d_wide_0s <- d_wide %>% 
  ungroup() %>%
  complete(nesting(location_code), date = seq(min(date), max(date), by = "day"))

any(is.na(d_wide_0s$`1 person`))

d_wide_0s$date[1:365]

d_wide_0s[is.na(d_wide_0s)] = 0

d_wide_0s = as.data.frame(d_wide_0s)
head(d_wide_0s)

any(is.na(d_wide_0s$`1 person`))
any(d_wide_0s$`1 person` == 0) #Minimum checked, but still possible errors existing.


### 8.
# ISO time
d_use = d_wide_0s
library(surveillance)

#isoWeekYear(d_use$date[1:5])

d_use$ISO_Y = isoWeekYear(d_use$date)$ISOYear
d_use$ISO_W = isoWeekYear(d_use$date)$ISOWeek

head(d_use)

### 9.
# Give sensible names.

# One time run:
#install.packages(c("fhidata","fhi","fhiplot"), repos = c("https://folkehelseinstituttet.github.io/drat", "https://cran.rstudio.com"))

nor_assume = fhidata::norway_population_b2020

nor_location = fhidata::norway_locations_b2020

d_all = merge(x = d_use, y = nor_location, by.x = "location_code", by.y = "municip_code",all.x = TRUE)

head(d_all) #Looks ok.

### 10.
# Training and test data

d_all_tt = d_all
d_all_tt$naive_month = floor(d_all_tt$ISO_W/4.4) #not correct enough...
unique(d_all_tt$naive_month)
table(d_all_tt$naive_month)

d_training = d_all[d_all_tt$ISO_Y < 2020,]
d_testing = d_all[!(d_all_tt$ISO_Y < 2020),]

### 11.
#Without doubt a fixed effect per month, but also a stochastic component per month...
#A mixed linear regression model would be ok if I could extract and model the months as random components.

head(d_training)

#3 Hours (180 minutes) have passed...































