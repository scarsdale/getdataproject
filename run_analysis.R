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
doesfeaturematch <- function(re) {
    function(label) {
        sapply(label, function(s) { length(grep(re, s)) != 0 })
    }
}
isfeaturemeantime <- doesfeaturematch("^t[a-zA-Z-]+-mean\\(\\)$")
isfeaturemeanfreq <- doesfeaturematch("^f[a-zA-Z-]+-meanFreq\\(\\)$")
isfeaturesd <- doesfeaturematch("-std\\(\\)$")
isfeaturemean <- function(label) {
    isfeaturemeantime(label) | isfeaturemeanfreq(label)
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
get.measurements <- function(pathfn, n=-1) {
    # read a full dataset (test or training)
    features <- get.colnames()
    ret <- read.fwf(getrawdata(pathfn("X")),
                    widths=rep(nchar(" -1.0000000e+000"),length(features)),
                    header=F,
                    col.names=features,
                    n=n)
    # re-set the column names because read.fwf truncates them
    colnames(ret) <- features
    ret
}
extract.mean.sd <- function(dat) {
    # subset data frame to only the mean / std dev measurements
    dat[,which(isfeaturemeanorsd(get.colnames()))]
}
get.activities <- function(pathfn, n=-1) {
    # get the activity classifications for the dataset as a factor vector
    activity.factor = make.activityfactor()
    activities <- read.table(getrawdata(pathfn("y")), header=F, nrows=n)
    activity.factor(activities[,1])
}
get.subjects <- function(pathfn, n=-1) {
    # get the subject identification for the dataset as a factor vector
    subjects <- read.table(getrawdata(pathfn("subject")), header=F, nrows=n)
    factor(subjects[,1])
}
make.intermediate.data <- function(pathfn, n=-1) {
    # make an intermediate data set consisting of
    # the mean and std dev measurements with activity and subject added
    dat <- extract.mean.sd(get.measurements(pathfn, n=n))
    dat$Activity <- get.activities(pathfn, n=n)
    dat$Subject <- get.subjects(pathfn, n=n)
    dat
}
make.merged.intermediate <- function(n=-1) {
    # merge the training and test sets into one intermediate data set
    rbind(make.intermediate.data(xy.file("train"), n=n),
          make.intermediate.data(xy.file("test"), n=n))
}
subject.activity.mean <- function(dat) {
    # return a function to build a 3-column data frame giving the mean
    # for the given feature for each subject, activity pair
    #
    # Subject Activity feature
    # 1       WALKING  3.141
    # ...
    function(feature) {
        m <- tapply(dat[,feature], list(dat$Subject, dat$Activity), mean)
        d <- data.frame(Subject=rep(row.names(m), ncol(m)),
                        Activity=rep(colnames(m), each=nrow(m)),
                        z=as.vector(m))
        colnames(d)[3] <- feature        
        d
    }
}
subject.activity.means <- function(dat) {
    # take an intermediate data set and reduce it to each variable's
    # overall mean for a given subject,activity pair
    measurecolnames <- colnames(dat)[isfeaturemean(colnames(dat))]
    mergecols <- c("Subject", "Activity")
    Reduce(function(acc, x) { merge(acc, x, by=mergecols) },
           lapply(measurecolnames, subject.activity.mean(dat)))
}
simplify.names <- function(labels) {
    # remove the 'Mag-mean()' suffix from measurement labels,
    # since we are reporting only the overall means of vector magnitudes
    # also deduplicate BodyBody to Body
    sapply(labels, function(s) {
        if (s %in% c("Activity", "Subject"))
            s
        else if (substr(s, 1, 1) == "t")
            sub("BodyBody",
                "Body",
                substr(s, 1, nchar(s) - nchar("Mag-mean()")),
                fixed=T)
        else
            sub("BodyBody",
                "Body",
                substr(s, 1, nchar(s) - nchar("Mag-meanFreq()")),
                fixed=T)
    })
}
expand.names <- function(labels) {
    # expand Acc -> Acceleration and Gyro -> AngularVelocity
    # remove t prefix and replace f prefix with FrequencyOf
    ret <- sub("Acc", "Acceleration", labels, fixed=T)
    ret <- sub("Gyro", "AngularVelocity", ret, fixed=T)
    ret <- sub("^t", "", ret)
    sub("^f", "FrequencyOf", ret)
}
make.tidy <- function(dat) {
    ret <- subject.activity.means(dat)
    colnames(ret) <- expand.names(simplify.names(colnames(ret)))
    ret
}
write.csv(make.tidy(make.merged.intermediate()),
          "tidy.csv",
          row.names=F)
