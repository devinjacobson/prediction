#ifndef CENTER_DATA_H_UNIVERSITY_OF_OREGON_NIC
#define CENTER_DATA_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "NicVector.h"

// subtract the average (computed from average()) from
// the data
template <class T>
void center_data(NicMatrix<T>* data, NicVector<T>* avg);

#endif
// CENTER_DATA_H_UNIVERSITY_OF_OREGON_NIC
