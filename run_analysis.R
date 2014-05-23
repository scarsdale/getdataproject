# Course project for Getting & Cleaning Data MOOC, dealing with smartphone
# accelerometer readings
#
# 1. Download and unpack the zipped data set (if necessary)
# 2. Merge the training and test data into one data set
# 3. Extract only the measurements on the mean and standard deviation
#    for each measurement
# 4. Label the activities with descriptive activity names
# 5. Create a second data set with the average of each variable for
#    each activity and each subject

getrawdata <- function(filename) {
    # extract the specified file from the zip archive,
    # downloading the zip archive first if necessary
    zipdirname <- "UCI HAR Dataset"
    getzipped <- function() {
        zipname <- paste(zipdirname, "zip", sep=".")
        zipurl <- paste("https://d396qusza40orc.cloudfront.net",
                        "getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                        sep="/")
        if (!file.exists(zipname)) {
            download.file(zipurl, zipname, method="curl", quiet=T)
        }
        zipname
    }
    getunzipped <- function(filename) {
        unz(getzipped(), paste(zipdirname, filename, sep="/"))
    }
    getunzipped(filename)
}
read.labels <- function(filename) {
    # read a file mapping numbers to strings, such as features.txt
    read.table(getrawdata(filename), sep=" ", colClasses=c("integer",
                                                  "character"))
}
make.activityfactor <- function() {
    # get the names of the activity classifications
    activity.labels <- read.labels("activity_labels.txt")
    function (x) {
        factor(x,
               levels=activity.labels[[1]],
               labels=activity.labels[[2]])
    }
}
get.colnames <- function() {
    # get the labels for the 561-feature vectors in the dataset
    feature.labels <- read.labels("features.txt")
    feature.labels[[2]]
}
tokenize.label <- function(label) {
    # the label names use `-' as a word delimiter;
    # use this to break vector of label names into a matrix of words
    # "tBodyAcc-mean()-X" => c("tBodyAcc","mean()","X")
    #
    # emits warnings when some of the passed in labels consist of
    # fewer words than the rest
    do.call(rbind, strsplit(label, "-", fixed=T))
}
isfeaturemean <- function(label) {
    tok <- tokenize.label(label)
    tok[,2] == "mean()"
}
isfeaturesd <- function(label) {
    tok <- tokenize.label(label)
    tok[,2] == "std()"
}
isfeaturemeanorsd <- function(label) {
    isfeaturemean(label) | isfeaturesd(label)
}
