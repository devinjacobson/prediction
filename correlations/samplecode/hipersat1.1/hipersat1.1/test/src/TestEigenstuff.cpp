#ifndef TESTEIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC
#define TESTEIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include "nic_matrix.h"
#include "nic_vector.h"
#include "eigenstuff.h"
#include "DataReader.h"


#include <iostream>
#include <fstream>
#include <string>

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    parser.addOption( SimpleCLParser::STRING, "-icov", "original covariance input", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-ivec", "eigenvectors input", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-ival", "eigenvalues input", isRequired );

    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of channels", isRequired );

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
    string covarianceFileName = clParser.readStringOption( "-icov" );
    ifstream covarianceFile( covarianceFileName.c_str(), ios::binary );
    if ( !covarianceFile )
    {
        std::cerr << "Error opening file " << covarianceFileName << std::endl;
        exit( 0 );
    }

    string eigenvectorFileName = clParser.readStringOption( "-ivec" );
    ifstream eigenvectorFile( eigenvectorFileName.c_str(), ios::binary );
    if ( !eigenvectorFile )
    {
        std::cerr << "Error opening file " << eigenvectorFileName << std::endl;
        exit( 0 );
    }

    string eigenvalueFileName = clParser.readStringOption( "-ival" );
    ifstream eigenvalueFile( eigenvalueFileName.c_str(), ios::binary );
    if ( !eigenvalueFile )
    {
        std::cerr << "Error opening file " << eigenvalueFileName << std::endl;
        exit( 0 );
    }

    // read the data
    int channels = clParser.readIntOption( "-c" );

    DataReader<double> covarianceReader( 
        covarianceFile,
        DataReader<double>::Binary, 
        DataReader<double>::BigEndian );
    nic_matrix cov( channels, channels );
    double* data = cov.data;
    while( covarianceReader.read( data ) ) ++data;

    DataReader<double> eigenvectorReader(
        eigenvectorFile,
        DataReader<double>::Binary,
        DataReader<double>::BigEndian );
    nic_matrix eigenvectors( channels, channels );
    data = eigenvectors.data;
    while( eigenvectorReader.read( data ) ) ++data;

    DataReader<double> eigenvalueReader(
        eigenvalueFile,
        DataReader<double>::Binary,
        DataReader<double>::BigEndian );
    nic_matrix eigenvalues( channels, channels );
    data = eigenvalues.data;
    while (eigenvalueReader.read( data ) ) ++data;

    cout << "Testing eigenstuff()" << std::endl;
    // run our method
    nic_vector computedEigenvalues( channels );
    nic_matrix computedEigenvectors;
    computedEigenvectors = cov;

    compute_eigenstuff( &computedEigenvectors, &computedEigenvalues );

    // check our computation against the data
    for ( int i = 0; i < channels; ++i )
    {
        assert( fabs( computedEigenvalues.data[i] - eigenvalues(i,i) ) < 1e-6 );
        for ( int j = 0; j < channels; ++j )
        {
            assert( 
                ( fabs( computedEigenvectors(i, j) - eigenvectors(i, j) ) < 1e-6 )
                ||
                ( fabs( computedEigenvectors(i, j) + eigenvectors(i, j) ) < 1e-6 ));
        }
    }
    cout << "   eigenstuff() passed" << std::endl;

    return 0;
}

#endif
// TESTEIGENSTUFF_CPP_UNIVERSITY_OF_OREGON_NIC
