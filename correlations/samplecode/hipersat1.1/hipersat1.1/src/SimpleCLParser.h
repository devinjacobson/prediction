#ifndef SIMPLECLPARSER_H_UNIVERSITY_OF_OREGON_NIC
#define SIMPLECLPARSER_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include <map>
#include <vector>
#include <set>

// A class to read from the command line. A quick and dirty
// hack that has hung around. It provides facilities for 
// distributed programming, including a way to shut down
// all of the nodes cleanly on input error
//
// the creation of options is done at run-time, which is
// in contrast to the method of generating a parser from
// a configuration file. I wanted to reduce compilation
// steps and dependencies that weren't C or C++
//
// This class reqires >= gcc 3.2, or intel or xlC
class SimpleCLParser
{
public:

  enum OptionType
  {
    FLAG,
    STRING,
    INTEGER,
    DOUBLE
  };

  SimpleCLParser( int argc, char** argv, 
    void(*safeExit)( std::string& message, SimpleCLParser* me ) = 0 );
  ~SimpleCLParser();

  bool addOption( OptionType type, const std::string& name, 
    const std::string& description, bool isMandatory = false );

  void addUsageHeader( const std::string& header );

  // have readOptions for many different types
  bool readOption( const std::string& name, bool& flagValue );
  bool readOption( const std::string& name, std::string& stringValue  );
  bool readOption( const std::string& name, int& integerValue );
  bool readOption( const std::string& name, double& doubleValue );

  // the previous interface is a bit clunky. tighten it up here
  bool readFlagOption( const std::string& name );
  std::string readStringOption( const std::string& name );
  int readIntOption( const std::string& name );
  double readDoubleOption( const std::string& name );

  std::vector<std::string> freeOptions();
  
  std::string usage();
  std::string usageHeader() { return m_usageHeader; }

  std::string getSetOptions();

  void parse();
  void checkRequired();

private:

  struct OptionRecord
  {
    std::string description;
    OptionType type;
    bool isMandatory;
    bool isSet;
    std::string stringValue;
    int intValue;
    double doubleValue;
  };

  std::string typeToString( OptionType type );

  bool m_parsed;
  int m_argc;
  char** m_argv;
  std::set< std::string > m_mappedNames;
  std::map< std::string, OptionRecord > m_optionTypeMap;
  std::vector< std::string > m_freeOptions;
  std::string m_usageHeader;

  // pointer to a function so we can bail out nicely if necessary
  // if this is set to zero, when errors are encounted the program will exit()
  void (*m_safeExit)( std::string& message, SimpleCLParser* me );
};

#endif
// SIMPLECLPARSER_H_UNIVERSITY_OF_OREGON_NIC
