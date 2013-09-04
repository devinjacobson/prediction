#include "NicMatrix.h"
#include "StreamWriter.h"
#include "StreamReader.h"
#include <string.h>

template <typename T> NicMatrix<T>::NicMatrix(int rows, int columns)
: m_rows(rows), m_columns(columns)
{
    if (m_rows <= 0)
    {
        m_rows = 1;
    }
    if (m_columns <= 0)
    {
        m_columns = 1;
    }
    m_size = m_rows*m_columns;
    m_data = new T[m_size];
    T* data = m_data;
    for ( int i = 0; i < m_size; ++i, ++data )
    {
        *data = 0;
    }
    
}

template <typename T> NicMatrix<T>::~NicMatrix()
{
    if (m_data != 0)
    {
        delete[] m_data;
    }
}

template <typename T> NicMatrix<T>& NicMatrix<T>::operator=(const NicMatrix<T>& rhs)
{
    if (this != &rhs)
    {
        if (m_data != 0)
        {
            delete[] m_data;
        }
        m_rows = rhs.m_rows;
        m_columns = rhs.m_columns;
        m_data = new T[m_rows*m_columns];
        memcpy((void*)(m_data), (const void*)(rhs.m_data), m_rows*m_columns*sizeof(T));
    }
    return *this;
}
    
template <typename T> T* NicMatrix<T>::data()
{
    return m_data;
}

template <typename T> const int NicMatrix<T>::rows()
{
    return m_rows;
}

template <typename T> const int NicMatrix<T>::columns()
{
    return m_columns;
}

template <typename T> const int NicMatrix<T>::size()
{
    return m_rows*m_columns;
}

template <typename T> T& NicMatrix<T>::operator()(int row, int column)
{
    return m_data[row + (column*m_rows)];
}

template <typename T> T& NicMatrix<T>::operator()(int index)
{
    return m_data[index];
}

template <typename T> void NicMatrix<T>::read(std::istream& is, DataFormat format)
{
    T* pointer = m_data;
    StreamReader<T> reader(is, format);
    
    if (format == Text)
    {
        for (int i = 0; i < m_rows; ++i)
        {
            for ( int j = 0; j < m_columns; ++j)
            {
                is >> (*this)(i,j);
            }
        }   
    }
    else
    {
        for ( int i = 0; i < m_columns; ++i)
        {
            reader.read(pointer, m_rows);
            pointer += m_rows;
        }
    }
}

template <typename T> void NicMatrix<T>::write(std::ostream& os, DataFormat format)
{
    T* pointer = m_data;
    StreamWriter<T> writer(os, format);
    if (format == Text)
    {
        for (int i = 0; i < m_rows; ++i)
        {
            for (int j = 0; j < m_columns; ++j)
            {
                os << (*this)(i,j) << " ";
            }
            os << std::endl;
        }
    }
    else
    {
        for (int i=0; i < m_columns; ++i)
        {
            writer.write(pointer, m_rows);
            pointer += m_rows;
        }
    }
}

template class NicMatrix<double>;
template class NicMatrix<float>;
