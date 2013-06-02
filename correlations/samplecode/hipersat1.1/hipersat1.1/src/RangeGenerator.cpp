#ifndef RANGEGENERATOR_CPP_UNIVERSITY_OF_OREGON_NIC
#define RANGEGENERATOR_CPP_UNIVERSITY_OF_OREGON_NIC

#include "RangeGenerator.h"
#include <iostream>

using namespace std;

template <class T>
RangeGenerator<T>::RangeGenerator( const string& description )
{
    int size = description.size();
    m_values[0] = 0;
    m_values[1] = 0;
    m_values[2] = 0;

    T* currentNumber = m_values;

    const char* s = description.c_str();

    bool good;

    int i = 0;
    while ( i < size && (currentNumber < (m_values + 3)) )
    {
        if( !readNext( s[i], currentNumber ) )
        {
            ++currentNumber;
        }
        ++i;
    }

    validate( description );

}

template <class T>
void RangeGenerator<T>::validate( const string& description )
{
    if ( m_values[1] == 0 )
    {
        std::cerr << "Error: range increment must me greater than" 
            << std::endl 
            << "zero. Range error in " << description << std::endl;
        exit(1);
    }

    if ( m_values[2] < m_values[1] )
    {
        std::cerr << "Error: upper bound smaller than lower bound in."
            << std::endl
            << "Range error in " << description << std::endl;
        exit(1);
    }
}

template <class T>
bool RangeGenerator<T>::readNext( char token, T* value )
{
    if ( token >= '0' && token <= '9' )
    {
        *value *= 10;
        *value += (token - '0');
        return true;
    }
    return false;
}

template <class T>
void RangeGenerator<T>::getRange( vector<T>& vec )
{
    vec.resize( 0 );
    T val = m_values[0];
    vec.push_back( val );
    while ( (val + m_values[1]) <= m_values[2] )
    {
        val += m_values[1];
        vec.push_back( val );        
    }
}

// there is a better way to do this. Fix it
// (or not, we don't really use it)
template <class T>
int RangeGenerator<T>::getSize()
{
    vector<T> x;
    getRange( x );
    return x.size();
}

/*
int main( int x, char** y )
{
    string desc;
    while ( cin >> desc )
    {
        RangeGenerator<int> foo( desc );
        vector<int> range;
        foo.getRange( range );
        for ( int i = 0; i < range.size(); ++i )
        {
            std::cout << range[i] << " ";
        }
        std::cout << std::endl;
    }
    return 0;
}
*/

#ifdef INSTANTIATE_TEMPLATES
template class RangeGenerator<int>;
#endif

#endif
// RANGEGENERATOR_CPP_UNIVERSITY_OF_OREGON_NIC
