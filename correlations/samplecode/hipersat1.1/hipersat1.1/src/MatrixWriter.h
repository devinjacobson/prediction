#ifndef MATRIXWRITER_H_UNIVERSITY_OF_OREGON_NIC
#define MATRIXWRITER_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include "NicMatrix.h"
#include "DataFormat.h"

// A much cleaner abstraction for writing out arbitray
// matrix types than the DataWriter class. This wraps
// around the DataWriter, and is much easier to use
template <class T>
class MatrixWriter
{
private:
    MatrixWriter() {}

public:
    static bool writeMatrix(
        NicMatrix<T>& matrix,
        DataFormat::DataFormat format,
        const std::string& fileName,
        bool transpose = false );
};

#endif
// MATRIXWRITER_H_UNIVERSITY_OF_OREGON_NIC
