#ifndef SIMPLECLPARSER_CPP_UNIVERSITY_OF_OREGON_NIC
#define SIMPLECLPARSER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "SimpleCLParser.h"
#include <sstream>
#include <iostream>

using namespace std;

//  load argc and argv
SimpleCLParser::SimpleCLParser( int argc, char** argv, 
  void (*safeExit)( string& message, SimpleCLParser* me ) )
: m_parsed( false ), m_argc( argc ), m_argv( argv ), m_safeExit( safeExit )
{
}

SimpleCLParser::~SimpleCLParser()
{
}

// at runtime, before anything else happens, the options to parse are loaded
// into the class. Compare this libraries where a configuration file is written,
// and c++ code is generated to parser options
bool
SimpleCLParser::addOption( SimpleCLParser::OptionType type,
  const string& name, const string& description, bool isMandatory )
{
  // initialize the record
  OptionRecord record;
  record.type = type;
  record.description = description;
  record.isMandatory = isMandatory;
  record.isSet = false;
  record.stringValue = "";
  record.intValue = 0;
  record.doubleValue = 0;

  // insert it into the map
  m_optionTypeMap[ name ] = record;
  m_mappedNames.insert( name );

  // why return true? what did I want to check here?
  // I really don't know....
  return true;
}

// Add a string describing what the program is for
void
SimpleCLParser::addUsageHeader( const string& header )
{
  m_usageHeader = header;
}

// the bool on these methods is to indicate if the option is available to
// the user in the desired type

// any option can be read as a flag... i.e. does the option appear on the
// command line?
bool
SimpleCLParser::readOption( const string& name, bool& flagValue )
{
  if ( !m_parsed ) parse();
  if ( m_mappedNames.count( name ) == 1 )
  {
    flagValue = m_optionTypeMap[ name ].isSet;
    return true;
  }
  return false;
}

bool
SimpleCLParser::readOption( const string& name, string& sv )
{
  if ( !m_parsed ) parse();
  if ( (m_mappedNames.count( name ) == 1) &&
       (m_optionTypeMap[ name ].type == STRING) &&
       (m_optionTypeMap[ name ].isSet) )
  {
    sv = m_optionTypeMap[ name ].stringValue;
    return true;
  }
  return false;
}

bool
SimpleCLParser::readOption( const string& name, int& intValue )
{
  if ( !m_parsed ) parse();
  if ( (m_mappedNames.count( name ) == 1) &&
       (m_optionTypeMap[ name ].type == INTEGER) &&
       (m_optionTypeMap[ name ].isSet) )
  {
    intValue = m_optionTypeMap[ name ].intValue;
    return true;
  }
  else return false;
}

bool
SimpleCLParser::readOption( const string& name, double& doubleValue )
{
  if ( !m_parsed ) parse();
  if ( (m_mappedNames.count( name ) == 1) &&
       (m_optionTypeMap[ name ].type == DOUBLE) &&
       (m_optionTypeMap[ name ].isSet) )
  {
    doubleValue = m_optionTypeMap[ name ].doubleValue;
    return true;
  }
  else return false;
}

// this is a different interface, without error checking. The values are passed
// back through the return value. If an error happens, the method is silent and
// returns a default "null" value.
bool 
SimpleCLParser::readFlagOption( const std::string& name )
{
  if ( !m_parsed ) parse();
  if ( (m_mappedNames.count( name ) == 1) &&
       (m_optionTypeMap[ name ].isSet) )
  {
    return true;
  }
  else return false;
}

std::string 
SimpleCLParser::readStringOption( const std::string& name )
{
  if ( readFlagOption( name ) && 
       m_optionTypeMap[ name ].type == STRING )
  {
    return m_optionTypeMap[ name ].stringValue;
  }
  else return "";
}

int 
SimpleCLParser::readIntOption( const std::string& name )
{
  if ( readFlagOption( name ) &&
       m_optionTypeMap[ name ].type == INTEGER )
  {
    return m_optionTypeMap[ name ].intValue; 
  }
  else return 0;
}

double
SimpleCLParser::readDoubleOption( const std::string& name )
{
  if ( readFlagOption( name ) &&
       m_optionTypeMap[ name ].type == DOUBLE )
  {
    return m_optionTypeMap[ name ].doubleValue;
  }
  else return 0;
}

// free options are things like file names
// they are not prefixed by any flags. This interface is useful if you have a
// large set of file names to pass in (i.e. for batch jobs)
vector< string > 
SimpleCLParser::freeOptions()
{
  if ( !m_parsed ) parse();
  return m_freeOptions;
}

// formats a string that describes the options and the type of arguments they
// take
string 
SimpleCLParser::usage()
{
  if ( !m_parsed ) parse();
  string returnValue = m_usageHeader;
  returnValue += "\n";
  set< string >::const_iterator current, end;
  current = m_mappedNames.begin();
  end = m_mappedNames.end();
  for ( ; current != end; ++current )
  {
    returnValue += *current;
    if ( m_optionTypeMap[ *current ].type != FLAG )
    {
      returnValue += " <";
      returnValue += typeToString( m_optionTypeMap[ *current ].type );
      returnValue += ">";
    }
    returnValue += " : ";
    returnValue += m_optionTypeMap[ *current ].description + "\n";
  }
  return returnValue;
}

// take argc and argv, and create records for their values
// at the end of the routine, make sure that all of the required options
// present on the command line
void
SimpleCLParser::parse()
{
  // first option is the program name, skip it
  // note that this can cause failure on systems (such as condor) that mangle
  // the argc/argv pair
  for ( char i = 1; i < m_argc; ++i )
  {
    string asString( m_argv[ i ] );
    if ( m_mappedNames.count( asString ) == 1 )
    {
      OptionRecord& record = m_optionTypeMap[ asString ];
      record.isSet = true;

      if ( record.type != FLAG )
      {
        if ( (i + 1) == m_argc )
        {
          cerr << "Error in parsing command line, abort" << endl;
          abort();
        }
        string valAsString( m_argv[ i+1 ] );
        stringstream converter; // a convenient way to convert from strings to
                                // other types
        switch ( record.type )
        {
          case FLAG:
            break;
          case STRING:
            record.stringValue = valAsString;
            break;
          case INTEGER:
            converter << valAsString;
            converter >> record.intValue;
            break;
          case DOUBLE:
            converter << valAsString;
            converter >> record.doubleValue;
            break;
        }
        ++i;
      }
    }
    else
    {
      m_freeOptions.push_back( asString );
    }
  }
  m_parsed = true;
  //checkRequired();
}

// check that all of the required flags are present on the command line
void
SimpleCLParser::checkRequired()
{
  map< string, OptionRecord >::iterator current, end;
  vector< string > botchedOptions;
  bool failed = false;

  for( current = m_optionTypeMap.begin(), end = m_optionTypeMap.end();
       current != end; ++current )
  {
    if ( ((*current).second.isMandatory) && !((*current).second.isSet) )
    {
      botchedOptions.push_back( (*current).first );
      failed = true;
    }
  }
  if ( failed )
  {
    vector<string>::iterator current, end;
    string errorMessage = "Command line parse failed. ";
    errorMessage += "The following options were not set:\n";
    for ( current = botchedOptions.begin(), end = botchedOptions.end();
          current != end; ++current )
    {
      errorMessage += *current;
      errorMessage += " <";
      errorMessage += typeToString( m_optionTypeMap[ *current ].type );
      errorMessage += "> : ";
      errorMessage += m_optionTypeMap[ *current ].description;
      errorMessage += "\n";
    }
    if ( m_safeExit != 0 ) m_safeExit( errorMessage, this );
    cerr << errorMessage;
    exit(1);
  }
}

string
SimpleCLParser::typeToString( SimpleCLParser::OptionType type )
{
  switch ( type )
  {
    case FLAG:
      return "flag";
    case STRING:
      return "string";
    case INTEGER:
      return "integer";
    case DOUBLE:
      return "double";
  }
  return "error";
}

string
SimpleCLParser::getSetOptions()
{
    std::string optionsString;
    std::map< std::string, OptionRecord>::iterator currentRecord, endRecord;
    currentRecord = m_optionTypeMap.begin();
    endRecord = m_optionTypeMap.end();
    while ( currentRecord != endRecord )
    {
        if ( (currentRecord->second).isSet )
        {
            optionsString += (currentRecord->first + " ");
            switch ( (currentRecord->second).type )
            {
                /*
                // TODO this stuff is horribly broken. I need to fix it
                case FLAG:
                    break;
                case STRING:
                    optionsString += (currentRecord->second).stringValue;
                    break;
                case INTEGER:
                    optionsString += (currentRecord->second).intValue;
                    break;
                case DOUBLE:
                    optionsString += (currentRecord->second).doubleValue;
                    break;
                    */
            }
            optionsString += "\n";
        }
        ++currentRecord;
    }
    return optionsString;
}
     
#endif
// SIMPLECLPARSER_CPP_UNIVERSITY_OF_OREGON_NIC
