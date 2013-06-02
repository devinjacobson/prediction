#ifndef DATAWRITER_H_UNIVERSITY_OF_OREGON_NIC
#define DATAWRITER_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>

// A bit of a misdesign here.
// Format and Endian are not
// as orthogonal as I first thought
// they were. It makes sense to
// wrap these up as one variable
// see DataFormat.h for the right
// way to handle this
template <class T>
class DataWriter
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

    DataWriter(
        std::ostream& os,
        Format format = Binary,
        Endian endian = NativeEndian );
    ~DataWriter();
    bool write( T* value );
    bool write( T& value );

    static char* writeBuffer( char* buffer, T& value );

    bool linebreak();

private:

    void reverseBytes( char* from, char* to );

    int m_sizeOfT;
    std::ostream& m_outputStream;
    Format m_format;
    Endian m_endian;
    Endian m_native;
    char* m_nextValue;
    char* m_nextValueCopy;
};

#endif
// DATAWRITER_H_UNIVERSITY_OF_OREGON_NIC
