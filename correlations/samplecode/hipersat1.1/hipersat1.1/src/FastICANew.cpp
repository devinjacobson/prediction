#ifndef FASTICANEW_CPP_UNIVERSITY_OF_OREGON_NIC
#define FASTICANEW_CPP_UNIVERSITY_OF_OREGON_NIC

#include "FastICANew.h"
#include "MPIWrapper.h"
#include "MatrixOperations.h"
#include <math.h>

template <class T>
FastICANew<T>::FastICANew( 
    const FastICASettings<T>& settings, 
    NicMatrix<T>* data,
    unsigned long seed,
    bool verbose )
:   
    m_settings( settings ),
    m_data( data ),
    m_mixingMatrix( data->rows, data->rows ),
    m_whiteningMatrix( 0 ),
    m_invWhiteningMatrix( 0 ),
    m_channels( data->rows ),
    m_samples( data->total_columns ),
    m_initialGuess( 0 ),
    m_randNumGen( seed ),
    m_contrastFunction( 
        ContrastFunction<T>::getContrastFunction(
        m_settings.contrastFunction ) ), 
    m_commRank( getMPIRank() ),
    m_commSize( getMPISize() ),
    m_verbose( verbose )
{
    loadGuess();
}

template <class T>
FastICANew<T>::~FastICANew()
{
    if ( m_whiteningMatrix != 0 ) delete m_whiteningMatrix;
    if ( m_invWhiteningMatrix != 0 ) delete m_invWhiteningMatrix;
    if ( m_initialGuess != 0 ) delete m_initialGuess;
}

template <class T>
void
FastICANew<T>::mixingMatrix( NicMatrix<T>& matrix, bool spheringApplied )
{
    if ( spheringApplied && (m_whiteningMatrix != 0) )
    {
        matrix = *m_whiteningMatrix;
        multiply( m_mixingMatrix, matrix );
    }
    else
    {
        matrix = m_mixingMatrix;
    }
}

template <class T>
void
FastICANew<T>::setWhiteningMatrix( NicMatrix<T>* matrix )
{
    m_whiteningMatrix = new NicMatrix<T>();
    *m_whiteningMatrix = *matrix;
    m_invWhiteningMatrix = new NicMatrix<T>;
    invert<T>( *m_whiteningMatrix, *m_invWhiteningMatrix );

}


template <class T>
void
FastICANew<T>::loadGuess()
{
    if ( m_commRank == 0 )
    {
        if ( m_settings.initializationType == FastICASettings<T>::USER_SPECIFIED )
        {
            m_initialGuess = new NicMatrix<T>( m_channels, m_channels );
            if ( !MatrixReader<T>::loadMatrix(
                *m_initialGuess,
                m_settings.userInitializationFileFormat,
                m_channels,
                m_channels,
                m_settings.userInitializationFile ) )
            {
                cerr << "Error loading user guess file " <<
                    m_settings.userInitializationFile <<
                    " in FastICANew." << endl;
                abort();
            }
//            multiply( *m_whiteningMatrix, *m_initialGuess );
        }
    }
}

template <class T>
void FastICANew<T>::runFastICA()
{
    if ( m_settings.initializationType == FastICASettings<T>::USER_SPECIFIED )
    {
        if ( m_whiteningMatrix != 0 )
        {
            multiply( *m_whiteningMatrix, *m_initialGuess );
        }
    }

    NicVector<T> w( m_channels );
    NicVector<T> w0( m_channels );
    NicVector<T> w1( m_channels );
    NicMatrix<T> matrixBBt( m_channels, m_channels );
    for ( int i = 0; i < m_channels; ++i )
    {
        int retries = 0;
        bool channelDone = false;
        if ( m_verbose ) cout << "IC " << i+1 << " ";
        while ( (retries < m_settings.maximumRetries) &&
                (!channelDone) )
        {
            initialize( w, i, retries );
            w.orthogonalize( &matrixBBt );
            w.normalize();
            int iterations = 0;
            T delta = 10000;
            while( (delta > m_settings.convergenceTolerance ) &&
                    ( iterations < m_settings.maximumIterations ) )
            {
                if ( m_verbose ) cout << "." << flush;
                (*m_contrastFunction)( m_data, &w, &w1 );
                allreduceDataMPI<T>( w1.data, w0.data, m_channels );
                w0.orthogonalize( &matrixBBt );
                w0.normalize();
                delta = estimateConvergence( w, w0 );
                w.swap_vectors( &w0 );
                w0.zero_vector();
                w1.zero_vector();
                ++iterations;
            }
            if ( delta < m_settings.convergenceTolerance )
            {
                T alpha = 1;
                int xIncrement = 1;
                NicVector<T> v( w );
//                if ( m_invWhiteningMatrix != 0 )
//                {
//                    NicVector<T> v1( w );
//                    multiply( *m_whiteningMatrix, v1, v );
//                }
                m_mixingMatrix.add_row( &v, i );
                Tger( &m_channels, &m_channels, &alpha, w.data,
                       &xIncrement, w.data, &xIncrement,
                       matrixBBt.data, &m_channels );
                channelDone = true;
                if ( m_verbose ) cout << iterations+1 << endl;
            }
            else
            {
                ++retries;
            }
        }
    }
}

template <class T>
T FastICANew<T>::estimateConvergence( NicVector<T>& w, NicVector<T>& w0 )
{
    T* dataOld = w.data;
    T* dataNew = w0.data;
    T delta = 0;
    T delta1 = 0; 
    T delta2 = 0;

    for ( int i = 0; i < m_channels; ++i )
    {
        delta1 += pow( dataOld[i] - dataNew[i], 2 );
        delta2 += pow( dataOld[i] + dataNew[i], 2 );
    }
    delta = ( delta1 < delta2 ) ? delta1 : delta2;
    delta = sqrt( delta );
    return delta;
}

template <class T>
void FastICANew<T>::initialize( NicVector<T>& w, int channel, int retries )
{
    if ( m_commRank == 0 )
    {
        if ( ( retries > 0 ) || 
             ( m_settings.initializationType == FastICASettings<T>::RANDOM ) )
        {
            T sum = 0.0;
            for ( int j = 0; j < m_channels; ++j )
            {
                w.data[j] = randTClosed<T>( m_randNumGen, -1, 1 );
                sum += ( w.data[j] * w.data[j] );
            }
            sum = sqrt( sum );
            for ( int j = 0; j < m_channels; ++j )
            {
                w.data[j] /= sum;
            }
        }
        else if ( m_settings.initializationType == FastICASettings<T>::IDENTITY )
        {
            for ( int i = 0; i < m_channels; ++i )
            {
                if ( i == channel ) w.data[i] = 1;
                else w.data[i] = 0;
            }
        }
        else if (m_settings.initializationType == FastICASettings<T>::USER_SPECIFIED )
        {
            memcpy( 
                w.data, 
                m_initialGuess->data + ( channel * m_channels ),
                m_channels * sizeof( T ) );
            NicVector<T> a( w );
            if ( m_whiteningMatrix != 0 )
            {
                multiply( *m_whiteningMatrix, a, w );
            }
        }
    }
    broadcastDataMPI( w.data, m_channels, 0 );
}

#ifdef INSTANTIATE_TEMPLATES
template class FastICANew<double>;
template class FastICANew<float>;
#endif

#endif
// FASTICANEW_CPP_UNIVERSITY_OF_OREGON_NIC
