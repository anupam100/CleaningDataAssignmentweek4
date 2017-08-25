library(reshape2)

filename <- "dataset.zip"

## downloading file
if (!file.exists(filename))
{
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename)
}  

## check if file already exists
if (!file.exists("UCI HAR Dataset")) 
{ 
  unzip(filename) 
}

# Loading features and activities
featureList <- read.table("UCI HAR Dataset/features.txt")
featureList[,2] <- as.character(featureList[,2])
activityList <- read.table("UCI HAR Dataset/activity_labels.txt")
activityList[,2] <- as.character(activityList[,2])


# Extract relavant  data on mean and std
relavantData <- grep(".*mean.*|.*std.*", featureList[,2])
relavantData.names <- featureList[relavantData,2]
relavantData.names = gsub('-mean', 'Mean', relavantData.names)
relavantData.names = gsub('-std', 'Std', relavantData.names)
relavantData.names <- gsub('[-()]', '', relavantData.names)


# now loading
trainData <- read.table("UCI HAR Dataset/train/X_train.txt")[relavantData]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainData <- cbind(trainSubjects, trainActivities, trainData)

testData <- read.table("UCI HAR Dataset/test/X_test.txt")[relavantData]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testData <- cbind(testSubjects, testActivities, testData)

# merge datasets and add labels
allData <- rbind(trainData, testData)
colnames(allData) <- c("subject", "activity", relavantData.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityList[,1], labels = activityList[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)