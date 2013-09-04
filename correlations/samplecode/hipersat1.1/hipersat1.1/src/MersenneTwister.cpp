#ifndef MERSENNETWISTER_CPP_UNIVERSITY_OF_OREGON_NIC
#define MERSENNETWISTER_CPP_UNIVERSITY_OF_OREGON_NIC

#include "MersenneTwister.h"
#include <algorithm>
#include <math.h>

const int MersenneTwister::m_stateSize = 624;
const int MersenneTwister::m_M = 397;
const unsigned long MersenneTwister::m_upperMask = 0x80000000UL;
const unsigned long MersenneTwister::m_lowerMask = 0x7fffffffUL;


MersenneTwister::MersenneTwister( unsigned long int seed )
{
    initialize( seed );
}

MersenneTwister::MersenneTwister( unsigned long* seedArray, int arrayLength )
{
    initialize( seedArray, arrayLength );
}

void MersenneTwister::initialize( unsigned long seed )
{
    m_state[0] = seed & 0xffffffffUL;
    for ( m_statePos = 1; m_statePos < m_stateSize; m_statePos++ )
    {
        m_state[ m_statePos ] =
            (1812433253UL * 
             (m_state[ m_statePos - 1 ] ^ (m_state[ m_statePos - 1 ] >> 30) 
             ) + m_statePos );
        // mask for machines with more than 32 bits of precision
        m_state[ m_statePos ] &= 0xffffffffUL;
    }
}

void MersenneTwister::initialize( unsigned long* seedArray, int arrayLength )
{
    initialize( 19650218UL );
    int i = 1;
    int j = 0;
    int k = ( m_stateSize > arrayLength ? m_stateSize : arrayLength ); 
    for ( ; k; --k )
    {
        m_state[ i ] = 
            ( m_state[i] ^ 
             ( ( m_state[i-1] ^ (m_state[i-1] >> 30) 
               ) * 1664525UL)
            ) + seedArray[ j ] + j;
        m_state[ i ] &= 0xffffffffUL;
        ++i;
        ++j;
        if ( i >= m_stateSize )
        {
            m_state[ 0 ] = m_state[ m_stateSize - 1 ];
            i = 1;
        }
        if ( j >= arrayLength ) j = 0;
    }
    for ( k = m_stateSize - 1; k; k-- )
    {
        m_state[ i ] = 
            ( m_state[i] ^ 
             ( ( m_state[i-1] ^ (m_state[i-1] >> 30) 
              ) * 1566083941UL) ) - i;
        m_state[ i ] &= 0xffffffffUL;
        ++i;
        if ( i >= m_stateSize )
        {
            m_state[ 0 ] = m_state[ m_stateSize - 1 ];
            i = 1;
        }
    }

    // prevent against worst case of all zero state array
    m_state[ 0 ] = m_state[0] = 0x80000000UL;
}

const unsigned long MersenneTwister::m_mag01[2] = { 0x0UL, 0x9908b0dfUL }; 

void MersenneTwister::generateValues()
{
    unsigned long y;

    for ( int k = 0; k < (m_stateSize - m_M); ++k )
    {
        y = 
            ( m_state[ k ] & m_upperMask ) |
            ( m_state[ k + 1 ] & m_lowerMask );
        m_state[ k ] = 
            m_state[ k + m_M ] ^
            ( y >> 1 ) ^ m_mag01[ y & 0x1UL ];
    }

    for ( int k = m_stateSize - m_M; k < m_stateSize - 1; ++k )
    {
        y = 
            ( m_state[k] & m_upperMask ) |
            ( m_state[ k + 1 ] & m_lowerMask );
        m_state[ k ] = 
            m_state[ k + ( m_M - m_stateSize ) ] ^
            ( y >> 1 ) ^ m_mag01[ y & 0x1UL ];
    }

    y = m_state[ m_stateSize - 1 ] & m_upperMask |
        m_state[ 0 ] & m_lowerMask;
        
    m_state[ m_stateSize - 1 ] =
        m_state[ m_stateSize - 1 ] ^
        ( y >> 1 ) ^ m_mag01[ y & 0x1UL ];

    m_statePos = 0;

}

unsigned long MersenneTwister::rand_unsigned_long()
{
    unsigned long returnValue;
    if ( m_statePos >= m_stateSize ) generateValues();

    
    returnValue = m_state[ m_statePos ];
    ++m_statePos;

    // Temper the value
    returnValue ^= ( returnValue >> 11 );
    returnValue ^= ( returnValue << 7 ) & 0x9d2c5680UL;
    returnValue ^= ( returnValue << 15 ) & 0xefc60000UL;
    returnValue ^= ( returnValue >> 18 );

    return returnValue;
}


double MersenneTwister::rand_double_closed( double lower, double upper )
{
    double range = upper - lower;
    return (rand_unsigned_long() * ( range / 4294967295.0 )) + lower;
    // we divide by 2^32 - 1
}

double MersenneTwister::rand_double_half_closed( double lower, double upper )
{
    double range = upper - lower;
    return (rand_unsigned_long() * ( range / 4294967296.0 )) + lower;
    // we divide by 2^32. The half closed interval is slightly smaller
    // than the closed interval, so the spacing is smaller (which means
    // we need to divide by a larger number
}

float MersenneTwister::rand_float_closed( float lower, float upper )
{
    float range = upper - lower;
    return (rand_unsigned_long() * ( range / 4294967295.0 )) + lower;
}

float MersenneTwister::rand_float_half_closed( float lower, float upper )
{
    float range = upper - lower;
    return (rand_unsigned_long() * ( range / 4294967296.0 )) + lower;
    // we divide by 2^32. The half closed interval is slightly smaller
    // than the closed interval, so the spacing is smaller (which means
    // we need to divide by a larger number
}

bool MersenneTwister::rand_bool()
{
    return rand_unsigned_long()%2;
}

template <>
float randTClosed<float>( MersenneTwister& rng, float lower, float upper )
{
    return rng.rand_float_closed( lower, upper );
}

template <>
double randTClosed<double>( MersenneTwister& rng, double lower, double upper )
{
    return rng.rand_double_closed( lower, upper );
}

template <>
float randTHalfClosed<float>( MersenneTwister& rng, float lower, float upper )
{
    return rng.rand_float_half_closed( lower, upper );
}

template <>
double randTHalfClosed<double>( MersenneTwister& rng, double lower, double upper )
{
    return rng.rand_double_half_closed( lower, upper );
}

#endif
// MERSENNETWISTER_CPP_UNIVERSITY_OF_OREGON_NIC
