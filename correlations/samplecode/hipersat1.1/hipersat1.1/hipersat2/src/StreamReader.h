#include <iostream>
#include "DataFormat.h"

template <class T>
class StreamReader
{
public:
    StreamReader( std::istream& is, DataFormat format = NativeEndian );
    void read(T* buffer, int numToRead);
    
private:
    
    int m_sizeofT;
    std::istream& m_inputStream;
    DataFormat m_format;
    bool m_swapOn;
};