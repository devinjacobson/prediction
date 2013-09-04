#include "DataReader.h"
#include "DataWriter.h"
#include "SimpleCLParser.h"
#include <string>
#include <fstream>
#include "version.h"

using namespace std;

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool isNotRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT Convert v. 1.1.alpha (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );


    parser.addOption( 
        SimpleCLParser::STRING,
        "-i",
        "input file", 
        isRequired );

    parser.addOption(
        SimpleCLParser::STRING,
        "-o",
        "output file",
        isRequired );

    parser.addOption(
        SimpleCLParser::STRING,
        "-op",
        "output precision (single, double, default: double)",
        isNotRequired );

    parser.addOption(
        SimpleCLParser::STRING,
        "-if",
        "input format (big, little, native, text, raw)",
        isRequired );

    parser.addOption(
        SimpleCLParser::STRING,
        "-of",
        "output format (big, little, native, text, raw)",
        isRequired );

    parser.addOption(
        SimpleCLParser::STRING,
        "-ip",
        "input precision (single, double, default: double)",
        isNotRequired );

    parser.addOption(
        SimpleCLParser::FLAG,
        "-h",
        "show usage",
        isNotRequired );

    parser.addOption(
        SimpleCLParser::INTEGER,
        "-c",
        "number of channels",
        isNotRequired );


    parser.parse();
    if ( parser.readFlagOption( "-h" ) )
    {
        std::cout << parser.usage() << std::endl;
    }

    parser.checkRequired();

}

void exitOnError( const char* message )
{
    std::cerr << message << std::endl;
    std::cerr << "Exiting." << std::endl;
    exit( 1 );
}

ifstream* openInputStream( SimpleCLParser& parser )
{
    string fileName = parser.readStringOption( "-i" );
    bool isText = (parser.readStringOption( "-if" ) == "text");
    
    ifstream* newFile = new ifstream( 
        fileName.c_str(),
        isText ? ios::in : ios::binary );

    if ( !newFile )
    {
        string message( "Unable to open input file " );
        exitOnError( ( message + fileName ).c_str() );
    }
    return newFile;
}

ofstream* openOutputStream( SimpleCLParser& parser )
{
    string fileName = parser.readStringOption( "-o" );
    bool isText = (parser.readStringOption( "-of" ) == "text");
    
    ofstream* newFile = new ofstream( 
        fileName.c_str(),
        isText ? ios::out : ios::binary );

    if ( !newFile )
    {
        string message( "Unable to open output file " );
        exitOnError( ( message + fileName ).c_str() );
    }
    return newFile;
}


template <class T>
DataReader<T>* createReader( SimpleCLParser& parser, ifstream* in )
{
    string informat = parser.readStringOption( "-if" );
    typename DataReader<T>::Format format;
    typename DataReader<T>::Endian endian;
    if ( "big" == informat )
    {
        format = DataReader<T>::Binary;
        endian = DataReader<T>::BigEndian;
    }
    else if ( "little" == informat )
    {
        format = DataReader<T>::Binary;
        endian = DataReader<T>::LittleEndian;
    }
    else if ( "native" == informat )
    {
        format = DataReader<T>::Binary;
        endian = DataReader<T>::NativeEndian;
    }
    else if ( "text" == informat )
    {
        format = DataReader<T>::Ascii;
        endian = DataReader<T>::NativeEndian;
    }
    else
    {
        string message( "Unknown input file format " );
        exitOnError( ( message + informat ).c_str() );
    }

    return new DataReader<T>( *in, format, endian );
}

template <class T>
DataWriter<T>* createWriter( SimpleCLParser& parser, ofstream* out )
{
    string outformat = parser.readStringOption( "-of" );
    typename DataWriter<T>::Format format;
    typename DataWriter<T>::Endian endian;
    if ( "big" == outformat )
    {
        format = DataWriter<T>::Binary;
        endian = DataWriter<T>::BigEndian;
    }
    else if ( "little" == outformat )
    {
        format = DataWriter<T>::Binary;
        endian = DataWriter<T>::LittleEndian;
    }
    else if ( "native" == outformat )
    {
        format = DataWriter<T>::Binary;
        endian = DataWriter<T>::NativeEndian;
    }
    else if ( "text" == outformat )
    {
        format = DataWriter<T>::Ascii;
        endian = DataWriter<T>::NativeEndian;
        out->precision( 16 );
    }
    else
    {
        string message( "Unknown output file format " );
        exitOnError( ( message + outformat ).c_str() );
    }

    return new DataWriter<T>( *out, format, endian );
}

template <class I, class O>
bool mainLoop( DataReader<I>* reader, DataWriter<O>* writer, int& count, int& channels )
{
    I inputValue;
    O outputValue;
    if ( !reader->read( inputValue ) ) return false;
    outputValue = (O)(inputValue);
    writer->write( outputValue );
    ++count;
    if ( count == channels )
    {
        writer->linebreak();
        count = 0;
    }
}

int main( int argc, char** argv )
{
    SimpleCLParser clParser( argc, argv );
    setupParser( clParser );
    cout << clParser.usageHeader() << endl;
    ifstream* inputFile = openInputStream( clParser );
    ofstream* outputFile = openOutputStream( clParser );

    bool inputSingle = (clParser.readStringOption( "-ip" ) == "single");
    bool outputSingle = (clParser.readStringOption( "-op" ) == "single" );

    DataReader<double>* readerDouble = 0;
    DataWriter<double>* writerDouble = 0;

    DataReader<float>* readerSingle = 0; 
    DataWriter<float>* writerSingle = 0; 

    if ( inputSingle )
    {
        readerSingle = createReader<float>( clParser, inputFile );
    }
    else
    {
        readerDouble = createReader<double>( clParser, inputFile );
    }

    if ( outputSingle )
    {
        writerSingle = createWriter<float>( clParser, outputFile );
    }
    else
    {
        writerDouble = createWriter<double>( clParser, outputFile );
    }


    int count = 0;
    int channels;
    if ( clParser.readFlagOption( "-c" ) )
    {
        channels = clParser.readIntOption( "-c" );
    }
    else
    {
        channels = 10; // a default value for number of text columns
    }

    if ( inputSingle && outputSingle )
    {
        while( mainLoop( readerSingle, writerSingle, count, channels ) ) {}
    }
    else if ( inputSingle && !outputSingle )
    {
        while( mainLoop( readerSingle, writerDouble, count, channels ) ) {}
    }
    else if ( !inputSingle && outputSingle )
    {
        while( mainLoop( readerDouble, writerSingle, count, channels ) ) {}
    }
    else if ( !inputSingle && !outputSingle )
    {
        while( mainLoop( readerDouble, writerDouble, count, channels ) ) {}
    }

    if (readerSingle) delete readerSingle;
    if (readerDouble) delete readerDouble;
    if (writerSingle) delete writerSingle;
    if (writerDouble) delete writerDouble;
    delete inputFile;
    delete outputFile;
}
