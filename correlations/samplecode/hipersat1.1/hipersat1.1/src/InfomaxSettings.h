#ifndef INFOMAXSETTINGS_H_UNIVERSITY_OF_OREGON_NIC
#define INFOMAXSETTINGS_H_UNIVERSITY_OF_OREGON_NIC

#include <string>
#include "ContrastFunctions.h"
#include "MatrixReader.h"
#include "DataFormat.h"

// On some platforms we run into a problem of uninitialized
// variables causing problems. We need a constructor
// to initialize all of the settings to reasonable default values
template <class T>
struct InfomaxSettings
{
    enum InitializationType
    {
        IDENTITY,
        RANDOM,
        USER_SPECIFIED
    };

    T convergenceTolerance;
    int maximumIterations;
    int maximumRetries;
    InitializationType initializationType;
    std::string userInitializationFile;
    DataFormat::DataFormat userInitializationFormat;

    int nnBlockSize;
    T nnLearningRate;
    T nnAnnealingDegree;
    T nnAnnealingScale;
    bool nnRandomLearning;
    T nnMaxWeight;
    T nnDivergence;
    T nnMaxDivergence;
    T nnWeightRestartFactor;
    T nnDivergenceFactor;
    T nnMinLearningRate;
};

#endif
// INFOMAXSETTINGS_H_UNIVERSITY_OF_OREGON_NIC
