#ifndef STATICGAINFILTER_CPP_UNIVERSITY_OF_OREGON_NIC
#define STATICGAINFILTER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "StaticGainFilter.h"

// a silly little filter, good for testing, but of little research interest

template <class T>
StaticGainFilter<T>::StaticGainFilter( T gain )
: m_gain( gain )
{
}

template <class T>
StaticGainFilter<T>::~StaticGainFilter()
{
}

template <class T>
void
StaticGainFilter<T>::filter( NicVector<T>& vector )
{
  T* data = vector.data;
  for ( int i = 0; i < vector.n; ++i )
  {
    data[i] *= m_gain;
  }
}

template class StaticGainFilter<double>;

#endif
// STATICGAINFILTER_CPP_UNIVERSITY_OF_OREGON_NIC
