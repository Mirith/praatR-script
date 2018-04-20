

# Introduction

This document is a guide to using the PraatR script at https://github.com/Mirith/praatR-script.  



There will be a brief overview of the script's goals, how it works, and how to use it.  After that, there will be more extensive explanation of the functions/methods.  



Some of this might be self-explanatory, but hopefully the rest is helpful!  

# Overview

As stated in the readme, you'll generally need PraatR, Praat, R, and some sort of code editor.  



To run the script, open it in an editor like R Studio and run it as you would a normal script.  



You will need to have a few additional requirements satisfied:

* All TextGrids and their corresponding .wav files must have the same name.  word-1.TextGrid and word1.wav will not count as a pair of files that the script will pair together.  
* TextGrids should have their own folder, and .wav files should have their own, separate folder as well.  Nothing else should be in those folders other than the correct files.  **TextGrid and .wav file directories must not have any space in them.  PraatR does not like this, and the script will not run**.  
* TextGrids should have only one interval tier, with each interval/phoneme annotated.  Word boundaries should be labeled with "#".  No interval should be left blank.  The script will not check for this being the case, and formatting TextGrids in a way other than this might be very bad for the script.  
* You should also have at least one more folder to put the temporary files the script makes, as well as the final .csv it outputs.  You can have these be the same, or they can be separate from each other.  Again, try to avoid spaces in directory names.  For the output file, you can have spaces in directory names, but not for temporary files.  
* Run only one speaker's data at a time, and adjust **pitch_range** accordingly based on gender.  

## Organization

The first part of the script deals with setting up everything.  Loading PraatR, setting proper directories, etc.  

The second part of the script is all of the functions.  

The third part is where the actual analysis happens.  The script will iterate through a list of TextGrids, search for a corresponding .wav file, and then write a Formant, Intensity, and Pitch object if it is successful in finding the .wav file.  And then it will iterate through each interval in the TextGrid.  For each labeled interval in the TextGrid that is a monophthong or diphthong, it will run each function on the formant, and add the collected data to one of many lists.  After iterating through each TextGrid, it will put all the lists into a dataframe, and write the dataframe to a .csv file.  

Third part psuedo-code:

```
for loop -- iterates through each TextGrid

	conditional if -- runs if TextGrid has matching .wav
		Creates the temporary files here.  ie just once per valid TextGrid/.wav pairing.  

		for loop -- iterates through the TextGrid's intervals
			Runs functions if interval has a monophthong or diphthong.  
			Also adds collected data to vectors defined outside the loop for the dataframe. 

	conditional else -- runs if TextGrid does not have matching .wav
```

# Details



You can probably just run the script based on the information above, but this section will contain more details.  

Formant values are in Hertz, amplitude/intensity values are in decibels.  Time is in seconds.  



```
rm(list = ls())
```
This line clears the memory of RStudio and ensures you start with a clean slate.  



```
setwd("C:/Users/Lauren Shin/Desktop")
```

This one sets your working directory.  Set this to where you want the csv with collected data to be written to.  Again, it can be the folder as where you put the temporary files.  But if that is the case, *you cannot have spaces in the directory name*.  



```
vowels = c("a", "e", "i", "o", "u", 
           "ua", "ao", "au", "ai", "ae", "ei", "ea", 
           "ia", "oa", "oe", "ui", "iu", "ie", "ia",
           "eo", "eu", "io", "oe", "ou", "ue", "uo") 
```

**vowels** is a vector of strings that the script will look for.  This script was designed to look at vowels (ie measure lots of things about vowel formants) so monophthongs and diphthongs are included here.  



```
pitch_range = list(0, 75, 300)
```

**pitch_range** can be adjusted based on if you have a female or male speaker.  You will need to set the second and third values to appropriate pitch floor and pitch ceilings based on gender.  list(0, 100, 600)  for female speakers and list(0, 75, 300)  for male speakers should be generally correct.  



```
# folder where text grids are
grid_path = "C:/praatR/data/grids/" 
# folder where wav files are
wav_path = "C:/praatR/data/audio/"
# temporary file locations for formants, intensities, and pitches
# create the temp folder yourself, or change the directory to somewhere that isn't the grid or wav path
formant_path = "C:/praatR/data/temp/formant.Matrix"
intensity_path = "C:/praatR/data/temp/intensity.Matrix"
pitch_path = "C:/praatR/data/temp/pitch.Matrix"
```

* **grid_path** is the folder where all the TextGrids are located.  Not the exact location of a file.  
* **wav_path** is the folder where all the .wav files are located.  Not the exact location of a file.  
* **formant_path, intensity_path, and pitch_path** are exact locations of temporary files.  Each of these files will be written and overwritten for each TextGrid/.wav file pair.  Create the /temp/ folder (or whatever you want to call it) before running the script.  You don't need to make the files though.  

All of these should have zero spaces in their names.  Other than that, you can generally set them to whatever makes sense for you.  



```
grid_list = list.files(grid_path)
wav_list = list.files(wav_path)
```

**grid_list** and **wav_list** are simply lists of file names in the given directories.  **grid_list** would contain things like 

>  [1] "word-SPEAKER-1.TextGrid"   
>
>  [2] "word-SPEAKER-2.TextGrid"   
>
>  [3] "word-SPEAKER-3.TextGrid"  ... 

while **wav_list** would be more like

>  [1] "word-SPEAKER-1.wav"   
>
>  [2] "word-SPEAKER-2.wav"    
>
> [3] "word-SPEAKER-3.wav"  ... 

The script will iterate through **grid_list** and find corresponding .wav files, and will analyze appropriate intervals from the TextGrid (ie intervals labeled with monophthongs or diphthongs).  If it cannot find a corresponding .wav file, it will print the missing file name.  

# Functions

For the purposes of this section and its subsections, files will be assumed to formatted/named/otherwise created/located in a way that the script can handle.  For example, TextGrid files will be assumed to have one interval tier, each phoneme has its own interval, counterpart .wav with same name, etc.  

Functions are listed in order of appearance in the script.  

## get_start_end

**Goal**: Extract the label, adjacent labels, and start/stop point of an interval, if it is labeled as a monopthong/diphthong.  

**Input**: 

* grid_loc -- a string that is the exact location of a TextGrid file.  

**Output**: 

* list of vectors -- each entry in the list is a vector with information about an interval.  The vector's order will be the interval's label, start point in seconds, end point in seconds, the interval label before, and the interval label after.  

**Example**: 

input: grid_loc = "C:/praatR/data/grids/grid-1.TextGrid".

output:

> [[1]]
> [1] "0.0903832788399135" "0.246765062360239"  "#"                  "a"                 "g"                 
>
> [[2]]
> [1] "0.362080040769082" "0.670328341444875" "g"                 "ia"               "b"                
>
> [[3]]
> [1] "0.794446468268737" "1.00282355311894"  "b"                 "a"                "#"      

**Other notes**: 

Output list/vectors will be all strings.  You should (and the script does) use as.numeric(str) to convert to floats before trying computation with the values.  

## formant_means

**Goal**: Extract the mean formant values for formant 1 through formant 4.  

**Input**:  

* fmean_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
* formant_loc -- a string that is the exact location of the temporary Formant matrix file.  

**Output**: 

A vector of four numbers, where the first is the first formant's mean, the second is the second formant's mean, etc.  

**Example**:

input: fmean_interval = c(0.09038328, 0.24676506).  formant_loc = "C:/praatR/data/temp/formant.Matrix".

output:  

> [1]  587.8651 1247.1852 2433.4685 3552.9289

**Other notes**:

na

## quart_med_amp

**Goal**:  Extract the first and third quartiles as well as the median amplitude of an interval.  

**Input**:  

* amp_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
* intensity_loc -- a string that is the exact location of the temporary Intensity matrix file.  

**Output**: 

A vector of three numbers, where the first is the median, the second is the first quartile, and the third number is the third quartile.  

**Example**:

input: amp_interval = c(0.09038328, 0.24676506).  intensity_loc = "C:/praatR/data/temp/intensity.Matrix".

output:

> 72.12203 67.52266 73.56588 

**Other notes**:  

The name is quartile-median-amplitude, but shortened.  

This function uses *interval_split*.  

## quart_med_F0

**Goals**: Extract the first and third quartiles as well as the median F0 of an interval.  

**Input**:  

* f0_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
* f0_loc -- a string that is the exact location of the temporary Pitch matrix file.  

**Output**: 

A vector of three numbers, where the first is the median, the second is the first quartile, and the third number is the third quartile.  

**Example**:

input: f0_interval = c(0.09038328, 0.24676506).  f0_loc = "C:/praatR/data/temp/pitch.Matrix".

output:

> 114.2202 106.0552 121.2981 

**Other notes**:

The name is quartile-median-F0, but shortened.  

see http://www.fon.hum.uva.nl/praat/manual/Sound__To_Pitch___.html Pitch floor section for why a little is trimmed off the start of the interval.  

This function uses *interval_split*.  

## max_F0

**Goal**: Return the maximum value of F0 in an interval.  

**Input**:  

- f0_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
- f0_loc -- a string that is the exact location of the temporary Pitch matrix file.  

**Output**: 

A single number, ie the max F0.  

**Example**:

input: f0_interval = c(0.09038328, 0.24676506).  f0_loc = "C:/praatR/data/temp/pitch.Matrix".

output:

> [1] 122.8931

**Other notes**:

na

## max_amp

**Goal:** Return the maximum intensity/amplitude value in an interval.  

**Input**:  

* amp_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
* intensity_loc -- a string that is the exact location of the temporary Intensity matrix file.  

**Output**: 

A single number, ie the max intensity/amplitude.  

**Example**:

input: amp_interval = c(0.09038328, 0.24676506).  intensity_loc = "C:/praatR/data/temp/intensity.Matrix".

output:

> [1] 75.4263

**Other notes**:

na

## mean_F0

**Goal**: Return the mean F0 in an interval.  

**Input**: 

- f0_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
- f0_loc -- a string that is the exact location of the temporary Pitch matrix file.  

**Output**: 

A single number, ie the mean F0.  

**Example**:

input: f0_interval = c(0.09038328, 0.24676506).  f0_loc = "C:/praatR/data/temp/pitch.Matrix".

output:

> [1] 108.7787

**Other notes**:

na

## mean_amp

**Goal**: Return the mean amplitude/intensity in an interval.  

**Input**: 

- amp_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
- intensity_loc -- a string that is the exact location of the temporary Intensity matrix file.  

**Output**: 

A single number, ie the mean amplitude/intensity.  

**Example**:

input: input: amp_interval = c(0.09038328, 0.24676506).  intensity_loc = "C:/praatR/data/temp/intensity.Matrix".

output: 

> [1] 72.11806

**Other notes**:

na

## f_sample

**Goal**: Sample values of formant at a given number of points, equidistant.  

**Input**:  

- f_interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
- num_samples -- an integer.  The number of samples to take, including the start and end point.  
- formant_loc -- a string that is the exact location of the temporary Pitch matrix file.  

**Output**: 

A single vector of numbers, with the first num_samples being formant 1, the next num_samples being formant 2, etc.  

**Example**:

input:  f_interval = c(0.09038328, 0.24676506).  num_samples = 11.  formant_loc = "C:/praatR/data/temp/pitch.Matrix".

output:

> [1]  213.0689  711.7080  719.5858  716.2928  673.9052  617.7351  616.9560  529.0025
>  [9]  486.4271  400.1265  331.8080 1012.3781 1176.4715 1130.9220 1166.7390 1116.4193
> [17] 1182.3153 1251.3856 1306.1394 1402.2992 1469.7118 1452.6406 1822.6732 2625.3517
> [25] 2611.4441 2642.8433 2612.3647 2471.1719 2277.2214 2346.0526 2329.1155 2129.3832
> [33] 1927.0067

**Other notes**:

This function uses *interval_split*

Will rework this a little, as it is *very* messy and silly in regards to the return value.  Or will call once per formant, and four times per script loop to neaten it up.  Returning a list of vectors as I did in other functions messed up adding things to the dataframe, for some reason.  

## interval_split

**Goal**: Given the start and end point of an interval, return a list with equidistant points, endpoints included.  

**Input**:

* interval -- vector with two values.  The first is the interval's start point, and the second is the interval's end point.  
* number_splits -- an integer.  The number of times to split the interval, endpoints included.  

**Output**: 

A vector of **number_splits** equidistant points.  

**Example**:

input: interval = c(0.09038328, 0.24676506).  number_splits = 9.  

output: 

> [1] 0.09038328 0.10993100 0.12947872 0.14902645 0.16857417 0.18812189 0.20766962 0.22721734
> [9] 0.24676506

**Other notes**:

na