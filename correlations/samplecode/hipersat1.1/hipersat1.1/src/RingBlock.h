#ifndef MPITOOLS_H_COPYRIGHT_2005_UNIVERSITY_OF_OREGON_NIC
#define MPITOOLS_H_COPYRIGHT_2005_UNIVERSITY_OF_OREGON_NIC

#include "MPIWrapper.h"

// This class is meant to assist in obvserving the output of MPI Programs.
// Upon creation it computes its location in the communicator space and
// its two nearest neighbors.
// It provides two methods, entry() and exit(). All nodes must make these
// calls simultaneously. An example to illustrate its use:
//
// RingBlock blocker( MPI_COMM_WORLD );
// blocker.entry()
// std::cout << "I'm process" << rank << std::endl;
// blocker.exit()
//
// Process 0 will write out its id, then process 1, and so on. Process 0
// blocks until its output is written, the process 1, and so on. The idea
// is to prevent messages from the different nodes from overlapping, and
// helps greatly in producing readable debugging output

class RingBlock
{
private:
#ifdef __DISTRIBUTED
    MPI_Comm m_comm;

    int m_commSize;
    int m_commRank;
    int m_up;
    int m_down;
    int m_waitData;
    int m_waitTag;
#endif

public:
#ifndef __DISTRIBUTED
    typedef int MPI_Comm;
#endif

    RingBlock( MPI_Comm theComm );
    void entry( );
    void exit( );
};

#endif
// MPITOOLS_H_COPYRIGHT_2005_UNIVERSITY_OF_OREGON_NIC

