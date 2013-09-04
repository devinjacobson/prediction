#ifndef INFOMAXNEW_CPP_UNIVERSITY_OF_OREGON_NIC
#define INFOMAXNEW_CPP_UNIVERSITY_OF_OREGON_NIC

#include "InfomaxNew.h"
#include "MatrixOperations.h"
#include <math.h>

template <class T>
InfomaxNew<T>::InfomaxNew(
    const InfomaxSettings<T>& settings,
    NicMatrix<T>* data,
    unsigned long seed,
    bool verbose )
:   m_settings( settings ),
    m_data( data ),
    m_mixingMatrix( data->rows, data->rows ),
    m_whiteningMatrix( 0 ),
    m_invWhiteningMatrix( 0 ),
    m_channels( data->rows ),
    m_samples( data->columns ),
    m_initialGuess( 0 ),
    m_initDelta( 0 ),
    m_delta( 0 ),
    m_deltaAngle( 0 ),
    m_oldDelta( 0 ),
    m_biasLoad( m_channels, settings.nnBlockSize ),
    m_tempM( m_channels, m_channels ), // is this right?
    m_tempV( m_channels ),
    m_xTraining( m_channels, settings.nnBlockSize ),
    m_weights( m_channels, m_channels ),
    m_oldWeights( m_channels, m_channels ),
    m_weightsDelta( m_channels, m_channels ),
    m_oldWeightsDelta( m_channels, m_channels ),
    m_u( m_channels, settings.nnBlockSize ),
    m_y( m_channels, settings.nnBlockSize ),
    m_bias( m_channels ),
    m_indexArray( m_samples, seed ),
    m_blocks( m_samples / settings.nnBlockSize ),
    m_extended( false ),
    m_randNumGen( seed ),
    m_verbose( verbose )
{
    if ( m_settings.initializationType == InfomaxSettings<T>::IDENTITY )
    {
        m_initialGuess = new NicMatrix<T>( m_data->rows, m_data->rows );
        m_initialGuess->identity_matrix();
    }
    else if ( m_settings.initializationType == InfomaxSettings<T>::RANDOM )
    {
        m_initialGuess = new NicMatrix<T>( m_data->rows, m_data->rows );
        m_initialGuess->random_matrix();
    }
    else if ( m_settings.initializationType == InfomaxSettings<T>::USER_SPECIFIED )
    {
        // we need to do this later per Bob's request
        //loadGuess();
    }
}

template <class T>
InfomaxNew<T>::~InfomaxNew()
{
    if ( m_whiteningMatrix != 0 ) delete m_whiteningMatrix;
    if ( m_invWhiteningMatrix != 0 ) delete m_invWhiteningMatrix;
    if ( m_initialGuess != 0 ) delete m_initialGuess;
}

template <class T>
void InfomaxNew<T>::mixingMatrix( NicMatrix<T>& matrix, bool spheringApplied )
{
    if ( spheringApplied && ( m_whiteningMatrix != 0 ) )
    {
        matrix = *m_whiteningMatrix;
        NicMatrix<T> temp = m_weights;
        multiply( temp, matrix );
    
    }
    else
    {
        matrix = m_weights;
    }
}

template <class T>
void InfomaxNew<T>::setWhiteningMatrix( NicMatrix<T>* matrix )
{
    m_whiteningMatrix = new NicMatrix<T>();
    *m_whiteningMatrix = *matrix;
    m_invWhiteningMatrix = new NicMatrix<T>;
    invert<T>( *m_whiteningMatrix, *m_invWhiteningMatrix );
}

template <class T>
void InfomaxNew<T>::loadGuess()
{
    if ( m_settings.initializationType == InfomaxSettings<T>::USER_SPECIFIED )
    {
        m_initialGuess = new NicMatrix<T>( m_channels, m_channels );
        if ( !MatrixReader<T>::loadMatrix(
                *m_initialGuess,
                m_settings.userInitializationFormat,
                m_channels,
                m_channels,
                m_settings.userInitializationFile ) )
        {
            cerr << "Error loading user guess file " <<
                m_settings.userInitializationFile <<
                " in InfomaxNew." << endl;
            abort();
        }
        if ( m_whiteningMatrix != 0 )
        {
            multiply( *m_whiteningMatrix, *m_initialGuess );
        }
    }
}


template <class T>
void InfomaxNew<T>::runInfomax()
{
    if ( m_settings.initializationType == InfomaxSettings<T>::USER_SPECIFIED )
    {
        loadGuess();
    }

    searchForWeights();
    cout << "after search for weights" << endl;
}

template <class T>
void InfomaxNew<T>::searchForWeights()
{
    bool valid = true;
    int steps = 0;
    int retries = 0;

    initializeNeuralNet();

    std::cout << "maximum iterations: " << m_settings.maximumIterations << endl;
    std::cout << m_settings.maximumIterations << " " << m_settings.convergenceTolerance << " " << m_settings.maximumRetries << endl;
    while( steps < m_settings.maximumIterations  &&
           m_delta > m_settings.convergenceTolerance &&
           retries < m_settings.maximumRetries )
    {
        if ( m_settings.nnRandomLearning )
        {
            m_indexArray.permute_uniform();
        }
        else
        {
            m_indexArray.ordered_indices();
        }

        T* wTemp = m_weights.data;
        int sizeTemp = m_weights.size;
        valid = trainingLoop();
        if ( valid )
        {
            m_delta = estimateConvergence();
            ++steps;
            cout << steps << ": Learning Rate:" << m_settings.nnLearningRate <<
                ", delta: " << m_delta << endl;
            if ( steps > 2 )
            {
                annealLearningRate();
                
                if ( m_delta > m_settings.nnMaxDivergence )
                {
                    m_settings.nnLearningRate *= m_settings.nnDivergenceFactor;
                }
            } 
            else if ( steps == 1 )
            {
                m_oldDelta = m_delta;
                m_oldWeightsDelta = m_weightsDelta;
            }
            else // steps == 2
            {
            }
        }
        else // not valid
        {
            steps = 0;
            m_settings.nnLearningRate *= m_settings.nnWeightRestartFactor;
            cout << "restart with new learning rate: " << m_settings.nnLearningRate << endl;
            if ( m_settings.nnLearningRate < m_settings.nnMinLearningRate )
            {
                cout << "Infomax could not converge on a solution." << endl;
                exit(1);
            }
            initializeNeuralNet();
        }
    }
}

template <class T>
void InfomaxNew<T>::initializeNeuralNet()
{
    m_initDelta = m_settings.convergenceTolerance + 10;
    m_delta = m_initDelta;
    m_deltaAngle = 0;
    m_oldDelta = 0;

    m_weights = *m_initialGuess;
    m_oldWeights = *m_initialGuess;

    m_weightsDelta.zero_matrix();
    m_oldWeightsDelta.zero_matrix();
    m_bias.zero_vector();
}

template <class T>
bool InfomaxNew<T>::trainingLoop()
{
    int size = m_u.size;
    T* y = m_y.data;
    bool rtn = true;
    for ( int i = 0; (i < m_blocks) && rtn; ++i )
    {
#ifdef __OPENMP_
#pragma omp parallel
#endif
        {
            setU(i);
            if ( !m_extended )
            {
                setY();
            }
            else
            {
                setYextended();
            }
        }
        if ( !m_extended )
        {
            updateW( size );
            updateBias();
        }
        else
        {
            updateWextended( size );
            updateBiasExtended();
        }
        rtn = !weightExceeded( );
    }
    if ( m_extended && rtn )
    {
        estimateKurtosis();
    }
    return rtn;
}

template <class T>
void InfomaxNew<T>::setU( int idx )
{
    T* u = m_u.data;
    T* b = m_bias.data;
    T* x_t;
    int* index;

    int i, j;
    index = m_indexArray.index + ( idx * m_settings.nnBlockSize );
    T oneD = 1.0;
    int oneI = 1;
    T zero = 0.0;
#ifdef __OPENMP_
#pragma omp for private(i,j) schedule(static)
#endif
    for ( int i = 0; i < m_settings.nnBlockSize; ++i )
    {
        u = m_u.data + i * m_channels;
        x_t = m_data->data + (index[i] * m_channels);

        parallelTgemv( "N", &m_channels, &m_channels, 
            &oneD, m_weights.data, &m_channels,
            m_data->data + (index[i]*m_channels), &oneI,
            &zero, u, &oneI );
        for ( j = 0; j < m_channels; ++j )
        {
            u[j] += b[j];
        }
    }
}

template <class T>
void InfomaxNew<T>::setY()
{
    T* y = m_y.data;
    T* u = m_u.data;

    int size = m_y.size;
    int i;
#ifdef __OPENMP_
#pragma omp for private(i) schedule(static)
#endif
    for ( i = 0; i < size; ++i )
    {
        y[i] = 1.0 / ( 1 + exp(-u[i]) );
    }
}

template <class T>
void InfomaxNew<T>::updateW( int size )
{
    T* y = m_y.data;
    T* u = m_u.data;
    T* bl = m_biasLoad.data;
    T* tm = m_tempM.data;
    T* w = m_weights.data;
    T* Dw = m_weightsDelta.data;
    int i;
    T oneD = 1.0;
    int oneI = 1;
    T zero = 0.0;

    m_weightsDelta.zero_matrix();


#ifdef __OPENMP_
#pragma omp parallel
#endif
    {
        updateBl( bl, y, m_y.size );
    }
    parallelTgemm( "N", "T", 
        &m_channels, &m_channels, &(m_settings.nnBlockSize),
        &oneD, bl, &m_channels,
        u, &m_channels,
        &zero, tm, &m_channels );

#ifdef __OPENMP_
#pragma omp parallel
#endif
    {
        updateTm( tm );
    }

    parallelTgemm( "N", "N",
        &m_channels, &m_channels, &m_channels,
        &(m_settings.nnLearningRate), tm, &m_channels,
        w, &m_channels,
        &zero, Dw, &m_channels );

#ifdef __OPENMP_
#pragma omp parallel
#endif
    {
        updateW( w, Dw, m_weights.size );
    }

}

template <class T>
void InfomaxNew<T>::updateBl( T* bl, T* y, int size )
{
    int i;
#ifdef __OPENMP_
#pragma omp for private(i) schedule(static)
#endif
    for( i = 0; i < size; ++i )
    {
        bl[i] = 1 - 2*(y[i]);
    }
}

template <class T>
void InfomaxNew<T>::updateTm( T* tm )
{
    int i;
#ifdef __OPENMP_
#pragma omp for private(i) schedule(static)
#endif
    for ( i = 0; i < m_channels; ++i )
    {
        tm[ i * m_channels + i ] += m_settings.nnBlockSize;
    }
}

template <class T>
void InfomaxNew<T>::updateW( T* w, T* dw, int size )
{
    int i;
#ifdef __OPENMP_
    {
#pragma omp for private(i) schedule(static)
#endif
        for ( i = 0; i < size; ++i )
        {
            w[i] += dw[i];
        }
#ifdef __OPENMP_
    }
#endif
}

// This can be parallelized
template <class T>
void InfomaxNew<T>::updateBias()
{
    T* b = m_bias.data;
    T* t;
    T* tv = m_tempV.data;
    int i, j;
    
    m_tempV.zero_vector();

    for ( i = 0; i < m_settings.nnBlockSize; ++i )
    {
        t = m_biasLoad.data + ( i * m_channels );
        for ( j = 0; j < m_channels; ++j )
        {
            tv[j] += t[j];
        }
    }

    for ( i = 0; i < m_channels; ++i )
    {
        (*b) += ((*tv ) * m_settings.nnLearningRate );
        ++b;
        ++tv;
    }
}

// this can be made parallel
template <class T>
bool InfomaxNew<T>::weightExceeded()
{
    T* w = m_weights.data;
    int size = m_weights.size;
    T max = 0;
    int i;

    for ( i = 0; i < size; ++i )
    {
        if (*w > max)
        {
            max = *w;
            if ( max > m_settings.nnMaxWeight )
            {
                return true;
            }
        }
        ++w;
    }
    return false;
}

// this can be made parallel too
template <class T>
T InfomaxNew<T>::estimateConvergence()
{
    T* W = m_weights.data;
    T* deltaW = m_weightsDelta.data;
    T* Wprime = m_oldWeights.data;
    int size = m_weights.size;

    // Dw = weights - oldWeights
    for ( int i = 0; i < size; ++i )
    {
        (*deltaW) = (*W) - (*Wprime);
        ++deltaW;
        ++W;
        ++Wprime;
    }
    m_oldWeights = m_weights;

    T delta = 0;
    deltaW = m_weightsDelta.data;

    for ( int i = 0; i < size; ++i )
    {
        delta += (*deltaW) * (*deltaW);
        ++deltaW;
    }

    return delta;
}

// this can also be made parallel
template <class T>
void InfomaxNew<T>::annealLearningRate()
{
    const T radToDeg = 180.0 / ( 3.1415926 );
    T* W = m_weightsDelta.data;
    T* Wold = m_oldWeightsDelta.data;
    T diff = 0;

    int size = m_weightsDelta.size;
    for ( int i = 0; i < size; ++i )
    {
        diff += W[i] * Wold[i];
    }

    m_deltaAngle = acos( diff / sqrt( m_delta * m_oldDelta ) ) * radToDeg;
    cout << "Delta Angle (deg) = " << m_deltaAngle << endl;

    if ( m_deltaAngle > m_settings.nnAnnealingDegree )
    {
        m_settings.nnLearningRate *= m_settings.nnAnnealingScale;
        m_oldDelta = m_delta;
        m_oldWeightsDelta = m_weightsDelta;
    }
}

template <class T>
void InfomaxNew<T>::posact( NicMatrix<T>& data, NicMatrix<T>& mixing )
{
    mixing.resize( data.rows, data.rows );
    mixingMatrix( mixing, false );

    multiply( mixing, data );

    // I think that eventually we will need a pseudo-inverse,
    // so we want cols x rows rather than rows x cols
    // I'll need to check on this
    NicMatrix<T> invMixing( mixing.columns, mixing.rows );

    invert<T>( mixing, invMixing );

    T value;
    for ( int i = 0; i < data.rows; ++i )
    {
        T posSum = 0;
        T negSum = 0;
        int posLen = 0;
        int negLen = 0;
        for ( int j = 0; j < data.columns; ++j )
        {
            value = data(i,j); 
            if ( value < 0 )
            {
                negSum += (value * value);
                negLen += 1;
            }
            else
            {
                posSum += (value * value);
                posLen += 1;
            }
        }
        if ( negLen != 0 ) negSum /= ((T) negLen);
        if ( posLen != 0 ) posSum /= ((T) posLen);
        negSum = sqrt( negSum );
        posSum = sqrt( posSum );
        if ( posSum < negSum )
        {
            cout << "-";
            for ( int j = 0; j < data.columns; ++j )
            {
                data(i,j) *= -1;
            }
            for ( int j = 0; j < data.rows; ++j )
            {
                invMixing(j,i) *= -1;
            }
        }
        cout << i << " ";
    }
    cout << endl;
    invert<T>( invMixing, mixing );
}

#ifdef INSTANTIATE_TEMPLATES
template class InfomaxNew<double>;
template class InfomaxNew<float>;
#endif

#endif
// INFOMAXNEW_CPP_UNIVERSITY_OF_OREGON_NIC
