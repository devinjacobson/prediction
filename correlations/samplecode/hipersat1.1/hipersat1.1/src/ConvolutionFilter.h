#ifndef CONVOLUTIONFILTER_H_UNIVERSITY_OF_OREGON_NIC
#define CONVOLUTIONFILTER_H_UNIVERSITY_OF_OREGON_NIC

#include "NICFilter.h"
#include "NicVector.h"

// A function object
//
// Given a set of filter coefficients with a given length,
// the convulution filter will take a vector of data
// and peform a convolution operation using the filter
// coefficients on that data.
//
// The discrete convultion is defined as
//       l-1
// A_n = sum( A_n + i * f_i )
//       i=0
// 
// where l is the length of the filter, A_n is a coefficient
// of the input vector, and f_i is a filter coefficient
template <class T>
class ConvolutionFilter : public NICFilter<T>
{
public:
  
  ConvolutionFilter( T* filterCoeffs = 0, int length = 0 );
  ~ConvolutionFilter();

  void filter( NicVector<T>& vector );

private:

  T* m_coefficients;
  int m_length;

};

#endif
// CONVOLUTIONFILTER_H_UNIVERSITY_OF_OREGON_NIC
