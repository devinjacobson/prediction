#ifndef COVARIANCE_CPP_UNIVERSITY_OF_OREGON_NIC
#define COVARIANCE_CPP_UNIVERSITY_OF_OREGON_NIC

#include "covariance.h"

#include <iostream>
using namespace std;

// we should fix this computation
#undef __DISTRIBUTED

template <class T>
void
covariance(NicMatrix<T>* data_, 
	   NicMatrix<T>* cov_,
	   NicVector<T>* avg_)
{
    T* data = data_->data;
    T* avg = avg_->data;
    T* cov = cov_->data;

    T* d_ptr = NULL;
    T* a_ptr = NULL;
    T* c_ptr = NULL;

    int ch = data_->rows;
    int obs = data_->columns;
    int size = cov_->size;


    int total_obs = obs;
    #ifdef __DISTRIBUTED
    total_obs = data_->total_columns;
    #endif

    T recip_n = 1./((T)total_obs);
    T recip_n_1 = 1./((T)total_obs - 1.);

    #ifdef __DISTRIBUTED
    NicMatrix<T> cov_temp(cov_->rows, cov_->columns);
    NicVector<T> avg_temp(avg_->n);
    #endif

    for (int i = 0; i < obs; i++) 
    {
        d_ptr = data + i * ch;

        for (int j = 0; j < ch; j++) 
        {
            avg[j] += d_ptr[j];
            for (int k = j; k < ch; k++) 
            {
	            *(cov + k + j * ch) += d_ptr[j] * d_ptr[k];
            }
        }
    } // finish data load

    #ifdef DEBUGCODE
    T cov_check[ch*ch];

    for(int j=0;j<ch;j++) 
    {
        for(int k=0; k<ch; k++) 
        {
            cov_check[k+j*ch] = *(cov + k + j*ch); 
        }
    }
    #endif

    #ifdef __DISTRIBUTED
    // In the distributed implementation, each processor has a partial
    // set of the sums and sums squared, they need to be accumulated
    // across all processors

    MPI_Allreduce(avg_->data, avg_temp.data, 
        ch, TypeIdentifier<T>::Type(), MPI_SUM, MPI_COMM_WORLD);
    MPI_Allreduce(cov_->data, cov_temp.data, 
        size, TypeIdentifier<T>::Type(), MPI_SUM, MPI_COMM_WORLD);

    cov_->swap_matrices(&cov_temp);
    avg_->swap_vectors(&avg_temp);

    cov = cov_->data;
    avg = avg_->data;

    // at this point, all processors have the total sum and sums of sqs
    #endif

    #ifdef DEBUGCODE
    cout<<"Are They Equal ? ";
    for(int j=0;j<ch;j++) 
    {
        for(int k=0; k<ch; k++) 
        {
		    cout<<(cov_check[k+j*ch]==cov[k+j*ch])<<" ";
	    }		
    }
    cout<<"\n";

    cout<<"Arbit Var : "<<recip_n_1<<" "<<recip_n<<"\n";
    #endif

    for (int j = 0; j < ch; j++) 
    {
        for (int k = j; k < ch; k++) 
        {
            *(cov + k + j * ch) -= avg[j] * avg[k] * recip_n;
            *(cov + j + k * ch) = *(cov + k * ch + j );
        }
    }

    for (int j = 0; j < ch; j++) 
    {
        avg[j] *= recip_n;
        for (int k = j; k < ch; k++) 
        {
            *(cov + k + j * ch) *= recip_n;
            *(cov + j + k * ch) = *(cov + k + j * ch);
        }
    }

    for (int i = 0; i < ch; i++) 
    {
        avg[i] *= recip_n;
    }

}

#ifdef INSTANTIATE_TEMPLATES
template void covariance<double>( NicMatrix<double>* data_,
    NicMatrix<double>* cov_, NicVector<double>* avg );
template void covariance<float>( NicMatrix<float>* data_,
    NicMatrix<float>* cov_, NicVector<float>* avg );
#endif


#endif
// COVARIANCE_CPP_UNIVERSITY_OF_OREGON_NIC
