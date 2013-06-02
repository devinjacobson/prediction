#ifndef NICFASTICA_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICFASTICA_CPP_UNIVERSITY_OF_OREGON_NIC

#include "hFastICA.h"
#include "covariance.h"
#include "sphering_matrix.h"
#include "center_data.h"
#include "FastICANew.h"
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "MPIWrapper.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "ContrastFunctions.h"
#include "MatrixOperations.h"
#include "average.h"
#include "PartitionedDataset.h"
#include "version.h"
#include "DataFormat.h"
#include "ProgramTools.h"

#include <string>

using namespace std;

class FastICAProgram : public ProgramTools
{
public:
    FastICAProgram( int argc, char** argv )
    : ProgramTools( argc, argv )
    {
    }

    virtual void setupParser()
    {
        bool isRequired = true;
        bool notRequired = false;

        // usage and copyright info
        string usage = "\nHiPerSAT FastICA v. 1.1.alpha (r";
        usage += hipersatVersionString();
        usage +=  ")\n\n";
        usage += NIC_COPYRIGHT;
        m_parser.addUsageHeader( usage );


        // input file options
        m_parser.addOption( SimpleCLParser::STRING, 
            "-i", "input data file name", 
            isRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-if", "input data format ( big, little, native, text )", 
            isRequired );
        m_parser.addOption( SimpleCLParser::INTEGER, 
            "-c", "number of input channels", 
            isRequired );
        m_parser.addOption( SimpleCLParser::INTEGER, 
            "-s", "number of samples per channel", 
            isRequired );

        m_parser.addOption( SimpleCLParser::FLAG, 
            "-single", "use single precision computations", 
            notRequired );

        // output options
        m_parser.addOption( SimpleCLParser::STRING, 
            "-o", "unmixed data file name", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-om", "mixing matrix file name", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-ow", "unmixing matrix file name", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-os", "sphering matrix file name", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-og", "weight matrix file name", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-of", "output data format ( big, little, native, text )", 
            notRequired );

        // sphering options
        m_parser.addOption( SimpleCLParser::FLAG, 
            "-sphering", "compute sphering matrix from input data", notRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-is", "load precomputed sphering matrix from file", notRequired );

        // FastICA options
        m_parser.addOption( SimpleCLParser::DOUBLE, 
            "-t", "convergence tolerance", isRequired );
        m_parser.addOption( SimpleCLParser::INTEGER, 
            "-I", "maximum numer of iterations per channel", isRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-C", "contrast function ( cubic, hyptan, gaussian )", isRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-g", "weight matrix initialization type ( identity, random, user )", isRequired );
        m_parser.addOption( SimpleCLParser::STRING, 
            "-ig", "weight matrix initialization file name", notRequired );
        m_parser.addOption( SimpleCLParser::INTEGER, 
            "-r", "maximum number of retries (using random restarts)", isRequired );

        setup();

    }
};

template <class T>
int mainWrapper( SimpleCLParser& parser, int rank, int size )
{
    int rows = parser.readIntOption( "-c" );
    int columns = parser.readIntOption( "-s" );

    // determing the file formats
    DataFormat::DataFormat inputDataFormat = getInputFormat( parser );
    DataFormat::DataFormat outputDataFormat = getOutputFormat( parser );

    NicMatrix<T> inputData; 
    NicMatrix<T>* spheringMatrix = 0;
    NicVector<T> avg( rows );
    if ( rank == 0 )
    {
        // read the data
        MatrixReader<T>::loadMatrix(
            inputData,
            inputDataFormat,
            rows, columns,
            parser.readStringOption( "-i" ) );

        // center the data
        average( &inputData, &avg );
        center_data( &inputData, &avg );

        // compute the sphering matrix
        if ( parser.readFlagOption( "-sphering" ) ) // compute the sphering matrix
        {
            spheringMatrix = new NicMatrix<T>( rows, rows );
            computeSpheringMatrix( &inputData, spheringMatrix, false );

            multiply( *spheringMatrix, inputData ); // in memory multiplication, overwrited inputData
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
    }

    PartitionedDataset<T>::distributeMatrix( &inputData );
    PartitionedDataset<T>::broadcastMatrix( spheringMatrix );

    // FastICA
    FastICASettings<T> settings;
    loadSettings<T>( parser, settings );
    bool verbose = false;
    if ( rank == 0 ) verbose = true;
    FastICANew<T> fastIca( settings, &inputData, 123456UL, verbose );
    if ( spheringMatrix != 0 )
    {
        fastIca.setWhiteningMatrix( spheringMatrix );
    }
    fastIca.runFastICA();

    // write the data

    if ( parser.readFlagOption( "-o" ) )
    {
        PartitionedDataset<T>::gatherMatrix( &inputData );
    }

    if ( rank == 0 )
    {
        NicMatrix<T> unmixingMatrix;
        fastIca.mixingMatrix( unmixingMatrix );
        // mixing matrix
        if ( parser.readFlagOption( "-om" ) )
        {
            NicMatrix<T> mixingMatrix;
            invert<T>( unmixingMatrix, mixingMatrix );
            MatrixWriter<T>::writeMatrix(
                mixingMatrix, outputDataFormat, parser.readStringOption( "-om" ) );
                
        }

        // unmixing matrix
        if ( parser.readFlagOption( "-ow") )
        {
            MatrixWriter<T>::writeMatrix(
                unmixingMatrix, outputDataFormat, parser.readStringOption( "-ow" ) );
        }

        // sphering matrix
        if ( parser.readFlagOption( "-os" ) && spheringMatrix != 0 )
        {
            MatrixWriter<T>::writeMatrix( 
                *spheringMatrix, outputDataFormat, parser.readStringOption( "-os" ) );
        }

        if ( parser.readFlagOption( "-og" ) )
        {
            NicMatrix<T> weightMatrix;
            fastIca.mixingMatrix( weightMatrix, false );
            MatrixWriter<T>::writeMatrix(
                weightMatrix, outputDataFormat, parser.readStringOption( "-og" ) );
        }
        
        // the separated data
        if ( parser.readFlagOption( "-o" ) )
        {
            NicMatrix<T> mixingMatrix;
            NicVector<T> unmixedAverages( rows );
            fastIca.mixingMatrix( mixingMatrix, false );

            // input data is replaced with unmixed signal
            multiply( mixingMatrix, inputData, false );


            fastIca.mixingMatrix( mixingMatrix );
            // unmix the averages
            multiply( mixingMatrix, avg, unmixedAverages );

            for ( int i = 0; i < rows; ++i )
            {
                for ( int j = 0; j < columns; ++j )
                {
                    inputData( i, j ) += unmixedAverages( i );
                }
            }

            MatrixWriter<T>::writeMatrix(
                inputData, outputDataFormat, parser.readStringOption( "-o" ) );
        }
    }

    return 0;
}

int main( int argc, char** argv )
{
    FastICAProgram program( argc, argv );
    program.setupParser();

    int rank, size;

    int returnValue;
    
    if ( program.parser().readFlagOption( "-single" ) )
    {
        returnValue = mainWrapper<float>(
            program.parser(), program.MPIrank(), program.MPIsize() );
    }
    else
    {
        returnValue = mainWrapper<double>(
            program.parser(), program.MPIrank(), program.MPIsize() );
    }

    program.shutdown();
    return returnValue;
}

void setupParser( SimpleCLParser& parser, int rank )
{
    bool isRequired = true;
    bool notRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT FastICA v. 1.0 (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );


    // input file options
    parser.addOption( SimpleCLParser::STRING, "-i", "input data file name", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-if", "input data format ( big, little, native, text )", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of input channels", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples per channel", isRequired );

    parser.addOption( SimpleCLParser::FLAG, "-single", "use single precision computations", notRequired );

    // output options
    parser.addOption( SimpleCLParser::STRING, "-o", "unmixed data file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-om", "mixing matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-ow", "unmixing matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-os", "sphering matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-og", "weight matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-of", "output data format ( big, little, native, text )", notRequired );

    // sphering options
    parser.addOption( SimpleCLParser::FLAG, "-sphering", "compute sphering matrix from input data", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-is", "load precomputed sphering matrix from file", notRequired );

    // FastICA options
    parser.addOption( SimpleCLParser::DOUBLE, "-t", "convergence tolerance", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-I", "maximum numer of iterations per channel", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-C", "contrast function ( cubic, hyptan, gaussian )", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-g", "weight matrix initialization type ( identity, random, user )", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-ig", "weight matrix initialization file name", notRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-r", "maximum number of retries (using random restarts)", isRequired );

    // usage
    parser.addOption( SimpleCLParser::FLAG, "-h", "usage information", notRequired );

    parser.parse();
    if ( parser.readFlagOption( "-h" ) )
    {
        if ( rank == 0 )
        {
            cout << parser.usage() << endl;
        }
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

template <class T>
void loadSettings( SimpleCLParser& parser, FastICASettings<T>& settings)
{
    settings.convergenceTolerance = parser.readDoubleOption( "-t" );
    settings.maximumIterations = parser.readIntOption( "-I" );
    string cf = parser.readStringOption( "-C" );
    if ( cf == "cubic" )
    {
        settings.contrastFunction = ContrastFunction<T>::CUBIC;
    }
    else if ( cf == "hyptan" )
    {
        settings.contrastFunction = ContrastFunction<T>::HYPERBOLIC_TAN;
    }
    else if ( cf == "gaussian" )
    {
        settings.contrastFunction = ContrastFunction<T>::GAUSSIAN;
    }
    else
    {
        cerr << "unknown constrast function: " << cf << endl;
        cerr << "exiting" << endl;
        exit( 1 );
    }
    string initType = parser.readStringOption( "-g" );
    if ( initType == "identity" )
    {
        settings.initializationType = FastICASettings<T>::IDENTITY;
    }
    else if ( initType == "random" )
    {
        settings.initializationType = FastICASettings<T>::RANDOM;
    }
    else if ( initType == "user" )
    {
        settings.initializationType = FastICASettings<T>::USER_SPECIFIED;
    }
    else
    {
        cerr << "unknown initialization type " << initType << endl;
        cerr << "exiting" << endl;
        exit( 1 );
    }
    settings.userInitializationFile = parser.readStringOption( "-ig" );
    // TODO make this smarter
    settings.userInitializationFileFormat = DataFormat::BIG;
    settings.maximumRetries = parser.readIntOption( "-r" );
}

#endif
// NICFASTICA_CPP_UNIVERSITY_OF_OREGON_NIC
