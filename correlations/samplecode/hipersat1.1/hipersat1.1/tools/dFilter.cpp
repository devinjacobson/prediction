#ifndef DFILTER_CPP_UNIVERSITY_OF_OREGON_TAU
#define DFILTER_CPP_UNIVERSITY_OF_OREGON_TAU

// NIC headers
#include "SimpleCLParser.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "NICFilter.h"
#include "StaticGainFilter.h"
#include "FilterFactory.h"
#include "FilterOptions.h"
#include "ConvolutionFilter.h"

// HiPerSAT Headers
#include "MatrixReader.h"
#include "MatrixWriter.h"
#include "DataFormat.h"

// standard headers
#include <fstream>
#include <iostream>
#include <string>
#include <signal.h>
#include <time.h>

// mpi headers
#ifdef __DISTRIBUTED
#include <mpi.h>
#endif

using namespace std;

void sigIntHandler( int sig )
{
    int rank=0;
#ifdef __DISTRIBUTED
    MPI_Comm_rank( MPI_COMM_WORLD, &rank );
#endif
#ifdef DEBUG
    cout << rank << " caught sigint. Exiting." << endl;
#endif
#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif
    exit(1);
}

// we need to exit the program safely so that all of the
// nodes in MPI land exit cleanly rather than hang
void safeExit( string& message, SimpleCLParser* parser )
{
  // we want this to be called by everybody before exit
  int rank=0;
#ifdef __DISTRIBUTED
  MPI_Comm_rank( MPI_COMM_WORLD, &rank );
#endif
  if ( rank == 0 ) 
  {
    if ( parser->readFlagOption( "-h" ) )
    {
      cout << parser->usage();
    }
    else
    {
      cerr << message << endl;
    }
  }
  else
  {
    cerr << "Process " << rank << " exiting." << endl;
  }
#ifdef __DISTRIBUTED
  MPI_Finalize();
#endif
  exit(1);
}

// set up the command line options here
void initializeParser( SimpleCLParser& parser )
{
  std::string usageHeader =
    "dFilter, an MPI based distributed signal processor.\n";
  usageHeader += 
    "Developed by the University of Oregon Neuroinformatics Center.\n";
  usageHeader += 
  "Based on the original filter code developed by Electrical Geodesics, Inc.\n";

  parser.addUsageHeader( usageHeader );

  parser.addOption( SimpleCLParser::STRING, "-i", "input file", true );
  parser.addOption( SimpleCLParser::STRING, "-o", "output file", true );
  parser.addOption( SimpleCLParser::INTEGER, "-c", "number of channels", true );
  parser.addOption( SimpleCLParser::INTEGER, "-s", "number of samples" , true );
  parser.addOption( SimpleCLParser::DOUBLE, "-g", "filter gain", false );
  parser.addOption( SimpleCLParser::FLAG, "-h", "print this message", false );
  parser.addOption( SimpleCLParser::FLAG, "-v", "verbose", false );
  parser.addOption( SimpleCLParser::STRING, "-t", "filter type ( gain, ramp, lowpass, highpass, bandpass, bandstop )" );
  parser.addOption( SimpleCLParser::DOUBLE, "-L", "low cutoff" );
  parser.addOption( SimpleCLParser::DOUBLE, "-H", "high cutoff" );
  parser.addOption( SimpleCLParser::INTEGER, "-r", "sampling rate (Hz)" );

  parser.parse();
}

NICFilter<double>* makeFilter( SimpleCLParser& parser )
{
  NICFilter<double>* returnFilter = 0;

  FilterOptions options; // use the default settings

  std::string type = parser.readStringOption( "-t" );
  int samples = parser.readIntOption( "-s" );
  int samplingRate = parser.readIntOption( "-r" );
  double lowCutoff = parser.readDoubleOption( "-L" );
  double highCutoff = parser.readDoubleOption( "-H" );
  double gain = parser.readDoubleOption( "-g" );

  FilterFactory factory( samples, samplingRate );

  string error("Not a valid filter");

  if ( type == "gain" ) returnFilter = new StaticGainFilter<double>( gain );
  else if ( type == "lowpass" ) 
    returnFilter = factory.makeLowpass( lowCutoff, options );
  else if ( type == "highpass" )
    returnFilter = factory.makeHighpass( highCutoff, options );
  else if ( type == "bandpass" )
    returnFilter = factory.makeBandpass( lowCutoff, highCutoff, options );
  else if ( type == "bandstop" )
    returnFilter = factory.makeBandstop( lowCutoff, highCutoff, options );
  else safeExit( error, &parser );

  return returnFilter;
}

void filter( double* data, int channels, int samples, 
  NICFilter<double>* filter )
{
  std::cout << *data << std::endl;
  NicVector<double> channelData;
  for ( int i = 0; i < channels; ++i )
  {
    channelData.externData( data + (samples * i), samples );
    filter->filter( channelData );
  }
}

// controller code
//
// it would make sense to break this up into smaller controller
// modules. i.e. one for filter creation, one for data loading,
// one for filtering, etc.
static void readSwappedData( double* buf, size_t elementSize, size_t numElements)
{
  double* dptr = buf;
  
  while ( numElements-- > 0 )
    {
      unsigned char*   cptr = (unsigned char*) dptr;
      unsigned char    tmp;
      
      tmp = cptr[ 0 ];
      cptr[ 0 ] = cptr[ 7 ];
      cptr[ 7 ] = tmp;
      
      tmp = cptr[ 1 ];
      cptr[ 1 ] = cptr[ 6 ];
      cptr[ 6 ] = tmp;
      
      tmp = cptr[ 2 ];
      cptr[ 2 ] = cptr[ 5 ];
      cptr[ 5 ] =tmp;
      
      tmp = cptr[ 3 ];
      cptr[ 3 ] = cptr[ 4 ];
      cptr[ 4 ] = tmp;
      
      dptr++;
    }
}      

void filterController( SimpleCLParser& parser )
{
  int rank=0;
  int size=1;

#ifdef __DISTRIBUTED
  MPI_Comm_rank(MPI_COMM_WORLD, &rank );
  MPI_Comm_size(MPI_COMM_WORLD, &size );
#endif

#ifdef DEBUG
  cout << "Controller running on node " << rank << endl << flush;
#endif
  // load the options into local variables
  string inFileName( parser.readStringOption( "-i" ) );
  string outFileName( parser.readStringOption( "-o" ) );
  int channels( parser.readIntOption( "-c" ) );
  int samples( parser.readIntOption( "-s" ) );
  double gain( parser.readDoubleOption( "-g") );

  NicMatrix<double> eeg;
  if ( 0 == rank )
  {
    MatrixReader<double>::loadMatrix(
        eeg,
        DataFormat::BIG,
        channels, 
        samples,
        inFileName.c_str(),
        true );

#ifdef DEBUG
    cout << "Done loading" << endl << flush;
#endif
  }
#ifdef DEBUG
  cout << "Initializing filter on node " << rank << endl << flush;
#endif
  // initialize the filter
  // Making these two filters is kind of lame, but it's not
  // very expensive and I'm lazy
  StaticGainFilter<double> gainFilter( gain );

  NICFilter<double>* theFilter = makeFilter( parser );

  NicVector<double> currentChannel;

  // compute the channel distribution and allocate the processing buffer
  int channelsPerNode = channels / size;
  int valuesPerNode = channelsPerNode * samples;

  double* data;

  // The guts of the filtering happen in this method
#ifdef DEBUG
  if(rank==0) {
    cout<<"Rank 0 data : \n";
    for(int p=0;p<valuesPerNode;p++) {
      cout<<data[p]<<" ";
    }
    cout<<"\n";
  }
  cout << "Filtering " << channelsPerNode << " channels on node " 
    << rank << endl;
#endif
  time_t seconds;
 
#ifdef __DISTRIBUTED
  data = new double[ valuesPerNode ];
  MPI_Scatter( eeg.data, valuesPerNode, MPI_DOUBLE, data, valuesPerNode,
    MPI_DOUBLE, 0, MPI_COMM_WORLD );
  seconds = time(NULL);
  filter( data, channelsPerNode, samples, theFilter );
#else
  filter( eeg.data, channelsPerNode, samples, theFilter );
#endif

  // process any leftover channels
  if ( 0 == rank )
  {
    int offset = (channelsPerNode * size) * samples;
    int channelsLeft = channels - ( channelsPerNode * size );
    filter( (eeg.data + offset), channelsLeft, samples, theFilter );
  }

#ifdef __DISTRIBUTED
  seconds = time(NULL) - seconds;
  cout<<seconds<<" SECONDS IT TOOK\n";
  MPI_Gather( data, valuesPerNode, MPI_DOUBLE, eeg.data, valuesPerNode,
    MPI_DOUBLE, 0, MPI_COMM_WORLD );
#endif

  if ( rank == 0 )
  {
#ifdef DEBUG
    cout << "Writing file " << outFileName << endl << flush;
#endif

    MatrixWriter<double>::writeMatrix(
        eeg,
        DataFormat::BIG,
        outFileName, 
        true );
  }

  delete theFilter;
#ifdef __DISTRIBUTED
  delete [] data;
#endif
}

int main( int argc, char* argv[] )
{
  // initialize signal handler
  signal( SIGINT, sigIntHandler );
  
  
  // initialize mpi
  int rank=0;
  int size=1;

#ifdef __DISTRIBUTED
  MPI_Init( &argc, &argv ); 
  MPI_Comm_rank( MPI_COMM_WORLD, &rank );
  MPI_Comm_size( MPI_COMM_WORLD, &size );
#endif

#ifdef DEBUG
  cout << "I am processor " << rank << " of " << size << endl << flush;
  cout << "Parsing options" << endl << flush; 
#endif

  SimpleCLParser clParser( argc, argv, safeExit );
  initializeParser( clParser );

  bool needHelp; clParser.readOption( "-h", needHelp );
  if ( needHelp )
  {
    if ( rank == 0 ) cout << clParser.usage() << endl << flush;
#ifdef __DISTRIBUTED
    MPI_Finalize();
#endif
    return 0;
  }

  filterController( clParser );
#ifdef __DISTRIBUTED
  MPI_Finalize();
#endif

  return 0;
}

#endif
// DFILTER_CPP_UNIVERSITY_OF_OREGON_TAU
