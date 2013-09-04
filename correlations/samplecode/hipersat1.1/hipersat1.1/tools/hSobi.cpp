#ifndef NICSOBI_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICSOBI_CPP_UNIVERSITY_OF_OREGON_NIC

#include "hSobi.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "Sobi.h"
#include "version.h"
#include "sphering_matrix.h"
#include "center_data.h"
#include "average.h"
#include "MatrixOperations.h"
#include "RangeGenerator.h"
#include <vector>

template <class T>
int mainWrapper( SimpleCLParser& parser )
{
    // determing the input data size and format
    int rows = parser.readIntOption( "-c" );
    int columns = parser.readIntOption( "-s" );

    DataFormat::DataFormat inputDataFormat = getInputFormat( parser );
    DataFormat::DataFormat outputDataFormat = getOutputFormat( parser );

    // load the data
    NicMatrix<T> inputData;
    MatrixReader<T>::loadMatrix(
        inputData,
        inputDataFormat,
        rows, columns,
        parser.readStringOption( "-i" ) );

    // center the data
    NicVector<T> avg( rows );
    average( &inputData, &avg );
    center_data( &inputData, &avg );

    // compute the sphering matrix
    NicMatrix<T>* spheringMatrix;
    if ( parser.readFlagOption( "-sphering" ) )
    {
        spheringMatrix = new NicMatrix<T>( rows, rows );
        computeSpheringMatrix( &inputData, spheringMatrix, true );
        multiply( *spheringMatrix, inputData );
    }
    else if ( parser.readFlagOption( "-is" ) )
    {
        spheringMatrix = new NicMatrix<T>( rows, rows );
        MatrixReader<T>::loadMatrix(
            *spheringMatrix,
            inputDataFormat,
            rows, rows,
            parser.readStringOption( "-is" ) );
    }
    else
    {
        spheringMatrix = new NicMatrix<T>( rows, rows );
        spheringMatrix->identity_matrix();
    }

    // setup for Sobi computation
    int* tau = 0;
    vector<int> vTau(0);
    int tauLength = 0;
    if ( parser.readFlagOption( "-tau" ) )
    {
        string sTau = parser.readStringOption( "-tau" );
        RangeGenerator<int> range( sTau );
        range.getRange( vTau );
        tau = makeTau( vTau );
        tauLength = vTau.size();
    }
    NicMatrix<T> W( rows, rows );
    NicMatrix<T> A( rows, rows );
    NicMatrix<T> G( rows, rows );

    T tolerance = 1e-6;
    if (parser.readFlagOption( "-tolerance" ))
    {
        tolerance = (T)(parser.readDoubleOption( "-tolerance" ));
    }

    std::cout << "Tolerance set to " << tolerance << std::endl;

    computeSobi( inputData, tau, tauLength, G, tolerance ); // weight matrix

    if ( tau != 0 ) delete [] tau;

    if ( spheringMatrix != 0 )
    {
        multiply( G, *spheringMatrix, W ); // unmixing matrix
    }
    else
    {
        W = G;
    }
    invert<T>( W, A );
    
    if ( parser.readFlagOption( "-ow" ) )
    {
        MatrixWriter<T>::writeMatrix(
            W,
            outputDataFormat,
            parser.readStringOption( "-ow" ) );

    }

    if ( parser.readFlagOption( "-om" ) )
    {
        MatrixWriter<T>::writeMatrix(
            A,
            outputDataFormat,
            parser.readStringOption( "-om" ) );
    }

    if ( parser.readFlagOption( "-og" ) )
    {
        MatrixWriter<T>::writeMatrix(
            G,
            outputDataFormat,
            parser.readStringOption( "-og" ) );

    }

    if ( parser.readFlagOption( "-os" ) )
    {
        MatrixWriter<T>::writeMatrix(
            *spheringMatrix,
            outputDataFormat,
            parser.readStringOption( "-os" ) );

    }

    if ( spheringMatrix != 0 ) delete spheringMatrix;
    return 0;
}

int main( int argc, char** argv )
{
    // setup the parser
    SimpleCLParser parser( argc, argv );
    setupParser( parser );
    cout << parser.usageHeader() << endl;

    if ( parser.readFlagOption( "-single" ) )
    {
        mainWrapper<float>( parser );
    }
    else
    {
        mainWrapper<double>( parser );
    }

}

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool notRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT Sobi v. 1.1.alpha (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );

    // input file options
    parser.addOption( SimpleCLParser::STRING,
                      "-i", 
                      "input file name", 
                      isRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-if", 
                      "input data format ( big, little, native, text )",
                      isRequired );
    parser.addOption( SimpleCLParser::INTEGER,
                      "-c",
                      "number of channels",
                      isRequired );
    parser.addOption( SimpleCLParser::INTEGER,
                      "-s",
                      "number of samples",
                      isRequired );
    parser.addOption( SimpleCLParser::FLAG,
                      "-sphering",
                      "sphere the data",
                      notRequired );

    parser.addOption( SimpleCLParser::FLAG,
                      "-single",
                      "data and computation is single precision (float)",
                      notRequired ); 

    // output options
    parser.addOption( SimpleCLParser::STRING,
                      "-og",
                      "output file name for weight matrix",
                      notRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-om",
                      "output file name for mixing matrix",
                      notRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-os",
                      "output file name for sphering matrix",
                      notRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-ow",
                      "output file name for unmixing matrix",
                      notRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-of",
                      "output data format ( big, little, native, text )",
                      isRequired );

    // Sobi options
    parser.addOption( SimpleCLParser::STRING,
                      "-tau",
                      "tau vector description- lower_value:step:upper_value",
                      notRequired );

    parser.addOption( SimpleCLParser::DOUBLE,
                      "-tolerance",
                      "the convergence tolerance (default 1e-6)",
                      notRequired );

    // help and usage
    parser.addOption( SimpleCLParser::FLAG, "-h", "usage", notRequired );

    parser.parse();
    if ( parser.readFlagOption( "-h" ) )
    {
        cout << parser.usage() << endl;
        exit( 0 );
    }

    parser.checkRequired();
}

DataFormat::DataFormat getInputFormat( SimpleCLParser& parser )
{
    string formatString = parser.readStringOption( "-if" );
    DataFormat::DataFormat returnValue;
    if ( formatString == "big" )
    {
        returnValue = DataFormat::BIG;
    }
    else if ( formatString == "little" )
    {
        returnValue = DataFormat::LITTLE;
    }
    else if ( formatString == "native" )
    {
        returnValue = DataFormat::NATIVE;
    }
    else if ( formatString == "text" )
    {
        returnValue = DataFormat::TEXT;
    }
    else
    {
        cerr << "Invalid file type: " << formatString << endl;
        exit(1);
    }
    return returnValue;
}

DataFormat::DataFormat getOutputFormat( SimpleCLParser& parser )
{
    DataFormat::DataFormat format = DataFormat::TEXT;

    if ( parser.readFlagOption( "-of" ) )
    {
        string formatName = parser.readStringOption( "-of" );
        if ( formatName == "big" )
        {
            format = DataFormat::BIG;
        }
        else if ( formatName == "little" )
        {
            format = DataFormat::LITTLE;
        }
        else if ( formatName == "native" )
        {
            format = DataFormat::NATIVE;
        }
        else if ( formatName == "text" )
        {
            format = DataFormat::TEXT;
        }
        else 
        {
            cerr << "Invalid output type. Defaulting to text" << endl;
        }
    }
    return format;
}

#endif
// NICSOBI_CPP_UNIVERSITY_OF_OREGON_NIC
