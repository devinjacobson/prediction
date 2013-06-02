#ifndef TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC
#define TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "nic_matrix.h"
#include "nic_vector.h"
#include "DataReader.h"
#include <math.h>

#include "covariance.h"

#include <iostream>
#include <fstream>
#include <string>

#ifdef __DISTRIBUTED
#include "MPIWrapper.h"
#include "PartitionedDataset.h"
#endif

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    parser.addOption( SimpleCLParser::STRING, "-io", "original input", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-ic", "covariance input", isRequired );

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
    int rank = 0;
    int size = 1;
#ifdef __DISTRIBUTED
    MPI_Init( &argc, &argv );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );
#endif
    // set up the parser
    SimpleCLParser clParser( argc, argv );
    setupParser( clParser );

    // read the data
    int channels = clParser.readIntOption( "-c" );
    int samples = clParser.readIntOption( "-s" );

    nic_matrix* original = 0;
    nic_matrix* cov = new nic_matrix( channels, channels );

    if ( rank == 0 )
    {

        // set up the file streams
        string originalFileName = clParser.readStringOption( "-io" );
        ifstream originalFile( originalFileName.c_str(), ios::binary );
        if ( !originalFile )
        {
            std::cerr << "Error opening file " << originalFileName << std::endl;
        }

        string covarianceFileName = clParser.readStringOption( "-ic" );
        ifstream covarianceFile( covarianceFileName.c_str(), ios::binary );
        if ( !covarianceFile )
        {
            std::cerr << "Error opening file " << covarianceFileName << std::endl;
        }


        DataReader<double> originalReader( 
            originalFile,
            DataReader<double>::Binary, 
            DataReader<double>::BigEndian );
        original = new nic_matrix( channels, samples );
        double* data = original->data;
        while( originalReader.read( data ) ) ++data;

        DataReader<double> covarianceReader(
            covarianceFile,
            DataReader<double>::Binary,
            DataReader<double>::BigEndian );
        data = cov->data;
        while( covarianceReader.read( data ) ) ++data;
    }
    else
    {
        // create an empty original
        original = new nic_matrix();
    }
#ifdef __DISTRIBUTED
    // send the original covariance data to the workers
    MPI_Bcast( cov->data, cov->size, MPI_DOUBLE, 0, MPI_COMM_WORLD );

    // distribute the input data to the workers
    PartitionedDataset::distributeMatrix( original );
#endif

    cout << "Testing covariance()" << std::endl;
    // run our method
    nic_vector rowAverage( channels );
    nic_matrix computedCovariance( channels, channels );
    covariance( original, &computedCovariance, &rowAverage );

    // check our computation against the data
    for ( int i = 0; i < channels * channels; ++i )
    {
        assert( fabs( cov->data[i] - computedCovariance.data[i] ) < 1e-4 );
    }
    cout << "   covariance() passed" << std::endl;

#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif

    return 0;
}

#endif
// TESTCENTERDATA_CPP_UNIVERSITY_OF_OREGON_NIC
