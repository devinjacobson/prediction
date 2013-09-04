#ifndef TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC
#define TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "nic_matrix.h"
#include "nic_vector.h"
#include "MatrixReader.h"
#include "DataReader.h"
#include "MatrixOperations.h"
#include "FastICASettings.h"
#include "FastICANew.h"
#include "ContrastFunctions.h"
#include "MPIWrapper.h"
#include "MersenneTwister.h"
#include "MPIWrapper.h"
#include "DataFormat.h"

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    parser.addOption( SimpleCLParser::STRING, "-icen", "centered data", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-isph", "sphering matrix", isRequired );

    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of channels", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples", isRequired );
    parser.addOption( SimpleCLParser::DOUBLE, "-tol", "convergence tolerance", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-maxIter", "maximum number of iterations", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-contrast", "contrast function (cubic, hyptan, gaussian)", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-init", "initialization type (identity, random, user)", isNotRequired );
    parser.addOption( SimpleCLParser::STRING, "-initFile", "file for user initialization", isNotRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-maxRetries", "maximum number of retries", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-mixingMatrix", "precomputed mixing matrix to test against", isRequired );

    parser.addOption( SimpleCLParser::FLAG, "-h", "print usage", isNotRequired );
    parser.parse();

    if ( parser.readFlagOption( "-h" ) )
    {
        cout << parser.usage() << endl;
        exit( 0 );
    }

    parser.checkRequired();
}

void loadSettings( FastICASettings<double>& settings, SimpleCLParser& parser )
{
    settings.convergenceTolerance = parser.readDoubleOption( "-tol" );
    settings.maximumIterations = parser.readIntOption( "-maxIter" );
    string cf = parser.readStringOption( "-contrast" );
    if ( cf == "cubic" )
    {
        settings.contrastFunction = ContrastFunction<double>::CUBIC;
    }
    else if ( cf == "hyptan" )
    {
        settings.contrastFunction = ContrastFunction<double>::HYPERBOLIC_TAN;
    }
    else if ( cf == "gaussian" )
    {
        settings.contrastFunction = ContrastFunction<double>::GAUSSIAN;
    }
    else
    {
        cerr << "unknown contrast function " << cf << endl;
        cerr << "exiting." << endl;
        exit(1);
    }
    string initType = parser.readStringOption( "-init" );
    if ( initType == "identity" )
    {
        settings.initializationType = FastICASettings<double>::IDENTITY;
    }
    else if ( initType == "random" )
    {
        settings.initializationType = FastICASettings<double>::RANDOM;
    }
    else if ( initType == "user" )
    {
        settings.initializationType = FastICASettings<double>::USER_SPECIFIED;
    }
    else
    {
        cerr << "unknown initialization type " << initType << endl;
        cerr << "exiting" << endl;
        exit(1);
    }
    settings.userInitializationFile = parser.readStringOption( "-initFile" );
    settings.userInitializationFileFormat = DataFormat::BIG;
    settings.maximumRetries = parser.readIntOption( "-maxRetries" );
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

    nic_matrix data;
    nic_matrix sphering;
    nic_matrix mixing;
    nic_matrix invMixing;
    
    bool loaded;

    loaded = MatrixReader<double>::loadMatrix(
        data,
        DataFormat::BIG,
        channels,
        samples,
        clParser.readStringOption( "-icen" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-icen" )
            << endl;
    }

    loaded = MatrixReader<double>::loadMatrix(
        sphering,
        DataFormat::BIG,
        channels,
        channels,
        clParser.readStringOption( "-isph" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-isph" )
            << endl;
    }

    nic_matrix realMixing;

    loaded = MatrixReader<double>::loadMatrix(
        realMixing,
        DataFormat::BIG,
        channels,
        channels,
        clParser.readStringOption( "-mixingMatrix" ) );
    if ( !loaded )
    {
        cerr << "Failed to load " << clParser.readStringOption( "-mixingMatrix" )
            << endl;
    }

    // load the settings into the settings object
    FastICASettings<double> settings;
    loadSettings( settings, clParser );

    // run our method
    cout << "Testing FastICA" << endl;
    FastICANew<double> fastIca( settings, &data, 123456UL, true );
    fastIca.setWhiteningMatrix( &sphering );
    fastIca.runFastICA();
    
    fastIca.mixingMatrix( mixing );
    invert( mixing, invMixing );

    double error;
    double tolerance = 1e-6;
    for ( int i = 0; i < mixing.rows; ++i )
    {
        for ( int j = 0; j < mixing.columns; ++j )
        {
            error = fabs( invMixing(i,j) - realMixing(j,i) );
            if ( !(error < tolerance ))
            {
                cout  << i << " " << invMixing(i,j) << " " << realMixing(j,i) <<
                    " " << error << endl;
            }
            assert( fabs( invMixing(i,j) - realMixing(j,i) ) < tolerance );
        }
    }

    cout << "   FastICA passed" << endl;

    return 0;
#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif
}

#endif
// TESTSPHERING_CPP_UNIVERSITY_OF_OREGON_NIC
