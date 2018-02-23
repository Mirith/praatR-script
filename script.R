# first script attempt
# goals: 
#
# measure F1, F2, F3 11 (?) times equidistant
# Mean F1, F2, F3, amplitude, F0
# length
# 1st quartile amplitude, F0
# 3rd quartile amplitude, F0
# median amplitude, F0

# deal with formatting outputs later, just get pieces in place
# eventually want to make a big dataframe for everything to work with

# multiple little pieces 
# measuring total length of ___
# computing average is built in to R
# measure median of ___
# quartile amplitude can call that one... 

# useful things that don't seem to exist in praatR
# formant listing (19 ish point measurements of first four formants in interval)
# get first formant (returns average of interval)

# looking in praat at buttons/menus gives explanation of each set of parameters

rm(list = ls())

library(PraatR)

path = "C:/praatR/Bitur/grids/asak-DM-1.TextGrid"
pathS = "C:/praatR/Bitur/audio/asak-DM-1.wav"

# takes a sound and text grid and returns the given interval's length
# grid_path = full path (no spaces allowed) of the text grid
    # ex "C:/praatR/Bitur/grids/ageta-DM-1.TextGrid"
# tier_number = number of the tier to look at
# interval_number = which interval you want the length of
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# to do: add functionality to get intervals only if they match a certain label?
# or make separate function to extract all interval numbers 
    # if it matches given character?
# also dataframe -- return values that integrate well?
get_length <- function(grid_path, tier_number, interval_number, label = NULL)
{
    start_time = as.numeric(praat("Get start point...", 
                       list(tier_number, interval_number), 
                       input = path, 
                       simplify = TRUE))
    end_time = as.numeric(praat("Get end point...", 
                     list(tier_number, interval_number), 
                     input = path, 
                     simplify = TRUE))
    return (end_time - start_time)
}

# checking above
# get_length(path, 1, 2)

# extracts formant information given intervals and labels
# sound_path is the location of the sound file
# formants is a list of the number of formants to take the mean of
# intervals is the output of get_start_end
formant_means <- function(sound_path, formants, intervals)
{
    # list to return later
    means = c()
    
    # cycles through all the formant numbers wanted
    for (formant_number in formants)
    {
        print(formant_number)
        # cycles through each interval in the intervals list
        for (interval in intervals)
        {        
            
            # gets start point, which should second entry in list
            start = as.numeric(interval[2])
            # gets end point, should be third entry in list
            end = as.numeric(interval[3])
            
            # create formant object
            formant_obj = praat("To Formant (keep all)...", 
                                list(0, 5, 5500, 0.025, 50),
                                input = sound_path,
                                output = "C:/praatR/Bitur/audio/test.Matrix",
                                overwrite = TRUE)
            mean = as.numeric(praat("Get mean...", 
                          list(formant_number, # number of formant to look at
                               start, # start point in time of formant
                               end, # end point in time of formant
                               "Hertz"), # measurement type
                          input = "C:/praatR/Bitur/audio/test.Matrix",
                          simplify = TRUE))
            means = append(means, mean)
        }
    }
    return (means)
}

formant_means(pathS, c(0,1,2,3), get_start_end(path))

# when passed a path of a text grid
# returns start and stop times with interval label as a list within a list
# everything in that list is a string 
# to do -- labels as list index names? 
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
            interval_start = praat("Get start point...", 
                                              list(1, interval), 
                                              input = text_grid, 
                                              simplify = TRUE)
            # and the end point
            # similar to how Get label of interval... works
            interval_end = praat("Get end point...", 
                                            list(1, interval), 
                                            input = text_grid, 
                                            simplify = TRUE)
        
        # adds the interval label and start/end points to the end of the list
        index = length(return_list) + 1
        return_list[[index]] = c(interval_label, interval_start, interval_end)
        }
    }
    return (return_list)
}

# testing above 
get_start_end(path)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# don't start until sure this is where this functionality should go!
# given sound_path, maps labeled textgrid intervals to sound path
# will have to do a lot of other thing with info... 
# way to save info?
# might want to do this in main functionality of file with everything else...
map_start_end <- function(sound_path)
{
    
}