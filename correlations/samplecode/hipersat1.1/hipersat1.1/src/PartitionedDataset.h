#ifndef __PARTITIONED_DATASET_H
#define __PARTITIONED_DATASET_H

#include <cstring>

#include "NicMatrix.h"

// A largely defunct class. The important methods to look at are the
// static distribute, broadcast, and gather calls.
// This is a way to transmit parts of a matrix to several different
// processors using MPI
template <class T>
class PartitionedDataset
{
public:
// forget this stuff. It's from the old signal cleaner days
    typedef char            FileType;
    enum
    {
        c_fileType_binaryBigEndian = 'B',
        c_fileType_binaryLittleEndian = 'L',
        c_fileType_binaryNativeEndian = 'P'
    };
    
    typedef char            FileOrientation;
    enum
    {
        c_fileOrientationColumnMajor = 'C',
        c_fileOrientationRowMajor = 'O'
    };
    
    
    void loadFile(
        int                 rank,
        const std::string&  dataSrc,
        NicMatrix<T>* data,
        int                 ch,
        int                 columns,
        int                 rem,
        int                 obs,
        int                 n_cpus,
        FileType            fileType,
        FileOrientation     fileOrientation );
        
    void storeFile( int rank, NicMatrix<T>* mat, const std::string& m_whitenedFilename , int n_cpus=1, int* shuffle=NULL, int* invVector=NULL) ;

    // these _are_ the droids you're looking for
    static void distributeMatrix( NicMatrix<T>* data );
    static void broadcastMatrix( NicMatrix<T>* data );
    static void gatherMatrix( NicMatrix<T>* data );
};

#endif


