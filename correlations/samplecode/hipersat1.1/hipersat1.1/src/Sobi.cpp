#ifndef SOBI_CPP_UNIVERSITY_OF_OREGON_NIC
#define SOBI_CPP_UNIVERSITY_OF_OREGON_NIC

#include "Sobi.h"
#include "MatrixOperations.h"
#include "NicVector.h"
#include <math.h>

#ifdef __OPENMP_
#include "omp.h"
#endif

// dataMatrix: m x n
// tau: vector of time lags, it is ok if this vector is of length 0
// W: output estimate of the inverse of the mixing matrix
template <class T>
void computeSobi( NicMatrix<T>& dataMatrix, int* tau, int& tauLength, 
    NicMatrix<T>& W, T tol )
{
    std::cout << "computeSobi" << std::endl;
    int rows = dataMatrix.rows;
    int columns = dataMatrix.columns;

    T tolerance = tol;

    // create the tau vector
    if ( 0 == tauLength || tau == 0 )
    {
        tauLength = columns / 3;
        if ( (columns % 3) > 0 ) ++tauLength;
        if ( tauLength > 100 ) tauLength = 100;
        tau = new int[ tauLength ];
        for ( int i = 0; i < tauLength; ++i )
        {
            tau[ i ] = ( i+1 );
        }
    }

    NicMatrix<T> covX( rows, tauLength * rows );

    int i = 0;
#pragma omp parallel for private( i ) schedule( runtime )
    for ( i = 0; i < tauLength; ++i )
    {
        int first = i * rows;
        computeStdCov( dataMatrix, tau[i], covX, first );
    }
    std::cout << std::endl;

    // joint diagonalization
    computeRjd( covX, W, tolerance );
}

template <class T>
void computeStdCov( NicMatrix<T>& dataMatrix, int tau, 
    NicMatrix<T>& covX, int first )
{
    std::cout << tau << " " << std::flush;
    int m = dataMatrix.rows;
    int columns = dataMatrix.columns;
    int n = m;
    int k = columns - tau;
    T alpha = 1.0 / (T)(k);
    T beta = 0.0;
    T* A;
    T* B;
    T* C;
    A = dataMatrix.data + (tau * m);
    B = dataMatrix.data;
    C = covX.data + (first * m);
    char tA = 'N';
    char tB = 'T';

    parallelTgemm<T>( &tA, &tB, &m, &m, &k, &alpha, A, &m, B, &m, &beta, C, &m );

    T norm = frobeniusNorm( C, m );
    for ( int i = 0; i < m * m; ++i )
    {
        (*C) *= norm;
        ++C;
    }
}

template <class T>
T frobeniusNorm( T* matrix, int size )
{
    T norm = 0.0;
    int length = size * size;
    for ( int i = 0; i < length; ++i )
    {
        norm += (*matrix) * (*matrix);
        ++matrix;
    }
    norm = sqrt( norm );
    return norm;
}

// A is a m x nm matrix
template <class T>
void computeRjd( NicMatrix<T>& A, NicMatrix<T>& W, T tolerance )
{
    std::cout << "computeRjd" << std::endl;
//    T tolerance = 1e-8;

    int rows = A.rows;
    int columns = A.columns / A.rows;
    assert( ( rows * columns ) == A.columns );

    W.resize( rows, rows );
    W.identity_matrix();

    bool encore = true;
    // g is a temp variable
    // G is the givens rotation
    NicMatrix<T> g( 2, columns );
    NicMatrix<T> G( 2, 2 );

    // p and q Matrices
    NicMatrix<T> Mp( rows, columns );
    NicMatrix<T> Mq( rows, columns );

    // p and q Rows
    NicVector<T> Rp( A.columns );
    NicVector<T> Rq( A.columns );

    // wTemp
    NicVector<T> Wtemp( rows );
    
    T ton;
    T toff;
    T theta;
    T c,s;
    int iteration = 0;
    int i = 0;
    int j = 0;
    int p = 0;
    int q = 0;
#pragma omp parallel private( q, p ) default( shared )
    {
    while ( encore )
    {
#pragma omp barrier
#pragma omp master
        {
        ++iteration;
        std::cout << "Iteration " << iteration << " convergence: " << std::flush;
        encore = false;
        }

        for ( p = 0; p < rows-1; ++p ) // loop p from 1 to rows - 1
        {
            for ( q = p+1; q < rows; ++q ) // loop q from p to rows
            {
                // compute the Givens rotation // parallel
#pragma omp for private( j ) schedule( runtime )
                for ( j = 0; j < columns; ++j )
                {
                    g( 0, j ) = A( p, p + (rows * j)) - A( q, q + (rows * j));
                    g( 1, j ) = A( p, q + (rows * j)) + A( q, p + (rows * j));
                }
#pragma omp master
                {
                    multiply( g, g, G, false, true );
                    ton = G(0,0) - G(1,1);
                    toff = G(0,1) + G(1,0);
                    T dist = sqrt( (ton*ton) + (toff*toff) );
                    theta = 0.5 * atan2( toff, ton  + dist );
                    c = cos( theta );
                    s = sin( theta );
                    encore = encore || ( fabs( s ) > tolerance );
                }
#pragma omp barrier

                // update A and W
                if ( fabs( s ) > tolerance )
                {

                    // initialize Mp and Mq
#pragma omp for private( i, j ) schedule( runtime )
                    for ( i = 0; i < rows; ++i ) // parallel
                    {
                        for ( j = 0; j < columns; ++j )
                        {
                            Mp( i, j ) = A( i, p + (rows * j));
                            Mq( i, j ) = A( i, q + (rows * j));
                        }
                    }

                    // first A update, this can be a point of optimization
#pragma omp for private( i, j ) schedule( runtime )
                    for ( i = 0; i < rows; ++i ) // parallel
                    {
                        for ( int j = 0; j < columns; ++j )
                        {
                            A( i, p + (rows * j)) = c * Mp(i,j) + s * Mq(i,j);
                            A( i, q + (rows * j)) = c * Mq(i,j) - s * Mp(i,j);
                        }
                    }

                    // initialize Rp and Rq
#pragma omp for private( i ) schedule( runtime )
                    for ( i = 0; i < A.columns; ++i ) // parallel
                    {
                        Rp(i) = A( p, i );
                        Rq(i) = A( q, i );
                    }

                    // second A update
#pragma omp for private( i ) schedule( runtime )
                    for ( i = 0; i < A.columns; ++i ) // parallel
                    {
                        A(p,i) = c * Rp(i) + s * Rq(i);
                        A(q,i) = c * Rq(i) - s * Rp(i);
                    }

                    // initialize Wtemp // parallel
#pragma omp for private( i ) schedule( runtime )
                    for ( i = 0; i < rows; ++i )
                    {
                        Wtemp(i) = W(p, i);
                    }

                    // update W // parallel
#pragma omp for private( i ) schedule( runtime )
                    for ( i = 0; i < rows; ++i )
                    {
                        W(p,i) = c*W(p,i) + s*W(q,i);
                        W(q,i) = c*W(q,i) - s*Wtemp(i);
                    }
                }
#pragma omp barrier
            }
//            std::cout << omp_get_thread_num() << std::flush;
#pragma omp barrier
        }
#pragma omp barrier
#pragma omp master
        std::cout << fabs(s) << std::endl;
    }
    }
}

int* makeTau( const std::vector<int> vals )
{
    int size = vals.size();
    if ( size == 0 ) return 0;
    int* rtn = new int[ size ];
    for ( int i = 0; i < size; ++i )
    {
        rtn[i] = vals[i];
    }
    return rtn;
}

#ifdef INSTANTIATE_TEMPLATES
template void computeSobi<double>( NicMatrix<double>& dataMatrix, int* tau, int& tauLength, NicMatrix<double>& W, double tol );
template void computeStdCov<double>( NicMatrix<double>& dataMatrix, int tau, NicMatrix<double>& covX, 
    int first );
template double frobeniusNorm<double>( double* matrix, int size );
template void computeRjd<double>( NicMatrix<double>& A, NicMatrix<double>& W, double tolerance );

template void computeSobi<float>( NicMatrix<float>& dataMatrix, int* tau, int& tauLength, NicMatrix<float>& W, float tol );
template void computeStdCov<float>( NicMatrix<float>& dataMatrix, int tau, NicMatrix<float>& covX, 
    int first );
template float frobeniusNorm<float>( float* matrix, int size );
template void computeRjd<float>( NicMatrix<float>& A, NicMatrix<float>& W, float tolerance );
#endif


#endif
// SOBI_CPP_UNIVERSITY_OF_OREGON_NIC
