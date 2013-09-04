#ifndef NICINFOMAX_H_UNIVERSITY_OF_OREGON_NIC
#define NICINFOMAX_H_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "InfomaxSettings.h"
#include "DataFormat.h"

void setupParser( SimpleCLParser& parser, int rank );
DataFormat::DataFormat getInputFormat( SimpleCLParser& parser );
DataFormat::DataFormat getOutputFormat( SimpleCLParser& parser );
template <class T>
void loadSettings( SimpleCLParser& parser, InfomaxSettings<T>& settings );

#endif
// NICINFOMAX_H_UNIVERSITY_OF_OREGON_NIC
