#ifndef SOBI_H_UNIVERSITY_OF_OREGON_NIC
#define SOBI_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include <vector>

// This should be wrapped up into a class to hide the helper methods
// and keep them from polluting the namespace

// dataMatrix: m x n
// tau: vector of time lags
// W: output estimate of the inverse of the mixing matrix
template <class T>
void computeSobi( NicMatrix<T>& dataMatrix, int* tau, int& tauLength, NicMatrix<T>& W, T tol = 1e-6 );

// helper monkeys
template <class T>
void computeStdCov( NicMatrix<T>& dataMatrix, int tau, NicMatrix<T>& covX, 
    int first );

template <class T>
T frobeniusNorm( T* matrix, int size );

template <class T>
void computeRjd( NicMatrix<T>& A, NicMatrix<T>& W, T tolerance );

int* makeTau( const std::vector<int> vals );

#endif
// SOBI_H_UNIVERSITY_OF_OREGON_NIC
