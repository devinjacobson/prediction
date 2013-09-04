#ifndef CONVOLUTIONFILTER_CPP_UNIVERSITY_OF_OREGON_NIC
#define CONVOLUTIONFILTER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "ConvolutionFilter.h"
#include <iostream>

using namespace std;


// there are two options for contructing a filter.
// * precompute the filter coefficients, and pass them to the contructor
// * allocate the space for the coefficients, and set them later
//
// to do the second, pass a null pointer as the filterCoeffs
template <class T>
ConvolutionFilter<T>::ConvolutionFilter( T* filterCoeffs, int length )
: m_coefficients( 0 ), m_length( length )
{
  if ( m_length > 0 )
  {
    m_coefficients = new T[ m_length ];
  }

  if ( filterCoeffs != 0 )
  {
    for ( int i = 0; i < m_length; ++i )
    {
      m_coefficients[i] = filterCoeffs[i];
    }
  }
  else
  {
    for ( int i = 0; i < m_length; ++i )
    {
      m_coefficients[i] = 0;
    }
  }
}

template <class T>
ConvolutionFilter<T>::~ConvolutionFilter()
{
  if ( (m_length > 0) && ( m_coefficients != 0 ) )
  {
    delete [] m_coefficients;
  }
}

template <class T>
void
ConvolutionFilter<T>::filter( NicVector<T>& vec )
{
  T* data = vec.data;
  int dataSize = vec.n;
  int numToFilter = dataSize - (m_length + 1); // + 1 ??? ;
  int toZero = std::min( m_length/2, dataSize );

  // zero the edges of the data. I guess that this is one way
  // to handle boundary conditions
  for ( int i = 0; i < toZero; ++i )
  {
    data[i] = 0;
    data[ dataSize - i - 1 ] = 0;
  }

  // copy the data over to a temporary array
  T* tempData = new T[ dataSize ];

  // apply the convolution filter
  // it is essential that i be outside the scope of the for loop
  int i;
  for ( i = 0; i < numToFilter; ++i )
  {
    tempData[i] = 0;
    for ( int j = 0; j < m_length; ++j )
    {
      tempData[i] += ( m_coefficients[j] * data[i + j] );
    }
  }
  for ( ; i < dataSize; ++i ) // boundary condition
  {
    tempData[i] = 0;
  }

  // copy the data back over to the original vector
  for ( int j = 0; j < dataSize; ++j )
  {
    data[j] = tempData[j];
  }
}

template class ConvolutionFilter<double>;

#endif
// CONVOLUTIONFILTER_CPP_UNIVERSITY_OF_OREGON_NIC
