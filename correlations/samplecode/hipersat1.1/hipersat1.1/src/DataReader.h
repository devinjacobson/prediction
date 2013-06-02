#ifndef DATAREADER_H_UNIVERSITY_OF_OREGON_NIC
#define DATAREADER_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>

// A bit of a misdesign here.
// Format and Endian are not
// as orthogonal as I first thought
// they were. It makes sense to
// wrap these up as one variable
// see DataFormat.h for the right
// way to handle this
template <class T>
class DataReader
{
public:
    enum Format
    {
        Binary,
        Ascii
    };

    enum Endian
    {
        BigEndian,
        LittleEndian,
        NativeEndian
    };

    DataReader( 
        std::istream& is, 
        Format format = Binary, 
        Endian endian = NativeEndian );
    bool read( T* value );
    bool read( T& value );

    static char* readBuffer( char* buffer, T& value );

private:

    void reverseBytes( char* data );

    int m_sizeOfT;
    std::istream& m_inputStream;
    Format m_format;
    Endian m_endian;
    Endian m_native;
    char* m_nextValue;
};

#endif
// DATAREADER_H_UNIVERSITY_OF_OREGON_NIC
