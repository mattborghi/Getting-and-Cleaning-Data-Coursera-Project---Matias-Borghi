# Getting and Cleaning Data Course Project

### CodeBook

The link for the data is found in the file **README.md**.
The file **run_analysis.R** does the following (as described in the source code):

1.	Merges the training and the test sets to create one data set.
	* Creates a new folder to save the new merged files if there is no one created
		
		```R
		if(!file.exists("./merged")){dir.create("./merged")}
		```

	* cbind() separately the test and training data sets
	

	**Test data set**
	Load the three files and check dimentions
	
	```R
	testSubject = read.table("test/subject_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
	dim(testSubject)
	#[1] 2947 1
	testFeatures = read.table("test/X_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
	dim(testFeatures)
	#[1] 2947 561
	testActivity = read.table("test/y_test.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
	dim(testActivity)
	#[1] 2947 1
	```

	Cbind the 563 columns in the order testSubject - testActivity - testFeatures
		
	```R
	testTable = cbind(testSubject,testActivity,testFeatures)
	#Check that have the desired dimentions
	dim(testTable)
	#[1] 2947 563 
	```

	Do the same for the train data set. 
	
	* Now rbind() the set and train data sets

		```R 
		mergedDS = rbind(testTable,trainTable)
		dim(mergedDS)
		#[1] 10299 563 
		```

2. Uses descriptive activity names to name the activities in the data set

3. Appropriately labels the data set with descriptive variable names.

	* We begin extracting the names for the 561 vector from the "features.txt" file
		
		```R
		features = read.table("features.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
		```

		We are interested in the second column
		
		```R
		names(mergedDS)[3: (length(testFeatures)+2) ]  = features[,2]
		```

	* Name the first two columns
		
		```R
		names(mergedDS)[1] = "IDsubject"
		names(mergedDS)[2] = "Activity"
		```

	* Now we are going to change the [1-6] values in the last column to a more descriptive form like the ones in the file **activity_labels.txt**
		
		```R
		activityLabels = read.table("activity_labels.txt",header=FALSE,sep="",stringsAsFactors=FALSE)
		mergedDS[,names(mergedDS)[2]] = sapply(mergedDS[,names(mergedDS)[2]],function(x) mergedDS[x,names(mergedDS)[2]] = activityLabels[x,2])
		```

4. Extract only the measurements on the mean and standard deviation for each measurement.
	
	```R
	meanNames <- grep("mean()",names(mergedDS),value=TRUE)
	stdNames <- grep("std()",names(mergedDS),value=TRUE)
	#Remember to add the first two columns
	extractNames <- c(names(mergedDS[1]),names(mergedDS[2]),meanNames,stdNames)
	filterDS <- mergedDS[,extractNames]
	```

	* Save the data frame
	
		```R
		write.table(filterDS,"merged/filteredTable.txt",row.name=FALSE )
		```

5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	
	Remove unwanted characters in the column names:
		
	```R
	#- The space
	names(filterDS) <- gsub(" ","",names(filterDS))
	#- The "-"
	names(filterDS) <- gsub("-","",names(filterDS))
	#- The "()"
	names(filterDS) <- gsub("\\(\\)","",names(filterDS))
	```
		
	Use a data frame to use the dplyr library
		
	```R
	mergedDF = as.data.frame.matrix(filterDS) 
	suppressPackageStartupMessages(library(dplyr))
	```

	* Using the pipeline operator and the *summarise_each()* function to compute the mean for all the columns. Finally, save the data.
		
		```R
		mergedDF %>% group_by(IDsubject,Activity) %>% summarise_each(funs(mean)) %>% write.table("merged/SummarizedTable.txt",row.name=FALSE ) 
		```



