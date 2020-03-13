# R Script: run_analysis.R 
# Assignment: Getting and Cleaning Data Course Project
# Data URL:  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Created by: Surina

# Instructions
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.



# Pre-Analysis 

## Load required libraries
```{r}
library(data.table)
library(reshape2)
```

## Get data
```{r}
URL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
DatasetZIP <- "./Dataset.zip"# Local Zipped data file
DirFile <- "./UCI HAR Dataset"
```

## Unzip data
```{r}
if (file.exists(DatasetZIP) == FALSE) {
  download.file(URL, destfile = DatasetZIP)
}
if (file.exists(DirFile) == FALSE) {
  unzip(DatasetZIP) 
}
```

## Assign  directory and filename of final clean/tidy data:
```{r}
tidyDatasetFile <- "./tidy-dataset.txt"
tidyDatasetFileAVG <- "./tidy-datasetAVG.csv"
tidyDatasetFileAVGtxt <- "./tidy-datasetAVG.txt"
```

## Read data
```{r}
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)

Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", header = FALSE)
Y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", header = FALSE)

Subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
Subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
```

# 1.  Merges the training and the test sets to create one data set.
```{r}
X <- rbind(X_train, X_test) #combining data table by "X_train" vs "_Xtest" by rows
Y <- rbind(Y_train, Y_test) #combining data table by "Y_train" vs "Y_test" by rows
S <- rbind(Subject_train, Subject_test) #combining data table by "S_train" vs "S_test" by rows
```

## 2.  Extracts only the measurements on the mean and standard deviation for each measurement.
```{r}
Features <- read.table("./UCI HAR Dataset/features.txt") # Read Features
names(Features) <- c('feat_id', 'feat_name') # Feature names to columns 

Index_features <- grep("-mean\\(\\)|-std\\(\\)", Features$feat_name) 
X <- X[, Index_features] # Search for matches to the mean or std dev

names(X) <- gsub("\\(|\\)", "", (Features[Index_features, 2])) # Replaces the matches from string
```

# 3.  Uses descriptive activity names to name the activities in the data set
```{r}
Activities <- read.table("./UCI HAR Dataset/activity_labels.txt") # Read activity labels

names(Activities) <- c('act_id', 'act_name') # Descriptive names
Y[, 1] = Activities[Y[, 1], 2]
names(Y) <- "Activity"
names(S) <- "Subject"
```

# 4.  Appropriately labels the data set with descriptive variable names.
```{r}
tidyDataSet <- cbind(S, Y, X)# Combine dataset by columns
```

# 5.  From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```{r}
m <- tidyDataSet[, 3:dim(tidyDataSet)[2]] 
Avg_tidyDataSet <- aggregate(m,list(tidyDataSet$Subject, tidyDataSet$Activity), mean)

names(Avg_tidyDataSet)[1] <- "Subject" # Activity column naming
names(Avg_tidyDataSet)[2] <- "Activity" # Subject column naming

write.table(tidyDataSet, tidyDatasetFile, sep="") # Created table for tidyDataSet

write.csv(Avg_tidyDataSet, tidyDatasetFileAVG) # Created CSV  for Avg_tidyDataSet

write.table(Avg_tidyDataSet, tidyDatasetFileAVGtxt, sep="", row.names=FALSE) # Create table for Avg_tidyDataSet
```
