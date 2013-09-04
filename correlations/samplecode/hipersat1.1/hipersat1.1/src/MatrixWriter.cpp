#ifndef MATRIXWRITER_CPP_UNIVERSITY_OF_OREGON_NIC
#define MATRIXWRITER_CPP_UNIVERSITY_OF_OREGON_NIC

#include <fstream>
#include "DataWriter.h"
#include "MatrixWriter.h"

using namespace std;

template <class T>
bool MatrixWriter<T>::writeMatrix(
    NicMatrix<T>& matrix,
    DataFormat::DataFormat format,
    const std::string& fileName,
    bool transpose )
{
    // set the mode for file io
    ios::openmode mode = ios::out;
    if ( format != DataFormat::TEXT ) mode |= ios::binary;

    typename DataWriter<T>::Endian endian;
    typename DataWriter<T>::Format writerFormat;

    switch ( format )
    {
        case DataFormat::BIG:
            endian = DataWriter<T>::BigEndian;
            writerFormat = DataWriter<T>::Binary;
            break;
        case DataFormat::LITTLE:
            endian = DataWriter<T>::LittleEndian;
            writerFormat = DataWriter<T>::Binary;
            break;
        case DataFormat::NATIVE:
            endian = DataWriter<T>::NativeEndian;
            writerFormat = DataWriter<T>::Binary;
            break;
        case DataFormat::TEXT:
            endian = DataWriter<T>::NativeEndian;
            writerFormat = DataWriter<T>::Ascii;
            break;
        default:
            endian = DataWriter<T>::NativeEndian;
            writerFormat = DataWriter<T>::Ascii;
    }

    ofstream outputFile( fileName.c_str(), mode );
    if ( !outputFile.good() )
    {
        return false;
    }

    DataWriter<T> writer( outputFile, writerFormat, endian );

    int numValues = matrix.rows * matrix.columns;
    int count = 0;
    T* d = matrix.data;
    if ( !transpose )
    {
        while( (count < numValues) && writer.write( d ) )
        {
            ++d;
            ++count;
            if (( count % matrix.rows) == 0)
            {
                writer.linebreak();
            }
        }
    }
    else
    {
        int r = 0;
        int c = 0;
        T d = matrix( r, c );
        while ( ( count < numValues ) && writer.write( d ) )
        {
            ++c;
            ++count;
            if ( c == matrix.columns ) 
            {
                writer.linebreak();
                c = 0;
                ++r;
                if ( r == matrix.rows )
                {
                    r = 0;
                }
            }
            d = matrix( r, c );
        }
    }
        
    outputFile.close();
    return ( count == numValues );
}

#ifdef INSTANTIATE_TEMPLATES
template class MatrixWriter<double>;
template class MatrixWriter<float>;
#endif

#endif
// MATRIXWRITER_CPP_UNIVERSITY_OF_OREGON_NIC
