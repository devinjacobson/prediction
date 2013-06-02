#ifndef NIC_NICMATRIX_H_2006
#define NIC_NICMATRIX_H_2006

#include "DataFormat.h"
#include <iostream>

template <typename T>
class NicMatrix
{
public:
    // allocation and deallocation
    NicMatrix (int rows, int columns);
    virtual ~NicMatrix ();
    NicMatrix<T>& operator=(const NicMatrix<T>& rhs);
    
    // data methods
    T* data();
    const int rows();
    const int columns();
    const int size();
    
    // matrix access
    T& operator()(int row, int column);
    
    // vector access
    T& operator()(int index);
    
    // read/write
    void read(std::istream& is, DataFormat format = NativeEndian);
    void write(std::ostream& os, DataFormat format = NativeEndian);

private:
    int m_rows, m_columns, m_size;
    T* m_data;
};

#endif
