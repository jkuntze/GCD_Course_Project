## R script called run_analysis.R that does the following: 

library(reshape2)

## 0. Gets zip file, and reads data

## remove comments below to download the data from the internet
##url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
##temp <- tempfile()
##download.file(url,temp,method="curl")

## coment line below when downloading data from the internet
temp <- "./UCI HAR Dataset.zip"

activity_labels <- read.table(unz(temp, "UCI HAR Dataset/activity_labels.txt"))
activity_labels$V2 <- sapply(activity_labels$V2, tolower) ## convert to lower case

features <- read.table(unz(temp, "UCI HAR Dataset/features.txt"), as.is = TRUE)

subj_test <- read.table(unz(temp, "UCI HAR Dataset/test/subject_test.txt"))
x_test <- read.table(unz(temp, "UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(unz(temp, "UCI HAR Dataset/test/y_test.txt"))

subj_train <- read.table(unz(temp, "UCI HAR Dataset/train/subject_train.txt"))
x_train <- read.table(unz(temp, "UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(unz(temp, "UCI HAR Dataset/train/y_train.txt"))

## remove comment characters to delete temporary downloaded file
## unlink(temp)

## 1. Merges the training data and the test data into one dataset.

colnames(subj_test) <- "subject"
colnames(subj_train) <- "subject"
colnames(y_test) <- "activity"
colnames(y_train) <- "activity"
colnames(x_test) <- features$V2
colnames(x_train) <- features$V2

test <- cbind(subj_test,y_test,x_test)
train <- cbind(subj_train,y_train,x_train)
dataset <- rbind(test,train)

## 2. Extracts only the measurements on the mean and standard deviation 
## for each measurement. 
mean_index <-grep("mean()",names(dataset),fixed = TRUE)                                                      
std_index <-grep("std()",names(dataset),fixed = TRUE) 
index <- sort(c(mean_index,std_index))
dataset2 <- dataset[c(1,2,index)]   ## columns 1 and 2:subject and activity info

## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names. 

## factor to describe activities
dataset2$Activity <- factor(dataset2$Activity,activity_labels$V1,
                            activity_labels$V2)

## converto to lower case and remove/replace special characters in the 
## variables names
dataset2_colnames <- sapply(names(dataset2), tolower)
colnames(dataset2) <- sapply(dataset2_colnames, gsub, 
                             pattern="([-,()])", replacement="")

## 5.Creates a second, independent tidy data set with the average of each 
## variable for each activity and each subject. 

## Tidy data guidelines
## 1. Each variable you measure should be in one column
## 2. Each different observation of that variable should be in a different row
## 3. There should be one table for each "kind" of variable
## 4. If you have multiple tables, they should include a column in the table
##    that allows them to be linked

datasetMelt<-melt(dataset2,id=c("activity","subject"),
                  measure.vars=names(dataset2[3:68]))
dataset3 <- dcast(datasetMelt, activity+subject ~ variable, mean)

## 6. write to tidydataset.csv
write.csv(dataset3, "tidydataset.csv", row.names = FALSE)