#ifndef CENTER_DATA__UNIVERSITY_OF_OREGON_NIC
#define CENTER_DATA__UNIVERSITY_OF_OREGON_NIC

#include "center_data.h"

template <class T>
void center_data(NicMatrix<T>* data, NicVector<T>* avg) 
{
    T* d_ptr = data->data;
    T* a_    = avg->data;
    T* a_ptr = NULL;
    int n_observations = data->columns;
    int n_channels = data->rows;

    // start shared memory block
    // unroll this loop

    for (int i = 0; i < n_observations; i++) 
    {
        d_ptr = data->data + (i * n_channels);
        a_ptr = a_;
        for (int j = 0; j < n_channels; j++) 
        {
            *d_ptr -= *a_ptr;
            ++d_ptr; 
            ++a_ptr;
        }
    }

    // end shared memory block
}

#ifdef INSTANTIATE_TEMPLATES
template void center_data<double>( NicMatrix<double>* data, 
    NicVector<double>* avg );
template void center_data<float>( NicMatrix<float>* data, 
    NicVector<float>* avg );
#endif

#endif
// CENTER_DATA__UNIVERSITY_OF_OREGON_NIC
