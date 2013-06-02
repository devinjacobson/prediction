#ifndef EPOCHMARKEDSIMPLEBINARY_CPP_UNIVERSITY_OF_OREGON_NIC
#define EPOCHMARKEDSIMPLEBINARY_CPP_UNIVERSITY_OF_OREGON_NIC

#include "DataReader.h"
#include "DataWriter.h"
#include "EpochMarkedSimpleBinary.h"
#include <fstream>
#include <sstream>

using namespace std;

EpochMarkedSimpleBinary::EpochMarkedSimpleBinary()
:   
    m_versionNumber( 0 ),
    m_byteSize( 0 ),
    m_year( 0 ),
    m_month( 0 ),
    m_day( 0 ),
    m_hour( 0 ),
    m_minute( 0 ),
    m_second( 0 ),
    m_millisecond( 0 ),
    m_samplingRate( 0 ),
    m_channels( 0 ),
    m_boardGain( 0 ),
    m_numConversionBits( 0 ),
    m_amplifierRange( 0 ),
    m_samples( 0 ),
    m_uniqueEventCodes( 0 ),
    m_eventCodes( 0 ),
    m_intData( 0 ),
    m_floatData( 0 ),
    m_intEvents( 0 ),
    m_floatEvents( 0 ),
    m_doubleData( 0 ),
    m_doubleEvents( 0 ),
    m_currentSSR( 0 ),
    m_dontDeleteData( false )
{
}

void EpochMarkedSimpleBinary::doNotDeleteData()
{
    m_dontDeleteData = true;
}

EpochMarkedSimpleBinary::~EpochMarkedSimpleBinary()
{
    if ( m_eventCodes != 0 ) delete[] m_eventCodes;

    if ( m_intData != 0 && !m_dontDeleteData ) delete[] m_intData;
    if ( m_intEvents != 0 ) delete [] m_intEvents;

    if ( m_floatData != 0 && !m_dontDeleteData ) delete[] m_floatData;
    if ( m_floatEvents != 0 ) delete[] m_floatEvents;

    if ( m_doubleData != 0 && !m_dontDeleteData ) delete[] m_doubleData;
    if ( m_doubleEvents != 0 ) delete[] m_doubleEvents;
}

string EpochMarkedSimpleBinary::headerString() const
{
    ostringstream header;

    header << "           Version number: " << m_versionNumber  << "\n"
           << "                     Date: " << m_month << "/" << m_day << "/" << m_year << "\n"
           << "                     Time: " << m_hour << ":";
    if ( m_minute < 10 ) header << "0";
    header << m_minute << ":";
    if ( m_second < 10 ) header << "0";
    header << m_second
           << "." << m_millisecond << "\n"
           << "                 Channels: " << m_channels  << "\n"
           << "                  Samples: " << m_samples << "\n"
           << "       Sampling rate (Hz): " << m_samplingRate << "\n"
           << "               Board gain: " << m_boardGain << "\n"
           << "Number of conversion bits: " << m_numConversionBits << "\n"
           << "          Amplifier range: " << m_amplifierRange << "\n"
           << "    Number of event codes: " << m_uniqueEventCodes << "\n";
    return header.str();
}

string EpochMarkedSimpleBinary::eventString() const
{
    ostringstream events;
    for ( int i = 0; i < m_uniqueEventCodes; ++i )
    {
        events << i << ": ";
        events << m_eventCodes[i] << "\n";
    }
    return events.str();
}

int EpochMarkedSimpleBinary::sizeofSSR() const
{
    // the version number corresponds to the number of bytes
    // a data member has
    return ( m_byteSize * ( m_channels + m_uniqueEventCodes ) );
}

int EpochMarkedSimpleBinary::sizeofEvents() const
{
    return ( m_uniqueEventCodes * 4 );
}

void EpochMarkedSimpleBinary::unpackHeader( char* buffer )
{
    // read the basic header information
    buffer = DataReader<int>::readBuffer( buffer, m_versionNumber );
    if (m_versionNumber == 6 ) m_byteSize = sizeof(double);
    else if (m_versionNumber == 4 ) m_byteSize = sizeof(float);
    else if (m_versionNumber == 2 ) m_byteSize = sizeof(int);  
    buffer = DataReader<short>::readBuffer( buffer, m_year );
    buffer = DataReader<short>::readBuffer( buffer, m_month );
    buffer = DataReader<short>::readBuffer( buffer, m_day );
    buffer = DataReader<short>::readBuffer( buffer, m_hour );
    buffer = DataReader<short>::readBuffer( buffer, m_minute );
    buffer = DataReader<short>::readBuffer( buffer, m_second);
    buffer = DataReader<int>::readBuffer( buffer, m_millisecond);
    buffer = DataReader<short>::readBuffer( buffer, m_samplingRate );
    buffer = DataReader<short>::readBuffer( buffer, m_channels );
    buffer = DataReader<short>::readBuffer( buffer, m_boardGain );
    buffer = DataReader<short>::readBuffer( buffer, m_numConversionBits );
    buffer = DataReader<short>::readBuffer( buffer, m_amplifierRange );
    buffer = DataReader<int>::readBuffer( buffer, m_samples );
    buffer = DataReader<short>::readBuffer( buffer, m_uniqueEventCodes);

    // perform byte swapping (if platform is not big endian)
#if BYTE_ORDER == LITTLE_ENDIAN
    std::cout << "swapping bytes" << std::endl;
    swapBytes( reinterpret_cast<char*>( &m_versionNumber ), sizeof( m_versionNumber ) );
    swapBytes( reinterpret_cast<char*>( &m_year ), sizeof( m_year ) );
    swapBytes( reinterpret_cast<char*>( &m_month ), sizeof( m_month ) );
    swapBytes( reinterpret_cast<char*>( &m_day ), sizeof( m_day ) );
    swapBytes( reinterpret_cast<char*>( &m_hour ), sizeof( m_hour ) );
    swapBytes( reinterpret_cast<char*>( &m_minute ), sizeof( m_minute ) );
    swapBytes( reinterpret_cast<char*>( &m_second ), sizeof( m_second ) );
    swapBytes( reinterpret_cast<char*>( &m_millisecond ), sizeof( m_millisecond ) );
    swapBytes( reinterpret_cast<char*>( &m_samplingRate ), sizeof( m_samplingRate ) );
    swapBytes( reinterpret_cast<char*>( &m_channels ), sizeof( m_channels ) );
    swapBytes( reinterpret_cast<char*>( &m_numConversionBits ), sizeof( m_numConversionBits ));
    swapBytes( reinterpret_cast<char*>( &m_boardGain ), sizeof( m_boardGain ) );
    swapBytes( reinterpret_cast<char*>( &m_amplifierRange ), sizeof( m_amplifierRange ) );
    swapBytes( reinterpret_cast<char*>( &m_samples ), sizeof( m_samples ) );
    swapBytes( reinterpret_cast<char*>( &m_uniqueEventCodes ), sizeof( m_uniqueEventCodes ) );
#endif
}

void EpochMarkedSimpleBinary::packHeader( char* bufferOrig )
{
    char* buffer = bufferOrig;
    // load the data into the buffer
    buffer = DataWriter<int>::writeBuffer( buffer, m_versionNumber );
    buffer = DataWriter<short>::writeBuffer( buffer, m_year );
    buffer = DataWriter<short>::writeBuffer( buffer, m_month );
    buffer = DataWriter<short>::writeBuffer( buffer, m_day );
    buffer = DataWriter<short>::writeBuffer( buffer, m_hour );
    buffer = DataWriter<short>::writeBuffer( buffer, m_minute );
    buffer = DataWriter<short>::writeBuffer( buffer, m_second );
    buffer = DataWriter<int>::writeBuffer( buffer, m_millisecond );
    buffer = DataWriter<short>::writeBuffer( buffer, m_samplingRate );
    buffer = DataWriter<short>::writeBuffer( buffer, m_channels );
    buffer = DataWriter<short>::writeBuffer( buffer, m_boardGain );
    buffer = DataWriter<short>::writeBuffer( buffer, m_numConversionBits );
    buffer = DataWriter<short>::writeBuffer( buffer, m_amplifierRange );
    buffer = DataWriter<int>::writeBuffer( buffer, m_samples );
    buffer = DataWriter<short>::writeBuffer( buffer, m_uniqueEventCodes );

    // perform byte swapping (if platform is not big endian)
#if BYTE_ORDER == LITTLE_ENDIAN
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof( int ) );
    bufferOrig += sizeof( int );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(int) );
    bufferOrig += sizeof( int );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short));
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(int) );
    bufferOrig += sizeof( int );
    swapBytes( reinterpret_cast<char*>( bufferOrig ), sizeof(short) );
    bufferOrig += sizeof( short );
#endif
}

void EpochMarkedSimpleBinary::unpackEvents( char* buffer )
{
    // allocate the event codes
    if ( m_uniqueEventCodes != 0 )
    {
        m_eventCodes = new EventCode[ m_uniqueEventCodes ];
    }

    // read the event codes (character data, so no byte swapping necessary)
    for ( int i = 0; i < m_uniqueEventCodes; ++i )
    {
        for ( int j = 0; j < 4; ++j )
        {
            m_eventCodes[i][j] = *buffer;
            ++buffer;
        }
        m_eventCodes[i][4] = 0;
    }
}

void EpochMarkedSimpleBinary::packEvents( char* buffer )
{
    // no need for byte swapping
    for ( int i = 0; i < m_uniqueEventCodes; ++i )
    {
        for ( int j = 0; j < 4; ++j )
        {
            *buffer = m_eventCodes[i][j];
            ++buffer;
        }
    }
}

void EpochMarkedSimpleBinary::unpackSSR( char* buffer, int numToUnpack )
{
    char* data = 0;
    char* events = 0;

    // determine which data pointer we are using
    if ( m_versionNumber == 2 )
    {
        data = reinterpret_cast<char*>
            ( m_intData + ( m_currentSSR * m_channels ) );
        events = reinterpret_cast<char*>
            ( m_intEvents+( m_currentSSR * m_uniqueEventCodes ) );
    }
    else if ( m_versionNumber == 4 )
    {
        data = reinterpret_cast<char*>
            ( m_floatData + ( m_currentSSR * m_channels ) );
        events = reinterpret_cast<char*>
            ( m_floatEvents + ( m_currentSSR * m_uniqueEventCodes ) );
    }
    else if ( m_versionNumber == 6 )
    {
        data = reinterpret_cast<char*>
            ( m_doubleData + (m_currentSSR * m_channels) );
        events = reinterpret_cast<char*>
            ( m_doubleEvents + ( m_currentSSR * m_uniqueEventCodes) );
    }

    // copy the buffer data to the class data
    int i = 0;
    while( (i < numToUnpack) && ( m_currentSSR < m_samples ) )
    {
        for ( int j = 0; j < m_channels; ++j )
        {
            for ( int k = 0; k < m_versionNumber; ++k )
            {
                *data = *buffer;
                ++data;
                ++buffer;
            }
#if BYTE_ORDER == LITTLE_ENDIAN
            swapBytes( data - m_byteSize, m_byteSize );
#endif
        }
        for ( int j = 0; j < m_uniqueEventCodes; ++j )
        {
            for ( int k = 0; k < m_byteSize; ++k )
            {
                *events = *buffer;
                ++events;
                ++buffer;
            }
#if BYTE_ORDER == LITTLE_ENDIAN
            swapBytes( events - m_byteSize, m_byteSize );
#endif
        }
        ++m_currentSSR;
        ++i;
    }
}

int EpochMarkedSimpleBinary::packSSR( char* buffer, int numToPack )
{
    char* data = 0;
    char* events = 0;
    int packed = 0;

    if ( m_versionNumber == 2 )
    {
        data = reinterpret_cast<char*>
            ( m_intData + ( m_currentSSR * m_channels ) );
        events = reinterpret_cast<char*>
            ( m_intEvents + ( m_currentSSR * m_uniqueEventCodes ) );
    }
    else if ( m_versionNumber == 4 )
    {
        data = reinterpret_cast<char*>
            ( m_floatData + ( m_currentSSR * m_channels ) );
        events = reinterpret_cast<char*>
            ( m_floatEvents + ( m_currentSSR * m_uniqueEventCodes ) );
    }

    else if ( m_versionNumber == 6 )
    {
        data = reinterpret_cast<char*>
            ( m_doubleData + ( m_currentSSR * m_channels ) );
        events = reinterpret_cast<char*>
            ( m_doubleEvents + ( m_currentSSR * m_uniqueEventCodes ) );
    }

    int i = 0;
    while ( ( i < numToPack) && ( m_currentSSR < m_samples ) )
    {
        for ( int j = 0; j < m_channels; ++j )
        {
            for ( int k = 0; k < m_byteSize; ++k )
            {
                *buffer = *data;
                ++data;
                ++buffer;
                ++packed;
            }
#if BYTE_ORDER == LITTLE_ENDIAN
            swapBytes( buffer - m_byteSize, m_byteSize );
#endif
        }
        for ( int j = 0; j < m_uniqueEventCodes; ++j )
        {
            for ( int k = 0; k < m_byteSize; ++k )
            {
                *buffer = *events;
                ++events;
                ++buffer;
                ++packed;
            }
            swapBytes( events - m_byteSize, m_byteSize );
        }
        ++m_currentSSR;
        ++i;
    }
    return packed;
}

void EpochMarkedSimpleBinary::allocateDataMemory()
{
    // free any memory that might have already been allocated
    if ( m_intData != 0 && !m_dontDeleteData ) 
    {
        delete[] m_intData;
        m_intData = 0;
    }

    if ( m_floatData != 0 &&!m_dontDeleteData ) 
    {
        delete[] m_floatData;
        m_floatData = 0;
    }

    if ( m_doubleData != 0 &&!m_dontDeleteData ) 
    {
        delete[] m_doubleData;
        m_doubleData = 0;
    }

    if ( m_intEvents != 0 ) 
    {
        delete[] m_intEvents;
        m_intEvents = 0;
    }

    if ( m_floatEvents != 0 ) 
    {
        delete[] m_floatEvents;
        m_floatEvents = 0;
    }

    if ( m_doubleEvents != 0 ) 
    {
        delete[] m_doubleEvents;
        m_doubleEvents = 0;
    }

    // allocate the buffer depending upon the file type
    if ( m_versionNumber == 2 )
    {
        m_intData = new short[ m_channels * m_samples ];
        m_intEvents = new short[ m_uniqueEventCodes * m_samples ];

        // for safety we initialize the data
        // we might want to remove this code for performance
        for ( int i = 0; i < (m_channels * m_samples); ++i )
        {
            m_intData[i] = 0;
        }
        for ( int i = 0; i < (m_uniqueEventCodes * m_samples); ++i )
        {
            m_intEvents[i] = 0;
        }
    }
    else if ( m_versionNumber == 4 )
    {
        m_floatData = new float[ m_channels * m_samples ];
        m_floatEvents = new float[ m_uniqueEventCodes * m_samples ];

        // for safety we initialize the data
        // we might want to remove this code for performance
        for ( int i = 0; i < (m_channels * m_samples); ++i )
        {
            m_floatData[i] = 0;
        }
        for ( int i = 0; i < (m_uniqueEventCodes * m_samples); ++i )
        {
            m_floatEvents[i] = 0;
        }
    }

    else if ( m_versionNumber == 6 )
    {
        m_doubleData = new double[ m_channels * m_samples ];
        m_doubleEvents = new double[ m_uniqueEventCodes * m_samples ];

        // for safety we initialize the data
        // we might want to remove this code for performance
        for ( int i = 0; i < (m_channels * m_samples); ++i )
        {
            m_doubleData[i] = 0;
        }
        for ( int i = 0; i < (m_uniqueEventCodes * m_samples); ++i )
        {
            m_doubleEvents[i] = 0;
        }
    }
}

void EpochMarkedSimpleBinary::swapBytes( char* value, int size )
{
    char temp;
    for ( int i = 0; i < size/2; ++i )
    {
        temp = value[i];
        value[i] = value[size - 1 - i];
        value[size - 1 - i] = temp;
    }
}

bool EpochMarkedSimpleBinary::readFile( const std::string& fileName )
{
    int bufferSize = 10000; // seems like a good place to start
    char* buffer = new char[ bufferSize ];
    ifstream inputFile( fileName.c_str(), ios_base::binary | ios_base::in );
    if ( !inputFile.good() )
    {
        cerr << "Error opening input raw file " << fileName << endl;
        return false;
    }

    inputFile.read( buffer, 36 );
    if ( !inputFile.good() )
    {
        cerr << "Error reading raw header in file " << fileName << endl;
        return false;
    }

    unpackHeader( buffer );
    cout << headerString() << endl;
    allocateDataMemory();

    if ( sizeofEvents() > 0 )
    {
        inputFile.read( buffer, sizeofEvents() );
        if ( !inputFile.good() )
        {
            cerr << "Error reading raw event information in file " << fileName << endl;
            return false;
        }
        unpackEvents( buffer );
    }
    cout << eventString() << endl;

    resetSSRCount();
    int readSSR = 0;
    int ssrToRead = bufferSize / sizeofSSR();
    int charToRead = ssrToRead * sizeofSSR();
    while ( readSSR < m_samples )
    {
        inputFile.read( buffer, charToRead );
        unpackSSR( buffer, ssrToRead );
        readSSR += ssrToRead;
    }

    delete[] buffer;
    std::cout << "read raw file" << std::endl;
    return true;
}

bool EpochMarkedSimpleBinary::writeFile( const std::string& fileName )
{
    int bufferSize = 10000; // an arbitraty value
    char* buffer = new char[ bufferSize ];
    ofstream outputFile( fileName.c_str(), ios_base::binary | ios_base::out );
    if ( !outputFile.good() )
    {
        cerr << "Error opening raw output file " << fileName << endl;
        return false;
    }

    packHeader( buffer );
    outputFile.write( buffer, 36 );

    packEvents( buffer );
    outputFile.write( buffer, sizeofEvents() );

    resetSSRCount();
    int writtenSSR = 0;
    int ssrToWrite = bufferSize / sizeofSSR();
    int charToWrite = 0; 
    while ( writtenSSR < m_samples )
    {
        charToWrite = packSSR( buffer, ssrToWrite );
        outputFile.write( buffer, charToWrite );
        writtenSSR += ssrToWrite;
    }
    delete[] buffer;
    return true;
}

#endif
// EPOCHMARKEDSIMPLEBINARY_CPP_UNIVERSITY_OF_OREGON_NIC
