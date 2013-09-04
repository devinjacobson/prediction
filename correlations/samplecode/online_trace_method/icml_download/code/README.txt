
README file for code accompanying the ICML 2010 paper
"Telling cause from effect based on high-dimensional observations"
by Janzing, Hoyer, and Schölkopf

-------------------------------------------------------------------------------

Using the software:

To run the code, you need to be in the 'code' directory (the directory 
containing this file), then start up R. Now start by calling

> source('loadmain.R')

(The ">" is just the prompt, do not enter that.) Now, whenever you call

> main( task )

where "task" is a task number, from the command line, it first reads 
in all the code in the directory and then executes the appropriate task
from the main.R file. In other words, you get 'matlab-like' functionality
in R. (Normally in R you have to always remember to 'source' in any file
that you have updated before issuing your commands.)

A good idea is also to issue

> options(error=recover)

as that allows some debugging if something goes wrong at any point in 
execution. (Hopefully, there will not be much need for that, at least
if no changes are made to the files.)

To reproduce the figures in the paper, simply use the command

> main( task )

The mapping from the tasks to the results in the paper is the following:

task     paper
----     -----
1        a simple demo (not described in the paper)
2        fig 1ab  (exact correspondence using 'detail <- TRUE' setting)
3        fig 1cd  (exact correspondence using 'detail <- TRUE' setting)
4        examples of the filtered image data (plots not shown in paper)
5        results on the filtered image data (Subsection 4.2)
6        precipitation data (Subsection 4.3) with renormalizing only X
7        precipitation  data (Subsection 4.3) with renormalizing X and Y
8        Chemnitz ozone data (Subsection 4.4)
9        Stock return data (Subsection 4.5, first experiment)
10       Stock return data (Subsection 4.5, second experiment) 

         (11-15 are the same experiments as 6-10, but  with rotation tests. The outputs 
         r[4] and r[5] are then the p-values for the hypotheses X --> Y 
         and Y --> X, respectively. The direction with higher  p-value is preferred. Note: no decision 
         is made only in the rare case of equal p-values since the user can directly use the  p-values for    
         judging the significance.)
                            
11       precipitation data (Subsection 4.3) with renormalizing only X 
12       precipitation  data (Subsection 4.3) with renormalizing X and Y
13       Chemnitz ozone data (Subsection 4.4)
14       Stock return data (Subsection 4.5, first experiment)
15       Stock return data (Subsection 4.5, second experiment) 




A very small and very explicit demo of how to run the main inference 
function is in task 1.

The digit image data can be downloaded from 
http://www-stat-class.stanford.edu/~tibs/ElemStatLearn/data.html
and needs to be placed in a directory called 'zipdata' which
is in the same directory as 'code' is located. That is, the directory
structure needs to look like this:

code/
  alg1cov.R
  ...
  transforms.R
zipdata/
  zip.test
  zip.train
data_sets/
  Chemnitz_data.txt
  precipitation_data.txt
  Stock_returns.txt 
  
The directory data_sets contains all the real-world data except for the handwritten digit example.

To try the code on some data of your own, the primary function to use 
is 'alg1samples'. The best way to do this is to copy task 1 (for instance, 
into task 100 or whatever else number you like) and then just load the 
appropriate data instead of generating simulated data; leaving the call 
to alg1samples as it is.

Note that the syntax is as follows:

> result <- alg2samples( X, Y, thresh )

where X and Y are matrices holding the data in their columns (so 
these matrices should have the same number of columns, but may differ
in their dimension i.e. number of rows), and 'thresh' is a scalar 
constant that determines how aggressively the algorithm makes decisions 
(i.e. how seldom it says it is unsure). Note that tresh=0 means it always
takes a guess. We have found a value on the order of 0.5 to work well
in many cases.

The result is a five-dimensional vector, where only one of the first 
three dimensions is 1 (the others being 0): The first is 1 if x is
judged to be the cause, the second is 1 if y is judged to be the cause,
and the third is 1 if unsure. The fourth and fifth dimensions give the
estimated values of the quantities involved.






