#ifndef PROGTOOLS_H_UNIVERSITY_OF_OREGON_NIC
#define PROGTOOLS_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include "SimpleCLParser.h"
#include "DataFormat.h"
#include "MPIWrapper.h"

// An experimental class that arose from the common
// functionality that all of the HiPerSAT programs
// have. It's still under heavy development, but
// will act as a sort of SDK for using the library
// functions in a consistent way
class ProgramTools
{
public:

    ProgramTools( int argc, char** argv );
    ProgramTools( const ProgramTools& pt );
    ~ProgramTools();

    ProgramTools& operator=( const ProgramTools& pt );

    SimpleCLParser& parser() { return m_parser; }
    int MPIrank() const;
    int MPIsize() const;

    void exitOnError( const char* message );
    void exitCleanly( ) { exit( 0 ); }
    void setup();
    void shutdown();

    DataFormat::DataFormat getFileFormat( const std::string& format );
    virtual void setupParser() = 0;

protected:
    SimpleCLParser m_parser;
    int m_rank;
    int m_size;

    void setupParserCommon();
};

#endif
// PROGTOOLS_H_UNIVERSITY_OF_OREGON_NIC
