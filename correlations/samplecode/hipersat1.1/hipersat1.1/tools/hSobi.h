#ifndef NICSOBI_H_UNIVERSITY_OF_OREGON_NIC
#define NICSOBI_H_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "DataFormat.h"

void setupParser( SimpleCLParser& parser );
DataFormat::DataFormat getInputFormat( SimpleCLParser& parser );
DataFormat::DataFormat getOutputFormat( SimpleCLParser& parser );

#endif
// NICSOBI_H_UNIVERSITY_OF_OREGON_NIC
