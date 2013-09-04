#include "DataReader.h"
#include "DataWriter.h"
#include "MersenneTwister.h"
#include <math.h>


#include <fstream>
#include <iostream>

typedef DataReader<double> DrD;
typedef DataWriter<double> DwD;

int main()
{
    int numValues = 6400000;
    double* values = new double [numValues];
    double value;
    MersenneTwister rng;
    for ( int i = 0; i < numValues; ++i )
    {
        values[i] = rng.rand_double_closed(-10000000, 10000000);
    }

    std::cout << "Testing big endian read/write" << std::endl;
    // write big
    std::ofstream bigFile( "/tmp/binaryBig", std::ios::binary );
    DwD bigWriter( bigFile, DwD::Binary, DwD::BigEndian );
    for ( int i = 0; i < numValues; ++i )
    {
        bigWriter.write( values + i );
    }
    bigFile.close();

    // read big and validate
    std::ifstream bigFileRead( "/tmp/binaryBig", std::ios::binary );
    DrD bigReader( bigFileRead, DrD::Binary, DrD::BigEndian );
    int count = 0;
    while ( bigReader.read( value ) )
    {
        assert( fabs( value - values[count] ) < 1e-8 );
        ++count;
    }
    assert( count == numValues );
    bigFileRead.close();
    std::cout << "  passed" << std::endl;
    
    std::cout << "Testing little endian read/write" << std::endl;
    // write little
    std::ofstream littleFile( "/tmp/binaryLittle", std::ios::binary );
    DwD littleWriter( littleFile, DwD::Binary, DwD::LittleEndian );
    for ( int i = 0; i < numValues; ++i )
    {
        littleWriter.write( values[i] );
    }
    littleFile.close();

    // read little and validate
    std::ifstream littleFileRead( "/tmp/binaryLittle", std::ios::binary );
    DrD littleReader( littleFileRead, DrD::Binary, DrD::LittleEndian );
    count = 0;
    while ( littleReader.read( value ) )
    {
        assert( fabs( value - values[count] ) < 1e-8 );
        ++count;
    }
    assert( count == numValues );
    littleFileRead.close();
    std::cout << "  passed" << std::endl;

    std::cout << "Testing text read/write" << std::endl;
    // write text
    std::ofstream textFile( "/tmp/text" );
    textFile.precision(16);
    textFile.setf( std::ios::scientific );
    DwD textWriter( textFile, DwD::Ascii );
    for ( int i = 0; i < 1000; ++i )
    {
        textWriter.write( values[i] );
        textWriter.linebreak();
    }
    textFile.close();

    // read text and validate
    std::ifstream textFileRead( "/tmp/text" );
    DrD textReader( textFileRead, DrD::Ascii );
    count = 0;
    double foo;
    while( textReader.read( value ) )
    {
        if ( fabs( value - values[ count ] ) >= 1e-8 )
        {
            std::cout << "value:" << value << " values[" 
                << count << "]:" << values[count] << std::endl;
        }
        assert( fabs( value - values[ count ] ) < 1e-8 );
        ++count;
    }
    assert( count == 1000 );
    textFileRead.close();
    std::cout << "  passed" << std::endl;
    delete [] values;
}
