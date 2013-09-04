#ifndef SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC
#define SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC

#include "sphering_matrix.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "MatrixOperations.h"
#include "eigenstuff.h"
#include "LAPACKWrapper.h"
#include "covariance.h"
#include "center_data.h"
#include "average.h"

#include <algorithm>

#ifdef __OPENMP_
#include "omp.h"
#endif

#include <math.h>

#include <iostream> // for debugging

using namespace std;

// this method assumes that the data has been centered
template <class T>
void computeSpheringMatrix( 
    NicMatrix<T>* centeredData, 
    NicMatrix<T>* spheringMatrix,
    bool useInfomax )
{
    int rows = centeredData->rows;
    NicMatrix<T> covrnce( rows, rows );
    NicVector<T> averageRows( rows );

    covariance<T>( centeredData, &covrnce, &averageRows );

    // compute the eigenvalues and eigenvectors = V
    NicMatrix<T> eigenvectors( rows, rows );
    NicVector<T> eigenvalues( rows );

    eigenvectors = covrnce; // make a copy of the data to be analyzed
    compute_eigenstuff( &eigenvectors, &eigenvalues );

    // compute lambda^(-1/2) = l
    bool lessThanZero = false;
    for ( int i = 0; i < eigenvalues.n; ++i )
    {
        if ( !(eigenvalues.data[i] > 0 ) )
        {
            lessThanZero = true;
            eigenvalues.data[i] = 0.0000001;
        }
        eigenvalues.data[i] = 1.0/sqrt(eigenvalues.data[i]);
        if ( useInfomax )
        {
            eigenvalues.data[i] *= 2;
        }
    }
    if ( lessThanZero )
    {
        std::cerr << "In computeSpheringMatrix:" << std::endl;
        std::cerr << "Warning! One or more eigenvalues was less than or equal to zero." << std::endl;
        std::cerr << "Those values were set to 10^-7. Results may be invalid." << std::endl;
    }

    // compute l * V'
    bool transpose = true;
    multiplyAdiag( eigenvalues, eigenvectors, *spheringMatrix, transpose );

    // Infomax does additional computation; 2*V*l*V'
    if ( useInfomax )
    {
        NicMatrix<T> infomaxSphering( rows, rows ); // = new NicMatrix<>( rows, rows );
        multiply( eigenvectors, *spheringMatrix, infomaxSphering );
        (*spheringMatrix) = infomaxSphering;
    }
}

template <class T>
void 
compute_sphering(NicMatrix<T>* cov, NicMatrix<T> * sph, 
			     NicMatrix<T>* q, NicVector<T>* lambda,
			     bool useInfomaxSphering )
{
    int n = cov->rows;
    T* d = NULL;

    // compute eigenstuff

    // this operation performs a deep copy of the matrix
    *q = *cov;

    compute_eigenstuff<T>( q, lambda );

    // compute lambda -1/2
    d = lambda->data;
    for (int i = 0; i < n; i++) 
    {
        d[i] = 1/sqrt(d[i]);
    }


    // compute sphering matrix S = L^{-1/2} Q^T
    T* 	l = lambda->data;
    T* 	s = sph->data;
    T* 	q_ = q->data;

    T* q_ptr = q_;


    for (int i = 0; i < n; i++) 
    {
        q_ptr = q_ + i;
        for (int j = 0; j < n; j++) 
        {
            *s++ = *q_ptr * l[j];
            q_ptr += n;
        }
    }

	if ( useInfomaxSphering )
	{
		//
		//	The Infomax sphering algorithm is different from that used by FastICA.
		//
		//	Infomax creates the sph matrix as:
		//		xxx = sqrtm( yyy )
		//
		//	Whereas FastICA computes it as:
		//		www = ????
		//
		
		//
		//	At this point, we have computed S = 
		
	    //	cerr << endl << "Using Infomax sphering..." << endl;
		
		T alpha = 2.0;
		T beta = 0.0;

  		NicMatrix<T>* 	tmpSph = new NicMatrix<T>( *sph );
		
		s = sph->data;

		parallelTgemm<T>( "N", "N", &n, &n, &n, &alpha, 
            q_, &n, tmpSph->data, &n, &beta, s, &n );
		
		delete tmpSph;
    }
	
    //Infomax sph=2*q*(fastica sph).
};

#ifdef INSTANTIATE_TEMPLATES
template void computeSpheringMatrix<double>( NicMatrix<double>* centeredData,
    NicMatrix<double>* spheringMatrix, bool useInfomax ); 
template void compute_sphering<double>(NicMatrix<double>* cov, 
    NicMatrix<double>* sph, NicMatrix<double>* q, NicVector<double>* lambda,
    bool useInfomaxSphering );

template void computeSpheringMatrix<float>( NicMatrix<float>* centeredData,
    NicMatrix<float>* spheringMatrix, bool useInfomax ); 
template void compute_sphering<float>(NicMatrix<float>* cov, 
    NicMatrix<float>* sph, NicMatrix<float>* q, NicVector<float>* lambda,
    bool useInfomaxSphering );

#endif

#endif
// SPHERING_MATRIX_H_UNIVERSITY_OF_OREGON_NIC
