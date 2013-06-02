#ifndef NICINFOMAX_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICINFOMAX_CPP_UNIVERSITY_OF_OREGON_NIC


#include "hInfomax.h"
#include "covariance.h"
#include "sphering_matrix.h"
#include "center_data.h"
#include "InfomaxNew.h"
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "MPIWrapper.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "ContrastFunctions.h"
#include "MatrixOperations.h"
#include "average.h"
#include "version.h"
#include "SortComponents.h"
#include "DataFormat.h"

#include <string>

using namespace std;

template <class T>
int mainWrapper( SimpleCLParser& parser )
{
    int rank = 0;
    int rows = parser.readIntOption( "-c" );
    int columns = parser.readIntOption( "-s" );

    // determing the file formats
    DataFormat::DataFormat inputDataFormat = getInputFormat( parser );
    DataFormat::DataFormat outputDataFormat = getOutputFormat( parser );

    NicMatrix<T> inputData; 
    NicMatrix<T>* spheringMatrix = 0;
    // read the data
    std::cout << "reading matrix" << std::endl;
    MatrixReader<T>::loadMatrix(
        inputData,
        inputDataFormat,
        rows, columns,
        parser.readStringOption( "-i" ) );

    // center the data
    NicVector<T> avg( rows );
    average( &inputData, &avg );
    center_data( &inputData, &avg );

    std::cout << rows << std::endl;

    // compute the sphering matrix
    if ( parser.readFlagOption( "-sphering" ) ) // compute the sphering matrix
    {
        spheringMatrix = new NicMatrix<T>( rows, rows );
        computeSpheringMatrix( &inputData, spheringMatrix, true );

        multiply( *spheringMatrix, inputData ); // in memory multiplication, overwrite inputData
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

    // Infomax
    InfomaxSettings<T> settings;
    loadSettings( parser, settings );
    bool verbose = false;
    if ( rank == 0 ) verbose = true;
    unsigned long seed = 123456UL;
    if ( parser.readFlagOption( "-seed" ) )
    {
        seed = parser.readIntOption( "-seed" );
    }
    InfomaxNew<T> infomax( settings, &inputData, seed, verbose );
    if ( spheringMatrix != 0 )
    {
        infomax.setWhiteningMatrix( spheringMatrix );
    }
    infomax.runInfomax();
    NicMatrix<T> mixingMatrix;

    infomax.posact( inputData, mixingMatrix );
    sortComponents( inputData, mixingMatrix, *spheringMatrix );

    // write the data

    NicMatrix<T> unmixingMatrix = mixingMatrix;
    //infomax.mixingMatrix( unmixingMatrix );

    // unmixing matrix
    if ( parser.readFlagOption( "-om" ) )
    {
        NicMatrix<T> mixingMatrix;
        invert<T>( unmixingMatrix, mixingMatrix );
        MatrixWriter<T>::writeMatrix(
            mixingMatrix, outputDataFormat, parser.readStringOption("-om"));
    }

    if ( parser.readFlagOption( "-ow" ) )
    {
        MatrixWriter<T>::writeMatrix(
            unmixingMatrix, outputDataFormat, parser.readStringOption("-ow"));
    }

    // sphering matrix
    if ( parser.readFlagOption( "-os" ) && spheringMatrix != 0 )
    {
        MatrixWriter<T>::writeMatrix( 
            *spheringMatrix, outputDataFormat, parser.readStringOption("-os"));
    }

    if ( parser.readFlagOption( "-og" ) )
    {
        NicMatrix<T> weightMatrix( rows, rows );
        //infomax.mixingMatrix( weightMatrix, false );
        NicMatrix<T> invSphering( rows, rows );
        if ( spheringMatrix != 0 )
        {
            invert<T>( *spheringMatrix, invSphering );
            multiply( unmixingMatrix, invSphering, weightMatrix );
        }
        else
        {
            weightMatrix = unmixingMatrix;
        }

        MatrixWriter<T>::writeMatrix(
            weightMatrix, outputDataFormat, parser.readStringOption("-og"));
    }
    
        // the separated data
        if ( parser.readFlagOption( "-o" ) )
        {
            NicMatrix<T> mixingMatrix;
            NicVector<T> unmixedAverages( rows );
            infomax.mixingMatrix( mixingMatrix, false );

            // input data is replaced with unmixed signal
            multiply( mixingMatrix, inputData, false );


            infomax.mixingMatrix( mixingMatrix );
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

    return 0;
}

int main( int argc, char** argv )
{
    int rank = 0;
    int size = 0;
    SimpleCLParser parser( argc, argv );

    setupParser( parser, rank );
    cout << parser.usageHeader() << endl;

    int returnValue;
    if ( parser.readFlagOption( "-single" ) || (parser.readStringOption("-if") == "raw" ))
    {
        returnValue = mainWrapper<float>( parser );
    }
    else
    {
        returnValue = mainWrapper<double>( parser );
    }

    return returnValue;
}

void setupParser( SimpleCLParser& parser, int rank )
{
    bool isRequired = true;
    bool notRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT Infomax v. 1.1.alpha (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );


    // input file options
    parser.addOption( SimpleCLParser::STRING, "-i", "input data file name", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-if", "input data format ( big, little, native, text, raw )", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of input channels", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples per channel", isRequired );

    parser.addOption( SimpleCLParser::STRING, "-is", "input sphering matrix" , notRequired );

    // output options
    parser.addOption( SimpleCLParser::STRING, "-o", "unmixed data file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-om", "mixing matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-ow", "unmixing matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-os", "sphering matrix file name", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-og", "weight matrix file name", notRequired );

    parser.addOption( SimpleCLParser::STRING, "-of", "output data format ( big, little, native, text )", notRequired );

    // infomax options
//    parser.addOption( SimpleCLParser::FLAG, "-extended", "use extended infomax", notRequired );
//    parser.addOption( SimpleCLParser::FLAG, "-pca", "principal component analysis", notRequired );
//    parser.addOption( SimpleCLParser::INT, "-ncomps", "number if ICA components to compute (default channels)", notRequired );
    parser.addOption( SimpleCLParser::FLAG, "-sphering", "flag sphering of data", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-g", "initial weight matrix (identity, random, user)", notRequired );
    parser.addOption( SimpleCLParser::STRING, "-ig", "file name for user weights", notRequired );
    parser.addOption( SimpleCLParser::DOUBLE, "-lrate", "initial ICA learning rate << 1 (default heuristic)", notRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-block", "ICA block size (default heuristic)", notRequired );
    parser.addOption( SimpleCLParser::DOUBLE, "-anneal", "annealing constant (default 0.90)", notRequired );
    parser.addOption( SimpleCLParser::DOUBLE, "-annealdeg", "annealing degree weight change (default 70)", notRequired );
    parser.addOption( SimpleCLParser::DOUBLE, "-stop", "weight change tolerance to stop training (default for channels < 34, 1e-6, else 1e-7)", notRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-maxsteps", "maximum number of ICA training steps", notRequired );
    parser.addOption( SimpleCLParser::FLAG, "-verbose", "give ascii messages of progress", notRequired );

    parser.addOption( SimpleCLParser::INTEGER, "-seed", "seed for random number generator (default 123456)", notRequired );

    parser.addOption( SimpleCLParser::FLAG, "-single", "use single precision for computations", notRequired );
    // usage
    parser.addOption( SimpleCLParser::FLAG, "-h", "usage information", notRequired );

    parser.parse();
    if ( parser.readFlagOption( "-h" ) )
    {
        cout << parser.usage() << endl;
        exit(0);
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
    else if ( formatString == "raw" )
    {
        returnValue = DataFormat::RAW;
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
void loadSettings( SimpleCLParser& parser, InfomaxSettings<T>& settings)
{
    if ( parser.readFlagOption( "-g" ) )
    {
        string value = parser.readStringOption( "-g" );
        if ( value == "identity" )
        {
            settings.initializationType = InfomaxSettings<T>::IDENTITY;
        }
        else if ( value == "random" )
        {
            settings.initializationType = InfomaxSettings<T>::RANDOM;
        }
        else if ( value == "user" )
        {
            settings.initializationType = InfomaxSettings<T>::USER_SPECIFIED;
            settings.userInitializationFile = parser.readStringOption( "-ig" );
        }
    }
    else
    {
        settings.initializationType = InfomaxSettings<T>::IDENTITY;
    }

    if ( parser.readFlagOption( "-lrate" ) )
    {
        settings.nnLearningRate = parser.readDoubleOption( "-lrate" );
    }
    else
    {
        T channels = parser.readIntOption( "-c" );
        settings.nnLearningRate = 0.00065 / ( log( channels ) );
    }

    if ( parser.readFlagOption( "-block" ) )
    {
        settings.nnBlockSize = parser.readIntOption( "-block" );
    }
    else
    {
        T samples = parser.readIntOption( "-s" );
        settings.nnBlockSize = (int)(ceil( 5.0*log( samples ) ) );
    }

    if ( parser.readFlagOption( "-anneal" ) )
    {
        settings.nnAnnealingScale = parser.readDoubleOption( "-anneal" );
    }
    else
    {
        settings.nnAnnealingScale = 0.90;
    }

    if ( parser.readFlagOption( "-annealdeg" ) )
    {
        settings.nnAnnealingDegree = parser.readDoubleOption( "-annealdeg" );
    }
    else
    {
        settings.nnAnnealingDegree = 70.0;
    }

    if ( parser.readFlagOption( "-stop" ) )
    {
        settings.convergenceTolerance = parser.readDoubleOption( "-stop" );
    }
    else
    {
        int  channels = parser.readIntOption( "-c" );
        if ( channels < 24 ) settings.convergenceTolerance = 1e-6;
        else settings.convergenceTolerance = 1e-7;
    }

    if ( parser.readFlagOption( "-maxsteps" ) )
    {
        settings.maximumIterations = parser.readIntOption( "-maxsteps" );
    }
    else
    {
        settings.maximumIterations = 512;
    }

    settings.nnWeightRestartFactor = 0.9;
    settings.nnDivergenceFactor = 0.8;
    settings.nnMaxWeight = 1e8;
    settings.nnMinLearningRate = 0.000001;
    settings.nnMaxDivergence = 1000000000;
    settings.nnRandomLearning = true;
    
    settings.maximumRetries = 100;

    // TODO make this smarter
    settings.userInitializationFormat = DataFormat::BIG;
}

#endif
// NICINFOMAX_CPP_UNIVERSITY_OF_OREGON_NIC
