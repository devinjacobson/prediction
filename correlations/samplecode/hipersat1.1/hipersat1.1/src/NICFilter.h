#ifndef NICFILTER_H_UNIVERSITY_OF_OREGON_NIC
#define NICFILTER_H_UNIVERSITY_OF_OREGON_NIC

template <class T> class NicVector;

// defines an abstract base class that provides one method, filter
template <class T>
class NICFilter
{
public:

  NICFilter() {}
  virtual ~NICFilter() {}

  virtual void filter( NicVector<T>& data ) = 0;

private:

};

#endif
// FILTER_H_UNIVERSITY_OF_OREGON_NIC
