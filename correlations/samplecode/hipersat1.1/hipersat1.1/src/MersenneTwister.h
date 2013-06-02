#ifndef MERSENNETWISTER_H_UNIVERSITY_OF_OREGON_NIC
#define MERSENNETWISTER_H_UNIVERSITY_OF_OREGON_NIC

#include <iostream>

// a portable random number generator class
class MersenneTwister
{
private:
    static const int m_stateSize;
    static const int m_M;
    static const unsigned long m_upperMask;
    static const unsigned long m_lowerMask;
    static const unsigned long m_mag01[ 2 ]; 

    void generateValues();

public:
    unsigned long m_state[ 624 ]; // 624 is the same as m_stateSize
    int m_statePos;

    MersenneTwister( unsigned long int seed = 5489UL );
    MersenneTwister( unsigned long* seedArray, int arrayLength );

    // reinitialize the algorithm with a new seed or a new seed array
    void initialize( unsigned long int seed );
    void initialize( unsigned long* seedArray, int arrayLength );

    // returns a value in [0, MAX_UNSIGNED_LONG]
    unsigned long rand_unsigned_long();

    // returns a value in [ lower, upper ]
    double rand_double_closed( double lower = 0.0, double upper = 1.0 );
    // returns a value in [ lower, upper )
    double rand_double_half_closed( double lower = 0.0, double upper = 1.0 );

    // returns a value in [ lower, upper ]
    float rand_float_closed( float lower = 0.0, float upper = 1.0 );
    // returns a value in [ lower, upper )
    float rand_float_half_closed( float lower = 0.0, float upper = 1.0 );

    bool rand_bool();

    // a helper to chop the input value to 1/(2^15) decimal places
    // (for values in [0,1]
    double chop( double input );
};

// a way to return arbitray types from the Mersenne Twister
template <class T>
T randTClosed( MersenneTwister& rng, T lower = 0.0, T upper = 1.0 );

template <class T>
T randTHalfClosed( MersenneTwister& rng, T lower = 0.0, T upper = 1.0 );


#endif
// MERSENNETWISTER_H_UNIVERSITY_OF_OREGON_NIC
