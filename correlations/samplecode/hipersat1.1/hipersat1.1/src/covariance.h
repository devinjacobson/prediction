#ifndef COVARIANCE_H_UNIVERSITY_OF_OREGON_NIC
#define COVARIANCE_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "NicVector.h"

#include "MPIWrapper.h"

// compute the average of the data, center the matrix,
// and compute the covariance.
// data_ is input/output
// cov_ is output
// avg_ is output
template <class T>
void
covariance(NicMatrix<T>* data_, 
	   NicMatrix<T>* cov_,
	   NicVector<T>* avg_);

#endif
// COVARIANCE_H_UNIVERSITY_OF_OREGON_NIC
