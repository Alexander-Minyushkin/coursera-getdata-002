
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
  
  out <- cbind( data.table(label = as.factor(activity_labels$label[y$label_id]),
                            subject = subject$id,
                            set),
                  mean_and_std)
}

train <- processSet("train")
test <- processSet("test")

result = rbind(train, test)
result$set <- as.factor(result$set)
