#ifndef EIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC
#define EIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC

#include "eigenstuff.h"
#include "MatrixOperations.h"

template <class T>
void compute_eigenstuff(NicMatrix<T>* q, NicVector<T>* lambda) 
{
    //  configure_eigenstuff(cov, lambda);
    T* eig_work_space;
    int info  = 0;
    int n = q->rows;
    T ws[2];
    int ldz = n;
    int lwork = -1;

    // lwork == -1 => dsyev loads size of work space into lwork[0]
    // q and lambda are unchanged, yeah right!!


    // we need to address this!
    Tsyev<T>("V", "L", &n, q->data, &ldz, lambda->data, ws, &lwork, &info);

    int size = (int)ws[0];

    // allocate work space
    eig_work_space = new T[size];
    for ( int i = 0; i < size; ++i ) eig_work_space[i] = 0;

    // with 
    lwork = size;

    Tsyev<T>("V", "L", &n, q->data, &ldz, lambda->data, eig_work_space, &lwork, &info);

    if (info < 0) 
    {
        cout << "ERROR: eigenvalue decomposition had illegal value on ";
        cout << -info << endl;
        exit(-15);
    } else if (info > 0) 
    {
        cout << "ERROR: eigenvalue decomposition failed on " << info;
        cout << " diagonal element" << endl;
        exit(-16);
    }
}

#ifdef INSTANTIATE_TEMPLATES
template void compute_eigenstuff<double>(NicMatrix<double>* q, 
    NicVector<double>* lambda);

template void compute_eigenstuff<float>(NicMatrix<float>* q, 
    NicVector<float>* lambda);
#endif


/*******************************************************************************
  Purpose                                                                       
  =======                                                                       
                                                                                
  DSYEV computes all eigenvalues and, optionally, eigenvectors of a             
  real symmetric matrix A.                                                      
                                                                                
  Arguments                                                                     
  =========                                                                     
                                                                                
  JOBZ    (input) CHARACTER*1                                                   
  = 'N':  Compute eigenvalues only;                                             
  = 'V':  Compute eigenvalues and eigenvectors.                                 
                                                                                
  UPLO    (input) CHARACTER*1                                                   
  = 'U':  Upper triangle of A is stored;                                        
  = 'L':  Lower triangle of A is stored.                                        
                                                                                
  N       (input) INTEGER                                                       
  The order of the matrix A.  N >= 0.                                           
                                                                                
  A       (input/output) DOUBLE PRECISION array, dimension (LDA, N)             
  On entry, the symmetric matrix A.  If UPLO = 'U', the                         
  leading N-by-N upper triangular part of A contains the                        
  upper triangular part of the matrix A.  If UPLO = 'L',                        
  the leading N-by-N lower triangular part of A contains                        
  the lower triangular part of the matrix A.                                    
  On exit, if JOBZ = 'V', then if INFO = 0, A contains the                      
  orthonormal eigenvectors of the matrix A.                                     
  If JOBZ = 'N', then on exit the lower triangle (if UPLO='L')                  
  or the upper triangle (if UPLO='U') of A, including the                       
  diagonal, is destroyed.                                                       
                                                                                
  LDA     (input) INTEGER                                                       
  The leading dimension of the array A.  LDA >= max(1,N).                       
                                                                                
  W       (output) DOUBLE PRECISION array, dimension (N)                        
  If INFO = 0, the eigenvalues in ascending order.                              
                                                                                
  WORK    (workspace/output) DOUBLE PRECISION array, dimension (LWORK)          
  On exit, if INFO = 0, WORK(1) returns the optimal LWORK.                      
                                                                                
  LWORK   (input) INTEGER                                                       
  The length of the array WORK.  LWORK >= max(1,3*N-1).                         
  For optimal efficiency, LWORK >= (NB+2)*N,                                    
  where NB is the blocksize for DSYTRD returned by ILAENV.                      
                                                                                
  If LWORK = -1, then a workspace query is assumed; the routine                 
  only calculates the optimal size of the WORK array, returns                   
  this value as the first entry of the WORK array, and no error                 
  message related to LWORK is issued by XERBLA.                                 
                                                                                
  INFO    (output) INTEGER                                                      
  = 0:  successful exit                                                         
  < 0:  if INFO = -i, the i-th argument had an illegal value                    
  > 0:  if INFO = i, the algorithm failed to converge; i                        
  off-diagonal elements of an intermediate tridiagonal                          
  form did not converge to zero.                                                
                                                                                
  ===============================================================================
********************************************************************************/
#endif
// EIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC
