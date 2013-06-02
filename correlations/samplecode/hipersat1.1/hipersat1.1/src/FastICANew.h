#ifndef FASTICANEW_H_UNIVERSITY_OF_OREGON_NIC
#define FASTICANEW_H_UNIVERSITY_OF_OREGON_NIC

#include "NicMatrix.h"
#include "NicVector.h"
#include "FastICASettings.h"
#include "MersenneTwister.h"
#include "LAPACKWrapper.h"


// In general, create the class with the settings
// and data, then set the whitening matrix, then run.
// The whitening matrix isn't part of the settings
// because it is often computed directly from the
// data at runtime
template <class T>
class FastICANew
{
public:
    FastICANew( 
        const FastICASettings<T>& settings, 
        NicMatrix<T>* data,
        unsigned long seed = 123456UL,
        bool verbose = false );
    ~FastICANew();

    // get the computed mixing matrix
    void mixingMatrix( NicMatrix<T>& matrix, bool spheringApplied = true );

    // set the whitening (aka sphering) matrix
    void setWhiteningMatrix( NicMatrix<T>* matrix );

    // compute the mixing matrix
    void runFastICA();

private:
    // private methods
    void initialize( NicVector<T>& w, int channel, int retries );
    void loadGuess();
    T estimateConvergence( NicVector<T>& w, NicVector<T>& w1 );

    //private members
    // settings
    FastICASettings<T> m_settings;
    
    // data
    NicMatrix<T>* m_data;
    NicMatrix<T> m_mixingMatrix;
    NicMatrix<T>* m_whiteningMatrix;
    NicMatrix<T>* m_invWhiteningMatrix;
    int m_channels; // rows of data
    int m_samples;  // columns of data
    NicMatrix<T>* m_initialGuess;

    // function objects and functions
    MersenneTwister m_randNumGen;
    ContrastFunction<T>* m_contrastFunction;

    // MPI information
    int m_commRank;
    int m_commSize;

    bool m_verbose;

};

#endif
// FASTICANEW_H_UNIVERSITY_OF_OREGON_NIC
