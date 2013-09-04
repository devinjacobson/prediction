#include "NicMatrix.h"

template <class T> void average(NicMatrix<T>* input, NicMatrix<T>* average);
template <class T> void center(NicMatrix<T>* input, NicMatrix<T>* average);
template <class T> void covariance(NicMatrix<T>* input, NicMatrix<T>* average, NicMatrix<T>* cov,  bool computeAverage = true, bool centered = false);
template <class T> void eigenvalues(NicMatrix<T>* input, NicMatrix<T>* eigenvals, NicMatrix<T>* eigenvect);
template <class T> void sphering(NicMatrix<T>* input, NicMatrix<T>* spheringMatrix, bool useInfomax);
