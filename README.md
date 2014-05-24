getdataproject
==============

Course project for Getting and Cleaning Data MOOC.

# Data Source

The data summarized here can be downloaded from:
<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

# Analysis Script

The script `run_analysis.R` produces a CSV file summarizing the human
activity recognition data in the form of overall mean time domain and
frequency domain measurements for linear acceleration and angular velocity
for each experimental subject and type of activity.

It performs the following steps:

1. Download the zipped original dataset if it does not already exist
in the current working directory.
1. Associate a name with each column in the dataset.
1. Extract the standard deviation, time domain mean, and frequency domain
weighted mean values from the training set.
1. Add a column identifying the experimental subject for each row.
1. Add a column identifying the type of activity for each row.
1. Repeat the above three steps for the test set.
1. Merge the above results for the training and test sets into one
intermediate data set.
1. Grouping the intermediate data set by experimental subject and type of
activity, take the overall mean of each mean value (discarding the
standard deviation values) for each group.
1. Simplify the column names in the resulting data set.
1. Write the resulting summary data set as comma-separated values to a file
named `tidy.csv`.

This process is described in more detail below.

## Data Download and Extraction

The original data set comes in the form of a zip archive containing
numerous text files, several of which need to be read for the work
performed by `run_analysis.R`.

The `getrawdata()` function is used in the script to read the contents
of text files within the archive. This function uses the standard R
`unz()` function to directly extract members of a zip archive within R,
without first expanding the archive. There is also logic to download the
zip archive if it doesn't already exist in the current working directory.

The main dataset is broken into a training set and a test set, consisting
respectively of 70% and 30% of the total data. These are in the files
`X_train.txt` and `X_test.txt`. Each file is a 561-column table of
floating-point numbers in the below format:  
```
-2.3285230e-002
```  
Each value is encoded using the same number of characters, so the
`read.fwf()` function is used to read the table, as shown below. This
is from the `get.measurements()` function in `run_analysis.R`.

```R
    ret <- read.fwf(getrawdata(pathfn("X")),  
                    widths=rep(nchar(" -1.0000000e+000"),length(features)),  
                    header=F,  
                    col.names=features,  
                    n=n)  
```

In the above listing, `features` is a feature of column names created as
described in the following section.

Because `read.fwf()` truncates column names so that they're the same
length as the values, the column names on the returned data frame
are manually set before `get.measurements()` returns:

```R
    # re-set the column names because read.fwf truncates them  
    colnames(ret) <- features  
```

## Column Name Identification

The `features.txt` file in the zip archive is a two-column table mapping
column numbers in the main dataset to names. In the `get.colnames()`
function, this file is read into R; it is then associated with the data
frame produced by the `get.measurements()` function, and also used as the
basis for selecting variables in the step below.

## Variable Selection

This analysis works with a small subset of the original data's 561 variables.
Only variables representing mean or standard deviation values are selected.

The subset of columns to consider is determined by examining each column
name. The features of a column name that are examined are:

* Whether the column is a time domain or frequency domain value (represented
by a `t` or `f` prefix)
* Whether the column is a vector norm, or individual X, Y, or Z dimension
component (representing by an `X`, `Y`, or `Z` axis suffix for components,
or a base name ending in `Mag` and no axis suffix for norms)
* Which aggregate function the value corresponds to (represented by a
function name suffix, following the name and preceding the axis suffix)

Based on the above features, the selection is made as follows:

* Only vector norms are selected
* For time domain values, the `mean()` aggregate function is selected
* For frequency domain values, `meanFreq()` aggregate function is selected

Frequency domain values have both a `mean()` and a `meanFreq()` column in
the original dataset; according to the README, `meanFreq()` is a weighted
average of the Fourier coefficients. This is chosen over the simple
arithmetic mean since the unit for each Fourier coefficient is different,
making a simple arithmetic mean difficult to interpret.

In `run_analysis.R`, the `isfeaturemeanorsd()` function takes a vector
of column names and returns a logical vector reflecting the selection of
columns based on the above criteria. This is used to subset the data
in the `extract.mean.sd()` function.

## Experimental Subject Identification

The `subject_train.txt` and `subject_test.txt` files in the zip archive
are single-column tables identifying the experimental subject associated
with each sampling window, as an integer between 1 and 30.

Since this table is in the same order as the full dataset, it is
straightforward to read it into R as a vector and then add it to the
intermediate data frame as a column named `Subject`. In `run_analysis.R`,
the subject table is read in the `get.subjects()` function and added to
an intermediate data frame in the `make.intermediate.data()` function.

## Activity Identification

In the zip archive, the `y_train.txt` and `y_test.x` files are
single-column tables giving the activity classification of each
sampling window (in the training and test sets, respectively) as integers
between 1 and 6. The `activity_labels.txt` in turn is a two-column table
mapping these integers to human-readable activity names like `STANDING` or
`WALKING`.

It is straightforward to read the `y` table into R as an integer vector,
and then cast it to a factor vector using the labels read from
`activity_labels.txt`. This is done by the `get.activities()` and
`activity.factor()` functions in `run_analysis.R`.

Since the `y` table is in the same order as the main dataset, it can be
directly added as a column to the intermediate data frame.

## Merging Training and Test Sets

The intermediate data frames corresponding to the training and test sets
are merged together using the built-in `rbind()` function.

## Averaging Grouped by Subject and Activity

For each value corresponding to a mean (i.e. the values that have been
selected thus far minus the standard deviation values), a data
frame is produced containing the overall mean of this measurement
across all sample windows corresponding to the same experimental subject
and type of activity. This is accomplished by creating a subject by activity
matrix of the mean values using the standard R `tapply()` function, then
flattening that matrix into a three-column data frame with a row for each
combination of subject, activity, and mean.

```R
        m <- tapply(dat[,feature], list(dat$Subject, dat$Activity), mean)  
        d <- data.frame(Subject=rep(row.names(m), ncol(m)),  
                        Activity=rep(colnames(m), each=nrow(m)),  
                        z=as.vector(m))  
```

These per-variable data frames are then merged together with the built-in
R `merge()` function, joining on the `Subject` and `Activity` columns,
yielding an 11-column data frame with columns for each of the 9 means, plus
`Subject` and `Activity`.

```R
    measurecolnames <- colnames(dat)[isfeaturemean(colnames(dat))]  
    mergecols <- c("Subject", "Activity")  
    Reduce(function(acc, x) { merge(acc, x, by=mergecols) },  
           lapply(measurecolnames, subject.activity.mean(dat)))  
```

`subject.activity.mean()` is a function-returning-function, creating a
function to perform the `tapply()` and `data.frame()` steps shown in the
previous listing.

## Column Name Transformation

The original data set contains 561 variables, of which this summary includes
only 9. Since only certain types of value are selected -- mean of vector
magnitude/norm -- shorter and less-precise column names can be used.

The `simplify.names()` function removes the `Mag` term indicating a vector
magnitude and the `mean()` or `meanFreq()` suffices indicating a mean
value. Also, for reasons unknown the names of some frequency domain
measurements in the original dataset use `BodyBody`; this is reduced to
`Body` in `simplify.names()`.

```R
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
```

Next, the `expand.names()` function takes certain abbreviations and expands
them into full words. Specifically, the `Acc` abbreviation is expanded to
`Acceleration` and `Gyro` is expanded to `AngularVelocity`. Also, the `t`
prefix denoting time domain values is removed, while the `f` prefix denoting
frequency domain values is expanded to `FrequencyOf`.

```R
    ret <- sub("Acc", "Acceleration", labels, fixed=T)  
    ret <- sub("Gyro", "AngularVelocity", ret, fixed=T)  
    ret <- sub("^t", "", ret)  
    sub("^f", "FrequencyOf", ret)  
```

Example: The column name `fBodyBodyGyroMag-meanFreq()` is replaced with
`FrequencyOfBodyAngularVelocity`.

## Summary Data Output

```R
write.csv(make.tidy(make.merged.intermediate()),
          "tidy.csv",
          row.names=F)
```

The summary data are written to a file named `tidy.csv` using the standard
R `write.csv()` function. The output of row names is suppressed by setting
the `row.names` parameter to `FALSE`.
