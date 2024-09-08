#######################################
# IUROPA Workshop 2024
# Date: September 10th-13th, 2024
# Author: Mauricio M. M.
#######################################

#######################################
# OUTLINE
#######################################
# 1. Setting your work environment
# 2. Building on R-basics
# 2.1 R-vectors and datatypes
# 2.2 R-lists and datatypes
# 3. Loading & binding data
# 4. Working with Dates
# 5. Dataframes & variables
# 6. Basic Visualizations
# 7. Excercises
#######################################


#######################################
# 1. Setting your work environment ----
#######################################
## 1.1 REVIEW packages
# install.packages("lubridate") # nolint
# install.packages("conflicted") # nolint

## 1.2 LOAD packagess into RSTUDIO
library(lubridate)
library(tidyverse)
library(conflicted)
library(openxlsx)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

## 1.3 REVIEW path and files
### VIEW current working directory
getwd()

### IF not "~/intro_data_session"
if (basename(getwd()) != "intro_data_session") {
  setwd("intro_data_session")
  print("CHANGED to intro_data_session")
} else{print("ALREADY in intro_data_session")
}

### VERIFY we're on desired working directory
getwd()

### LIST all the csv files in our current working directory
list.files(pattern = "*.csv", full.names = TRUE)
print("How should my directory look like?")
# ~/intro_data_session/
# └──"iu_judgements_part1.csv"
# └──"iu_judgements_part2.csv"
# └──"iu_judgements_part3.csv"

cat("***********************************")
# <> CHECKPOINT <>

#######################################
# 2. Building on R-basics     	   ----
#######################################
## 2.1 R-vectors and datatypes      ----
### Q1: What is R-vector?
### A1: A list of numbers with a index.
myvec <- c(1:30)

### What prints out?
myvec[3]

### WHAT class is it?
glimpse(myvec)
class(myvec[20]) # <- CHANGE number what happens?

### Q2: What is an R-character-vector?
### A2: A list of characters stringed together with an index.
mychar_vec <- c("iuropa", "2024-09-11", "General Court", "CJEU", NA)

### What prints out?
mychar_vec[2]
glimpse(mychar_vec)

### What class is it?
class(mychar_vec[2])
## 2.1 R-lists and datatypes        ----
### Q3: What is a list ?
### A3: A list of elements (any) with an index for each element.
mylist <- list(myvec, mychar_vec)
mylist
### Inspecting the list
mylist[[1]]
mylist[[2]][2]

### What prints out?
mylist[[2]][2]
### Adding dataframe elements to list?
position_vec <- c(1:5)
my_dataframe <- data.frame(position_vec, mychar_vec)

mylist[[3]] <- my_dataframe

### What prints out?
mylist[[3]][1]

# [ ] Visual intution
# <> CHECKPOINT <>
#######################################
# 3. Loading & binding data        ----
## LOADING csvs into RSTUDIO
list.files(pattern = "*.csv", full.names = TRUE)

# ARE all pathfile names correct?
part1 <- read.csv("./iu_judgdements_part1.csv")
part2 <- read.csv("./iu_judgdements_part2.csv")
part3 <- read.csv("./iu_judgdements_part3.csv")

# LET's inspect the datasets
glimpse(part1[2:4]) # <- What does [2:4] mean?
glimpse(part2[2:4])
glimpse(part3[2:4])

# LET's verify they have the same names
names(part1) %in% names(part2)
names(part2) %in% names(part3)

# HOW to make all dataframes into one object?
all_parts <- list(part1, part2, part3)
glimpse(all_parts[[3]][4:10])

# LET'S put them together
iu_full_data <- dplyr::bind_rows(all_parts) # bind rows
glimpse(iu_full_data)
# <> CHECKPOINT <>

#######################################
# 4. Working with Dates			   ----
# ARE date really dates?
class(iu_full_data$decision_date)
glimpse(iu_full_data$decision_date)

# LETS's change decision_date to datetime format
iu_full_data <- iu_full_data  %>%
  mutate(decision_date = as_date(decision_date, format = "%Y-%m-%d"))

class(iu_full_data$decision_date)
range(iu_full_data$decision_date)

## LETS CREATE decision_month AND decision_year
iu_full_data <- iu_full_data  %>%
  mutate(decision_month = lubridate::month(decision_date, label = TRUE),
         decision_year = lubridate::year(decision_date))

## LET's inspect our variables
table(iu_full_data$decision_month)
glimpse(iu_full_data$decision_year)
# <> CHECKPOINT <>

#######################################
# 5. Dataframes & variables		   ----
# What IF I want all PPU preliminary references procedure after 1990?
# vars: celex proceeding_name cjeu_case_id

## RENAME celex to  celex_judgement
iu_full_data <- iu_full_data |>
  rename(celex_judgement = celex)

## LET's verify we corretcly rename
iu_full_data$celex_judgement[1:10] # <- Why do I add [1:10]

# CREATE variable of cases that are preliminary references
## USING case_when()
iu_full_data <- iu_full_data |>
  mutate(dummy_pre_ruling =
           case_when(
             list_referring_member_states == "not applicable" &
               list_referring_national_courts == "not applicable" ~ 0,
             TRUE ~ 1
           ))

# What is the usefulness of iuropa id variables?
glimpse(iu_full_data)

unique(iu_full_data$proceeding_suffix)
table(iu_full_data$proceeding_suffix)

# USING export excel as information source
glimpse(iu_full_data)

# FILTER SAVE csv
export_data <- iu_full_data |> 
  filter(court == "Court of Justice" & dummy_pre_ruling == 1 &
           proceeding_suffix == "PPU") |>
  select(ecli, proceeding_name, celex_judgement)

glimpse(export_data)

# SAVE EXCEL for another time
write.xlsx(x = export_data,
           file = "ppu_exportdata.xlsx",
           overwrite = TRUE)

# [?] separate_longer_delim(cols = list_referring_national_courts,
#                       delim = ";") |>
separate_longer_delim()

#######################################
# 6. Basic Visualizations		   ----
# [ ] CREATE some basic visuzalization

## EXAMPLE 1 One that leverages time


## EXAMPLE 2 One that leverages list_referring_national_courts


## EXAMPLE 3 One that leverages member states counts


#######################################
# 7. Excercises					   ----

## Excercise 1 What ECJ formations takes longest delivering judgments?
### 0. SELECT judgments, formation, and duration_days
### 1. FILTER court is "Court of Justice" to do ECJ formations only.
### 2. USE geom_bar()
### 3. VISUALIZE the results.




## Excercise 2 What court delivers the most judgments per month?
### 1. GROUPBY "month" and "court" and n()
### 2. USE geom_bar()
### 3. VISUALIZE the results.




## Excercise 3 What month of year delivers most judgements by court?
### 1. CREATE a scattter using month variable for each court.
### 2. USE geom_point() +  facetwrap() to make R do it.
### 3. VISUALIZE the results.




#######################################
# GLOSSARY						   ----
# rscript: a text file that contains R-code that can be executed in R-Studio.
# directory: a fancy name for folder on your system. The intuition for directory is that its an actual address where the file lives # nolint
# cwd: current working directory, the folder where your script is being executed. By default, is the same folder where your r-scripy lives.   # nolint
# assign: <-
# readxl: library for working with Excel files in R (reading only), see: https://readxl.tidyverse.org/ # nolint
# openxlsx: library for creating, editing, and writing Excel files in R, see: https://ycphs.github.io/openxlsx/ # nolint


#######################################
# MISCELLANEOUS					   ----
# ARCHIVE
# CHECK Session
sessionInfo()
# GLOBAL option encoding for UTF-8
options(encoding = "UTF-8")
# GLOBAL  encoding for Norwegian, just in case
Sys.setlocale("LC_ALL", "nb-NO.UTF-8")

# FIND where R executable lives
file.path(R.home("bin"), "R")

# CHECK if you have installed package
a <- installed.packages()
packages <- a[, 1]
is.element("boot", packages)

#######################################
# PREPARATION					   ----
library(lubridate)
library(tidyverse)
library(conflicted)
library(openxlsx)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

iu_judgements <- read.csv("../iu-judgements.csv")
glimpse(iu_judgements)

unique(iu_judgements$proceeding_suffix)
# [X] Trim clutter variables
iu_trimmed <- iu_judgements |>
  select(court, iuropa_case_id, cjeu_case_id,
         cjeu_proceeding_id, proceeding_suffix, proceeding_name, ecli, celex,
         decision_date, duration_days, count_procedures,
         list_referring_member_states, count_referring_member_states,
         list_referring_national_courts, formation, list_subject_keywords)

glimpse(iu_trimmed)

# [X] Change to datetime
iu_trimmed <- iu_trimmed |>
  mutate(decision_date = as_date(decision_date, format = "%Y-%m-%d"),
         decision_year = year(decision_date))

# [X] Filter using datetime
glimpse(iu_trimmed$decision_date)

glimpse(iu_trimmed)
range(iu_trimmed$decision_date)

iu_trimmed$list_referring_national_courts[1]

# CREATE PART I
iu_judgdements_part1 <- iu_trimmed |>
  filter(decision_date >= "1954-12-21" & decision_date <=  "1990-12-31")

write.csv(iu_judgdements_part1, file = "iu_judgdements_part1.csv",
          row.names = FALSE)

# CREATE PART II
iu_judgdements_part2 <- iu_trimmed |>
  filter(decision_date >= "1991-01-01" & decision_date <=  "1999-12-31")

write.csv(iu_judgdements_part2, file = "iu_judgdements_part2.csv",
          row.names = FALSE)

# CREATE PART III
iu_judgdements_part3 <- iu_trimmed |>
  filter(decision_date >= "2000-01-01" & decision_date <=  "2023-12-21")

write.csv(iu_judgdements_part3, file = "iu_judgdements_part3.csv",
          row.names = FALSE)
glimpse(iu_judgdements_part3)
