#include "DataFormat.h"
#include <algorithm>


template <typename T> void swapBytes( char* data )
{
    for (int i = 0; i < sizeof(T)/2; ++i )
    {
        std::swap( *(data+i), *(data + sizeof(T) - i - 1));
    }
}

template void swapBytes<double>(char*);
template void swapBytes<float>(char*);

