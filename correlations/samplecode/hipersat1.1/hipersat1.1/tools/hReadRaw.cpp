#ifndef NICREADRAW_CPP_UNIVERSITY_OF_OREGON_NIC
#define NICREADRAW_CPP_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "version.h"
#include "EpochMarkedSimpleBinary.h"
#include "hReadRaw.h"
#include "MatrixWriter.h"

int main( int argc, char** argv )
{
    // setup the parser
    SimpleCLParser parser( argc, argv );
    setupParser( parser );
    cout << parser.usageHeader() << endl;

    EpochMarkedSimpleBinary egiRaw;
    bool read = egiRaw.readFile( parser.readStringOption( "-i" ) );
    if ( !read )
    {
        std::cout << "Exiting" << std::endl;
        return 1;
    }

    NicMatrix<float> nicMatrix;
    NicMatrix<float> eventData;

    NicMatrix<double> nicMatrixDouble;
    NicMatrix<double> eventDataDouble;

    if ( egiRaw.doubleData() != 0 )
    {
        nicMatrixDouble.alias( egiRaw.doubleData(), egiRaw.channels(), egiRaw.samples() );
        eventDataDouble.alias( egiRaw.doubleEvents(), egiRaw.events(), egiRaw.samples() );

        DataFormat::DataFormat outputDataFormat = getOutputFormat( parser );

        if ( outputDataFormat == DataFormat::RAW )
        {
            egiRaw.writeFile( parser.readStringOption( "-o" ) );
        }
        else
        {
            MatrixWriter<double>::writeMatrix(
                nicMatrixDouble,
                outputDataFormat,
                parser.readStringOption( "-o" ) );

            MatrixWriter<double>::writeMatrix(
                eventDataDouble,
                outputDataFormat,
                parser.readStringOption( "-oe" ) );
        }
    }
    else
    {
        nicMatrix.alias( egiRaw.floatData(), egiRaw.channels(), egiRaw.samples() );
        eventData.alias( egiRaw.floatEvents(), egiRaw.events(), egiRaw.samples() );

        DataFormat::DataFormat outputDataFormat = getOutputFormat( parser );

        if ( outputDataFormat == DataFormat::RAW )
        {
            egiRaw.writeFile( parser.readStringOption( "-o" ) );
        }
        else
        {
            MatrixWriter<float>::writeMatrix(
                nicMatrix,
                outputDataFormat,
                parser.readStringOption( "-o" ) );

            MatrixWriter<float>::writeMatrix(
                eventData,
                outputDataFormat,
                parser.readStringOption( "-oe" ) );
        }
    }

    return 0;
}

void setupParser( SimpleCLParser& parser )
{
    bool isRequired = true;
    bool notRequired = false;

    // usage and copyright info
    string usage = "\nHiPerSAT Raw Reader v. 1.1.alpha (r";
    usage += hipersatVersionString();
    usage +=  ")\n\n";
    usage += NIC_COPYRIGHT;
    parser.addUsageHeader( usage );

    // input file options
    parser.addOption( SimpleCLParser::STRING,
                      "-i", 
                      "input file name", 
                      isRequired );

    // output options
    parser.addOption( SimpleCLParser::STRING,
                      "-o",
                      "output data file name",
                      isRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-oe",
                      "output events file name",
                      isRequired );
    parser.addOption( SimpleCLParser::STRING,
                      "-of",
                      "output data format ( big, little, native, raw, text )",
                      isRequired );

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
        else if ( formatName == "raw" )
        {
            format = DataFormat::RAW;
        }
        else 
        {
            cerr << "Invalid output type. Defaulting to text" << endl;
        }
    }
    return format;
}

#endif
// NICREADRAW_CPP_UNIVERSITY_OF_OREGON_NIC
