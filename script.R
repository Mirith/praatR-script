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

# multiple little pieces 
# measuring total length of ___
# computing average is built in to R
# measure median of ___
# quartile amplitude can call that one... 

# how to get data from one interval from one sound? 
# go sound by sound, looking for one vowel

library(PraatR)

path = "C:/praatR/Bitur/grids/ageta-DM-1.TextGrid"

# takes a sound and text grid and returns the given interval's length
# grid_path = full path (no spaces allowed) of the text grid
    # ex "C:/praatR/Bitur/grids/ageta-DM-1.TextGrid"
# tier_number = number of the tier to look at
# interval_number = which interval you want the length of
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# to do: add functionality to get intervals only if they match a certain label?
# or make separate function to extract all interval numbers 
    # if it matches given character?
get_length <- function(grid_path, tier_number, interval_number, label = NULL)
{
    start_time = praat("Get start point...", 
                       list(tier_number, interval_number), 
                       input = path, 
                       simplify = TRUE)
    end_time = praat("Get end point...", 
                     list(tier_number, interval_number), 
                     input = path, 
                     simplify = TRUE)
    return (as.numeric(end_time) - as.numeric(start_time))
}

get_length(path, 1, 2)

# returns a list of intervals measuring formant values
get_intervals <- function(sound_path, num_intervals, formant)
{
    
}