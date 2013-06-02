#ifndef MPIWRAPPER_CPP_UNIVERSITY_OF_OREGON_NIC
#define MPIWRAPPER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "MPIWrapper.h"
#include "TypeIdentifier.h"

#ifdef __DISTRIBUTED

int getMPIRank()
{
    int rank;
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    return rank;
}

int getMPISize()
{
    int size = 0;
    MPI_Comm_size( MPI_COMM_WORLD, &size );
    return size;
}

template <class T>
void broadcastDataMPI( T* data, int length, int root )
{
    MPI_Bcast( data, length, TypeIdentifier<T>::Type(), root, MPI_COMM_WORLD );
}

template <class T>
void allreduceDataMPI( T* input, T* output, int length )
{
    MPI_Allreduce( input, output, length, 
        TypeIdentifier<T>::Type(), MPI_SUM, MPI_COMM_WORLD );
}

void initializeMPI( int argc, char** argv, int& rank, int& size )
{
    MPI_Init( &argc, &argv );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );
}

void finalizeMPI()
{
    MPI_Finalize();
}

#else

int getMPIRank()
{
    return 0;
}

int getMPISize()
{
    return 1;
}

template <class T>
void broadcastDataMPI( T* data, int length, int root )
{
    return;
}

template <class T>
void allreduceDataMPI( T* input, T* output, int length )
{
    for ( int i = 0; i < length; ++i )
    {
        output[i] = input[i];
    }
}

void initializeMPI( int argc, char** argv, int& rank, int& size )
{
    rank = 0;
    size = 1;
}

void finalizeMPI()
{
}

#endif

#ifdef INSTANTIATE_TEMPLATES
template void broadcastDataMPI<double>( double* data, int length, int root );
template void allreduceDataMPI<double>( double* input, double* output, 
    int length );

template void broadcastDataMPI<float>( float* data, int length, int root );
template void allreduceDataMPI<float>( float* input, float* output, 
    int length );
#endif

#endif
// MPIWRAPPER_CPP_UNIVERSITY_OF_OREGON_NIC
