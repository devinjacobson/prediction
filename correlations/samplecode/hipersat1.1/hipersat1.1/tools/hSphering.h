#ifndef SPHERING_H_UNIVERSITY_OF_OREGON_NIC
#define SPHERING_H_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "NicMatrix.h"

void setupParser( SimpleCLParser& parser );
NicMatrix<double>*  readData( SimpleCLParser& parser );
void writeData( SimpleCLParser& parser, NicMatrix<double>* data );
void exitOnError( const char* message );

#endif
// SPHERING_H_UNIVERSITY_OF_OREGON_NIC
