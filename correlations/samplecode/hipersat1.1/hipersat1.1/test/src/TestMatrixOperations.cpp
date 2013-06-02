
// we're loading the source in directly so we don't have to build
// the object files
#include "nic_matrix.h"
#include "nic_vector.h"
#include "MersenneTwister.h"
#include "MatrixOperations.h"

#include <math.h>
#include <sys/time.h>

#include <iostream>

#include <algorithm>

bool test( int m, int k, int n, bool transA, bool transB )
{
    MersenneTwister rng( n + k + m );
    int aRows = transA ? k : m;
    int aCols = transA ? m : k;

    int bRows = transB ? n : k;
    int bCols = transB ? k : n;

    nic_matrix A( aRows, aCols );
    nic_matrix B( bRows, bCols );

    nic_matrix C( m, n );
    nic_matrix D( m, n );
    
    

    for ( int i = 0; i < aRows; ++i )
    {
        for ( int j = 0; j < aCols; ++j )
        {
            A(i,j) = rng.rand_double_closed( -1, 1 );
        }
    }

    for ( int i = 0; i < bRows; ++i )
    {
        for ( int j = 0; j < bCols; ++j )
        {
            B(i,j) = rng.rand_double_closed( -1, 1 );
        }
    }

    int tick, tock;
    multiply( A, B, C, transA, transB );
    multiplySimple( A, B, D, transA, transB );

    for ( int i = 0; i < m; ++i )
    {
        for ( int j = 0; j < n; ++j )
        {
            assert( fabs( C(i,j) - D(i,j) ) < 0.00001 );
        }
    }

    return true;
}

bool testTime( int m, int k, int n, bool transA, bool transB )
{
    MersenneTwister rng( n + k + m );
    int aRows = transA ? k : m;
    int aCols = transA ? m : k;

    int bRows = transB ? n : k;
    int bCols = transB ? k : n;

    nic_matrix A( aRows, aCols );
    nic_matrix B( bRows, bCols );

    nic_matrix C( m, n );

    for ( int i = 0; i < aRows; ++i )
    {
        for ( int j = 0; j < aCols; ++j )
        {
            A(i,j) = rng.rand_double_closed( -1, 1 );
        }
    }

    for ( int i = 0; i < bRows; ++i )
    {
        for ( int j = 0; j < bCols; ++j )
        {
            B(i,j) = rng.rand_double_closed( -1, 1 );
        }
    }

    double tick, tock;
    timeval tim;
    gettimeofday( &tim, NULL );
    tick = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    multiply( A, B, C, transA, transB );
    gettimeofday( &tim, NULL );
    tock = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    std::cout << "A" << ( transA ? "'" : " " ) 
        << " * B" << (transB ? "'" : " " ) 
        << " time: " << tock-tick << std::endl;;
    return true;
}

void testDiag( int rows, int columns, bool transposeB )
{
    nic_matrix A(rows, rows);
    nic_vector a(rows);
    nic_matrix B( 
        (transposeB ? columns:rows), (transposeB ? rows: columns));
    nic_matrix C(rows, columns);
    nic_matrix D(rows, columns);

    MersenneTwister rng( rows * columns );

    for ( int i = 0; i < rows; ++i )
    {
        a(i) = rng.rand_double_closed( -1, 1 );
        A(i,i) = a(i);
        for ( int j = 0; j < columns; ++j )
        {
            B((transposeB? j:i),(transposeB? i:j) ) = rng.rand_double_closed( -1, 1 );
        }
    }

    multiplySimple( A, B, C, false, transposeB );
    multiplyAdiag( a, B, D, transposeB );

    for ( int i = 0; i < rows; ++i )
    {
        for ( int j = 0; j < columns; ++j )
        {
            assert( fabs(C(i,j) - D(i,j)) < 0.0001 );
        }
    }

}

bool testTimeDiag( int rows, int columns, bool transposeB )
{
    MersenneTwister rng( rows * columns );

    nic_matrix A(rows, rows);
    nic_vector a(rows);
    nic_matrix B( 
        (transposeB ? columns:rows), (transposeB ? rows: columns));
    nic_matrix C(rows, columns);

    for ( int i = 0; i < rows; ++i )
    {
        a(i) = rng.rand_double_closed( -1, 1 );
        A(i,i) = a(i);
        for ( int j = 0; j < columns; ++j )
        {
            B((transposeB? j:i),(transposeB? i:j) ) = rng.rand_double_closed( -1, 1 );
        }
    }

    double tick, tock;
    timeval tim;
    gettimeofday( &tim, NULL );
    tick = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    multiplyAdiag( a, B, C, transposeB );
    gettimeofday( &tim, NULL );
    tock = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    std::cout << "optimized time:"<< tock-tick <<  " ";

    gettimeofday( &tim, NULL );
    tock = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    multiply( A, B, C, false, transposeB );
    gettimeofday( &tim, NULL );
    tick = tim.tv_sec + ( tim.tv_usec/1000000.0 );
    std::cout << "standard time:" << tick-tock <<  std::endl;

    return true;
}

void testAB( int m, int n, bool transposeA )
{
    nic_matrix A( m, m );
    nic_matrix B( m, n );
    nic_matrix C( m, n );

    MersenneTwister rng( m * n );

    for ( int i = 0; i < m; ++i )
    {
        for ( int j = 0; j < m; ++j )
        {
            A(i,j) = rng.rand_double_closed( -1, 1 );
        }
        for ( int j = 0; j < n; ++j )
        {
            B(i,j) = rng.rand_double_closed( -1, 1 );
        }
    }

    multiplySimple( A, B, C, transposeA, false );

    multiply( A, B, transposeA );

    for ( int i = 0; i < m; ++i )
    {
        for ( int j = 0; j < n; ++j )
        {
//            cout << B(i,j) << " " << C(i,j) << " " << fabs( B(i,j) - C(i,j) )<< endl;
            assert( fabs(B(i,j) - C(i,j)) < 1e-6 );
        }
    }
}


int main( int argc, char** argv )
{
    int rank;

    test( 22, 29, 37, false, false );
    std::cout << "A*B passed" << std::endl;
    test( 23, 29, 37, false, true );
    std::cout << "A*B' passed" << std::endl;
    test( 23, 28, 37, true, false );
    std::cout << "A'*B passed" << std::endl;
    test( 23, 39, 37, true, true );
    std::cout << "A'*B' passed" << std::endl;

    testDiag( 23, 45, false );
    std::cout << "Adiag * B passed" << std::endl;
    testDiag( 23, 45, true );
    std::cout << "Adiag * B' passed" << std::endl;

    testAB( 23, 29, false );
    std::cout << "B = AB passed" << std::endl;
    testAB( 27, 41, true );
    std::cout << "B = A'B passed" << std::endl;

    testTime( 2000, 2001, 1999, false, false );
    testTime( 2000, 2001, 1999, false, true );
    testTime( 2000, 2001, 1999, true, false );
    testTime( 2000, 2001, 1999, true, true );
    
    testTimeDiag( 2300, 4500, false );
    testTimeDiag( 2300, 4500, true );

    return 0;
}
