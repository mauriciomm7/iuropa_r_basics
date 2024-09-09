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
library(ggplot2)
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
iu_full_data$celex_judgement[1:10] # <- Why do I add [1:10] ?

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
glimpse(iu_full_data$cjeu_proceeding_id)
unique(iu_full_data$proceeding_suffix)
table(iu_full_data$proceeding_suffix)

# USING export excel as information source
glimpse(iu_full_data)

# FILTER SAVE to EXCEL file
export_data <- iu_full_data |>
  filter(court == "Court of Justice" & dummy_pre_ruling == 1 &
           proceeding_suffix == "PPU") |>
  select(cjeu_proceeding_id, ecli, proceeding_name, celex_judgement)

glimpse(export_data)

# SAVE EXCEL for another time!
write.xlsx(x = export_data,
           file = "ppu_exportdata.xlsx",
           overwrite = TRUE)




# Expanding Dataframes: Change of unit of analysis

## LET's filter on prelimary rulings again but all columns
expanded_data <- iu_full_data |>
  filter(court == "Court of Justice" & dummy_pre_ruling == 1)

## What is my unit of analysis? hint: each row is...
glimpse(expanded_data) # OR have a look at vars...

## Lets change it to national courts (because of joined cases)
expanded_data2 <- expanded_data |>
  separate_longer_delim(cols = list_referring_national_courts,
                        delim = ",")

### [?] What is a delimiter [?]
expanded_data$list_referring_national_courts[20:20]


# What happens to the number of rows?
nrow(expanded_data) # <- How many before ?
nrow(expanded_data2) # <- How many after ?

# What happens to row values?
expanded_data$list_referring_national_courts[20:21] # <- Values before
expanded_data2$list_referring_national_courts[20:22] # <- Values after

# <> Checkpoint <>
#######################################
# 6. Basic Visualizations		   ----

## EXAMPLE 1: What Court takes the longest to deliver judgements since Lisbon?
### FILTER $decision_date all judgements after 1 December 2009
### SELECT $court, $duration_days $year
### GROUPBY $court, $decision_year CALCULATE median() for duration_days
### USE GGPLOT2 AND save as png
example1_data <- iu_full_data |>
  filter(decision_date >= "2008-12-01") |>
  select(court, decision_year, duration_days) |>
  group_by(court, decision_year) |>
  summarize(median_duration = median(duration_days))

# LET's see if the data looks right! :)
table(example1_data$median_duration)

# USING GGPLOT2 lets make bar graph
example1_plot <- example1_data |>
  ggplot(aes(x = factor(decision_year), y = median_duration, fill = court)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  labs(
    title = "Median Duration per Decision Year by Court",
    x = "Decision Year",
    y = "Median Duration (Days)",
    fill = "Court"
  ) +
  scale_fill_discrete() +
  theme_minimal() +
  theme(legend.position = "bottom")

# LET's display the plot
print(example1_plot)

# SAVING plot as png and make it look nice
ggsave("nice_plot1.pdf", plot = example1_plot,
       width = 16,
       height = 9,
       units = "in",
       dpi = 300)

## EXAMPLE 2 When does the ECJ decides backlog cases?
### FILTER $court is European Court of Justice
### SELECT $decision_date, $duration_days
### GGPLOT2 scatter_plot() export to .png

example2_data <- iu_full_data |>
  filter(court == "Court of Justice") |>
  select(decision_date, duration_days)

example2_plot <- example2_data |>
  ggplot(aes(x = decision_date,
             y = duration_days)) +
  geom_point(color = "skyblue") +
  geom_smooth(color = "darkblue", fill = "cornflowerblue") +
  labs(x = "Judgement Date", y = "Duration in Days (lodge to judgement)") +
  theme_classic()
example2_plot


# SAVING plot as png and make it look nice
ggsave("nice_plot2.png", plot = example2_plot,
       width = 8,
       height = 6,
       units = "in",
       dpi = 300)

## EXAMPLE 3 What are the top 10 National Courts have referred the most?
### FILTER $dummy_pre_ruling
### SELECT $list_referring_national_courts , $iuropa_case_id
### SEPARATE ROWS courts  separate_longer_delim( )
### RENAME $list_referring_national_courts to $national_court
### GROUPBY $national_court count totalcases using  n()
### ARRANGE $cases AND select top 10
### USE GGPLOT2 and EXPORT to .pdf

example3_data <-  iu_full_data |>
  filter(dummy_pre_ruling == 1) |>
  select(list_referring_national_courts, iuropa_case_id) |>
  separate_longer_delim(cols = list_referring_national_courts,
                        delim = ",") |>
  rename(national_court = list_referring_national_courts) |>
  group_by(national_court) |>
  summarize(cases = n()) |>
  arrange(desc(cases)) 	|>
  head(10)

# Another way of selecting TOP10 observations?
example3_plot <- example3_data |>
  ggplot(aes(x = fct_reorder(national_court, cases),
             y = cases)) +
  geom_bar(stat = "identity",
           fill = "steelblue",
           color = "steelblue4") +
  coord_flip() +
  labs(x = "Referring National Court",
       y = "Count of Preliminary References") +
  theme_classic()

# CAN we change the extension when exporting?
# SAVING plot as png and make it look nice
ggsave("nice_plot3.pdf", plot = example3_plot,
       width = 10,
       height = 4,
       units = "in",
       dpi = 300)

# <> Checkpoint <>
#######################################
# 7. Excercises					   ----
## Excercise 1 What ECJ formations takes the longest delivering judgments?
### 1. FILTER $court is "Court of Justice" to get ECJ formations only.
### 2. SELECT $judgments, $formation, and $duration_days
### 3. USE geom_bar() to tell R how do it.
### 4. VISUALIZE the results.


## Excercise 2 When CJEU courts decide backlog cases?
### 1. CREATE a scattter using variable for each court.
### 2  SELECT $decision_date $duration_days $court
### 3. USE geom_point() + facetwrap() to tell R how do it.
### 4. VISUALIZE the results.


## Excercise 3 What member state has reffered the most?
### 1. CREATE a bar plot with counts of member state referrals.
### 2. SELECT $list_referring_national_courts,
###        $iuropa_case_id and $list_referring_member_states
### 3. SEPARATE ROWS courts separate_longer_delim()
### 4. RENAME list_referring_member_states = member_state
### 5. GROUPBY $national_court count totalcases using  n()
### 6. USE geom_bar() to tell R how do it.
### 7. VISUALIZE the results.


#######################################
# GLOSSARY						   ----
# rscript: a text file that contains R-code that can be executed in R-Studio.
# directory: a fancy name for folder on your system. The intuition for directory is that its an actual address where the file lives # nolint
# cwd: current working directory, the folder where your script is being executed. By default, is the same folder where your r-scripy lives.   # nolint
# assign: <- the arrow pointing left is know as assign operator.
# select a var: the $ the dollar sign is used to select a single var.
# LIBRARIES ###########################
# readxl: library for working with Excel files in R (reading only), see: https://readxl.tidyverse.org/ # nolint
# openxlsx: library for creating, editing, and writing Excel files in R, see: https://ycphs.github.io/openxlsx/ # nolint
# ggplot2: library for creating complex and customizable visualizations in R, part of the tidyverse, see: https://ggplot2.tidyverse.org/ # nolint
# lubridate: library for working with dates and times in R, parse, manipulate, and analyze date-time data, see: https://lubridate.tidyverse.org/ # nolint
# tidyverse: a collection of R packages designed for data science, including dplyr, ggplot2, and others, providing tools for data manipulation, visualization, and more, see: https://www.tidyverse.org/ # nolint





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
