#ifndef PARTITIONEDDATASET_CPP_UNIVERSITY_OF_OREGON_NIC
#define PARTITIONEDDATASET_CPP_UNIVERSITY_OF_OREGON_NIC
#include <cstdio>

#include "PartitionedDataset.h"
#include "MPIWrapper.h"
#include "TypeIdentifier.h"

#if defined(__APPLE__)
#include <machine/endian.h>
#elif defined(MINGW)
#include "WinHeader.h"
#else
#include <endian.h>
#endif

#include <iostream>

using namespace std;


// totally misnamed now.
// TODO fix this brokenness!!!
template <class T>
static void readSwappedDoubles( T* buf, size_t numElements, FILE* fh, bool swap )
{        
    // This is my lame attempt at error handling TODO do something better!
    // check to see if the file handle exists
    if ( !fh )
    {
        std::cerr << "Null file handle. Check to see if file exists." << std::endl;
        std::cerr << "Aborting" << std::cout;
        abort();
    }
    fread( buf, sizeof( T ), numElements, fh );   // read in the master's data first
    
    if ( swap )
    {
        T* dptr = buf;
        
        while ( numElements-- > 0 )
        {
           unsigned char*   cptr = (unsigned char*) dptr;
           unsigned char    tmp;
           
           tmp = cptr[ 0 ];
           cptr[ 0 ] = cptr[ 7 ];
           cptr[ 7 ] = tmp;
           
           tmp = cptr[ 1 ];
           cptr[ 1 ] = cptr[ 6 ];
           cptr[ 6 ] = tmp;
           
           tmp = cptr[ 2 ];
           cptr[ 2 ] = cptr[ 5 ];
           cptr[ 5 ] =tmp;
           
           tmp = cptr[ 3 ];
           cptr[ 3 ] = cptr[ 4 ];
           cptr[ 4 ] = tmp;
           
           dptr++;
        }
    }
}

template <class T>
void PartitionedDataset<T>::loadFile(
    int                 rank,
    const std::string&  dataSrc,
    NicMatrix<T>* data,
    int                 ch,
    int                 columns,
    int                 rem,
    int                 obs,
    int                 n_cpus,
    FileType            fileType,
    FileOrientation     fileOrientation )
{
    // read binary version
    
//cerr << "BIG_ENDIAN=" << BIG_ENDIAN << endl;
//cerr << "BYTE_ORDER=" << BYTE_ORDER << endl;

#if BIG_ENDIAN == BYTE_ORDER
    FileType            nativeType = 'B';
    bool                swap = ( fileType == 'L' );
#elif LITTLE_ENDIAN == BYTE_ORDER
    FileType            nativeType = 'L';
    bool                swap = ( fileType == 'B' );
#endif

#ifdef __DISTRIBUTED
    MPI_Status status;
    if ( rank == 0 )
    {
        FILE*               fh = fopen( dataSrc.c_str(), "rb" );

        readSwappedDoubles<T>( data->data, ch * columns, fh, swap );

        //
        //  We'll use a separate array for the per-worker buffers. This is for understandabiliy.
        //  Reusing the master's buffer is an exercise left to the reader.
        //
        
        assert( data->size == ch * columns );
        
        T*          workerData = new T[ ch * columns ];   // may be one column bigger than necessary
                                                        // when rank > rem

        for ( int i = 1; i < n_cpus; i++ )
        {
            int     workerColumns = obs / n_cpus;
            
            if ( i < rem )
            {
                ++workerColumns;
            }
            
            readSwappedDoubles<T>( workerData, ch * workerColumns, fh, swap );
            
            MPI_Send( workerData, ch * workerColumns, 
                TypeIdentifier<T>::Type(), i, 1, MPI_COMM_WORLD );
        }

        delete[] workerData;
        
        fclose( fh );
    }
    else
    {
        // receive and unpack data, store it in the matrix
        MPI_Recv( data->data, data->size, 
            TypeIdentifier<T>::Type(), 0, 1, MPI_COMM_WORLD, &status );
    }
#else
    FILE*               fh = fopen( dataSrc.c_str(), "rb" );

    readSwappedDoubles<T>( data->data, ch * columns, fh, swap );

    fclose( fh );   // read in the master's data first
#endif

    return;
}


template <class T>
void PartitionedDataset<T>::storeFile( 
    int rank, 
    NicMatrix<T>* mat, 
    const std::string& m_whitenedFilename , 
    int n_cpus, 
    int* shuffle,
    int* invVector) 
{       
    // no of cpus has been defaulted to write the independent 
    // components for infomax. 
    
    T* data;
    T* d = NULL;
    T* dtemp = NULL;
    int rows;
    int columns;
    int size, count;
    data         = mat->data;
    rows         = mat->rows;
    columns      = mat->columns;
    size = rows * columns;
    T*          workerData = new T[ size ];   // 
#ifdef __DISTRIBUTED
    MPI_Status status;
    if (rank == 0)
    {
        FILE*            fh = fopen( m_whitenedFilename.c_str(), "wb" );   

        // Write binary values in column-major representation,
        // the data is output as a column x rows matrix. 
        
        if(shuffle==NULL)
        {
        /*
            for(int j=0;j<columns;j++)
            {
                for(int i=0;i<rows;i++) 
                {
                    cout<<data[j*rows+i]<<" ";
                }
                cout<<'\n';
            }
         */   
            fwrite(data, sizeof(T), columns*rows, fh);
        }
        else
        {
            for(int j=0;j<columns;j++)
            {
                dtemp = data + j*rows;
                for(int i=0;i<rows;i++)
                {
                    d = dtemp + shuffle[i];
                    *d = (*d)*invVector[shuffle[i]];
                    fwrite(d, sizeof(T), 1, fh);
                }
            }
        }
        
        for ( int i = 1; i < n_cpus; i++ )
	  {   //cout<<" I is : "<<i<<"\n";
            MPI_Recv(workerData, size, MPI_DOUBLE, i, 1, MPI_COMM_WORLD, &status);
            MPI_Get_count(&status, MPI_DOUBLE, &count); 
            
            /*
            for(int j=0;j<(count/rows);j++)
            {
                for(int i=0;i<rows;i++) 
                {
                    cout<<workerData[j*rows+i]<<" ";
                }
                cout<<'\n';
            }
            */
            
            if(shuffle == NULL) 
            {
                fwrite(workerData, sizeof(T), count, fh);
            }
            else 
            {
                for(int j=0;j<(count)/rows/*columns*/;j++) //because every column would have data for all the channels
                                                       //but the no of columns may vary with different processors 
                {
                    dtemp = workerData + j*rows;
                    for(int i=0;i<rows;i++)
                    {
                        d = dtemp + shuffle[i];
                        *d = (*d)*invVector[shuffle[i]];
                        
                        fwrite(d, sizeof(T), 1, fh);
                    }
                }
            }
	    // cout<<"Successful Receive from "<<i<<"\n";
           
        }
        fclose(fh);
    }
    else {
      //cout<<"Rank["<<rank<<"] "<<mat->rows<<" "<<mat->columns<<"\n";
      MPI_Send( mat->data, mat->rows * mat->columns, MPI_DOUBLE, 0, 1, MPI_COMM_WORLD );
      //cout<<"Successful Send Rank : "<<rank<<"\n"; 
    }
    //MPI_Finalize();
#else
    FILE*            fh = fopen( m_whitenedFilename.c_str(), "wb" );
    
    if(shuffle==NULL)
    {
        fwrite(data, sizeof(T), columns*rows, fh);
    }
    else 
    {
        for(int j=0;j<columns;j++)
        {
            dtemp = data + j*rows;
            for(int i=0;i<rows;i++)
            {
                d = dtemp + shuffle[i];
                *d = (*d)*invVector[shuffle[i]];
                fwrite(d, sizeof(T), 1, fh);
            }
        }
    }   
    fclose(fh);    
#endif
        delete [] workerData;
 return;   

}

template <class T>
void PartitionedDataset<T>::broadcastMatrix( NicMatrix<T>* data )
{
#ifdef __DISTRIBUTED
    int rank;
    int size;
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );

    int headerPacket[1];
    if ( 0 == rank )
    {
        if ( data != 0 )
        {
            headerPacket[0] = data->rows;
            headerPacket[1] = data->columns;
        }
        else
        {
            headerPacket[0] = 0;
            headerPacket[1] = 0;
        }
    }
    MPI_Bcast( headerPacket, 2, MPI_INTEGER, 0, MPI_COMM_WORLD );

    int rows = headerPacket[0];
    int columns = headerPacket[1];

    if ( rows != 0 )
    {
        if ( data == 0 ) data = new NicMatrix<T>( rows, columns );
        MPI_Bcast( data->data, rows * columns, MPI_DOUBLE, 0, MPI_COMM_WORLD );
    }
#endif
}

template <class T>
void PartitionedDataset<T>::distributeMatrix( NicMatrix<T>* data )
{
#ifdef __DISTRIBUTED
    int rank;
    int size;
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );

    // 0:samples per node 1:extra samples 2:channels
    int headerPacket[2];

    // distribute the information about the data set
    if ( 0 == rank )
    {
        headerPacket[0] = data->rows;
        headerPacket[1] = data->columns;
    }
    MPI_Bcast( headerPacket, 2, MPI_INTEGER, 0, MPI_COMM_WORLD );

    int numRows = headerPacket[0];
    int numColumns = headerPacket[1] / size;
    if ( rank < (headerPacket[1] % size) ) ++numColumns;
    
    // create the destination matrix
    NicMatrix<T> recvMatrix( 
        numRows, numColumns, headerPacket[0], headerPacket[1], rank, size );

    // prepare for the scatter communication
    int* sendCounts = new int[ size ];
    int* sendBase = new int[ size ];
    sendBase[ 0 ] = 0;
    int columnsPerProc = headerPacket[ 1 ] / size;
    int extraColumns = headerPacket[ 1 ] % size;
    int minDataCount = columnsPerProc * headerPacket[ 0 ];
    for ( int i = 0; i < size; ++i )
    {
        sendCounts[ i ] = minDataCount;
        if ( i < extraColumns ) sendCounts[ i ] += headerPacket[ 0 ];
        if ( 0 != i ) sendBase[ i ] = sendBase[ i - 1 ] + sendCounts[ i - 1 ];
    }

    // send the data
    MPI_Scatterv( 
        data->data, sendCounts, sendBase, MPI_DOUBLE, 
        recvMatrix.data, sendCounts[ rank ], MPI_DOUBLE,
        0, MPI_COMM_WORLD );

    // copy the data into the matrix pointer
    (*data) = recvMatrix;

    delete[] sendCounts;
    delete[] sendBase;
#endif
}

template <class T>
void PartitionedDataset<T>::gatherMatrix( NicMatrix<T>* data )
{
#ifdef __DISTRIBUTED
    int rank;
    int size;
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );

    T* d = data->data;

    int columns = data->columns;
    int rows = data->rows;
    int dataLength = columns * rows;

    T* recvData = 0;
    int totalDataLength = data->total_rows * data->total_columns;

    if ( rank == 0 )
    {
        recvData = new T[ totalDataLength ];
    }

    // prepare to scatter
    int* recvCounts = new int[ size ];
    int* recvBase = new int[ size ];
    recvBase[ 0 ] = 0;
    int columnsPerProc = data->total_columns / size;
    int extra = data->total_columns % size;
    int minDataCount = columnsPerProc * rows;
    for ( int i = 0; i < size; ++i )
    {
        recvCounts[ i ] = minDataCount;
        if ( i < extra ) recvCounts[ i ] += rows;
        if ( 0 != i ) recvBase[ i ] = recvBase[ i - 1 ] + recvCounts[ i - 1 ];
    }

    MPI_Gatherv( d, dataLength, MPI_DOUBLE,  // send information
        recvData, recvCounts, recvBase, MPI_DOUBLE, // recv info
        0, MPI_COMM_WORLD );

    if ( rank == 0 )
    {
        data->data = recvData;
        data->columns = data->total_columns;
        delete[] d;
    }


#endif
}

#ifdef INSTANTIATE_TEMPLATES
template class PartitionedDataset<double>;
template class PartitionedDataset<float>;
#endif

#endif
// PARTITIONEDDATASET_CPP_UNIVERSITY_OF_OREGON_NIC
