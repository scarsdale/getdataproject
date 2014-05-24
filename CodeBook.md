# Summary Dataset Code Book

This summary data set is a table of 11 comma-separated values:

1. Subject
1. Activity
1. BodyAcceleration
1. GravityAcceleration
1. BodyAccelerationJerk
1. BodyAngularVelocity
1. BodyAngularVelocityJerk
1. FrequencyOfBodyAcceleration
1. FrequencyOfBodyAccelerationJerk
1. FrequencyOfBodyAngularVelocity
1. FrequencyOfBodyAngularVelocityJerk

The subject and activity columns are metadata identifying the
measurements.  
The measurements are measurements of linear acceleration and angular
velocity, as measured by the accelerometer and gyroscope of a
Samsung Galaxy S II smartphone worn on the subjects' waists.  
The measurements in this summary dataset are the overall means for each
subject and each activity.

## Linear Acceleration

The linear acceleration on the X, Y, and Z axes was measured at a rate of
50 Hz over a period of 2.59 seconds, for a total of 128 samples per window.  

The acceleration is in gravities, i.e. 9.8 meters per second squared.  

In the original dataset,
the Euclidean norm of the X, Y, and Z components was then taken to yield a
magnitude for each 3-dimensional vector and the arithmetic mean of these
128 per-sample magnitudes taken to produce a per-sampling window mean.  

In this summary dataset, the sampling windows were grouped by subject and
activity, and the overall mean over all sampling windows for each subject
and activity is reported.

## Angular Velocity

The angular velocity on the X, Y, and Z axes was measured at a rate of 50 Hz
over a period of 2.59 seconds, for a total of 128 samples per window.  

The angular velocity is in radians per second.  

In the original dataset,
the Euclidean norm of the X, Y, and Z components was then taken to yield a
magnitude for each 3-dimensional vector and the arithmetic mean of these
128 per-sample magnitudes taken to produce a per-sampling window mean.  

In this summary dataset, the sampling windows were grouped by subject and
activity, and the overall mean over all sampling windows for each subject
and activity is reported.

## Frequency Domain Measurements

In the original dataset, the Discrete Fourier Transforms (DFT) of the
linear acceleration and angular velocity measurements were taken to yield
frequency domain signals. Since 128 samples were taken at a rate of 50 Hz,
the raw frequency domain signal for each window is a set of 128 spectral
coefficients as increasing multiples of 50 Hz divided by 128, or about
0.39 Hz.  

The original dataset contains a weighted average of the spectral
coefficients for each smapling window, called "mean frequency." It's
unclear whether this should be interpreted as a multiple of 1 Hz or
a multiple of the sampling rate, 50 Hz.  

In this summary dataset, the sampling windows were grouped by subject and
activity, and the overall mean frequency over all sampling windows for
each subject and activity is reported.

## Missing Values

This summary contains no missing values.

## Individual Variables

### Subject

An integer 1 to 30 identifying which of the 30 experimental subjects these
measurements are associated with. The subjects were volunteers between 19
and 48 years of age.

### Activity

A string identifying which activity the measurements are associated with.
This can be one of the following six activities:

* WALKING
* WALKING_UPSTAIRS
* WALKING_DOWNSTAIRS
* SITTING
* STANDING
* LAYING

### BodyAcceleration

The acceleration that was not due to gravity, i.e. acceleration that can
be attributed to the subject's body movements.

### GravityAcceleration

Acceleration due to gravity.

### BodyAccelerationJerk

The derivative of the body's linear acceleration,
in units of 9.8 meters per second cubed.

### BodyAngularVelocity

The angular velocity of the body in radians per second.

### BodyAngularVelocityJerk

The derivative of BodyAngularVelocity, in radians per second squared.

### FrequencyOfBodyAcceleration

The overall mean frequency of the body's linear acceleration in Hz.

### FrequencyOfBodyAccelerationJerk

The overall mean frequency of the body's jerk in Hz.

### FrequencyOfBodyAngularVelocity

The overall mean frequency of the body's angular velocity in Hz.

### FrequencyOfBodyAngularVelocityJerk

The overall mean frequency of the body's angular jerk in Hz.
