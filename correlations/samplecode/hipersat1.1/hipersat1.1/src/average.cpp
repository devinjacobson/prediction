#ifndef AVERAGE__UNIVERSITY_OF_OREGON_NIC
#define AVERAGE__UNIVERSITY_OF_OREGON_NIC

#include "average.h"

template <class T>
void average(NicMatrix<T>* d, NicVector<T>* a) 
{
    T* data = d->data;
    T* avg = a->data;

    T* d_ptr = NULL;
    T* a_ptr = NULL;

    int ch = d->rows;
    int obs = d->columns;
    int size = d->size;

    // multiply is faster than divide, so divide once and multiply many times
    // premature optimization...
    T n = 1/((T)(obs));

    for (int i = 0; i < obs; i++) 
    {
        d_ptr = data + i * ch;
        a_ptr = avg;

        for (int j = 0; j < ch; j++) 
        {
            *a_ptr += d_ptr[j];
            ++a_ptr;
        }
    }

    for (int i = 0; i < ch; i++) 
    {
        avg[i] *= n;
    }
}

#ifdef INSTANTIATE_TEMPLATES
template void average<double>( NicMatrix<double>* d, NicVector<double>* a );
template void average<float>( NicMatrix<float>* d, NicVector<float>* a );
#endif

#endif
// AVERAGE__UNIVERSITY_OF_OREGON_NIC
