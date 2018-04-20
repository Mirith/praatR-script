

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
* TextGrids should have only one interval tier, with each interval/phoneme annotated.  Word boundaries should be labeled with "#".  No interval should be left blank.  
* You should also have at least one more folder to put the temporary files the script makes, as well as the final .csv it outputs.  You can have these be the same, or they can be separate from each other.  Again, try to avoid spaces in directory names.  For the output file, you can have spaces in directory names, but not for temporary files.  
* Run only one speaker's data at a time, and adjust **pitch_range** accordingly based on gender.  

## Organization

The first part of the script deals with setting up everything.  Loading PraatR, setting proper directories, etc.  

The second part of the script is all of the functions.  

The third part is where the actual analysis happens.  The script will iterate through a list of TextGrids, search for a corresponding .wav file, and then write a Formant, Intensity, and Pitch object if it is successful in finding the .wav file.  And then it will iterate through each interval in the TextGrid.  For each labeled interval in the TextGrid that is a monophthong or diphthong, it will run each function on the formant, and add the collected data to one of many lists.  After iterating through each TextGrid, it will put all the lists into a dataframe, and write the dataframe to a .csv file.  

# Details



You can probably just run the script based on the information above, but this section will contain more details.  



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