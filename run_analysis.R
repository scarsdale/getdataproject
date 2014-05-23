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
memoize.nullary <- function(fn) {
    # memoize a function taking no arguments
    rv <- NULL
    function() {
        if (is.null(rv)) {
            rv <<- fn()
        }
        rv
    }
}
make.activityfactor <- memoize.nullary(function() {
    # get the names of the activity classifications
    activity.labels <- read.labels("activity_labels.txt")
    function (x) {
        factor(x,
               levels=activity.labels[[1]],
               labels=activity.labels[[2]])
    }
})
get.colnames <- memoize.nullary(function() {
    # get the labels for the 561-feature vectors in the dataset
    feature.labels <- read.labels("features.txt")
    feature.labels[[2]]
})
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
xy.file <- function(dataset) {
    # return a function to build a path for the X or Y files within a set
    function (xy) {
        paste(dataset, paste(xy, "_", dataset, ".txt", sep=""), sep="/")
    }
}
get.measurements <- function(pathfn) {
    # read a full dataset (test or training)
    features <- get.colnames()
    read.fwf(getrawdata(pathfn("X")),
             widths=rep(nchar(" -1.0000000e+000"),length(features)),
             header=F,
             col.names=features)
             
}
extract.mean.sd <- function(dat) {
    # subset data frame to only the mean / std dev measurements
    dat[,which(isfeaturemeanorsd(get.colnames()))]
}
get.activities <- function(pathfn) {
    # get the activity classifications for the dataset as a factor vector
    activity.factor = make.activityfactor()
    activities <- read.table(getrawdata(pathfn("y")), header=F)
    activity.factor(activities[,1])
}
get.subjects <- function(pathfn) {
    # get the subject identification for the dataset as a factor vector
    subjects <- read.table(getrawdata(pathfn("subject")), header=F)
    factor(subjects[,1])
}
make.intermediate.data <- function(pathfn) {
    dat <- extract.mean.sd(get.measurements(pathfn))
    dat$Activity <- get.activities(pathfn)
    dat$Subject <- get.subjects(pathfn)
}
