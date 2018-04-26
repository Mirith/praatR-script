# goals: 
# measure F1, F2, F3 11 (?) times equidistant
# Mean F1, F2, F3, amplitude, F0
# length
# 1st quartile amplitude, F0
# 3rd quartile amplitude, F0
# median amplitude, F0
# peak F0 and amplitude
# get label of adjacent segments

# special symbols in file names break script... fix?

rm(list = ls())
setwd("C:/Users/Lauren Shin/Desktop")
library(PraatR)

# what you want the file name to be
# it will write to the working directory
output_file = "vowels.csv"

# labels of intervals to examine
vowels = c("a", "e", "i", "o", "u", # monophthongs
           "ua", "ao", "au", "ai", "ae", "ei", "ea", # observed diphthongs
           "ia", "oa", "oe", "ui", "iu", "ie", "ia",
           "eo", "eu", "io", "oe", "ou", "ue", "uo") # unobserved diphthongs

# list(time step, pitch floor, pitch ceiling)
# generally, use 
# list(0, 75, 300) 
# for male speakers, and 
# list(0, 100, 600) 
# for female speakers
pitch_range = list(0, 75, 300)

# folder where text grids are
grid_path = "C:/praatR/data/grids/" 
# folder where wav files are
wav_path = "C:/praatR/data/wavs/"
# temporary file locations for formants, intensities, and pitches
# create the temp folder yourself, or change the directory to somewhere that isn't the grid or wav path
formant_path = "C:/praatR/data/temp/formant.Matrix"
intensity_path = "C:/praatR/data/temp/intensity.Matrix"
pitch_path = "C:/praatR/data/temp/pitch.Matrix"

# create list of all files in directory
grid_list = tolower(list.files(grid_path))
wav_list = tolower(list.files(wav_path))

############ useful functions ##################################################

# when passed a path of a text grid
# returns label, start and stop time, as well as adjacent labels of each interval
# in a list of vectors
# each entry in the list is a vector containing 
# label, start time, end time, before label, after label -- in that order
# only if the interval had a label that matched the contents of the vowel list
get_start_end <- function(grid_loc)
{
    # stores the total number of intervals in the text grid
    interval_numbers = as.numeric(
        praat("Get number of intervals...", # praat command
              list(1), # 1 = the number of the tier to look at
              input = grid_loc, # path of text grid
              simplify = TRUE)) # return only number (still a string)
    
    # empty, to be filled and returned later
    return_list <- vector("list")
    
    # cycles through each interval in the text grid
    # starting with the second, as the first should be #
    for (interval in c(2:interval_numbers))
    {
        # gets the label of the interval
        interval_label = praat("Get label of interval...", # praat command
                               list(1, interval), # tier and interval to look at
                               input = grid_loc)
        
        # if it's a vowel -- get adjacent interval labels
        # if not, go to next interval
        if(interval_label %in% vowels)
        {
            # gets the preceding adjacent label
            before_label = praat("Get label of interval...", # praat command
                                   list(1, interval - 1), # tier and interval to look at
                                   input = grid_loc)
            
            # gets the following adjacent label
            after_label = praat("Get label of interval...", # praat command
                                   list(1, interval + 1), # tier and interval to look at
                                   input = grid_loc)
            
            # finds the start point
            # similar to how Get label of interval... works
            interval_start = as.numeric(praat("Get start point...", 
                                              list(1, interval), 
                                              input = grid_loc, 
                                              simplify = TRUE))
            # and the end point
            # similar to how Get label of interval... works
            interval_end = as.numeric(praat("Get end point...", 
                                            list(1, interval), 
                                            input = grid_loc, 
                                            simplify = TRUE))
            
            # increments position of where to add the list of label/points
            index = length(return_list) + 1
            
            # temporary vector to add to list
            to_add_temp = c(interval_start, interval_end, 
                            before_label, interval_label, after_label)
            # names(to_add_temp) = c("label", "start", "end", "before", "after")
            
            # adds the temporary vector to return_list at correct index
            return_list[[index]] = to_add_temp
        }
    }
    return (return_list)
}

# extracts means of f1 through f4
# formant_loc is the full path of the formant file, ie formant_path
# fmean_interval is the start and end point of the interval 
# (usually [2] and [3] from get_start_end)
# returns a vector of numbers
formant_means <- function(fmean_interval, formant_loc)
{
    # list to return later
    means = c()
    # formants to look at
    # can be changed if desired
    formants_nums = c(1,2,3,4)
    # empty, to return later
    fmeans = c()

    # cycles through each interval in the intervals list
    for (formant_number in formants_nums)
    {        
        # gets start point, which should second entry in list
        start = fmean_interval[1]
        # gets end point, should be third entry in list
        end = fmean_interval[2]
        
        mean = as.numeric(praat("Get mean...", 
                      list(formant_number, # number of formant to look at
                           start, # start point in time of formant
                           end, # end point in time of formant
                           "Hertz"), # measurement type
                      input = formant_loc,
                      simplify = TRUE))
        
        fmeans = append(fmeans, mean)
        
    }
    
    # can name the outputs, not necessary though
    # names(fmeans) = c("F1", "F2", "F3", "F4")
    
    return (fmeans)
}

# quartile and median calculation for amplitude
# amp_interval is a list of the start and end point of the interval to examine
# intensity_loc is the full path of the intensity file, ie intensity_path
quart_med_amp <- function(amp_interval, intensity_loc)
{
    # divide up desired length by 9 pieces
        # can divide into however many pieces desired (probably 9 +)
    # use interval_split() to create 9 points to sample
    # and put in list for loop to iterate through
    point_list = interval_split(amp_interval, 9)

    # empty, to be filled with loop
    data_points = c()
    
    # loop to fill data_list
    for (point in point_list)
    {
        data_points = append(data_points, 
                             as.numeric(praat("Get value at time...",
                                   input = intensity_loc,
                                   list(point,
                                        "Cubic"),
                                   simplify = TRUE)))
    }
    
    # sort by value
    sort(data_points)
    # find median for list
    median = median(data_points, na.rm = TRUE)
    # find quartile for list
    # returns 4 values -- 2nd and 4th entries are 1st and 3rd quartile respectively
    quantiles = quantile(data_points, na.rm = TRUE)
    
    # adds to list, and labels entries
    return_vals = c(median, quantiles[2], quantiles[4])
    
    # names(return_vals) = c("amp median", "amp 1st", "amp 3rd")
    
    return (return_vals)
    
}

# quartile and median calculation for f0
# f0_interval is a list of the start and end point of the interval to examine
# f0_loc is the full path of the pitch file, ie pitch_path
quart_med_F0 <- function(f0_interval, f0_loc)
{
    # accounting for Praat's sampling of f0 (75 pitch floor Hz = 40 ms sample)
    # see http://www.fon.hum.uva.nl/praat/manual/Sound__To_Pitch___.html Pitch floor section
    new_interval = c(f0_interval[1] + .04, f0_interval[2])
    
    # divide up desired length by 9 pieces
    point_list = interval_split(new_interval, 9)
    
    # empty, to be filled with loop
    data_points = c()
    
    # loop to fill data_list
    for (point in point_list)
    {
        new_num = as.numeric(praat("Get value at time...",
                               input = f0_loc,
                               list(point,
                                    "Hertz",
                                    "Linear"),
                               simplify = TRUE))
        
        data_points = append(data_points, new_num)
    }
    
    # sort by value
    sort(data_points)
    # find median for list
    median = median(data_points, na.rm = TRUE)
    # find quartile for list
    # returns 4 numbers -- 2nd and 4th entries are 1st and 3rd quartile respectively
    quantiles = quantile(data_points, na.rm = TRUE)
    
    # adds to list
    return_vals = c(median, quantiles[2], quantiles[4])
    
    # names(return_vals) = c("f0 median", "f0 1st", "f0 3rd")
    
    return (return_vals)
}

# returns max F0 value of interval passed 
# f0_interval is a list of the start and end point of the interval to examine
# f0_loc is the full path of the pitch file, ie pitch_path
max_F0 <- function(f0_interval, f0_loc)
{
    start = f0_interval[1]
    end = f0_interval[2]
    
    # calculates max f0 
    val = as.numeric(praat("Get maximum...",
                     list(start, end, "Hertz", "Parabolic"),
                     input = f0_loc,
                     simplify = TRUE))
    return (val)
}

# returns max intensity of interval passed
# amp_interval is a list of the start and end point of the interval to examine
# intensity_loc is the full path of the intensity file, ie intensity_path
max_amp <- function(amp_interval, intensity_loc)
{
    start = amp_interval[1]
    end = amp_interval[2]
    
    # calculates max intensity
    val = as.numeric(praat("Get maximum...",
                           list(start, end, "Parabolic"),
                           input = intensity_loc,
                           simplify = TRUE))
    return (val)
}

# returns mean f0 of interval passed
# f0_times is a list of the start and end point of the interval to examine
# f0_loc is the full path of the pitch file, ie pitch_path
mean_F0 <- function(f0_interval, f0_loc)
{
    start = f0_interval[1]
    end = f0_interval[2]
    
    # calculates mean of f0
    mean = as.numeric(praat("Get mean...", 
                            list(start, end, "Hertz"), 
                            input = f0_loc, 
                            simplify = TRUE))
    return (mean)
}

# returns mean intensity of interval passed
# amp_times is a list of the start and end point of the interval to examine
# intensity_loc is the full path of the intensity file, ie intensity_path
mean_amp <- function(amp_interval, amp_loc)
{
    start = amp_interval[1]
    end = amp_interval[2]
    
    # calculates mean amplitude/intensity
    mean = as.numeric(praat("Get mean...", 
                            list(start, end, "energy"), 
                            input = amp_loc, 
                            simplify = TRUE))
    return (mean)
}

# returns a list of samples of f1 through f3
# f_interval is a list of the start and end point of the interval to look at
# num_samples is the number of samples to take for the formants
# formant_loc is the full path of the formant file, ie formant_path
f_sample <- function(f_interval, num_samples, formant_loc)
{
    # splits interval into desired number of sample points
    split = interval_split(c(f_interval[1], f_interval[2]), num_samples)
    
    f1 = c()
    f2 = c()
    f3 = c()
    
    for (point in split)
    {
        # record the f1 value at point
        f1_val = as.numeric(praat("Get value at time...", 
                                 list(1, point, "Hertz", "Linear"),
                                 input = formant_loc,
                                 simplify = TRUE))
        
        # record the f2 value at point
        f2_val = as.numeric(praat("Get value at time...", 
                                  list(2, point, "Hertz", "Linear"),
                                  input = formant_loc,
                                  simplify = TRUE))
        
        # record the f3 value at point
        f3_val = as.numeric(praat("Get value at time...", 
                                  list(3, point, "Hertz", "Linear"),
                                  input = formant_loc,
                                  simplify = TRUE))
        
        f1 = append(f1, f1_val)
        f2 = append(f2, f2_val)
        f3 = append(f3, f3_val)
    }
    
    return (c(f1, f2, f3))
}

# returns a list of points in interval passed, split into number_splits points
# ex:
# > interval_split(c(2, 3), 4)
# > c(2, 2.33, 2.66, 3)
# interval is the interval to be split, ie a list of two points in time
interval_split <- function(interval, number_splits)
{
    # 0 splits = same interval as passed... 
    if (number_splits == 0)
    {
        return (interval)
    }
    
    # first and last point returned should be passed points
    # check that second point passed is bigger than the first, ie no negative time
    if (interval[1] < interval[2])
    {
        # empty, filled by loop 
        return_vals = c(interval[1])
        
        # finds value to increment by 
        # total time divided by number of splits wanted minus one, 
        # to get last value in array
        increment = (interval[2] - interval[1])/(number_splits - 1)
        
        # first time to add to loop
        time = interval[1] + increment
        for (point in c(1: (number_splits - 1)))
        {
            return_vals = append(return_vals, time)
            time = time + increment
        }
        
        return (return_vals)
    }
    
}

#################################################################
# pulling everything together

# vectors to add to in nested loop, to add to dataframe as columns later
word = c()
label = c()
beforeLabel = c()
afterLabel = c()
meanF1 = c()
meanF2 = c()
meanF3 = c()
meanF4 = c()
F1.1 = c()
F1.2 = c()
F1.3 = c()
F1.4 = c()
F1.5 = c()
F1.6 = c()
F1.7 = c()
F1.8 = c()
F1.9 = c()
F1.10 = c()
F1.11 = c()
F2.1 = c()
F2.2 = c()
F2.3 = c()
F2.4 = c()
F2.5 = c()
F2.6 = c()
F2.7 = c()
F2.8 = c()
F2.9 = c()
F2.10 = c()
F2.11 = c()
F3.1 = c()
F3.2 = c()
F3.3 = c()
F3.4 = c()
F3.5 = c()
F3.6 = c()
F3.7 = c()
F3.8 = c()
F3.9 = c()
F3.10 = c()
F3.11 = c()
medianAmplitude = c()
firstQuartileAmplitude = c()
thirdQuartileAmplitude = c()
medianF0 = c()
firstQuartileF0 = c()
thirdQuartileF0 = c()
length = c()
maxF0 = c()
maxAmplitude = c()
meanF0 = c()
meanAmplitude = c()

# prints start time of analysis
print(Sys.time())

# iterate through each text grid in directory
# can subset grid_list for testing changes, ie grid_list[1:5]
for (file in grid_list)
{
    # gets file name minus .TextGrid
    fileName = sub('\\.textgrid$', '', file)
    
    if (paste(fileName, ".wav", sep = "") %in% wav_list)
    {
        # prints file name just to check progress, can comment or delete
        print(fileName)
        
        # create full path for text grid file
        # ie "C:/praatR/Bitur/grids/ + awaga-DM-3.TextGrid"
        temp_grid = paste(grid_path, file, sep = "")
        
        # create full path for wav file
        # ex "C:/praatR/Bitur/audio/ + awaga-DM-3.TextGrid - .TextGrid + wav
        temp_wav = paste(wav_path, 
                         fileName, 
                         ".wav", 
                         sep = "")
        
        # getting start/end times of intervals in the file
        intervals = get_start_end(temp_grid)
        
        # create temporary formant object
        formant_obj = praat("To Formant (keep all)...", 
                            list(0, # time step
                                 5, # max num formants
                                 5500, # max formant hz
                                 0.025, # window length
                                 50), # pre-emphasis hz
                            input = temp_wav,
                            overwrite = TRUE,
                            output = formant_path)
        
        # create temporary intensity object
        intensity = praat("To Intensity...", 
                          list(100, # minumum pitch
                               0, # time step (0 auto)
                               "yes"), # subtract mean
                          input = temp_wav,
                          overwrite = TRUE,
                          output = intensity_path)
        
        # create temporary pitch object
        pitch_obj = praat("To Pitch...", 
                          pitch_range,
                          input = temp_wav,
                          overwrite = TRUE,
                          output = pitch_path)
        
        # cycle through each valid (ie labeled with vowel(s)) interval in file
        for (interval in intervals)
        {
            # append word name to proper vector
            word = append(word, fileName)
            
            # create proper interval to pass to other functions
            start = as.numeric(interval[1])
            end = as.numeric(interval[2])
            interval_list = c(start, end)
            
            # append interval labels to proper vector
            label = append(label, interval[4])
            beforeLabel = append(beforeLabel, interval[3])
            afterLabel = append(afterLabel, interval[5])
            
            # append length to proper vector
            lengthInt = end - start
            length = append(length, lengthInt)
    
            # calculate and append f1 through f4 means to proper vectors
            f_means = formant_means(interval_list, formant_path)
            meanF1 = append(meanF1, f_means[1])
            meanF2 = append(meanF2, f_means[2])
            meanF3 = append(meanF3, f_means[3])
            meanF4 = append(meanF4, f_means[4])
    
            # calculate and append f1 through f3 sampled points to proper vectors
            f_pts = f_sample(interval_list, 11, formant_path)
            F1.1 = append(F1.1, f_pts[1])
            F1.2 = append(F1.2, f_pts[2])
            F1.3 = append(F1.3, f_pts[3])
            F1.4 = append(F1.4, f_pts[4])
            F1.5 = append(F1.5, f_pts[5])
            F1.6 = append(F1.6, f_pts[6])
            F1.7 = append(F1.7, f_pts[7])
            F1.8 = append(F1.8, f_pts[8])
            F1.9 = append(F1.9, f_pts[9])
            F1.10 = append(F1.10, f_pts[10])
            F1.11 = append(F1.11, f_pts[11])
            F2.1 = append(F2.1, f_pts[12])
            F2.2 = append(F2.2, f_pts[13])
            F2.3 = append(F2.3, f_pts[14])
            F2.4 = append(F2.4, f_pts[15])
            F2.5 = append(F2.5, f_pts[16])
            F2.6 = append(F2.6, f_pts[17])
            F2.7 = append(F2.7, f_pts[18])
            F2.8 = append(F2.8, f_pts[19])
            F2.9 = append(F2.9, f_pts[20])
            F2.10 = append(F2.10, f_pts[21])
            F2.11 = append(F2.11, f_pts[22])
            F3.1 = append(F3.1, f_pts[23])
            F3.2 = append(F3.2, f_pts[24])
            F3.3 = append(F3.3, f_pts[25])
            F3.4 = append(F3.4, f_pts[26])
            F3.5 = append(F3.5, f_pts[27])
            F3.6 = append(F3.6, f_pts[28])
            F3.7 = append(F3.7, f_pts[29])
            F3.8 = append(F3.8, f_pts[30])
            F3.9 = append(F3.9, f_pts[31])
            F3.10 = append(F3.10, f_pts[32])
            F3.11 = append(F3.11, f_pts[33])
    
            # calculate and append median, and quartiles of amplitude to proper vector
            qma_amp = quart_med_amp(interval_list, intensity_path)
            medianAmplitude = append(medianAmplitude, qma_amp[1])
            firstQuartileAmplitude = append(firstQuartileAmplitude, qma_amp[2])
            thirdQuartileAmplitude = append(thirdQuartileAmplitude, qma_amp[3])
    
            # calculate and append median, and quartiles of f0 to proper vector
            qma_f0 = quart_med_F0(interval_list, pitch_path)
            medianF0 = append(medianF0, qma_f0[1])
            firstQuartileF0 = append(firstQuartileF0, qma_f0[2])
            thirdQuartileF0 = append(thirdQuartileF0, qma_f0[3])
    
            # calculate and append max f0 to proper vector
            f0_max = max_F0(interval_list, pitch_path)
            maxF0 = append(maxF0, f0_max)
    
            # calculate and append max amplitude to proper vector
            amp_max = max_amp(interval_list, intensity_path)
            maxAmplitude = append(maxAmplitude, amp_max)
    
            # calculate and append mean f0 to proper vector
            f0_mean = mean_F0(interval_list, pitch_path)
            meanF0 = append(meanF0, f0_mean)
    
            # calculate and append mean amplitude to proper vector
            amp_mean = mean_amp(interval_list, intensity_path)
            meanAmplitude = append(meanAmplitude, amp_mean)
        }
    }
    else
    {
        # should only print if textgrid is missing wav file counterpart
        # if wav files are missing textgrid counterparts, no message will print...
        print(paste("corresponding wav file not found:", fileName))
    }
}

# dataframe -- each column is a vector created in previous loop
data = data.frame(word, label, beforeLabel, afterLabel, length,
                  meanF1, meanF2, meanF3, meanF4,
                  medianAmplitude, firstQuartileAmplitude, thirdQuartileAmplitude, 
                  medianF0, firstQuartileF0, thirdQuartileF0, 
                  maxF0, maxAmplitude, 
                  meanF0, meanAmplitude, 
                  F1.1, F1.2, F1.3, F1.4, F1.5, F1.6, F1.7, F1.8, F1.9, F1.10, F1.11, 
                  F2.1, F2.2, F2.3, F2.4, F2.5, F2.6, F2.7, F2.8, F2.9, F2.10, F2.11, 
                  F3.1, F3.2, F3.3, F3.4, F3.5, F3.6, F3.7, F3.8, F3.9, F3.10, F3.11) 

# writes to working directory -- can change it to whatever you want
write.table(data, sep = ",", row.names = FALSE, file = output_file)
