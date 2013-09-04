#ifndef DATAREADER_CPP_UNIVERSITY_OF_OREGON_NIC
#define DATAREADER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "DataReader.h"
#ifdef MINGW
#include "WinHeader.h"
#endif

template < class T >
DataReader<T>::DataReader( 
    std::istream& is, 
    typename DataReader<T>::Format format,
    typename DataReader<T>::Endian endian )
:   m_sizeOfT( sizeof( T ) ),
    m_inputStream( is ),
    m_format( format ),
    m_endian( endian )
{
    if ( BYTE_ORDER == BIG_ENDIAN )
    {
        m_native = DataReader<T>::BigEndian;
    }
    else
    {
        m_native = DataReader<T>::LittleEndian;
    }
    if ( m_endian == DataReader<T>::NativeEndian )
    {
        m_endian = m_native;
    }
}

template <class T>
bool
DataReader<T>::read( T& value )
{
    return read( &value );
}

template <class T>
bool
DataReader<T>::read( T* value )
{
    bool success = false;
    if ( m_format == DataReader<T>::Ascii )
    {
        m_inputStream >> *value;
        if ( m_inputStream.good() ) success = true;
    }
    else
    {
        m_nextValue = reinterpret_cast< char* >( value );
        if( (m_inputStream.read( m_nextValue, m_sizeOfT )).good() )
        {
            if( m_endian != m_native )
            {
                this->reverseBytes( m_nextValue );
            }
            success = true;
        }
    }
    return success;
}

template <class T>
char*
DataReader<T>::readBuffer( char* buffer, T& value )
{
    char* v = reinterpret_cast< char* >( &value );
    for ( int i = 0; i < sizeof( T ); ++i )
    {
        v[i] = buffer[i];
    }
    return ( buffer + sizeof( T ) );
}

template < class T >
void
DataReader<T>::reverseBytes( char* data )
{
    for ( int i = 0; i < m_sizeOfT/2; ++i )
    {
        std::swap( *(data + i), *(data + m_sizeOfT - i - 1) );
    }
}

#ifdef INSTANTIATE_TEMPLATES
template class DataReader<double>;
template class DataReader< char [5] >;
template class DataReader< int >;
template class DataReader< float >;
template class DataReader< short >;
#endif

#endif
// DATAREADER_CPP_UNIVERSITY_OF_OREGON_NIC
