# Info 
Uses [PraatR](https://github.com/usagi5886/PraatR), made by [Aaron Albin](http://www.aaronalbin.com/praatr/index.html).  

Extracts relevant data from annotated sound files (annotated in Praat) and analyzes that data.  (Formant values, vowel length, average amplitude, etc).

Very much a work in progress right now.  

This script requires PraatR to be working, as well as R/some text editor for R.  (I'm using RSTudio). 

Also, there can be no spaces in any directory name.  The spaces will mess up PraatR.  Really.  

The script will eventually be made of mostly helper functions, for the purposes of modularity.  

# Progess

get_length function written and working

get_start_end function written and working 

formant_means written and working

**Note: Does not work for F0**.

need more functionality:

* quartile measuring -- F0 and amplitude

* median measuring -- formants and amplitude

* mean of F0

Once everything is written out and mostly working, figuring out exactly how to systematically go through all the files will be the next step.  Hopefully that will involve minimal changing of existing code.  

# usage

Basically what the MIT license says, I guess.  

```
MIT License

Copyright (c) [year] [fullname]

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
