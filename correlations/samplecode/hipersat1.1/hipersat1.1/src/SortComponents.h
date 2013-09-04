#ifndef SORTCOMPONENTS_H_UNIVERSITY_OF_OREGON_NIC
#define SORTCOMPONENTS_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"

// a method to shuffle the rows of the mixing matrix
// so that the resulting unmixed data channels are
// sorted in descending order (measured by the norm 
// of the channel)
template <class T>
void sortComponents( NicMatrix<T>& data, NicMatrix<T>& w, NicMatrix<T>& s );

#endif
// SORTCOMPONENTS_H_UNIVERSITY_OF_OREGON_NIC
