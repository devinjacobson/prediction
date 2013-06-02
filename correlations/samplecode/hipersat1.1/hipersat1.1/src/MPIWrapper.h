#ifndef MPIWRAPPER_H_UNIVERSITY_OF_OREGON_NIC
#define MPIWRAPPER_H_UNIVERSITY_OF_OREGON_NIC

// Wrap around all of the MPI function that
// we use in the code. This allows us to
// build without using MPI and not have
// a mess of ifdefs scattered throughout  
// the algorithms

#ifdef __DISTRIBUTED

#ifdef USE_INTEL_MPICH
#include "mpi.h"
#define SEEK_SET 0
#endif

#ifdef USE_LAMMPI

#include "mpi.h"

#endif

#ifdef USE_MPICH2
//#undef SEEK_SET                                                               //
//#undef SEEK_CUR                                                               //
//#undef SEEK_END                                                               //

#include "mpi.h"
#endif

#endif
// __DISTRIBUTED

int getMPIRank();
int getMPISize();

template <class T>
void broadcastDataMPI( T* data, int length, int root );

template <class T>
void allreduceDataMPI( T* input, T* output, int length );

void initializeMPI( int argc, char** argv, int& rank, int& size );
void finalizeMPI();

#endif
// MPIWRAPPER_H_UNIVERSITY_OF_OREGON_NIC
