#include "BlasLapack.h"

typedef __CLPK_integer CLAPACK_integer;

template <>
void tsyev<double>( char *jobz, char* uplo, int* n, double* a,
    int* lda, double* w, double* work, int* lwork, int* info )
{
    dsyev_( jobz, uplo, 
        (CLAPACK_integer*)(n), a, (CLAPACK_integer*)(lda), w, work, 
        (CLAPACK_integer*)(lwork), 
        (CLAPACK_integer*)(info) );
}

template <>
void tsyev<float>( char *jobz, char* uplo, int* n, float* a,
    int* lda, float* w, float* work, int* lwork, int* info )
{
    ssyev_( jobz, uplo, 
        (CLAPACK_integer*)(n), a, (CLAPACK_integer*)(lda), w, work, 
        (CLAPACK_integer*)(lwork), 
        (CLAPACK_integer*)(info) );
}
