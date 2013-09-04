#ifndef TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC
#define TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "nic_matrix.h"
#include "nic_vector.h"
#include "MatrixReader.h"
#include "sphering_matrix.h"
#include "covariance.h"
#include "DataReader.h"
#include "MatrixOperations.h"
#include "eigenstuff.h"
#include "MPIWrapper.h"

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    parser.addOption( SimpleCLParser::STRING, "-icen", "centered data", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-isph", "sphering data", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-icov", "covariance data", isRequired );

    parser.addOption( SimpleCLParser::FLAG, "-infomax", "use Infomax sphering" );

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
#ifdef __DISTRIBUTED
    MPI_Init( &argc, &argv );
#endif
    int rank = 0;
    int size = 1;

    // set up the parser
    SimpleCLParser clParser( argc, argv );
    setupParser( clParser );

    // read the data
    int channels = clParser.readIntOption( "-c" );
    int samples = clParser.readIntOption( "-s" );

    nic_matrix centered;
    nic_matrix cov;
    nic_matrix sphering;
    nic_matrix eigenvectors( channels, channels );
    nic_vector eigenvalues( channels );
    nic_matrix computedSphering( channels, channels );
    
    bool loaded;

    loaded = MatrixReader::loadMatrix(
        centered,
        MatrixReader::BIG,
        channels,
        samples,
        clParser.readStringOption( "-icen" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-icen" )
            << endl;
    }

    loaded = MatrixReader::loadMatrix(
        cov,
        MatrixReader::BIG,
        channels,
        channels,
        clParser.readStringOption( "-icov" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-icov" )
            << endl;
    }


    loaded = MatrixReader::loadMatrix(
        sphering,
        MatrixReader::BIG,
        channels,
        channels,
        clParser.readStringOption( "-isph" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-isph" )
            << endl;
    }


    // run our method
    bool useInfomax = clParser.readFlagOption( "-infomax" );
    cout << "Testing compute_sphering()" << endl;
    compute_sphering( 
        &cov, 
        &computedSphering, 
        &eigenvectors, 
        &eigenvalues, 
        useInfomax );

    // check our computation against the data
    double error;
    
    for ( int i = 0 ; i < sphering.size; ++i )
    {
        error = min(
            fabs( sphering.data[i] - computedSphering.data[i] ),
            fabs( sphering.data[i] + computedSphering.data[i] ) );
        assert( ( error < 1e-3 ) );
    } 

    cout << "   compute_sphering() passed" << endl;

    cout << "Testing computeSpheringMatrix()" << endl;
    computeSpheringMatrix( &centered, &computedSphering, useInfomax );
    for ( int i = 0 ; i < sphering.size; ++i )
    {
        error = min(
            fabs( sphering.data[i] - computedSphering.data[i] ),
            fabs( sphering.data[i] + computedSphering.data[i] ) );
        assert( ( error < 1e-3 ) );
    } 
    cout << "   computeSpheringMatrix() passed" << endl;


    return 0;
#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif
}

#endif
// TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC
