
setwd("~/GitHub/coursera-getdata-002")
require(data.table)

if( !any(dir() == "UCI HAR Dataset") ){
  cat("Unzipping getdata-projectfiles-UCI HAR Dataset.zip\n")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}


activity_labels <- read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep = "")
names(activity_labels) <- c("id", "label")

features <- read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep = "")
names(features) <- c("id", "name")

#Removing special characters from names
# For example "tBodyAcc-mean()-X" become "tBodyAcc_mean_X"
features$name <- gsub("\\W", "_", features$name)            
features$name <- gsub("___", "_", features$name)  
features$name <- gsub("__", "_", features$name)  
features$name <- gsub("_$", "", features$name)  

X_train <- read.csv("UCI HAR Dataset/train/X_train.txt", header=FALSE, sep = "")
names(X_train) <- features$name
  
y_train <- read.csv("UCI HAR Dataset/train/y_train.txt", header=FALSE, sep = "", col.names="label_id")
subject_train<- read.csv("UCI HAR Dataset/train/subject_train.txt", header=FALSE, sep = "", col.names="id")

train <- cbind( data.table(label = as.factor(activity_labels$label[y_train$label_id]),
                          subject = subject_train$id,
                          set="train"),
                X_train)

