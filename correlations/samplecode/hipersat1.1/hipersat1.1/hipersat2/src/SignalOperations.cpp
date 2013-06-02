#include "SignalOperations.h"
#include "BlasLapack.h"
#include <iostream>

template <class T> void average(NicMatrix<T>* input, NicMatrix<T>* average)
{
    T* data = input->data();
    T* avg = average->data();
    T* dataLocation = NULL;
    int channels = input->rows();
    int samples = input->columns();
    T denominator = 1/((T)(samples));
    
    
    for (int i = 0; i < samples; ++i)
    {
        avg = average->data();
        
        for (int j = 0; j < channels; ++j)
        {
            *avg += *data;
            ++avg;
            ++data;
        }
    }
    
    avg = average->data();
    for (int i = 0; i < channels; ++i, ++avg)
    {
        *avg *= denominator;
    }
}

template <class T> void center(NicMatrix<T>* input, NicMatrix<T>* average)
{
    T* data = input->data();
    T* avg = average->data();
    int channels = input->rows();
    int samples = input->columns();
    
    for (int i = 0; i < samples; ++i)
    {
        avg = average->data();
        for (int j = 0; j < channels; ++j)
        {
            *data -= *avg;
            ++avg;
            ++data;
        }
    }
}

template <class T> void covariance(NicMatrix<T>* input, NicMatrix<T>* avg, NicMatrix<T>* cov, bool computeAverage, bool centered)
{
    // compute the average and center the data if necessary
    if (computeAverage)
    {
        average<T>(input, avg);
    }
    if (!centered)
    {
        center(input, avg);
    }
    
    int rows = input->rows();
    int cols = input->columns();
    
    // computes the covariance
    for (int i = 0; i < rows; ++i)
    {
        for (int j = i; j < rows; ++j) // start at i because cov is symmetric
        {
            T value = 0;
            for (int k = 0; k < cols; ++k)
            {
                value += (*input)(i,k)*(*input)(j,k);
            }
            value /= (T)(cols-1);
            (*cov)(i,j) = value;
            (*cov)(j,i) = value;
        }
    }
    
    // undo the centering if necessary
    if (!centered)
    {
        // flip the values on the average
        for (int i = 0; i < avg->size(); ++i)
        {
            (*avg)(i) *= -1;
        }
        center(input, avg); // this reverses the original center command
        for (int i = 0; i < avg->size(); ++i) // flip them back...
        {
            (*avg)(i) *= -1;
        }
    }
}

// eigenvectors are stored as columns
// input is assumed to be a symmetric matrix
template <typename T> void eigenvalues(NicMatrix<T>* input, NicMatrix<T>* eigenvals, NicMatrix<T>* eigenvectors)
{
    //  configure_eigenstuff(cov, lambda);
    T* eig_work_space;
    *eigenvectors = *input;
    int info  = 0;
    int n = input->rows();
    T ws[2];
    int ldz = n;
    int lwork = -1;

    // lwork == -1 => dsyev loads size of work space into lwork[0]
    // q and lambda are unchanged, yeah right!!

    // we need to address this!
    tsyev<T>("V", "L", &n, eigenvectors->data(), &ldz, eigenvals->data(), ws, &lwork, &info);

    int size = (int)ws[0];

    // allocate work space
    eig_work_space = new T[size];
    for ( int i = 0; i < size; ++i ) eig_work_space[i] = 0;

    // with 
    lwork = size;

    tsyev<T>("V", "L", &n, eigenvectors->data(), &ldz, eigenvals->data(), eig_work_space, &lwork, &info);

    if (info < 0) 
    {
        std::cerr << "ERROR: eigenvalue decomposition had illegal value on ";
        std::cerr << -info << std::endl;
        exit(-15);
    } else if (info > 0) 
    {
        std::cerr << "ERROR: eigenvalue decomposition failed on " << info;
        std::cerr << " diagonal element" << std::endl;
        exit(-16);
    }
}

template <class T> void sphering(NicMatrix<T>* input, NicMatrix<T>* spheringMatrix, bool useInfomax)
{
    
}

template void average<double>(NicMatrix<double>* input, NicMatrix<double>* average);
template void average<float>(NicMatrix<float>* input, NicMatrix<float>* average);
template void center<double>(NicMatrix<double>* input, NicMatrix<double>* average);
template void center<float>(NicMatrix<float>* input, NicMatrix<float>* average);
template void covariance<double>(NicMatrix<double>*, NicMatrix<double>*, NicMatrix<double>*, bool, bool);
template void covariance<float>(NicMatrix<float>*, NicMatrix<float>*, NicMatrix<float>*, bool, bool);
template void eigenvalues(NicMatrix<double>* input, NicMatrix<double>* eigenvect, NicMatrix<double>* eigenvals);
template <class T> void eigenvalues(NicMatrix<float>* input, NicMatrix<float>* eigenvect, NicMatrix<float>* eigenvals);
template void sphering(NicMatrix<double>* input, NicMatrix<double>* spheringMatrix, bool useInfomax);
template void sphering(NicMatrix<float>* input, NicMatrix<float>* spheringMatrix, bool useInfomax);
