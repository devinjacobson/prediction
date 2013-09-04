#ifndef LAPACKWRAPPER
#define LAPACKWRAPPER

// The LAPACK wrapper is a bit misnamed. We also include the 
// definitions of blas calls too.

// this whole file is a bit of a mess. it needs to be
// cleaned up
#include "../../../../correlations/stdafx.h"
#ifdef __PPC64_ESSL

#include "essl.h"

typedef int CLAPACK_integer;
typedef int integer;
typedef double doublereal;
typedef float floatreal;

extern "C"
{
// double precision blas calls
int dgetri_(integer *n, doublereal *a, integer *lda, integer 
        *ipiv, doublereal *work, integer *lwork, integer *info);

int dgetrf_(integer *m, integer *n, doublereal *a, integer *
        lda, integer *ipiv, integer *info); 

int dsyev_(char *jobz, char *uplo, integer *n, doublereal *a,
         integer *lda, doublereal *w, doublereal *work, integer *lwork,
        integer *info);

int dgemm_(char *, char *, int *, int *, int *, 
		  double *, double *, int *, double *, 
		  int *, double *, double *, int *);

// single precision blas calls
int sgetri_(integer *n, floatreal *a, integer *lda, integer 
        *ipiv, floatreal *work, integer *lwork, integer *info);

int sgetrf_(integer *m, integer *n, floatreal *a, integer *
        lda, integer *ipiv, integer *info); 

int ssyev_(char *jobz, char *uplo, integer *n, floatreal *a,
         integer *lda, floatreal *w, floatreal *work, integer *lwork,
        integer *info);

int sgemm_(char *, char *, int *, int *, int *, 
		  float *, float*, int *, float*, 
		  int *, float*, float*, int *);

}



#endif

#ifdef __NEURONIC_MKL

#include "mkl.h"
typedef int CLAPACK_integer;
typedef int integer;
typedef double doublereal;
typedef float floatreal;


extern "C"
{
int dgetri_(integer *n, doublereal *a, integer *lda, integer 
        *ipiv, doublereal *work, integer *lwork, integer *info);

int dgetrf_(integer *m, integer *n, doublereal *a, integer *
        lda, integer *ipiv, integer *info); 

int dsyev_(char *jobz, char *uplo, integer *n, doublereal *a,
         integer *lda, doublereal *w, doublereal *work, integer *lwork,
        integer *info);

int dgemm_(char *, char *, int *, int *, int *, 
		  double *, double *, int *, double *, 
		  int *, double *, double *, int *);

// single precision blas calls
int sgetri_(integer *n, floatreal *a, integer *lda, integer 
        *ipiv, floatreal *work, integer *lwork, integer *info);

int sgetrf_(integer *m, integer *n, floatreal *a, integer *
        lda, integer *ipiv, integer *info); 

int ssyev_(char *jobz, char *uplo, integer *n, floatreal *a,
         integer *lda, floatreal *w, floatreal *work, integer *lwork,
        integer *info);

int sgemm_(char *, char *, int *, int *, int *, 
		  float*, float*, int *, float*, 
		  int *, float*, float*, int *);

}

 
#endif 
// __NEURONIC_MKL

#ifdef __MANUAL_LAPACK //#######################################################

#if 1
#include "../../../CLAPACK/CLAPACK-3.1.1-VisualStudio/INCLUDE/blaswrap.h"                                                         //
#include "../../../CLAPACK/CLAPACK-3.1.1-VisualStudio/INCLUDE/f2c.h"                                                              //

extern "C"
{
	#include "../../../CLAPACK/CLAPACK-3.1.1-VisualStudio/INCLUDE/clapack.h"
}

#else

extern "C"
{
	#include "../../../CLAPACK/CLAPACK-3.1.1-VisualStudio/INCLUDE/cblas.h"

typedef int integer;
typedef double doublereal;
typedef float floatreal;

int dgetri_(integer *n, doublereal *a, integer *lda, integer 
        *ipiv, doublereal *work, integer *lwork, integer *info);

int dgetrf_(integer *m, integer *n, doublereal *a, integer *
        lda, integer *ipiv, integer *info);                                                                                                                               

int dsyev_(char *jobz, char *uplo, integer *n, doublereal *a,
         integer *lda, doublereal *w, doublereal *work, integer *lwork,
        integer *info);
                                                                                                                
int dgemm_(char *, char *, int *, int *, int *, 
		  double *, double *, int *, double *, 
		  int *, double *, double *, int *);

// single precision blas calls
int sgetri_(integer *n, floatreal *a, integer *lda, integer 
        *ipiv, floatreal *work, integer *lwork, integer *info);

int sgetrf_(integer *m, integer *n, floatreal *a, integer *
        lda, integer *ipiv, integer *info); 

int ssyev_(char *jobz, char *uplo, integer *n, floatreal *a,
         integer *lda, floatreal *w, floatreal *work, integer *lwork,
        integer *info);

int sgemm_(char *, char *, int *, int *, int *, 
		  float *, float*, int *, float*, 
		  int *, float*, float*, int *);

typedef int CLAPACK_integer;

}


#endif

#undef abs                                                                    //
typedef integer CLAPACK_integer;

#elif  __MAC_LAPACK    //-----------------------------------------------------//
#include <Accelerate/Accelerate.h>                                            //
#include <cblas.h>                                                            //
typedef __CLPK_integer CLAPACK_integer;
#endif  //--------------------------------------------------------------------//

#endif
