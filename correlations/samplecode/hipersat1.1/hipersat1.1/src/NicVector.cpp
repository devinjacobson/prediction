#ifndef NICVECTOR_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICVECTOR_CPP_UNIVERSITY_OF_OREGON_NIC

#include "NicVector.h"
#include "NicMatrix.h"
#include <cmath>

using namespace std;


/***************************************************************
Test the template parameter for valid types
 **************************************************************/
template <class T>
NicVector<T>::NicVector() : n (0), data(NULL), m_extern( false ) {}

template <class T>
NicVector<T>::NicVector(int n_) : n (n_), data(new T[n]) 
{
    T* d = data;

    for (int i = 0; i < n; i++) 
    {
        *d++ = 0; 
    }
}

template <class T>
NicVector<T>::NicVector(const NicVector&  v) 
:   n(v.n), data(new T[v.n]) 
{
    memcpy(data, v.data, sizeof(T) * n);
}

template <class T>
NicVector<T>::~NicVector()
{
    if ( data && !m_extern ) delete[] data;
}

template <class T>
void 
NicVector<T>::swap_vectors(NicVector * v) 
{
    T* temp = data;
    data = v->data;
    v->data = temp;
}

template <class T>
void 
NicVector<T>::zero_vector() 
{
    T* temp = data;
    for (int i = 0; i < n; i++) 
    {
        *temp = 0;
        ++temp;
    }
}


template <class T>
void 
NicVector<T>::constant_vector(T& v) 
{
    T* temp = data;
    for (int i = 0; i < n; i++) 
    {
        *temp++ = v;
    }
}

template <class T>
void
NicVector<T>::normalize() 
{
    T norm = 0;
    int i = 0;

    T * d = (T *) data;

    for (i = 0; i < n; i++) 
    {
        norm += d[i] * d[i];
    }
    norm = sqrt(norm);

    for (i = 0; i < n; i++) 
    {
        d[i] /= norm;
    }
}

template <class T>
void
NicVector<T>::externData( T* d, int size )
{
    if ( data && !m_extern )
    {
        delete [] data;
    }

    data = d;
    n = size;
    m_extern = true;
}

/****
The A is assumed to be normalized, 
v[i] = v[i] - A*v
*/
template <class T>
void
NicVector<T>::orthogonalize(NicMatrix<T>* A) 
{ 
    int i = 0, j = 0;
    T * temp = (T *)new T[n];
    T * a = (T *)(A->data);
    T * d = (T *)data;

    for (i = 0; i < n; i++) 
    {
        temp[i] = d[i];
    }

    for (i = 0; i < n; i++) 
    {
        for (j = 0; j < n; j++) 
        {
            temp[i] -= a[i + n * j] * d[j];
        }
    }

    for (i = 0; i < n; i++) 
    {
        d[i] = temp[i];
    }

    delete [] temp;
}

// THIS SHOULD ACCEPT A R.N. GENERATING FUNCTION FOR THE PARTICULAR DATA TYPE
template <class T>
void 
NicVector<T>::random_vector(T min, T max) 
{
    T* d = data;
    T delta = max - min;

    for (int i = 0; i < n;  i++) 
    {
        *d++ = (T)(min + delta * rand()/((T)RAND_MAX));
    }
}

template <class T>
void NicVector<T>::operator=(NicVector& v) 
{
    if ( this != &v )
    {
      if ( !m_extern ) 
      {
          delete [] data;
          m_extern = false;
      }
      data = new T[ v.n ];

      memcpy(data, v.data, sizeof(T)*n);
    }
}

template <class T>
bool NicVector<T>::operator==(NicVector& v) 
{
    bool rtn = true;
    T* d = v.data;

    if (v.n != n) 
    {
        rtn = false;
    } 
    else 
    {
        for (int i = 0; i < n && rtn != false; i++) 
        {
            if (d[i] != data[i]) 
            {
                rtn = false;
            }
        }
    }
    return rtn;
}

template <class T>
bool NicVector<T>::resize( int size, bool copy )
{
    if ( copy )
    {
        T* temp = new T[ size ];
        int s = std::min( size, n );
        for ( int i = 0; i < size; ++i )
        {
            temp[i] = data[i];
        }
        delete[] data;
        data = temp;
        n = size;
    }
    else
    {
        delete[] data;
        data = new T[size];
        n = size;
    }
}

#ifdef INSTANTIATE_TEMPLATES
template class NicVector<double>;
template class NicVector<float>;
#endif

#endif
// NICVECTOR_CPP_UNIVERSITY_OF_OREGON_NIC
