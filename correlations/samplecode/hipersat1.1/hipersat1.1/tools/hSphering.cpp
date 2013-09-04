// hipersat headers
#include "hSphering.h"
#include "sphering_matrix.h"
#include "DataReader.h"
#include "DataWriter.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "average.h"
#include "center_data.h"
#include "version.h"

#ifdef __DISTRIBUTED
#include "MPIWrapper.h"
#endif

// standard headers
#include <iostream>
#include <fstream>
#include <string>

int main( int argc, char** argv )
{
    int rank = 0;
    int size = 1;
#ifdef __DISTRIBUTED
    MPI_Init( &argc, &argv );
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
    MPI_Comm_size( MPI_COMM_WORLD, &size );
#endif
    SimpleCLParser clParser( argc, argv );
    setupParser( clParser);
    if ( rank == 0 )
    {
        cout << clParser.usageHeader() << endl;
    }
    // read the data
    NicMatrix<double>* inputData = readData( clParser );
    NicVector<double>* avg = new NicVector<double>( inputData->rows );

    // compute the average and center the data
    average( inputData, avg );
    center_data( inputData, avg );

    // compute the sphering matrix
    NicMatrix<double>* spheringMatrix = 
        new NicMatrix<double>( inputData->rows, inputData->rows );
    computeSpheringMatrix( inputData, spheringMatrix, false );

    // output the data
    writeData( clParser, spheringMatrix );
#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif
}


// sets up the options that the command line parser recognizes, 
// then parses the options
void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT Sphering v. 1.1.alpha (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );

    // file io options
    parser.addOption( SimpleCLParser::STRING, "-i", "input file", isRequired );
    parser.addOption( SimpleCLParser::STRING, "-o", "output file", isRequired );


    // number of samples and channels
    parser.addOption( SimpleCLParser::INTEGER, "-c", "number of channels", isRequired );
    parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples", isRequired );
    
    // format of the data
    parser.addOption( SimpleCLParser::STRING, "-ie", "input binary data format (big or little)", isNotRequired );
    parser.addOption( SimpleCLParser::STRING, "-oe", "output binary data format (big or little)", isNotRequired );
    parser.addOption( SimpleCLParser::FLAG, "-it", "input is text", isNotRequired );
    parser.addOption( SimpleCLParser::FLAG, "-ot", "output is text", isNotRequired );

    parser.addOption( SimpleCLParser::FLAG, "-h", "prints usage", isNotRequired );

    parser.parse();
    std::cout << parser.getSetOptions() << std::endl;

    if ( parser.readFlagOption("-h") )
    {
        std::cout << parser.usage() << std::endl;
        exit( 0 );
    }

    parser.checkRequired();
}

// reads the input matrix
NicMatrix<double>* readData( SimpleCLParser& parser )
{
    // open the input stream
    ifstream file( 
        parser.readStringOption("-i").c_str(),
        parser.readFlagOption("-t") ? std::ios::in  : std::ios::binary );
    if ( !file )
    {
        std::string message( "Unable to open input file " );
        exitOnError( (message + parser.readStringOption( "-i" )).c_str() );
        // program terminates with exitOnError
    }

    // set up the data reader
    std::string type = parser.readStringOption("-ie");
    DataReader<double>::Endian dataEndian;
    DataReader<double>::Format dataFormat;
    if ( type == "big" )
    {
        dataEndian = DataReader<double>::BigEndian;
    } else if ( type == "little" )
    {
        dataEndian = DataReader<double>::LittleEndian;
    }
    else
    {
        dataEndian = DataReader<double>::NativeEndian;
    }
    if ( parser.readFlagOption( "-it" ) )
    {
        dataFormat = DataReader<double>::Ascii;
    }
    else
    {   
        dataFormat = DataReader<double>::Binary;
    }
    DataReader<double> reader( file, dataFormat, dataEndian );

    // create the NicMatrix<double>
    NicMatrix<double>* matrix = 
        new NicMatrix<double>( 
            parser.readIntOption( "-c" ), parser.readIntOption( "-s" ) );
    double* data = matrix->data;
    std::cout << parser.readIntOption( "-c" ) << " " << 
        parser.readIntOption( "-s" ) << std::endl;

    // read the data
    while ( reader.read( data ) ) 
    {
        ++data;
    }


    return matrix;
}

void writeData( SimpleCLParser& parser, NicMatrix<double>* data )
{
    std::ofstream file(
        parser.readStringOption("-o").c_str(),
        parser.readFlagOption("-t") ? std::ios::out : std::ios::binary );
    if ( !file )
    {
        std::string message( "Unable to open output file " );
        exitOnError( (message + parser.readStringOption( "-o" )).c_str() );
        // program terminates with exitOnError
    }

    std::string type = parser.readStringOption( "-oe" );
    DataWriter<double>::Endian dataEndian;
    DataWriter<double>::Format dataFormat;
    if ( type == "big" )
    {
        dataEndian = DataWriter<double>::BigEndian;
    } 
    else if ( type == "little" )
    {
        dataEndian = DataWriter<double>::LittleEndian;
    }
    else
    {
        dataEndian = DataWriter<double>::NativeEndian;
    }

    if ( parser.readFlagOption( "-ot" ) )
    {
        dataFormat = DataWriter<double>::Ascii;
    }
    else
    {
        dataFormat = DataWriter<double>::Binary;
    }
    DataWriter<double> writer( file, dataFormat, dataEndian );
    int size = data->rows * data->columns;
    double* rawData = data->data;
    for ( int i = 0; i < data->columns; ++i )
    {
        for ( int j = 0; j < data->rows; ++j )
        {
            writer.write( rawData );
            ++rawData;
        }
        writer.linebreak();
    }
}
    

void exitOnError( const char* message )
{
    std::cerr << message << std::endl;
    std::cerr << "Exiting." << std::endl;
    exit( 1 );
}
