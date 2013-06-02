#ifndef FASTICASETTINGS_H_UNIVERSITY_OF_OREGON_NIC
#define FASTICASETTINGS_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include "ContrastFunctions.h"
#include "MatrixReader.h"
#include "DataFormat.h"

// On some platforms we run into a problem of uninitialized
// variables causing problems. We need a constructor
// to initialize all of the settings to reasonable default values
template <class T>
struct FastICASettings
{
    enum InitializationType
    {
        IDENTITY,
        RANDOM,
        USER_SPECIFIED
    };

    T convergenceTolerance;
    int maximumIterations;
    typename ContrastFunction<T>::Type contrastFunction;
    InitializationType initializationType;
    std::string userInitializationFile;
    DataFormat::DataFormat userInitializationFileFormat;
    int maximumRetries;

};

#endif
// FASTICASETTINGS_H_UNIVERSITY_OF_OREGON_NIC
