#ifndef TYPEIDENTIFIER_CPP_UNIVERSITY_OF_OREGON_NIC
#define TYPEIDENTIFIER_CPP_UNIVERSITY_OF_OREGON_NIC

#ifdef __DISTRIBUTED

#include "TypeIdentifier.h"
template<> 
MPI_Datatype 
TypeIdentifier<signed char>::Type()
{
    return MPI_CHAR;
}

template<> 
MPI_Datatype 
TypeIdentifier<signed short int>::Type()
{
    return MPI_SHORT;
}

template<> 
MPI_Datatype 
TypeIdentifier<signed int>::Type()
{
    return MPI_INT;
}

template<> 
MPI_Datatype 
TypeIdentifier<signed long int>::Type()
{
    return MPI_LONG;
}

template<> 
MPI_Datatype 
TypeIdentifier<unsigned char>::Type()
{
    return MPI_UNSIGNED_CHAR;
}

template<> 
MPI_Datatype 
TypeIdentifier<unsigned short int>::Type()
{
    return MPI_UNSIGNED_SHORT;
}

template<> 
MPI_Datatype 
TypeIdentifier<unsigned int>::Type()
{
    return MPI_UNSIGNED;
}

template<> 
MPI_Datatype 
TypeIdentifier<unsigned long int>::Type()
{
    return MPI_UNSIGNED_LONG;
}

template<> 
MPI_Datatype 
TypeIdentifier<float>::Type()
{
    return MPI_FLOAT;
}

template<> 
MPI_Datatype 
TypeIdentifier<double>::Type()
{
    return MPI_DOUBLE;
}

template<> 
MPI_Datatype 
TypeIdentifier<long double>::Type()
{
    return MPI_LONG_DOUBLE;
}

template<> 
std::string
TypeIdentifier<signed char>::Type2String()
{
    return "MPI_CHAR";
}

template<> 
std::string
TypeIdentifier<signed short int>::Type2String()
{
    return "MPI_SHORT";
}

template<> 
std::string
TypeIdentifier<signed int>::Type2String()
{
    return "MPI_INT";
}

template<> 
std::string
TypeIdentifier<signed long int>::Type2String()
{
    return "MPI_LONG";
}

template<> 
std::string
TypeIdentifier<unsigned char>::Type2String()
{
    return "MPI_UNSIGNED_CHAR";
}

template<> 
std::string
TypeIdentifier<unsigned short int>::Type2String()
{
    return "MPI_UNSIGNED_SHORT";
}

template<> 
std::string
TypeIdentifier<unsigned int>::Type2String()
{
    return "MPI_UNSIGNED";
}

template<> 
std::string
TypeIdentifier<unsigned long int>::Type2String()
{
    return "MPI_UNSIGNED_LONG";
}

template<> 
std::string
TypeIdentifier<float>::Type2String()
{
    return "MPI_FLOAT";
}

template<> 
std::string
TypeIdentifier<double>::Type2String()
{
    return "MPI_DOUBLE";
}

template<> 
std::string
TypeIdentifier<long double>::Type2String()
{
    return "MPI_LONG_DOUBLE";
}

#endif
// __DISTRIBUTED

#endif
// TYPEIDENTIFIER_CPP_UNIVERSITY_OF_OREGON_NIC
