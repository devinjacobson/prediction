#include <clapack.h>

template <class T>
void tsyev( char *jobz, char* uplo, int* n, T* a,
    int* lda, T* w, T* work, int* lwork, int* info );