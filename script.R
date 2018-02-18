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

library(PraatR)

path = "C:/praatR/Bitur/grids/asak-DM-1.TextGrid"

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

# returns a list of intervals measuring formant values
# might have to create formanttier or similar object with start/end times
# from textgrid to actually get formants
get_formant <- function(file_path, num_samples, formant_level)
{
    
}

# when passed a text grid, returns start and stop times with interval label
# as a list
# helper function for bigger functions that need this functionality
get_start_end <- function(text_grid)
{
    interval_numbers = as.numeric(praat("Get number of intervals...", 
                                        list(1), 
                                        input = text_grid, 
                                        simplify = TRUE))
    return_list <- c()
    
    for (interval in c(1:interval_numbers))
    {
        interval_label = praat("Get label of interval...", 
                               list(1, interval), 
                               input = text_grid)
        if(interval_label != "")
        {
            interval_start = praat("Get start point...", 
                                              list(1, interval), 
                                              input = text_grid, 
                                              simplify = TRUE)
            interval_end = praat("Get end point...", 
                                            list(1, interval), 
                                            input = text_grid, 
                                            simplify = TRUE)
        
        return_list = append(return_list, 
                             c(interval_label, interval_start, interval_end))
        
        }
        
    }
    # want different structure, this is just a single list
    return (return_list)
}

# testing above 
# get_start_end(path)

# given sound_path, maps labeled textgrid intervals to sound path
# will have to do a lot of other thing with info... 
# way to save info?
# might want to do this in main functionality of file with everything else
map_start_end <- function(sound_path)
{
    
}