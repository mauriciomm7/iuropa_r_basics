
Review Materials for Creating R Workshop
- [R basics](https://raw.githack.com/lfoswald/R-workshop/main/primer-1-basics/1-basics.html#Sources)
- [Tidiverse](https://raw.githack.com/lfoswald/R-workshop/main/primer-2-tidyverse/2-tidyverse.html#Tidyverse_packages)
- [R with RStudio](https://raw.githack.com/intro-to-data-science-21/labs/main/session-1-intro/1-intro.html#Sources)
- [Automated Data Collection in R](http://www.r-datacollection.com/)

Text as Data Exercise
Create an simple dictionary based approach for classifying legal arguments which follow particular phrases that you care about on account of your expert knowledge. " " 
- Aim: Students will learn to to query text paragraohs and classify them into conceptual categories that they assign
- Define your scope of inference:
- Create dictionary of terms with respective categories:
- Validation Strategy:
  - Exhaustive validation 
  - Random Sampling validation
 - Reliability Tests:
   - For first ten items validate schemes we selected people upload their csvs to dropbox  I run it lived and get results.
 - EXERCISES:
- CREATE barplot of counts per category
- CREATE scatterplot of categories over time
- CREATE Lineplot of average monthly counts by court 
- CREATE ANOVA plots per category per court.


For me 
- CREATE a trimmed version of the text data ['par_id', par_num', 'par_text']  plus features ['court_id', 'date']
  - TRIM text after creation of General Court.   
- CREATE validation function that returns para and category for a given range and you input whether it matched what you wanted or not.
    - Copies DF
    - Returns only validated items descriptive statistics
- CREATE function that reads dropbox folder *.csv |> checks if keyids are the same |> concatenates them |> print reliability estimates.
- CREATE main .qmd file with requirements (libraries, loading custom functions), examples, and exercises
  - ADD codeblock that creates and saves csv output.csv  

REPO requirements
- `./droot`: root directory for IUROPA workshop
- `./_day2:`: directory for specific text exercise.
- `project.RPROJECT`: Rproject of QMD file.
- `working_with_text.cvs`: Trimmed version of the IUROPA DB for workshop.
- `custom_functions.r`: Script with costum functions for exercises.
- `main_notebook.qmd`: Main .qmd file with exercises and examples.
- `_figures`: main diretory where figures are saved.


NOTE we're creating a project and a dirs so that it makes it easier to work with relative paths.
