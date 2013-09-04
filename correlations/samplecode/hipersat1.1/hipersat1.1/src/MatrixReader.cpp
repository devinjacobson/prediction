#ifndef MATRIXREADER_CPP_UNIVERSITY_OF_OREGON_NIC
#define MATRIXREADER_CPP_UNIVERSITY_OF_OREGON_NIC

#include <fstream>
#include "DataReader.h"
#include "MatrixReader.h"
#include "NicMatrix.h"
#include "EpochMarkedSimpleBinary.h"

using namespace std;

template <class T>
bool MatrixReader<T>::loadMatrix( 
    NicMatrix<T>& matrix, 
    DataFormat::DataFormat format, 
    int& rows,
    int& columns,
    const string& fileName,
    bool transpose )
{
    // set the mode for file io
    ios::openmode mode = ios::in;
    if ( format != DataFormat::TEXT ) mode |= ios::binary;
    typename DataReader<T>::Endian endian;
    typename DataReader<T>::Format readerFormat;

    switch ( format )
    {
        case DataFormat::BIG:
            endian = DataReader<T>::BigEndian;
            readerFormat = DataReader<T>::Binary;
            break;
        case DataFormat::LITTLE:
            endian = DataReader<T>::LittleEndian;
            readerFormat = DataReader<T>::Binary;
            break;
        case DataFormat::NATIVE:
            endian = DataReader<T>::NativeEndian;
            readerFormat = DataReader<T>::Binary;
            break;
        case DataFormat::TEXT:
            endian = DataReader<T>::NativeEndian;
            readerFormat = DataReader<T>::Ascii;
            break;
        default:
            endian = DataReader<T>::NativeEndian;
            readerFormat = DataReader<T>::Ascii;
    }

    if ( format == DataFormat::RAW )
    {
        EpochMarkedSimpleBinary rawReader;
        rawReader.readFile( fileName );
        rawReader.doNotDeleteData();

        // bad assumption. This could be int data
        // in fact, lots of bad things happen in this block
        //
        // hopefully things will break properly
        // if this block is ever reached when T is double
        if ( sizeof(T) != 4 ) abort();

        T* rawData = (T*)(rawReader.floatData());

        rows = rawReader.channels();
        columns = rawReader.samples();

        matrix.alias( rawData, rows, columns ); 

        return true;
    }

    ifstream inputFile( fileName.c_str(), mode );
    if ( !inputFile.good() )
    {
        return false;
    }

    if ( transpose )
    {
        matrix.resize( columns, rows );
    }
    else
    {
        matrix.resize( rows, columns );
    }

    DataReader<T> reader( inputFile, readerFormat, endian );
    
    T* d = matrix.data;
    int count = 0;
    int numValues = rows * columns;
    if ( !transpose )
    {
        while ( (count < numValues) && reader.read( d ) )
        {
            ++d;
            ++count;
        }
    }
    else
    {
        T temp = 0;
        d = &temp;
        int r = 0;
        int c = 0;
        while ( ( count < numValues ) && reader.read( d ) )
        {
            matrix( c, r ) = *d;
            ++r;
            ++count;
            if ( r == rows )
            {
                r = 0;
                ++c;
                if ( c == columns )
                {
                    c = 0;
                }
            }
        }
    }
    inputFile.close();
    
    return ( count == numValues );
}

#ifdef INSTANTIATE_TEMPLATES
template class MatrixReader<double>;
template class MatrixReader<float>;
#endif

#endif
// MATRIXREADER_CPP_UNIVERSITY_OF_OREGON_NIC
