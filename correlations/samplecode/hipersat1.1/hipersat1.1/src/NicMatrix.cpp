#ifndef NICMATRIX_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICMATRIX_CPP_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"

#include <iostream>

template <class T>
NicMatrix<T>::NicMatrix(int r, int c, int t_r, int t_c, 
    int rk, int n_c) 
:   rows(r), columns(c), size(r*c), 
    rank(rk), n_cpus(n_c), total_size(t_c*t_r), total_columns(t_c), 
    total_rows(t_r) , isAlias( false )
{
    referenceCount = 0;
    if (total_rows == 0) total_rows = rows;
    if (total_columns == 0) total_columns = columns;
    if (total_size == 0) total_size = size;

    if (size == 0) 
    {
        data = 0;
    } 
    else 
    {
        data = new T[size];
        T* d = data;
        for ( int i = 0; i < size; ++i ) 
        {
            *d++ = 0;
        }
    }
}

template <class T>
void NicMatrix<T>::resize( int r, int c, int t_r, int t_c, int rk, int n_c )
{
    rows = r;
    columns = c;
    size = r*c;
    rank = rk;
    n_cpus = n_c;

    if ( 0 == t_r ) total_rows = r;
    else total_rows = t_r;

    if ( 0 == t_c ) total_columns = columns;
    else total_columns = t_c;

    if ( data != NULL  && !isAlias ) delete [] data;
    if ( size != 0 )
    {
        data = new T[size];
        isAlias = false;
        T* d = data;
        for ( int i = 0; i < size; ++i )
        {
            *d++ = 0;
        }
    }
}


template <class T>
NicMatrix<T>::NicMatrix(const NicMatrix & m) 
:   rows(m.rows), columns(m.columns), size(m.size),
    rank(m.rank), n_cpus(m.n_cpus), total_columns(m.total_columns),
    total_rows(m.total_rows), total_size(m.total_size)
{
    referenceCount = 0;
    data = new T[size];
    memcpy(data, m.data, sizeof(T) * size);
    isAlias = false;
}

template <class T>
NicMatrix<T>::~NicMatrix()
{
    // this may not be safe
    if ( data != NULL && !isAlias) delete[] data;
}

template <class T>
void
NicMatrix<T>::incrementReferenceCount( NicMatrix* matrix )
{
      ++(matrix->referenceCount);
}

template <class T>
void
NicMatrix<T>::freeReference( NicMatrix* matrix )
{
      --(matrix->referenceCount);
      if ( matrix->referenceCount == 0 )
      {
          delete matrix;
      }
}

template <class T>
void
NicMatrix<T>::zero_matrix() 
{
  T* ptr = data;

  for (int i = 0; i < size; i++) {
    *ptr++ = 0;
  }
}

template <class T>
void
NicMatrix<T>::identity_matrix() 
{
  T* ptr = data;

  if (rows == columns) {
    for (int i = 0; i < size; i++) {
      *ptr++ = 0;
    }
    for (int i = 0; i < rows; i++) {
      *(data + i * rows + i) = 1;
    }
    
  } else {
    cout << "ERROR: (NicMatrix<T>::identity_matrix)-- Matrix must be square" << endl;
    exit(-8);
  }

}

template <class T>
void
NicMatrix<T>::random_matrix(T min, T max) 
{
  T* d = data;
  T delta = max - min;

  for (int i = 0; i < size;  i++) {
    *d++ = (T)(min + delta * rand()/((T)RAND_MAX));
  }
};

template <class T>
void
NicMatrix<T>::constant_matrix(T& v) 
{
  T* ptr = data;

  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < columns; j++) {
      *ptr++ = v;
    }
  }
};

template <class T>
void 
NicMatrix<T>::add_column(NicVector<T>* v_, int i)
{
  T* d = data + i * rows;
  T* v = v_->data;

  for (int i = 0; i < rows; i++)
  {
    *d = *v;
    ++d;
    ++v;
    // *d++ = *v++; cch what's above is much clearer!
  }
}


template <class T>
void
NicMatrix<T>::add_row(NicVector<T>* v_, int i)
{
  T* d = data + i;
  T* v = v_->data;

  for (int i = 0; i < rows; i++)
  {
    *d = *v++;
    d += rows;
  }
}




template <class T>
void 
NicMatrix<T>::add_diagonal(NicVector<T>* v_) 
{
  T* d = data;
  T* v = v_->data;

  for (int i = 0; i < rows; i++) {
    *d = *v++;
    d += rows + 1;
  }
}

template <class T>
void NicMatrix<T>::alias( T* d, int r, int c )
{
    rows = r;
    columns = c;
    total_rows = r;
    total_columns = c;
    size = r * c;
    total_size = size;
    if ( data != 0 && !isAlias )
    {
        delete [] data;
    }
    data = d;
    isAlias = true;
}

template <class T>
void NicMatrix<T>::swap_matrices(NicMatrix * A) 
{
    T* d = data;
    data = A->data;
    A->data = d;
}

// i is row
// j is column
template <class T>
T& NicMatrix<T>::operator()(int i, int j)
{
    assert( ( i >= 0 ) && ( i < rows ) );
    assert( ( j >= 0 ) && ( j < columns ) );
    
    return data[ i + (j * rows)];
}

template <class T>
void NicMatrix<T>::operator=(NicMatrix & B) 
{
    if (data != NULL) 
    {
        delete[] data;
    }
    rows = B.rows;
    columns = B.columns;
    size = B.size;
    total_size = B.total_size;
    total_rows = B.total_rows;
    total_columns = B.total_columns;
    n_cpus = B.n_cpus;
    rank = B.rank;

    data = new T[size];
    isAlias = false;

    T* d = data;
    T* b = B.data;

    for (int i = 0; i < size; i++) 
    {
        *d++ = *b++;
    }
}

#ifdef INSTANTIATE_TEMPLATES
template class NicMatrix<double>;
template class NicMatrix<float>;
#endif

#endif
// NICMATRIX_CPP_UNIVERSITY_OF_OREGON_NIC
