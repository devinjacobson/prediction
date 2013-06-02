#ifndef MATRIXREADER_H_UNIVERSITY_OF_OREGON_NIC
#define MATRIXREADER_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include "NicMatrix.h"
#include "DataFormat.h"

// A much cleaner abstraction for reading in arbitray
// matrix types than the DataReader class. This wraps
// around the DataReader, and is much easier to use
template <class T>
class MatrixReader
{
private:
    MatrixReader() {}

public:
    // returns true if successful
    //
    // reading raw will overwrite the rows and columns
    static bool loadMatrix(
        NicMatrix<T>& matrix, 
        DataFormat::DataFormat format, 
        int& rows, 
        int& columns,
        const std::string& fileName,
        bool transpose = false );

};

#endif
// MATRIXREADER_H_UNIVERSITY_OF_OREGON_NIC
