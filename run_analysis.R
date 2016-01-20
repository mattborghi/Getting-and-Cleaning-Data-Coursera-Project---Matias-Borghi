#You should create one R script called run_analysis.R that does the following.

#1.	Merges the training and the test sets to create one data set.
#Create a new folder to save the new merged files if there is no one created
if(!file.exists("./merged")){dir.create("./merged")}
#First we are going to cbind() separately the test and training data sets..
#================================================================================
#Test data set
#Load the three files and check dimentions
testSubject = read.table("test/subject_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(testSubject)
#[1] 2947 1
testFeatures = read.table("test/X_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(testFeatures)
#[1] 2947 561
testActivity = read.table("test/y_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(testActivity)
#[1] 2947 1
#Cbind the 563 columns in the order testSubject - testActivity - testFeatures
testTable = cbind(testSubject,testActivity,testFeatures)
#Check that have the desired dimentions
dim(testTable)
#[1] 2947 563 
#----------------------------------------------------------------------------------
#Training data set
#Load the three files and check dimentions
trainSubject = read.table("train/subject_train.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(trainSubject)
#[1] 7352 1
trainFeatures = read.table("train/X_train.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(trainFeatures)
#[1] 7352 561
trainActivity = read.table("train/y_train.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
dim(trainActivity)
#[1] 7352 1
#Cbind the 563 columns in the order trainSubject - trainActivity - trainFeatures
trainTable = cbind(trainSubject,trainActivity,trainFeatures)
#Check that have the desired dimentions
dim(trainTable)
#[1] 7352 563
#--------------------------------------------------------------------------------------
#Now rbind() the set and train data sets
mergedDS = rbind(testTable,trainTable)
dim(mergedDS)
#[1] 10299 563 
#=====================================================================================================
#Now do the 3 & 4 points
#3. Uses descriptive activity names to name the activities in the data set
#4. Appropriately labels the data set with descriptive variable names.

#We begin extracting the names for the 561 vector from the "features.txt" file
features = read.table("features.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
#We are interested in the second column
names(mergedDS)[3: (length(testFeatures)+2) ]  = features[,2]
#Name the subject column to ID Subject
names(mergedDS)[1] = "IDsubject"
#Nme the last column
names(mergedDS)[2] = "Activity"
#------------------------------------------------------------------------------------------------------
#Now we are going to change the [1-6] values in the last column to a more descriptive form like the ones
#in the file "activity_labels.txt"
activityLabels = read.table("activity_labels.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
mergedDS[,names(mergedDS)[2]] = sapply(mergedDS[,names(mergedDS)[2]],function(x) mergedDS[x,names(mergedDS)[2]] = activityLabels[x,2])
#=============================================================================================================
#2. Extracts only the measurements on the mean and standard deviation for each measurement.
meanNames <- grep("mean()",names(mergedDS),value=TRUE)
stdNames <- grep("std()",names(mergedDS),value=TRUE)
#Remember to add the first two columns
extractNames <- c(names(mergedDS[1]),names(mergedDS[2]),meanNames,stdNames)

filterDS <- mergedDS[,extractNames]
#It has the same columns as the length of the variable extractNames + the first two columns
dim(filterDS)
#[1] 10299 81
#Save the data frame
write.table(filterDS,"merged/filteredTable.txt",row.name=FALSE )
#==============================================================================================================
#5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
#Method 1
#Use ddply
#library(plyr)
#Remove unwanted characters in the column names:
#- The space
names(filterDS) <- gsub(" ","",names(filterDS))
#- The "-"
names(filterDS) <- gsub("-","",names(filterDS))
#- The "()"
names(filterDS) <- gsub("\\(\\)","",names(filterDS))
#summData <- ddply(filterDS,c(names(filterDS)[1], names(filterDS)[2]),summarise,mean = mean( names(filterDS)[3] ) )
#Method 2 - Using a data frame and dplyr with summarize
#Use a data frame to use the dplyr library
mergedDF = as.data.frame.matrix(filterDS) 
suppressPackageStartupMessages(library(dplyr))
#Using the pipeline operator
#And the summarise_each() function to compute the mean for all the columns
#Finally, save the data
mergedDF %>% group_by(IDsubject,Activity) %>% summarise_each(funs(mean)) %>% write.table("merged/SummarizedTable.txt",row.name=FALSE ) 
