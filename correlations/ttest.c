//====================================================== file = ttest.c =====
//=  Program to compute confidence interval using a Student's T test        =
//=    - Hardcoded for 95 percent confidence interval                       =
//===========================================================================
//=  Notes:                                                                 =
//=    1) Input from input file "in.dat" to stdin (see example below)       =
//=        * Comments are bounded by "&" characters at the beginning and    =
//=          end of the comment block                                       =
//=    2) Output is to stdout                                               =
//=    3) Maximum number of samples means in "in.dat" is fixed to be 100    =
//=-------------------------------------------------------------------------=
//= Example "in.dat" file:                                                  =
//=                                                                         =
//=    & Sample series of data which can be integers or reals.              =
//=      There are 11 values in this file. &                                =
//=    50                                                                   =
//=    42                                                                   =
//=    48                                                                   =
//=    61                                                                   =
//=    60                                                                   =
//=    53                                                                   =
//=    39                                                                   =
//=    54                                                                   =
//=    42                                                                   =
//=    59                                                                   =
//=    53                                                                   =
//=-------------------------------------------------------------------------=
//= Example output (for above "in.dat"):                                    =
//=                                                                         =
//=   ------------------------------------------------- ttest.c -----       =
//=     Number of samples       = 11                                        =
//=     Sample mean             = 51.000000                                 =
//=     Sample variance         = 57.800000                                 =
//=     95% confidence interval = +/- 5.107518                              =
//=     Low bound               = 45.892482                                 =
//=     High bound              = 56.107518                                 =
//=   ---------------------------------------------------------------       =
//=-------------------------------------------------------------------------=
//=  Build: bcc32 ttest.c                                                   =
//=-------------------------------------------------------------------------=
//=  Execute: ttest < in.dat                                                =
//=-------------------------------------------------------------------------=
//=  Author: Ken Christensen                                                =
//=          University of South Florida                                    =
//=          WWW: http://www.csee.usf.edu/~christen                         =
//=          Email: christen@csee.usf.edu                                   =
//=-------------------------------------------------------------------------=
//=  History: KJC (09/16/98) - Genesis                                      =
//=           KJC (07/25/06) - Cosmetic clean-up                            =
//=           KJC (01/25/07) - Changed output to have low and high bounds   =
//===========================================================================

//----- Include files -------------------------------------------------------
#include <stdio.h>                 // Needed for printf() and feof()
#include <math.h>                  // Needed for pow() and sqrt()
#include <stdlib.h>                // Needed for exit() and atof()
#include <string.h>                // Needed for strcmp()

//----- Defines -------------------------------------------------------------
#define MAX_SAMPLES  100           // Maximum size of samples array is fixed
                                   // at 100 (this is size of T_table[])

//----- Globals -------------------------------------------------------------
double     X[MAX_SAMPLES];         // Samples read from "in.dat"
int        N;                      // Number of samples
double     Mean;                   // Mean of samples
double     Sample_variance;        // Sample variance
double     T_table[MAX_SAMPLES + 1] =
{0.0, 12.70615030, 4.30265572, 3.18244929, 2.77645085, 2.57057763,
       2.44691364, 2.36462256, 2.30600562, 2.26215888, 2.22813923,
       2.20098627, 2.17881279, 2.16036824, 2.14478859, 2.13145085,
       2.11990482, 2.10981852, 2.10092366, 2.09302470, 2.08596247,
       2.07961420, 2.07387529, 2.06865479, 2.06389813, 2.05953711,
       2.05553078, 2.05182914, 2.04840944, 2.04523075, 2.04227035,
       2.03951458, 2.03693161, 2.03451691, 2.03224317, 2.03011040,
       2.02809133, 2.02619048, 2.02439423, 2.02268893, 2.02107457,
       2.01954208, 2.01808234, 2.01669081, 2.01536750, 2.01410330,
       2.01289367, 2.01173861, 2.01063358, 2.00957401, 2.00855993,
       2.00758222, 2.00664544, 2.00574504, 2.00488102, 2.00404429,
       2.00323938, 2.00246631, 2.00171598, 2.00099748, 2.00029717,
       1.99962414, 1.99896931, 1.99834175, 1.99772785, 1.99713667,
       1.99656369, 1.99600890, 1.99546775, 1.99494479, 1.99443547,
       1.99394435, 1.99346232, 1.99299847, 1.99254373, 1.99210262,
       1.99167516, 1.99125679, 1.99084752, 1.99045189, 1.99006535,
       1.98968791, 1.98931957, 1.98896032, 1.98861016, 1.98826910,
       1.98793259, 1.98760972, 1.98729139, 1.98697762, 1.98667294,
       1.98637735, 1.98608631, 1.98579982, 1.98552243, 1.98524958,
       1.98498582, 1.98472207, 1.98446741, 1.98421730, 1.98397174};

//----- Function prototypes -------------------------------------------------
void   load_X_array(void);         // Load X array
double compute_mean(void);         // Compute mean
double compute_sample_var(void);   // Compute sample variance
double compute_ci(void);           // Compute confidence interval

//===========================================================================
//=  Main program                                                           =
//===========================================================================
void main(void)
{
  double   ci_value;               // Computed confidence interval value

  // Load the sample means into X and determine global variable N
  printf("------------------------------------------------- ttest.c -----\n");
  load_X_array();

  // Make sure than N is less than MAX_SAMPLES
  if (N >= MAX_SAMPLES)
  {
    printf("*** ERROR - more than %d samples in input \n", MAX_SAMPLES);
    exit(1);
  }

  // Make sure than N is at least 2
  if (N < 2)
  {
    printf("*** ERROR - need more than one sample mean in input \n");
    exit(1);
  }

  // Compute global variables Mean and Sample_variance for X
  Mean = compute_mean();
  Sample_variance = compute_sample_var();

  // Compute confidence interval value
  ci_value = compute_ci();

  // Output results
  printf("  Number of samples       = %d        \n", N);
  printf("  Sample mean             = %f        \n", Mean);
  printf("  Sample variance         = %f        \n", Sample_variance);
  printf("  95%% confidence interval = +/- %f   \n", ci_value);
  printf("  Low bound               = %f        \n", (Mean - ci_value));
  printf("  High bound              = %f        \n", (Mean + ci_value));
  printf("---------------------------------------------------------------\n");
}

//===========================================================================
//=  Function to load X array from stdin and determine N                    =
//===========================================================================
void load_X_array(void)
{
  char      temp_string[1024];     // Temporary string variable

  // Read all values into X
  N = 0;
  while(1)
  {
    scanf("%s", temp_string);
    if (feof(stdin)) goto end;

    // This handles a comment bounded by "&" symbols
    while (strcmp(temp_string, "&") == 0)
    {
      do
      {
        scanf("%s", temp_string);
        if (feof(stdin)) goto end;
      } while (strcmp(temp_string, "&") != 0);
      scanf("%s", temp_string);
      if (feof(stdin)) goto end;
    }

    // Enter value in array and increment array index
    X[N] = atof(temp_string);
    N++;

    // Check if MAX_SAMPLES data values exceeded
    if (N > MAX_SAMPLES)
    {
      printf("*** ERROR - greater than %ld values \n", MAX_SAMPLES);
      exit(1);
    }
  }

  // End-of-file escape
  end:

  return;
}

//===========================================================================
//=  Function to compute mean for a series X                                =
//===========================================================================
double compute_mean(void)
{
  double   mean;                 // Computed mean value to be returned
  int      i;                    // Loop counter

  // Loop to compute mean
  mean = 0.0;
  for (i=0; i<N; i++)
    mean = mean + (X[i] / N);

  return(mean);
}

//===========================================================================
//=  Function to compute sample variance for a series X                     =
//===========================================================================
double compute_sample_var(void)
{
  double   sample_var;           // Computed sample variance value
  int      i;                    // Loop counter

  // Loop to compute sample variance
  sample_var = 0.0;
  for (i=0; i<N; i++)
    sample_var = sample_var + (pow((X[i] - Mean), 2.0) / (N - 1));

  return(sample_var);
}

//===========================================================================
//=  Function to compute CI for given N and Sample_variance                 =
//===========================================================================
double compute_ci(void)
{
  double   ci_value;             // Computed CI value to be returned
  double   t_score;              // T score value from T_table[]

  // Get T score and compute ci_value
  t_score = T_table[N - 1];
  ci_value = t_score * sqrt(Sample_variance / N);

  return(ci_value);
}
