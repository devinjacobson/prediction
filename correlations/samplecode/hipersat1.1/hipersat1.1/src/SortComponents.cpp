#ifndef SORTCOMPONENTS_CPP_UNIVERSITY_OF_OREGON_NIC
#define SORTCOMPONENTS_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SortComponents.h"
#include "MatrixOperations.h"

#include <algorithm>
#include <vector>

using namespace std;

template <class T>
bool comparePair( pair< int, T > l, pair< int, T > r )
{
    return l.second > r.second;
}

template <class T>
void sortComponents( NicMatrix<T>& data, NicMatrix<T>& w, NicMatrix<T>& s )
{
    vector< pair< int, T > > meanVariances;

    NicMatrix<T> tempS = s;
    multiply( w, tempS );

    NicMatrix<T> wInv( w.rows, w.columns );
    invert<T>( tempS, wInv );


    // compute the mean variances of the projected data
    for ( int k = 0; k < data.rows; ++k )
    {
        T mean = 0;
        for ( int i = 0; i < data.columns; ++i )
        {
            T variance = 0.0;
            for ( int j = 0; j < data.rows; ++j )
            {
                variance += wInv( j, k ) * wInv(j, k ) * data( j, i ) * data(j, i );
            }
            mean += variance;
        }
        pair< int, T > result( k, mean );
        meanVariances.push_back( result );
    }

    sort( meanVariances.begin(), meanVariances.end(), comparePair<T> );

    vector< int > ordering( data.rows );
    for ( int i = 0; i < data.rows; ++i )
    {
        ordering[i] = i;
    }

    T temp;
    int tempInt;

    for ( int i = 0; i < data.rows; ++i )
    {
        // find the location of the vector to move
        int toMove = meanVariances[i].first;
        int location = toMove;
        while ( toMove != ordering[ location ] )
        {
            location = ordering[ location ];
        }

        if ( i != location )
        {
            // now we swap i row with location row
            for ( int j = 0; j < data.columns; ++j )
            {
                temp = data( location, j );
                data( location, j ) = data( i, j );
                data( i, j ) = temp;
            }
            for ( int j = 0; j < data.rows; ++j )
            {
                temp = w( location, j );
                w( location, j ) = w( i, j );
                w( i, j ) = temp;
            }
            tempInt = ordering[ location ];
            ordering[ location ] = ordering[ i ];
            ordering[ i ] = tempInt;
        }
    }
}

#ifdef INSTANTIATE_TEMPLATES
template void sortComponents<double>( NicMatrix<double>& data, 
    NicMatrix<double>& w, NicMatrix<double>& s );
template void sortComponents<float>( NicMatrix<float>& data, 
    NicMatrix<float>& w, NicMatrix<float>& s );

template bool comparePair<double>( pair< int, double > l, 
    pair< int, double > r );
template bool comparePair<float>( pair< int, float > l, 
    pair< int, float > r );
#endif

#endif
// SORTCOMPONENTS_CPP_UNIVERSITY_OF_OREGON_NIC
