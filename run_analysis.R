# Course project for Getting & Cleaning Data MOOC, dealing with smartphone
# accelerometer readings
#
# 1. Download and unpack the zipped data set (if necessary)
# 2. Merge the training and test data into one data set
# 3. Label the activities with descriptive activity names
# 4. Create a second data set with the average of each variable for
#    each activity and each subject

getrawdata <- function(filename) {
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
