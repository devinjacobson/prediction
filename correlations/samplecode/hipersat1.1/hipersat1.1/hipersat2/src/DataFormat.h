#ifndef NIC_DATAFORMAT
#define NIC_DATAFORMAT

    enum DataFormat
    {
        BigEndian,
        LittleEndian,
        NativeEndian,
        Text
    };

template <typename T> void swapBytes( char* data );

#endif
