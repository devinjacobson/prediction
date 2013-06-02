#ifndef STATICGAINFILTER_H_UNIVERSITY_OF_OREGON_NIC
#define STATICGAINFILTER_H_UNIVERSITY_OF_OREGON_NIC

#include "NICFilter.h"
#include "NicVector.h"

// A very simple test filter.
// multiply the input data stream by a constant
template <class T>
class StaticGainFilter : public NICFilter<T>
{
public:

  StaticGainFilter( T gain );
  ~StaticGainFilter();

  void filter( NicVector<T>& vector );

private:

  T m_gain;

};

#endif
// STATICGAINFILTER_H_UNIVERSITY_OF_OREGON_NIC
