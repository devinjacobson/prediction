#ifndef VERSION_CPP_UNIVERSITY_OF_OREGON_NIC
#define VERSION_CPP_UNIVERSITY_OF_OREGON_NIC

#include "version.h"
#include <string>

int g_hipersatVersion = HIPERSAT_VERSION;

char* NIC_COPYRIGHT =
    "Copyright 2005-2006, Neuroinformatics Center, University of Oregon\nThe University of Oregon makes no representations about the\nsuitability for this software for any purpose. It is provided\n\"as is\" without express or implied warranty.\n\n";
    
std::string hipersatVersionString()
{
    std::string stringValue = "";
    int value = HIPERSAT_VERSION;
    while ( value != 0 )
    {
        std::string temp = stringValue;
        stringValue  = ((char)(value%10) + '0');
        stringValue += temp;
        value /= 10;
    }
    return stringValue;
}

#endif
// VERSION_CPP_UNIVERSITY_OF_OREGON_NIC
