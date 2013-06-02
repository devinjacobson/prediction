#ifndef MPITOOLS_CPP_UNIVERSITY_OF_OREGON_NIC
#define MPITOOLS_CPP_UNIVERSITY_OF_OREGON_NIC

#include "RingBlock.h"

RingBlock::RingBlock( MPI_Comm theComm )
{
    #ifdef __DISTRIBUTED
    m_comm = theComm; 
    MPI_Comm_size( m_comm, &m_commSize );
    MPI_Comm_rank( m_comm, &m_commRank );
    m_up = ( m_commRank + m_commSize + 1 ) % m_commSize;
    m_down = ( m_commRank + m_commSize - 1 ) % m_commSize;
    m_waitData = 0;
    m_waitTag = 3604;
    #endif
}

void RingBlock::entry( )
{
    #ifdef __DISTRIBUTED
    if ( 0 != m_commRank )
    {
        MPI_Recv( &m_waitData, 1, MPI_INT, 
            m_down, m_waitTag, m_comm, 
            MPI_STATUS_IGNORE );
    }
    #endif
}

void RingBlock::exit( )
{
    #ifdef __DISTRIBUTED
    if ( 0 == m_commRank )
    {
        if ( m_commSize > 1 )
        {
            MPI_Send( &m_waitData, 1, MPI_INT,
                m_up, m_waitTag, m_comm );
            MPI_Recv( &m_waitData, 1, MPI_INT,
                m_down, m_waitTag, m_comm,
                MPI_STATUS_IGNORE );
        }
    }
    else
    {
        MPI_Send( &(m_waitData), 1, MPI_INT,
            m_up, m_waitTag, m_comm );
    }
    #endif
}


#endif
// MPITOOLS_CPP_UNIVERSITY_OF_OREGON_NIC
