#ifndef EPOCHMARKEDSIMPLEBINARY_H_UNIVERSITY_OF_OREGON_NIC
#define EPOCHMARKEDSIMPLEBINARY_H_UNIVERSITY_OF_OREGON_NIC

#include <string>

// all data is stored as big-endian
class EpochMarkedSimpleBinary
{
public:
    EpochMarkedSimpleBinary();
    ~EpochMarkedSimpleBinary();

    // ** File IO ** //
    bool readFile( const std::string& fileName );
    bool writeFile( const std::string& fileName );

    // the data can be stored as either floats or
    // shorts
    float* floatData() { return m_floatData; }
    short* intData() { return m_intData; }
    double* doubleData() { return m_doubleData; }

    // events are stored in the same format as the
    // data
    float* floatEvents() { return m_floatEvents; }
    short* intEvents() { return m_intEvents; }
    double* doubleEvents() { return m_doubleEvents; }

    // accessor methods
    int samples() const { return m_samples; }
    int channels() const { return m_channels; }
    int events() const { return m_uniqueEventCodes; }

    // methods to print the header and events in
    // human readable format
    std::string headerString() const;
    std::string eventString() const;

    void doNotDeleteData();
private:
    typedef char EventCode[5];

    // ** Data File Header ** // 
        
    // the unpacked values from the header, in order of their appearance
    int m_versionNumber;
    int m_byteSize;
    short m_year;
    short m_month;
    short m_day;
    short m_hour;
    short m_minute;
    short m_second;
    int m_millisecond;
    short m_samplingRate;
    short m_channels;
    short m_boardGain;
    short m_numConversionBits;
    short m_amplifierRange;
    int m_samples;
    short m_uniqueEventCodes;
    EventCode* m_eventCodes;

    // header methods
    void unpackHeader( char* buffer );
    void unpackEvents( char* buffer );
    void swapBytes( char* value, int size );

    void packHeader( char* buffer );
    void packEvents( char* buffer );

    // ** EEG Data ** //

    // the raw data
    short* m_intData;
    short* m_intEvents;

    float* m_floatData;
    float* m_floatEvents;

    double* m_doubleData;
    double* m_doubleEvents;

    int m_currentSSR;

    // data methods
    void allocateDataMemory();
    void unpackSSR( char* buffer, int numToUnpack = 1 );

    void resetSSRCount() { m_currentSSR = 0; }
    int packSSR( char* buffer, int numToPack = 1 );

    int sizeofSSR() const;
    int sizeofEvents() const;

    bool m_dontDeleteData;
};

#endif
// EPOCHMARKEDSIMPLEBINARY_H_UNIVERSITY_OF_OREGON_NIC
