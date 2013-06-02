#ifndef INFOMAXNEW_H_UNIVERSITY_OF_OREGON_NIC
#define INFOMAXNEW_H_UNIVERSITY_OF_OREGON_NIC

#include "InfomaxSettings.h"
#include "NicMatrix.h"
#include "NicVector.h"
#include "MersenneTwister.h"
#include "LAPACKWrapper.h"
#include "index_array.h"

// In general, create the class with the settings
// and data, then set the whitening matrix, then run.
// An optional step is to set all of the activations
// from the resulting mixing matrix to be positive.
// The whitening matrix isn't part of the settings
// because it is often computed directly from the
// data at runtime
template <class T>
class InfomaxNew
{
public:
    InfomaxNew(
        const InfomaxSettings<T>& settings,
        NicMatrix<T>* data,
        unsigned long seed,
        bool verbose );
    ~InfomaxNew();

    // get the computed mixing matrix
    void mixingMatrix( NicMatrix<T>& matrix, bool spheringApplied = true );

    // set the whitening (aka sphering) matrix
    void setWhiteningMatrix( NicMatrix<T>* matrix );
    
    // compute the mixing matrix
    void runInfomax();

    // modify the mixing matrix so that all of the
    // activation channels have positive mean
    void posact( NicMatrix<T>& data, NicMatrix<T>& mixing );

private:
    // private methods
    void loadGuess();
    void searchForWeights();
    void initializeNeuralNet();
    bool trainingLoop();
    void setU( int index );
    void setY( );
    void updateW( int size );
    void updateBl( T* bl, T* y, int size );
    void updateTm( T* tm );
    void updateW( T* w, T* Dw, int size);
    void updateBias();
    bool weightExceeded();
    T estimateConvergence();
    void annealLearningRate();

    // private members
    InfomaxSettings<T> m_settings;

    // data
    NicMatrix<T>* m_data;
    NicMatrix<T> m_mixingMatrix;
    NicMatrix<T>* m_whiteningMatrix;
    NicMatrix<T>* m_invWhiteningMatrix;
    int m_channels;
    int m_samples;
    NicMatrix<T>* m_initialGuess;

    // algorithm structures for neural net
    T m_initDelta;
    T m_delta;
    T m_deltaAngle;
    T m_oldDelta;

    // a bunch of temorary data matrices
    NicMatrix<T> m_biasLoad;
    NicMatrix<T> m_tempM;
    NicVector<T> m_tempV;
    NicMatrix<T> m_weights;
    NicMatrix<T> m_oldWeights;
    NicMatrix<T> m_xTraining;
    NicMatrix<T> m_weightsDelta;
    NicMatrix<T> m_oldWeightsDelta;
    NicMatrix<T> m_u;
    NicMatrix<T> m_y;
    NicVector<T> m_bias;
    IndexArray m_indexArray;
    int m_blocks;

    // new fields and methods for extended mode
    bool m_extended;
    int m_extendedBlocks; // eeglab defaults to 1
    int m_kurtosisSize ; // eeglab defaults to 6000
    void setYextended() {}
    void updateWextended( int size ) {}
    void updateBiasExtended() {}
    void estimateKurtosis() {}


    // function objects and functions
    MersenneTwister m_randNumGen;
    ContrastFunction<T>* m_contrastFunction;

    bool m_verbose;
};

#endif
// INFOMAXNEW_H_UNIVERSITY_OF_OREGON_NIC
