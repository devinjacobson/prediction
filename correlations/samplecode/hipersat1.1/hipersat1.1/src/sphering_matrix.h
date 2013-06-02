#ifndef SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC
#define SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC

#include "LAPACKWrapper.h"

#include <iostream>

#include <cmath>

#include "NicMatrix.h"
#include "NicVector.h"

// this method assumes that the data has been centered
template <class T>
void computeSpheringMatrix( 
    NicMatrix<T>* centeredData,  
    NicMatrix<T>* spheringMatrix,
    bool useInfomax ); 

// this interface will be deprecated
template <class T>
void 
compute_sphering(NicMatrix<T>* cov, NicMatrix<T>* sph, 
			     NicMatrix<T>* q, NicVector<T>* lambda,
			     bool useInfomaxSphering );

#endif
// SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC
