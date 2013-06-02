#ifndef RANGEGENERATOR_H_UNIVERSITY_OF_OREGON_NIC
#define RANGEGENERATOR_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include <vector>

template <class T>
class RangeGenerator
{
    public:

    RangeGenerator( const std::string& description );

    void getRange( std::vector<T>& range );
    int getSize( );

    private:

    bool readNext( char token, T* value );
    void validate( const std::string& description );

    T m_values[3];

};

#endif
// RANGEGENERATOR_H_UNIVERSITY_OF_OREGON_NIC
