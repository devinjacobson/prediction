#include "StreamReader.h"
#include <algorithm>

template <typename T> StreamReader<T>::StreamReader( std::istream& is, DataFormat format )
: m_sizeofT(sizeof(T)), m_inputStream(is), m_format(format), m_swapOn(false)
{
    if (((m_format == BigEndian) && (BYTE_ORDER == LITTLE_ENDIAN)) ||
        ((m_format == LittleEndian) && (BYTE_ORDER == BIG_ENDIAN)))
    {
            m_swapOn = true;
    }
}
    
template <typename T> void StreamReader<T>::read(T* buffer, int numToRead)
{
    if (m_format == Text)
    {
        for ( int i = 0; i < numToRead; ++i, ++buffer )
        {
            m_inputStream >> *buffer;
        }
    } 
    else
    {
        m_inputStream.read( (char*)(buffer), m_sizeofT*numToRead );
    
        if (m_swapOn)
        {
            for ( int i = 0; i < numToRead; ++i, ++buffer )
            {
                swapBytes<T>((char*)(buffer));
            }
        }
    }
}

template class StreamReader<double>;
template class StreamReader<float>;
