#ifndef CONTRASTFUNCTIONS_H_UNIVERSITY_OF_OREGON_NIC
#define CONTRASTFUNCTIONS_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "NicVector.h"

// The virtual wrapper for the contrast functions
// also includes a factory method to create a
// specific subclass.
template <class T>
class ContrastFunction
{
public:
    virtual void operator()( NicMatrix<T>*, NicVector<T>*, NicVector<T>* ) = 0;

    enum Type
    {
        HYPERBOLIC_TAN,
        CUBIC,
        GAUSSIAN
    };

    static ContrastFunction<T>* getContrastFunction( Type type );
};

template <class T>
class HyperbolicTan : public ContrastFunction<T>
{
    void operator()( NicMatrix<T>*, NicVector<T>*, NicVector<T>* );
};


template <class T>
class Cubic : public ContrastFunction<T>
{

    void operator()( NicMatrix<T>*, NicVector<T>*, NicVector<T>* );
};

template <class T>
class Gaussian : public ContrastFunction<T>
{
    void operator()( NicMatrix<T>*, NicVector<T>*, NicVector<T>* );
};


#endif
// CONTRASTFUNCTIONS_H_UNIVERSITY_OF_OREGON_NIC
