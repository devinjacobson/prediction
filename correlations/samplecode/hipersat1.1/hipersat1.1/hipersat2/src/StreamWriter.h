#include <iostream>
#include "DataFormat.h"

template <class T>
class StreamWriter
{
public:
    
    StreamWriter( std::ostream& os, DataFormat format = NativeEndian );
    
    void write(T* buffer, int numToWrite);
    
private:
    
    int m_sizeofT;
    std::ostream& m_outputStream;
    DataFormat m_format;
    bool m_swapOn;
    
};
