#ifndef NICFASTICA_H_UNIVERSITY_OF_OREGON_NIC
#define NICFASTICA_H_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "FastICASettings.h"
#include "DataFormat.h"

void setupParser( SimpleCLParser& parser, int rank );
DataFormat::DataFormat getInputFormat( SimpleCLParser& parser );
DataFormat::DataFormat getOutputFormat( SimpleCLParser& parser );

template <class T>
void loadSettings( SimpleCLParser& parser, FastICASettings<T>& settings );

#endif
// NICFASTICA_H_UNIVERSITY_OF_OREGON_NIC
