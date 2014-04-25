
setwd("~/GitHub/coursera-getdata-002")
require(data.table)
require(plyr)

if( !any(dir() == "UCI HAR Dataset") ){
  cat("Unzipping getdata-projectfiles-UCI HAR Dataset.zip\n")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}

cat("Reading activity_labels.txt\n")
activity_labels <- read.csv("UCI HAR Dataset/activity_labels.txt", header=FALSE, sep = "")
names(activity_labels) <- c("id", "activity")

cat("Reading features.txt\n")
features <- read.csv("UCI HAR Dataset/features.txt", header=FALSE, sep = "")
names(features) <- c("id", "name")

# IDs of the measurements on the mean and standard deviation for each measurement. 
mean_and_std_IDs <- c( grep("mean", features$name, fixed=TRUE), grep("std", features$name, fixed=TRUE))

#Removing special characters from names
# For example "tBodyAcc-mean()-X" become "tBodyAcc_mean_X"
features$name <- gsub("\\W", "_", features$name)            
features$name <- gsub("___", "_", features$name)  
features$name <- gsub("__", "_", features$name)  
features$name <- gsub("_$", "", features$name)  

# Train an test folders have similar structure and file names. 
# So to follow DRY principle (http://en.wikipedia.org/wiki/Don't_repeat_yourself) 
# I am going to use one function to process both data sets.
# As a helper I need to have function to get path to apropriate files.

getPath <-function(f, set) { paste0("UCI HAR Dataset/", set,"/", f, "_", set,".txt")}

processSet <- function(set){
  X <- read.csv(getPath("X", set), header=FALSE, sep = "")
  names(X) <- features$name
  
  #2) Extracts only the measurements on the mean and standard deviation for each measurement. 
  mean_and_std <- X[mean_and_std_IDs]
    
  y <- read.csv(getPath("y", set), header=FALSE, sep = "", col.names="label_id")
  subject<- read.csv(getPath("subject", set), header=FALSE, sep = "", col.names="id")
  
  out <- cbind( data.table(activity = as.factor(activity_labels$activity[y$label_id]),
                            subject = subject$id,
                            set),
                  mean_and_std)
}

cat("Reading train set\n")
train <- processSet("train")

cat("Reading test set\n")
test <- processSet("test")

result = rbind(train, test)
result$set <- as.factor(result$set)

independent_dataset <- ddply(result, .(activity, subject), .fun = function(x){ colMeans(x[, 4:82], na.rm = TRUE)})


# Unit test:
# Alternative way to compute mean value is used to verify one value from independent_dataset
 if( independent_dataset[1,]$tBodyAcc_mean_X == 
       mean(result[activity=="LAYING" & subject==1,]$tBodyAcc_mean_X)){
   cat("Unit test passed\n")
 }else{
    cat("Unit test FAILED!!!!!\n")
  }


write.table(independent_dataset, file="./independent_tidy_data_set.txt", sep="\t", row.names=FALSE)
