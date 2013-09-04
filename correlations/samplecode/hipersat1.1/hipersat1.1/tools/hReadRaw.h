#ifndef NICREADRAW_H_UNIVERSITY_OF_OREGON_NIC
#define NICREADRAW_H_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h" 
#include "MatrixReader.h"
#include "MatrixWriter.h"

void setupParser( SimpleCLParser& parser );
DataFormat::DataFormat getInputFormat( SimpleCLParser& parser );
DataFormat::DataFormat getOutputFormat( SimpleCLParser& parser );

#endif
// NICREADRAW_H_UNIVERSITY_OF_OREGON_NIC
