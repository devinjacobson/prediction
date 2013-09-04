#ifndef EIGENSTUFF_H_UNIVERSITY_OF_OREGON_NIC
#define EIGENSTUFF_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>
#include "LAPACKWrapper.h"
#include <cmath>

#include "NicMatrix.h"
#include "NicVector.h"

// compute the eigenvalues of the matrix
template <class T>
void compute_eigenstuff(NicMatrix<T>* q, NicVector<T>* lambda);

#endif
// EIGENSTUFF_H_UNIVERSITY_OF_OREGON_NIC
