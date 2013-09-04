#ifndef TYPEIDENTIFIER_H_UNIVERSITY_OF_OREGON_NIC
#define TYPEIDENTIFIER_H_UNIVERSITY_OF_OREGON_NIC

#ifdef __DISTRIBUTED
#include <mpi.h>
#include <string>

// MPI Trickery. This provides compile-time and
// run-time identification of MPI types for the
// development of templated parallel algorithms
// very cool and useful
template < class T >
class TypeIdentifier
{
public:
    static MPI_Datatype Type( );
    static std::string Type2String();

    static T* Type2Type( void* ptr )
        { return reinterpret_cast<T*>( ptr ); }


private:
    TypeIdentifier() {}
};

#endif
// __DISTRIBUTED

#endif
// TYPEIDENTIFIER_H_UNIVERSITY_OF_OREGON_NIC
