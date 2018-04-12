# first script attempt
# goals: 
# measure F1, F2, F3 11 (?) times equidistant
# Mean F1, F2, F3, amplitude, F0
# length
# 1st quartile amplitude, F0
# 3rd quartile amplitude, F0
# median amplitude, F0
# peak F0 and amplitude
# get label of adjacent segments

#################### check out Warning messages: ###############################
#1: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
#2: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
#3: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
#4: In append(data_points, as.numeric(praat("Get value at time...",  ... : 
# NAs introduced by coercion
# 5: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 6: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 7: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 8: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 9: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 10: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
# 11: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
# 12: In f_sample(interval, 11, formant_path) : NAs introduced by coercion
# 13: In append(data_points, as.numeric(praat("Get value at time...",  ... :
# NAs introduced by coercion
# 14: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 15: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
# 16: In quart_med_F0(interval, pitch_path) : NAs introduced by coercion
                                                                                       
############ useful functions ##################################################

rm(list = ls())

library(PraatR)

# when passed a path of a text grid
# returns start and stop times with interval label as a list within a list
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
    for (interval in c(2:interval_numbers))
    {
        # gets the preceding adjacent label 
        interval_label = praat("Get label of interval...", # praat command
                               list(1, interval - 1), # tier and interval to look at
                               input = grid_loc)
        
        # # gets the label of the interval
        # interval_label = paste(interval_label, 
        #                         praat("Get label of interval...", # praat command
        #                               list(1, interval), # tier and interval to look at
        #                               input = grid_loc), sep = " ")
        # 
        # # gets the following adjacent label, if interval is not last
        # if (interval < interval_numbers)
        # {
        #     interval_label = paste(interval_label, 
        #                            praat("Get label of interval...", # praat command
        #                                  list(1, interval + 1), # tier and interval to look at
        #                                  input = grid_loc), sep = " ")
        # }
        
        # if it has a label
        # it should have a label, but... 
            # account for missing labels? (will end with missing adjacents...)
        if(interval_label != "")
        {
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
    median = median(data_points, na.rm = TRUE)
    # 2nd and 4th entries are 1st and 3rd quartile respectively
    quantiles = quantile(data_points, na.rm = TRUE)
    
    # adds to list, and labels entries
    return_vals = c(median, quantiles[2], quantiles[4])
    names(return_vals) = c("amp median", "amp 1st", "amp 3rd")
    
    return (return_vals)
    
}

# quartile and median calculation
# F0
quart_med_F0 <- function(f0_interval, f0_loc)
{
    # accounting for Praats sampling of f0 (75 floor Hz = 40 ms sample)
    new_interval = c(f0_interval[1] + .04, f0_interval[2])
    # divide up desired length by 9 pieces
    # use interval_split()
    # and put in list for loop
    point_list = interval_split(new_interval, 9)
    
    # empty, to be filled with loop
    # holds the decibel intensities to be worked with later
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
    # find median for list
    # find quartile for list
    sort(data_points)
    median = median(data_points, na.rm = TRUE)
    # 2nd and 4th entries are 1st and 3rd quartile respectively
    quantiles = quantile(data_points, na.rm = TRUE)
    
    # adds to list, and labels entries
    return_vals = c(median, quantiles[2], quantiles[4])
    names(return_vals) = c("f0 median", "f0 1st", "f0 3rd")
    
    return (return_vals)
}

# returns max F0 value of interval passed 
# f0_time is a list of the start and end point of the interval to look at
max_F0 <- function(f0_time, f0_loc)
{
    start = f0_time[1]
    end = f0_time[2]
    
    val = as.numeric(praat("Get maximum...",
                     list(start, end, "Hertz", "Parabolic"),
                     input = f0_loc,
                     simplify = TRUE))
    return (val)
}

# max amplitude value finder of interval passed 
# amp_time is a list of the start and end point of the interval to look at 
max_amp <- function(amp_time, intensity_loc)
{
    start = amp_time[1]
    end = amp_time[2]
    
    val = as.numeric(praat("Get maximum...",
                           list(start, end, "Parabolic"),
                           input = intensity_loc,
                           simplify = TRUE))
    return (val)
}

# f0_interval is a list of the start and end point of the interval to look at
mean_F0 <- function(f0_interval, f0_loc)
{
    start = f0_interval[1]
    end = f0_interval[2]
    
    mean = as.numeric(praat("Get mean...", 
                            list(start, end, "Hertz"), 
                            input = f0_loc, 
                            simplify = TRUE))
    return (mean)
}

# amp_interval is a list of the start and end point of the interval to look at
mean_amp <- function(amp_interval, amp_loc)
{
    start = amp_interval[1]
    end = amp_interval[2]
    
    mean = as.numeric(praat("Get mean...", 
                            list(start, end, "energy"), 
                            input = amp_loc, 
                            simplify = TRUE))
    return (mean)
}

# f_interval is a list of the start and end point of the interval to look at
f_sample <- function(f_interval, num_samples, formant_loc)
{
    split = interval_split(c(f_interval[1], f_interval[2]), num_samples)
    return_vals = vector("list")
    
    f1 = c()
    f2 = c()
    f3 = c()
    
    for (point in split)
    {
        f1_val = as.numeric(praat("Get value at time...", 
                                 list(1, point, "Hertz", "Linear"),
                                 input = formant_loc,
                                 simplify = TRUE))
        
        f2_val = as.numeric(praat("Get value at time...", 
                                  list(2, point, "Hertz", "Linear"),
                                  input = formant_loc,
                                  simplify = TRUE))
        
        f3_val = as.numeric(praat("Get value at time...", 
                                  list(3, point, "Hertz", "Linear"),
                                  input = formant_loc,
                                  simplify = TRUE))
        
        f1 = append(f1, f1_val)
        f2 = append(f2, f2_val)
        f3 = append(f3, f3_val)
    }
    
    return_vals[[1]] = f1
    return_vals[[2]] = f2
    return_vals[[3]] = f3
    
    return (return_vals)
}

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
    
    print(intervals)
    
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

        label = names(start)
        
        
        length = end - start

        f_means = formant_means(interval, formant_path)
        f_pts = f_sample(interval, 11, formant_path)
        
        qma_amp = quart_med_amp(interval, intensity_path)
        qma_f0 = quart_med_F0(interval, pitch_path)
        
        f0_max = max_F0(interval, pitch_path)
        amp_max = max_amp(interval, intensity_path)
        
        f0_mean = mean_F0(interval, pitch_path)
        amp_mean = mean_amp(interval, intensity_path)

        nums_return = c(length, f0_max, amp_max, f0_mean, amp_mean)
        names(nums_return) = c("length (s)",
                               "max f0 (Hz)",
                               "max amp (dB)",
                               "mean f0 (Hz)",
                               "mean amp (dB)")

        print(f_means)
        print(qma_amp)
        print(qma_f0)
        print(nums_return)
        print(f_pts)
    }
}


