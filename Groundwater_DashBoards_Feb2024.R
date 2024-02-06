#Groundwater Dashboards
#Feb 2024

library(tidyverse)
library(DBI)
library(odbc)
library(lubridate)
library(hms)
library(glue)
library(dbplyr)
library(googlesheets4)
library(janitor)

#Connect to WQTS Database
GW <- dbConnect(odbc(), 
                Driver = "SQL Server",
                Server = "localhost\\SQLEXPRESS", 
                Database = "WQTS", 
                Trusted_Connection = "True")

#GW data all

GW_All <- tbl(GW, "WQTS_Data") %>%
  filter(CharacteristicName == 'Depth') %>%
  collect() %>%
  group_by(MONLOC_AB) %>%
  mutate(StartDate = as.Date(StartDate), ResultMeasureValue = as.numeric(ResultMeasureValue)) %>%
  complete(StartDate = seq.Date(min(StartDate), max(StartDate), by = "day")) %>%
  mutate(month = floor_date(StartDate, "month"))  %>%
  group_by(MONLOC_AB, StartDate) %>%
  summarise(mean = mean(ResultMeasureValue)) %>%
  clean_names()



#
#  mutate(StartTime = substr(StartTime, 1,8)) %>%
#  mutate(StartDate = as.Date(StartDate)) %>%
#  mutate(DateTime = as.POSIXct(paste(StartDate, StartTime), format = "%Y-%m-%d %H:%M:%S")) %>%
#  select(MONLOC_AB, DateTime, ResultMeasureValue, ResultMeasureUnitCode) %>%
#  clean_names()


gs4_auth(email = "OVIWC106@gmail.com")

gs4_create("OVIWC GW Data Raw", sheets = GW_All)

sheet_write(GW_All, ss = "https://docs.google.com/spreadsheets/d/1kfyElI156rpuaeALqwfXHdqJu-YC7NjtaRlDjoo9Lp4/edit#gid=1724840507")
