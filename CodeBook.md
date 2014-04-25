## Code book for Coursera Getting and Cleaning Data project

Whole processing is done in run_analysis.R script.
Once you clone this repo you probably will need to change working directory for the script in the line:
```
setwd("~/GitHub/coursera-getdata-002")
```

You can see how required libraries are loaded:
```
require(data.table)
require(plyr)
```

Following code will unzip raw data at first run of the script. If you will not delete these files, unzipping will be skiped during next runs.
```
if( !any(dir() == "UCI HAR Dataset") ){
  cat("Unzipping getdata-projectfiles-UCI HAR Dataset.zip\n")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}
```

Very straightforward reading of activities and features from text files. Names are changed to be more descriptive, by default it is V1 and V2.
```
cat("Reading activity_labels.txt\n")
activity_labels <- read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep = "")
names(activity_labels) <- c("id", "activity")

cat("Reading features.txt\n")
features <- read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep = "")
names(features) <- c("id", "name")
```

Next is important part: looking for column IDs where "mean" and "std" words are mentioned since we need to extract  only the measurements on the mean and standard deviation for each measurement
```
mean_and_std_IDs <- c( grep("mean", features$name, fixed=TRUE), grep("std", features$name, fixed=TRUE))
```

Making variable names suitable for work in R: removing brackets, commas and repeatable underscores.
For example "tBodyAcc-mean()-X" become "tBodyAcc_mean_X"
```
features$name <- gsub("\\W", "_", features$name)            
features$name <- gsub("___", "_", features$name)  
features$name <- gsub("__", "_", features$name)  
features$name <- gsub("_$", "", features$name)  
```

Folders "test" and "trainig" have similar structure, so I write one function to process them ```processSet``` and helper function to cunstruct exact path to required files:
```
getPath <-function(f, set) { paste0("UCI HAR Dataset/", set,"/", f, "_", set,".txt")}
```

Function ```processSet <- function(set) {...}``` takes set name as an only argument. It's value  can be "test" or "trainig"

Reading main data and leaving only "mean" and "std" values:
```
  X <- read.csv(getPath("X", set), header=FALSE, sep = "")
  names(X) <- features$name  
  mean_and_std <- X[mean_and_std_IDs]
```

Reading activity and subject IDs
```
  y <- read.csv(getPath("y", set), header=FALSE, sep = "", col.names="label_id")
  subject<- read.csv(getPath("subject", set), header=FALSE, sep = "", col.names="id")
```

Applying descriptive activity names to name the activities in the data set, also labeling trainig/test data
```
  out <- cbind( data.table(activity = as.factor(activity_labels$activity[y$label_id]),
                            subject = subject$id,
                            set),
                  mean_and_std)
```

Loading and combining traing and test data into one data set
```
cat("Reading train set\n")
train <- processSet("train")

cat("Reading test set\n")
test <- processSet("test")

result = rbind(train, test)
result$set <- as.factor(result$set)
```

Creation of a second, independent tidy data set with the average of each variable for each activity and each subject. 
```
independent_dataset <- ddply(result, .(activity, subject), .fun = function(x){ colMeans(x[, 4:82], na.rm = TRUE)})
```

### Functions
getPath - function to cunstruct exact path to required files
processSet  - loading and proper labeling of data

### Variables created during script execution
activity_labels - Activity lables from raw data.
features - Features from raw data
independent_dataset - Dataset for project submission
mean_and_std_IDs - IDs of data columns to be processed
result - joined test and train data
test - test in tidy form
train - train in in tidy form

### Files created during script execution
UCI HAR Dataset - folder with raw data
independent_tidy_data_set.txt - file with data for project submission