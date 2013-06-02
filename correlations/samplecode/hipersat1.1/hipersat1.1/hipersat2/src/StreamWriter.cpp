#include <iostream>
#include <string.h>
#include "StreamWriter.h"

template <typename T> StreamWriter<T>::StreamWriter( std::ostream& os, DataFormat format )
: m_sizeofT(sizeof(T)), m_outputStream(os), m_format(format), m_swapOn(false)
{
    if (((m_format == BigEndian) && (BYTE_ORDER == LITTLE_ENDIAN)) ||
        ((m_format == LittleEndian) && (BYTE_ORDER == BIG_ENDIAN)))
    {
        m_swapOn = true;
    }
}
    
template <typename T> void StreamWriter<T>::write(T* buffer, int numToWrite)
{
    if (m_format == Text)
    {
        for ( int i = 0; i < numToWrite; ++i, ++buffer )
        {
            m_outputStream << *buffer << " ";
        }
        m_outputStream << std::endl;
    }
    else
    {
        T* tempBuffer = buffer;
        
        if (m_swapOn)
        {
            tempBuffer = new T[numToWrite];
            T* buffercounter = tempBuffer;
            memcpy((void*)(tempBuffer), (const void*)(buffer), numToWrite*m_sizeofT);
            for ( int i = 0; i < numToWrite; ++i, ++buffercounter)
            {
                swapBytes<T>((char*)(buffercounter));
            }
        }
        m_outputStream.write( (char*)(tempBuffer), numToWrite*m_sizeofT);
        
        if (m_swapOn)
        {
            delete[] tempBuffer;
        }
    }
}

template class StreamWriter<double>;
template class StreamWriter<float>;
