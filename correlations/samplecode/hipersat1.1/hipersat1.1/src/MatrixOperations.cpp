#ifndef MATRIXOPERATIONS_CPP_UNIVERSITY_OF_OREGON_NIC
#define MATRIXOPERATIONS_CPP_UNIVERSITY_OF_OREGON_NIC

#include "MatrixOperations.h"
#ifdef __OPENMP_
#include "omp.h"
#endif

template <class T>
void transposeSquare( NicMatrix<T>& matrix )
{
    T temp;
    for ( int i = 0; i < matrix.rows; ++i )
    {
        for ( int j = 0; j < i; ++j )
        {
            temp = matrix( i, j );
            matrix( i, j ) = matrix( j, i );
            matrix( j, i ) = temp;
        }
    }
}

template <>
void parallelTgemm<double>( 
    char* tA, char* tB,
    int* m, int* n, int* k,
    double* alpha, double* A, int* ldA,
    double* B, int* ldB,
    double* beta, double* C, int* ldC )
{
    bool transposeA = ( *tA == 'T' || *tA == 't' );
    int mTemp = *m;
#ifdef __PPC64_ESSL
    // empty
#elif defined( __OPENMP_ )
    int M = *m;
    int numThreads, threadNum;
#pragma omp parallel default(shared) firstprivate(mTemp, A, C, numThreads, threadNum, ldA )
    {
        numThreads = omp_get_num_threads();
        threadNum = omp_get_thread_num();
        mTemp = M / numThreads;
        A += ( transposeA ? (mTemp * threadNum * (*m)) : (mTemp * threadNum ));
        C += ( mTemp * threadNum );
        if ( threadNum == (numThreads-1) )
        {
            mTemp += M % numThreads;
        }
#endif
        dgemm_( tA, tB,
            &mTemp, n, k,
            alpha,
            A, ldA,
            B, ldB,
            beta, C, ldC );

#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    }
#endif
}

template <>
void parallelTgemm<float>( 
    char* tA, char* tB,
    int* m, int* n, int* k,
    float* alpha, float* A, int* ldA,
    float* B, int* ldB,
    float* beta, float* C, int* ldC )
{
    bool transposeA = ( *tA == 'T' || *tA == 't' );
    int mTemp = *m;
#ifdef __PPC64_ESSL
    // empty
#elif defined( __OPENMP_ )
    int M = *m;
    int numThreads, threadNum;
#pragma omp parallel default(shared) firstprivate(mTemp, A, C, numThreads, threadNum, ldA )
    {
        numThreads = omp_get_num_threads();
        threadNum = omp_get_thread_num();
        mTemp = M / numThreads;
        A += ( transposeA ? (mTemp * threadNum * (*m)) : (mTemp * threadNum ));
        C += ( mTemp * threadNum );
        if ( threadNum == (numThreads-1) )
        {
            mTemp += M % numThreads;
        }
#endif
        sgemm_( tA, tB,
            &mTemp, n, k,
            alpha,
            A, ldA,
            B, ldB,
            beta, C, ldC );

#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    }
#endif
}

template <>
void parallelTgemv<double>(
    char* tA,
    int* m, int* n,
    double* alpha, double* A, int* ldA,
    double* x, int* incx,
    double* beta, double* y, int* incy )
{
    bool transposeA = ( *tA == 'T' || *tA == 't' );
    int rows = ( transposeA ? *m : *n );
    int columns = ( transposeA ? *n : *m );
    int mTemp = *m;

#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    int M = *m;
    int numThreads, threadNum;
#pragma omp parallel default(shared) firstprivate( mTemp, A, y, numThreads, threadNum, ldA )
    {
        numThreads = omp_get_num_threads();
        threadNum = omp_get_thread_num();
        mTemp = M / numThreads;
        A += (transposeA ? (mTemp * threadNum * rows) : (mTemp * threadNum) );
        y += ( mTemp * threadNum );
        if ( threadNum == (numThreads - 1 ) )
        {
            mTemp += M % numThreads;
        }
#endif
        dgemv_( tA, &mTemp, n, alpha, A, ldA, x, incx, beta, y, incy );
#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    }
#endif
}


template <>
void parallelTgemv<float>(
    char* tA,
    int* m, int* n,
    float* alpha, float* A, int* ldA,
    float* x, int* incx,
    float* beta, float* y, int* incy )
{
    bool transposeA = ( *tA == 'T' || *tA == 't' );
    int rows = ( transposeA ? *m : *n );
    int columns = ( transposeA ? *n : *m );
    int mTemp = *m;

#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    int M = *m;
    int numThreads, threadNum;
#pragma omp parallel default(shared) firstprivate( mTemp, A, y, numThreads, threadNum, ldA )
    {
        numThreads = omp_get_num_threads();
        threadNum = omp_get_thread_num();
        mTemp = M / numThreads;
        A += (transposeA ? (mTemp * threadNum * rows) : (mTemp * threadNum) );
        y += ( mTemp * threadNum );
        if ( threadNum == (numThreads - 1 ) )
        {
            mTemp += M % numThreads;
        }
#endif
        sgemv_( tA, &mTemp, n, alpha, A, ldA, x, incx, beta, y, incy );
#ifdef __PPC64_ESSL
#elif defined( __OPENMP_ )
    }
#endif
}


template <class T>
void multiply(
    NicMatrix<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeA,
    bool transposeB )
{
    char tA = transposeA ? 'T' : 'N';
    char tB = transposeB ? 'T' : 'N';

    T alpha = 1;
    T beta = 0;
    int m = transposeA ? A.columns : A.rows;
    int n = transposeB ? B.rows :    B.columns;
    int k = transposeA ? A.rows :    A.columns;
    
    int lda = A.rows;
    int ldb = transposeB ? n : k;
    int ldc = m;

    T* aData = A.data;
    T* bData = B.data;
    T* cData = C.data;

    parallelTgemm<T>( &tA, &tB, 
        &m, &n, &k, 
        &alpha, aData, &lda, 
        bData, &ldb, 
        &beta, cData, &ldc );
}

// in place multiplication, B is overwritten
// A can be transposed, B can not
template <>
void multiply<double>(
    NicMatrix<double>& A,
    NicMatrix<double>& B,
    bool transposeA )
{
    double* temp = new double[ B.columns ];

    char tA = transposeA ? 'T' : 'N';
    double alpha = 1;
    double beta = 0;
    int m = transposeA ? A.columns : A.rows;
    int n = transposeA ? A.rows : A.columns;
    int lda = A.rows;
    int incx = 1;
    double* aData = A.data;
    double* bData = temp;
    double* cData;

    size_t columnLength = B.rows * sizeof( double );
    for ( int i = 0; i < B.columns; ++i )
    {
        cData = B.data + ( i * B.rows );
        memcpy( bData, cData, columnLength );
        dgemv_( &tA, &m, &n, &alpha, aData, &lda, bData, &incx,
            &beta, cData, &incx );
    }
    delete[] temp;
}

// in place multiplication, B is overwritten
// A can be transposed, B can not
template <>
void multiply<float>(
    NicMatrix<float>& A,
    NicMatrix<float>& B,
    bool transposeA )
{
    float* temp = new float[ B.columns ];

    char tA = transposeA ? 'T' : 'N';
    float alpha = 1;
    float beta = 0;
    int m = transposeA ? A.columns : A.rows;
    int n = transposeA ? A.rows : A.columns;
    int lda = A.rows;
    int incx = 1;
    float* aData = A.data;
    float* bData = temp;
    float* cData;

    size_t columnLength = B.rows * sizeof( float );
    for ( int i = 0; i < B.columns; ++i )
    {
        cData = B.data + ( i * B.rows );
        memcpy( bData, cData, columnLength );
        sgemv_( &tA, &m, &n, &alpha, aData, &lda, bData, &incx,
            &beta, cData, &incx );
    }
    delete[] temp;
}

template <class T>
void multiply(
    NicMatrix<T>& A,
    NicVector<T>& b,
    NicVector<T>& c,
    bool transposeA )
{
    char tA = transposeA ? 'T' : 'N';
    T alpha = 1;
    T beta = 0;
    int m = transposeA ? A.columns : A.rows;
    int n = transposeA ? A.rows : A.columns;
    int lda = A.rows;
    T* aData = A.data;
    T* bData = b.data;
    T* cData = c.data;
    int incx = 1;

    parallelTgemv<T>( &tA, &m, &n, &alpha, aData, &lda, bData, &incx,
        &beta, cData, &incx );
}

template <class T>
void multiplyAdiag(
    NicVector<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeB )
{
    // for now we use our own hand-rolled implementation
    // TODO: investigate speeding up and parallelizing this

    int row = 0;
    int column = 0;
    int rows    = transposeB ? B.columns : B.rows;
    int columns = transposeB ? B.rows    : B.columns;
    int* rowPtr = transposeB ?    &column : &row;
    int* columnPtr = transposeB ? &row    : &column;

    for ( row = 0; row < rows; ++row )
    {
        for ( column = 0; column < columns; ++column )
        {
            T valB = B( *rowPtr, *columnPtr );
            T valA = A.operator()(row);
            C( row, column ) = valA * valB;
        }
    }
}

// slow matrix multiplication, used to verify that
// the OpenMP multiply routine works
template <class T>
void multiplySimple(
    NicMatrix<T>& A,
    NicMatrix<T>& B,
    NicMatrix<T>& C,
    bool transposeA,
    bool transposeB )
{
    int aRows = transposeA ? A.columns : A.rows;
    int aColumns = transposeA ? A.rows : A.columns;
    int bRows = transposeB ? B.columns : B.rows;
    int bColumns = transposeB ? B.rows : B.columns;

    for ( int aRow = 0; aRow < aRows; ++aRow )
    {
        for ( int bColumn = 0; bColumn < bColumns; ++bColumn )
        {
            T sum = 0;
            for ( int aColumn = 0; aColumn < aColumns; ++aColumn )
            {
                // aColumn == bRow
                T valA = transposeA ? A( aColumn, aRow ) : A(aRow, aColumn );
                T valB = transposeB ? B( bColumn, aColumn ):  B(aColumn, bColumn );
                sum += valA * valB;
            }
            C( aRow, bColumn ) = sum;
        }
    }
}

template <>
bool invert<double>( NicMatrix<double>& A, NicMatrix<double>& Ainv )
{
    Ainv = A;
    CLAPACK_integer rows = A.rows;
    CLAPACK_integer* ipiv = new CLAPACK_integer[ rows ];
    CLAPACK_integer info;
    double worksize;
    // compute the LU factorization
    dgetrf_( &rows, &rows, Ainv.data, &rows, ipiv, &info );
    bool success = false;
    if ( 0 == info )
    {
        CLAPACK_integer lwork = -1;
        dgetri_( &rows, Ainv.data, &rows, ipiv, &worksize, &lwork, &info );
        if ( 0 == info ) // inverse exists
        {
            lwork = (CLAPACK_integer)(worksize);
            double* workVector = new double[ lwork ];
            dgetri_( &rows, Ainv.data, &rows, ipiv, workVector, &lwork, &info );
            success = true;
            delete[] workVector;
        }
    }
    delete[] ipiv;
    return success;
}

template <>
bool invert<float>( NicMatrix<float>& A, NicMatrix<float>& Ainv )
{
    Ainv = A;
    CLAPACK_integer rows = A.rows;
    CLAPACK_integer* ipiv = new CLAPACK_integer[ rows ];
    CLAPACK_integer info;
    float worksize;
    // compute the LU factorization
    sgetrf_( &rows, &rows, Ainv.data, &rows, ipiv, &info );
    bool success = false;
    if ( 0 == info )
    {
        CLAPACK_integer lwork = -1;
        sgetri_( &rows, Ainv.data, &rows, ipiv, &worksize, &lwork, &info );
        if ( 0 == info ) // inverse exists
        {
            lwork = (CLAPACK_integer)(worksize);
            float* workVector = new float[ lwork ];
            sgetri_( &rows, Ainv.data, &rows, ipiv, workVector, &lwork, &info );
            success = true;
            delete[] workVector;
        }
    }
    delete[] ipiv;
    return success;
}

template <>
void Tsyev<double>( char *jobz, char* uplo, int* n, double* a,
    int* lda, double* w, double* work, int* lwork, int* info )
{
    dsyev_( jobz, uplo, 
        (CLAPACK_integer*)(n), a, (CLAPACK_integer*)(lda), w, work, 
        (CLAPACK_integer*)(lwork), 
        (CLAPACK_integer*)(info) );
}

template <>
void Tsyev<float>( char *jobz, char* uplo, int* n, float* a,
    int* lda, float* w, float* work, int* lwork, int* info )
{
    ssyev_( jobz, uplo, 
        (CLAPACK_integer*)(n), a, (CLAPACK_integer*)(lda), w, work, 
        (CLAPACK_integer*)(lwork), 
        (CLAPACK_integer*)(info) );
}

template <>
void Tger<double>( int* a, int* b, double* c, double* d, int* e, 
    double* f, int* g, double* h, int* i )
{
    dger_( a, b, c, d, e, f, g, h, i );
}

template <>
void Tger<float> ( int* a, int* b, float* c, float* d, int* e, 
    float* f, int* g, float* h, int* i)
{
    sger_( a, b, c, d, e, f, g, h, i );
}


#ifdef INSTANTIATE_TEMPLATES

template void transposeSquare<double>( NicMatrix<double>& matrix );
template void multiply<double>( NicMatrix<double>& A, NicMatrix<double>& B, 
    NicMatrix<double>& C, bool transposeA, bool transposeB );
template void multiply<double>( NicMatrix<double>& A, NicVector<double>& b,
    NicVector<double>& c, bool transposeA );
template void multiplyAdiag<double>( NicVector<double>& A, 
    NicMatrix<double>& B, NicMatrix<double>& C, bool transposeB );
template void multiplySimple<double>( NicMatrix<double>& A, 
    NicMatrix<double>& B, NicMatrix<double>& C, bool transposeA,
    bool transposeB );
template void transposeSquare<float>( NicMatrix<float>& matrix );
template void multiply<float>( NicMatrix<float>& A, NicMatrix<float>& B, 
    NicMatrix<float>& C, bool transposeA, bool transposeB );
template void multiply<float>( NicMatrix<float>& A, NicVector<float>& b,
    NicVector<float>& c, bool transposeA );
template void multiplyAdiag<float>( NicVector<float>& A, 
    NicMatrix<float>& B, NicMatrix<float>& C, bool transposeB );
template void multiplySimple<float>( NicMatrix<float>& A, 
    NicMatrix<float>& B, NicMatrix<float>& C, bool transposeA,
    bool transposeB );
#endif

#endif
// MATRIXOPERATIONS_CPP_UNIVERSITY_OF_OREGON_NIC
