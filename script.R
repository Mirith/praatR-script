# first script attempt
# goals: 
# measure F1, F2, F3 11 (?) times equidistant
# Mean F1, F2, F3, amplitude, F0
# length
# 1st quartile amplitude, F0
# 3rd quartile amplitude, F0
# median amplitude, F0
# peak F0 and amplitude

# deal with formatting outputs later, just get pieces in place
# eventually want to make a big dataframe for everything to work with

# looking in praat at buttons/menus gives explanation of each set of parameters

# to do -- vowels v consonants analysis?  
# consonants and pitch...

rm(list = ls())

library(PraatR)

# text grid and sound path should be automatically grabbed later
# following are hard-coded for testing purposes
# path for text grid file
path = "C:/praatR/Bitur/grids/abua-DM-1.TextGrid"
# path for sound file
sound_path = "C:/praatR/Bitur/audio/abua-DM-1.wav"
# path for outputs of converted files
# will be overwritten many times as script runs
inten_path = "C:/praatR/Bitur/audio/inten.Matrix"
pitch1_path = "C:/praatR/Bitur/audio/untitled.Pitch"

# when passed a path of a text grid
# returns start and stop times with interval label as a list within a list
get_start_end <- function(text_grid)
{
    # stores the total number of intervals in the text grid
    interval_numbers = as.numeric(
        praat("Get number of intervals...", # praat command
              list(1), # 1 = the number of the tier to look at
              input = text_grid, # path of text grid
              simplify = TRUE)) # return only number (still a string)
    # empty, to be filled and returned later
    return_list <- vector("list")
    
    # cycles through each interval in the text grid
    for (interval in c(1:interval_numbers))
    {
        # gets the label of the interval
        interval_label = praat("Get label of interval...", # praat command
                               list(1, interval), # tier and interval to look at
                               input = text_grid)
        # if it has a label
        if(interval_label != "")
        {
            # finds the start point
            # similar to how Get label of interval... works
            interval_start = as.numeric(praat("Get start point...", 
                                              list(1, interval), 
                                              input = text_grid, 
                                              simplify = TRUE))
            # and the end point
            # similar to how Get label of interval... works
            interval_end = as.numeric(praat("Get end point...", 
                                            list(1, interval), 
                                            input = text_grid, 
                                            simplify = TRUE))
            
            # adds the interval label and start/end points to the end of the list
            index = length(return_list) + 1
            
            to_add_temp = c(interval_start, interval_end)
            names(to_add_temp) = c(interval_label, interval_label)
            
            return_list[[index]] = to_add_temp
        }
    }
    return (return_list)
}

# extracts formant information given intervals and a formant object
# formant_loc is the full path of the formant file
# formants is a list of formants to take the mean of
# intervals is the output of get_start_end
# returns a list of lists
formant_means <- function(fmean_interval, formant_loc)
{
    # list to return later
    means = c()
    # formants to look at
    formants_nums = c(1,2,3,4)

    # cycles through each interval in the intervals list
    adding = c()
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
        
        adding = append(adding, mean)
        
    }
    
    # adding sensible names to the output
    names(adding) = c("F1", "F2", "F3", "F4")
    
    return (adding)
}

# formant_means(c(.0878, .21314), "C:/praatR/Bitur/temp/formant.Matrix")

# quartile and median calculation
# amplitude
# amp_interval is a list of the start and end point of the interval to examine
quart_med_amp <- function(amp_interval, intensity_loc)
{
    # divide up desired length by 9 pieces
    # use interval_split()
    # and put in list for loop
    point_list = interval_split(amp_interval, 9)

    # empty, to be filled with loop
    # holds the decibel intensities to be worked with later
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
    # find median for list
    # find quartile for list
    sort(data_points)
    median = median(data_points)
    # 2nd and 4th entries are 1st and 3rd quartile respectively
    quantiles = quantile(data_points)
    
    # adds to list, and labels entries
    return_vals = c(median, quantiles[2], quantiles[4])
    names(return_vals) = c("median", "1st", "3rd")
    
    return (return_vals)
    
}

# quart_med_amp(c(.0878, .21314), intensity_path)

# quartile and median calculation
# F0
# needs to loop for each interval in sound from get_start_end path
# quart_med_F0 <- function(sound_path)
# {
#     # change from intensity to f0 thing?
#     praat("To Pitch...", 
#           list(0, # time step 
#                0, # minumum hz considered 
#                600), # maximum hz considered
#           input = sound_path,
#           overwrite = TRUE,
#           output = pitch1_path)
#     
#     # divide up desired length by 9 pieces
#     # use interval_split()
#     # and put in list for loop
#     # where path = text grid
#     temp = get_start_end(path)
#     
#     # accesses the intervals from get_start_end
#     # change hard-coding later
#     temp_list = c(temp[[1]][1], temp[[1]][2])
#     
#     # pitch object does not calculate pitch in the first and last .02 seconds
#     # trying to calculate it will break it
#     # change all values that are bad to closest they can be?
#     
#     points = interval_split(temp_list, 9)
#     
#     point_list = c()
#     for (time in points)
#     {
#         end_time = as.numeric(praat("Get end time", 
#                                     input = sound_path, 
#                                     simplify = TRUE))
#         if (time < .02)
#         {
#             point_list = append(point_list, .02)
#         }
#         else if (time > end_time - .02)
#         {
#             point_list = append(point_list, end_time - .02)
#         }
#         
#         else
#         {
#             point_list = append(point_list, time)
#         }
# 
#     }
#     
#     # empty, to be filled with loop
#     data_points = c()
#     
#     # loop to fill data_list
#     for (point in point_list)
#     {
#         print(point)
#         temp_point = as.numeric(praat("Get value at time...",
#                                       input = inten_path,
#                                       list(point, "Hertz", "Linear"),
#                                       simplify = TRUE))
#         print(temp_point)
#         if (!is.na(temp_point))
#         {
#             data_points = append(data_points, temp_point)
#         }
#         else
#         {
#             data_points = append(data_points, 0)
#         }
#     }
# 
#     # sort by value
#     # find median for list
#     # find quartile for list
#     sort(data_points)
#     median = median(data_points)
#     # 2nd and 4th entries are 1st and 3rd quartile respectively
#     quantiles = quantile(data_points)
#     
#     # adds to list, and labels entries
#     return_vals = c(median, quantiles[2], quantiles[4])
#     names(return_vals) = c("median", "1st", "3rd")
#     
#     return (return_vals)
# }
# 
# quart_med_F0(sound_path)
# [1] 0.08784719
# [1] NA
# [1] 0.1035099
# [1] 103.4881
# [1] 0.1191725
# [1] 106.3803
# [1] 0.1348352
# [1] 106.5775
# [1] 0.1504979
# [1] 106.8138
# [1] 0.1661605
# [1] 108.4301
# [1] 0.1818232
# [1] 109.7767
# [1] 0.1974859
# [1] 109.2602
# [1] 0.2131485
# [1] 127.9983
# median      1st      3rd 
# 106.8138 106.3803 109.2602 
# Warning message:
#     In quart_med_F0(sound_path) : NAs introduced by coercion


# returns max F0 value of interval passed 
# f0_time is a list of the start and end point of the interval to look at
max_F0 <- function(f0_time, f0_path)
{
    start = f0_time[1]
    end = f0_time[2]
    
    val = as.numeric(praat("Get maximum...",
                     list(start, end, "Hertz", "Parabolic"),
                     input = f0_path,
                     simplify = TRUE))
    return (val)
}

# max_F0(c(.0878, .21314), pitch_path)

# max amplitude value finder of interval passed 
# amp_time is a list of the start and end point of the interval to look at 
max_amp <- function(amp_time, intensity_path)
{
    start = amp_time[1]
    end = amp_time[2]
    
    val = as.numeric(praat("Get maximum...",
                           list(start, end, "Parabolic"),
                           input = intensity_path,
                           simplify = TRUE))
    return (val)
}

# max_amp(c(.0878, .21314), inten_path)

# get_start_end(path)
# returns a list of points in time split into number_splits points
# ex:
# > interval_split(c(2, 3), 4)
# > c(2, 2.33, 2.66, 3)
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

grid_path = "C:/praatR/Bitur/grids/"
wav_path = "C:/praatR/Bitur/audio/"
formant_path = "C:/praatR/Bitur/temp/formant.Matrix"
intensity_path = "C:/praatR/Bitur/temp/intensity.Matrix"
pitch_path = "C:/praatR/Bitur/temp/pitch.Matrix"

# create list of all files in directory
grid_list = list.files(grid_path)
wav_list = list.files(wav_path)

data = data.frame()
    # eventual format of data frame will be columns containing 
    # interval name, length, f0 average (then f1-f4), intensity average, 
    # f0 peak, intensity peak, 1 and 3 quartile of F0 and intensity, 
    # and 11 equidistant measures of f1-4

# iterate through each text grid
for (file in grid_list[1:3])
{
    # create full path for text grid file
    # ie "C:/praatR/Bitur/grids/awaga-DM-3.TextGrid"
    temp_grid = paste(grid_path, file, sep = "")
    
    # full path for wav file
    # assuming corresponding wav file for textgrid...
    # to do -- figure out how to safeguard against missing/extraneous files?
    temp_wav = paste(wav_path, 
                     substr(file, length(file), length(file) + 8), 
                     ".wav", 
                     sep = "")
    
    # getting start/end times of intervals in the file
    intervals = get_start_end(temp_grid)
        # intervals is now a list of lists of the start and end points of the intervals
        # of the current text grid
        # also labeled with the textgrid interval's label
    
    # create formant object (pitch object?)
    formant_obj = praat("To Formant (keep all)...", 
                        list(0, # time step
                             5, # max num formants
                             5500, # max formant hz
                             0.025, # window length
                             50), # pre-emphasis hz
                        input = temp_wav,
                        overwrite = TRUE,
                        output = formant_path)
    
    # create intensity object
    intensity = praat("To Intensity...", 
                      list(100, # minumum pitch
                           0, # time step (0 auto)
                           "yes"), # subtract mean
                      input = temp_wav,
                      overwrite = TRUE,
                      output = intensity_path)
    
    # create pitch object
    pitch_obj = praat("To Pitch...", 
                      list(0, # time step
                           75, # pitch floor
                           600), # pitch ceiling
                      input = temp_wav,
                      overwrite = TRUE,
                      output = pitch_path)
    
    for (interval in intervals)
    {
        start = interval[1]
        end = interval[2]
        temp_interval = c(start, end)

        label = names(start)
        f_means = formant_means(temp_interval, formant_path)
        qma = quart_med_amp(temp_interval, intensity_path)
        length = end - start 
        mf0 = max_F0(temp_interval, pitch_path)
        ma = max_amp(temp_interval, intensity_path)
        
        nums_return = c(length, mf0, ma)
        names(nums_return) = c("length", "max f0", "max amp")
        
        print(f_means)
        print(qma)
        print(nums_return)
    }
}


