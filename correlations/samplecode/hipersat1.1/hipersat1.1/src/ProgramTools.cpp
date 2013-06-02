#ifndef PROGRAMTOOLS_CPP_UNIVERSITY_OF_OREGON_NIC
#define PROGRAMTOOLS_CPP_UNIVERSITY_OF_OREGON_NIC

#include "ProgramTools.h"
#include <iostream>

using namespace std;

ProgramTools::ProgramTools( int argc, char** argv )
:
    m_parser( argc, argv ),
    m_rank( 0 ),
    m_size( 1 )
{
    initializeMPI( argc, argv, m_rank, m_size );
}

ProgramTools::~ProgramTools()
{
}

void ProgramTools::exitOnError( const char* message )
{
    std::cerr << message << std::endl;
    std::cerr << "Exiting." << std::endl;
    finalizeMPI();
    exit( 1 );
}

void ProgramTools::setup()
{
    setupParserCommon();
    if ( m_rank == 0 )
    {
        cout << m_parser.usageHeader() << endl;
    }
}

void ProgramTools::shutdown()
{
    finalizeMPI();
}

int ProgramTools::MPIrank() const 
{
    return m_rank;
}

int ProgramTools::MPIsize() const
{
    return m_size;
}

void ProgramTools::setupParserCommon()
{
    bool required = true;
    bool notRequired = false;

    m_parser.addOption( SimpleCLParser::FLAG, "-h", "usage", notRequired );

    m_parser.parse();
    if ( m_parser.readFlagOption( "-h" ) )
    {
        if ( m_rank == 0 )
        {
            cout << m_parser.usage() << endl;
        }
        exitCleanly();
    }

    m_parser.checkRequired();
}

DataFormat::DataFormat
ProgramTools::getFileFormat( const std::string& option )
{
    string formatString = m_parser.readStringOption( option );
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
        string message = "Invalid file type: ";
        message += formatString;
        message += "\n";
        exitOnError( message.c_str() );
    }
    return returnValue;
}


#endif
// PROGRAMTOOLS_CPP_UNIVERSITY_OF_OREGON_NIC
