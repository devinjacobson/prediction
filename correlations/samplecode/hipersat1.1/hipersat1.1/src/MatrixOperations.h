#ifndef MATRIXOPERATIONS_H_UNIVERSITY_OF_OREGON_NIC
#define MATRIXOPERATIONS_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "NicVector.h"
#include "LAPACKWrapper.h"

// Provide one stop shopping for the commonly
// used matrix operations.
//
// Since we are using OpenMP and MPI to parallelize
// many of these operations, but OMP and MPI aren't 
// available on all platforms and configurations
// we need a way to abtract the parallelization away.

// This file also handles the templatization of the
// blas and lapack calls. Another alternative would
// be to use function overloading, which actually 
// makes more sense. But hey, I was in a template
// frame of mind at the time.

extern "C" int dgemm_(char *, char *, int *, int *, int *, double *,
    double *, int *, double *, int *, double *, double *, int *);

extern "C" int dgemv_( char*, int*, int*, double*, double*, int*,
    double*, int*, double*, double*, int* );

extern "C" int sgemm_(char *, char *, int *, int *, int *, float*,
    float*, int *, float*, int *, float*, float*, int *);

extern "C" int sgemv_( char*, int*, int*, float*, float*, int*,
    float*, int*, float*, float*, int* );

extern "C" int dger_(int *, int *, double *, double *, int *, 
    double *, int *, double *, int *);

extern "C" int sger_(int *, int *, float *, float *, int *, 
    float *, int *, float *, int *);

template <class T>
void transposeSquare( NicMatrix<T>& matrix );

template <class T>
void parallelTgemm( 
    char* tA, char* tB,
    int* m, int* n, int* k,
    T* alpha, T* A, int* ldA,
    T* B, int* ldB,
    T* beta, T* C, int* ldC );

template <class T>
void parallelTgemv(
    char* tA,
    int* m, int* n,
    T* alpha, T* A, int* ldA,
    T* x, int* incx,
    T* beta, T* y, int* incy );

// compute C = op1(A)*op2(B)
template <class T>
void multiply(
    NicMatrix<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeA = false,
    bool transposeB = false );


// compute c = op(A) * b
template <class T>
void multiply(
    NicMatrix<T>& A,
    NicVector<T>& b,
    NicVector<T>& c,
    bool transposeA = false );

// compute B = op(A) * B
// B is overwritten, can not be transposed
template <class T>
void multiply(
    NicMatrix<T>& A,
    NicMatrix<T>& B,
    bool transposeA = false );

template <class T>
void multiplyAdiag(
    NicVector<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeB = false );

template <class T>
void multiplySimple(
    NicMatrix<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeA = false,
    bool transposeB = false );

template <class T>
bool invert( NicMatrix<T>& A, NicMatrix<T>& Ainv );

template <class T>
void Tsyev( char *jobz, char* uplo, int* n, T* a,
    int* lda, T* w, T* work, int* lwork, int* info );

template <class T>
void Tger( int*, int*, T*, T*, int*, T*, int*, T*, int*);

#endif
// MATRIXOPERATIONS_H_UNIVERSITY_OF_OREGON_NIC
