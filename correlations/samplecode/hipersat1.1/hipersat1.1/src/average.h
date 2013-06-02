#ifndef AVERAGE_H_UNIVERSITY_OF_OREGON_NIC
#define AVERAGE_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>

#include "NicMatrix.h"
#include "NicVector.h"

#include "MPIWrapper.h"

// average all of the channels of d and return the result in a
template <class T>
void average( NicMatrix<T>* d, NicVector<T>* a );

#endif
// AVERAGE_H_UNIVERSITY_OF_OREGON_NIC
