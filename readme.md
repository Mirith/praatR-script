# Info 
Uses [PraatR](https://github.com/usagi5886/PraatR), made by [Aaron Albin](http://www.aaronalbin.com/praatr/index.html).  

Extracts relevant data from annotated sound files (annotated in Praat) and analyzes that data.  (Formant values, vowel length, average amplitude, etc).

Work in progress right now.  Currently editing functions and getting them to play nicely with each other.  

This script requires PraatR to be working, as well as R/some text editor for R.  (I'm using RSTudio). 

Also, there can be no spaces in any directory name.  The spaces will mess up PraatR.  Really.  

The script will be made of mostly helper functions, for the purposes of modularity.  

# Progess

get_length function deleted -- easier to subtract end/start points from get_start_end... 

get_start_end function written and working 

formant_means written and working.  

quart_med_amp written and working

interval_split written and working.  

max_f0 and max_amp written and working

to do:

* F0 quartile and median measures -- in progress, but totally broken.  

* mean of F0

* mean of amplitude 

* equidistant measures of F1, F2, F3

* ~~fix variable names to make things run more smoothly.~~ mostly done, still need to check things.  

* ~~get everything running together and automatically.~~ mostly done.  

* put gathered data into a dataframe.  

# usage

Basically what the MIT license says, I guess.  

```
MIT License

2018

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
This script isn't actually copyrighted at all, but if you use any part of it, please credit at least the creator of PraatR (mentioned above)!  I would also appreciate it if you could at least link back to this repository.  
