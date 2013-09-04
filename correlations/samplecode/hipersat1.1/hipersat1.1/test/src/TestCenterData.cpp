#ifndef TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC
#define TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC

#include "center_data.h"
#include "SimpleCLParser.h"
#include "nic_matrix.h"
#include "nic_vector.h"
#include "average.h"
#include "DataReader.h"


#include <iostream>
#include <fstream>
#include <string>
#include <math.h>

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    parser.addOption( SimpleCLParser::STRING, "-io", "original input", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-ic", "centered input", isRequired );

    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of channels", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples", isRequired );

    parser.addOption( SimpleCLParser::FLAG, "-h", "print usage", isNotRequired );
    parser.parse();

    if ( parser.readFlagOption( "-h" ) )
    {
        cout << parser.usage() << endl;
        exit( 0 );
    }

    parser.checkRequired();
}

int main( int argc, char** argv )
{
    // set up the parser
    SimpleCLParser clParser( argc, argv );
    setupParser( clParser );

    // set up the file streams
    string originalFileName = clParser.readStringOption( "-io" );
    ifstream originalFile( originalFileName.c_str(), ios::binary );
    if ( !originalFile )
    {
        std::cerr << "Error opening file " << originalFileName << std::endl;
    }

    string centeredFileName = clParser.readStringOption( "-ic" );
    ifstream centeredFile( centeredFileName.c_str(), ios::binary );
    if ( !centeredFile )
    {
        std::cerr << "Error opening file " << centeredFileName << std::endl;
    }

    // read the data
    int channels = clParser.readIntOption( "-c" );
    int samples = clParser.readIntOption( "-s" );

    DataReader<double> originalReader( 
        originalFile,
        DataReader<double>::Binary, 
        DataReader<double>::BigEndian );
    nic_matrix original( channels, samples );
    double* data = original.data;
    while( originalReader.read( data ) ) ++data;

    DataReader<double> centeredReader(
        centeredFile,
        DataReader<double>::Binary,
        DataReader<double>::BigEndian );
    nic_matrix centered( channels, samples );
    data = centered.data;
    while( centeredReader.read( data ) ) ++data;

    cout << "Testing average() and center_data()" << std::endl;
    // run our method
    nic_vector rowAverage( channels );
    average( &original, &rowAverage );
    center_data( &original, &rowAverage );

    // check our computation against the data
    for ( int i = 0; i < channels * samples; ++i )
    {
//        cout <<  fabs( centered.data[i] - original.data[i] ) << endl;
        assert( fabs( centered.data[i] - original.data[i] ) < 1e-4 );
    }
    cout << "   average() and center_data() passed" << std::endl;

    return 0;
}

#endif
// TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC
