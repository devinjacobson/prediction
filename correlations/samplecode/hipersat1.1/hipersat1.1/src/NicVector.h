#ifndef NICVECTOR_H_UNIVERSITY_OF_OREGON_NIC
#define NICVECTOR_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>
#include "NicMatrix.h"

template <class T> class NicMatrix;

// Also a simple thin abstraction that
// has always been a bit of a disaster.
// So many methods depend upon the crappiness
// of this class
template <class T>
class NicVector 
{
public:

    int n;

    T* data;
    bool m_extern;

    NicVector();
    NicVector(int n_);
    NicVector(const NicVector& v);
    ~NicVector();

    void swap_vectors(NicVector* v);
    void zero_vector();
    void constant_vector(T & v);
    void random_vector(T min = 0, T max = 1);
    void orthogonalize( NicMatrix<T>* m );
    void normalize();

    void externData( T* data, int size );

    bool resize( int size, bool copy = false );

    T& operator()(int i) { return data[ i ]; }

    void operator= (NicVector& v);
    bool operator== (NicVector& v);

    friend std::ostream& operator<<(std::ostream & out, 
        const NicVector<T>& v) 
    {
        int n = v.n;
        T* data = v.data;

        if (n == 0) 
        {
            out << "[]" << std::endl;
        } 
        else 
        {
            out << "[" << *data++;
            for (int i = 1; i < n; i++) 
            {
                out << ", " << *data++;
            }
            out << "]";
        }
        return out;
    }
};

#endif
// NICVECTOR_H_UNIVERSITY_OF_OREGON_NIC
