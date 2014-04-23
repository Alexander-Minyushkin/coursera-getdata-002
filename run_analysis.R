
setwd("~/GitHub/coursera-getdata-002")

if( !any(dir() == "UCI HAR Dataset") ){
  cat("Unzipping getdata-projectfiles-UCI HAR Dataset.zip\n")
  unzip("getdata-projectfiles-UCI HAR Dataset.zip")
}



l <- readLines("UCI HAR Dataset/train/X_train.txt")