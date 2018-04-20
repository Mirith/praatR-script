# Info 

For details on how to run this script, see [here](https://github.com/Mirith/praatR-script/blob/master/praat%20script%20info.md).  

Uses [PraatR](https://github.com/usagi5886/PraatR), made by [Aaron Albin](http://www.aaronalbin.com/praatr/index.html).  

Extracts relevant data from annotated sound files (annotated in Praat) and analyzes that data.  (Formant values, vowel length, average amplitude, etc).

This script requires PraatR to be installed and working, as well as R/some editor for R.  (I'm using RSTudio).  Also, there can be no spaces in any directory name.  The spaces will mess up PraatR.  Really.  

You should put TextGrids and wav files in two separate folders.  Only put TextGrids in the TextGrids folder, and only put wav files in the wav folder.  Also have a place to write some temporary files, and a place to output the csv.  

The script can process about 30 file pairs every 15 minutes (8 GB RAM, 2.4 Ghz processor), depending on how many intervals are labeled as vowels per word.  

# Progess

All functions written and working.  Can add to dataframe and write that dataframe to a csv.  

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
