#ifndef FILTERFACTORY_CPP_UNIVERSITY_OF_OREGON_NIC
#define FILTERFACTORY_CPP_UNIVERSITY_OF_OREGON_NIC

#include "FilterFactory.h"
#include "ConvolutionFilter.h"
#include <cmath>

#include <iostream>

using namespace std;

FilterFactory::FilterFactory( long numSamples, int samplingRate )
: m_numSamples( numSamples ), m_samplingRate( samplingRate ),
  m_pi( 3.14159265 ) // where is PI defined in a reliable place?
{
}

NICFilter<double>*
FilterFactory::makeBandpass( double lowCutoff, double highCutoff, 
                             FilterOptions& options )
{
  return makeFilterGen(lowCutoff, highCutoff, Bandpass, options);

  // the egi code flips the high and low cutoff ?? why ??
  //return makeFilterGen(highCutoff, lowCutoff, Bandpass, options);
}

NICFilter<double>*
FilterFactory::makeHighpass( double highCutoff, FilterOptions& options )
{
  return makeFilterGen( 0.0, highCutoff, Highpass, options );
}

NICFilter<double>*
FilterFactory::makeBandstop( double lowCutoff, double highCutoff,
                             FilterOptions& options )
{
  return makeFilterGen( lowCutoff, highCutoff, Bandstop, options );
}

NICFilter<double>*
FilterFactory::makeLowpass( double lowCutoff, FilterOptions& options )
{
  return makeFilterGen( lowCutoff, 0.0, Lowpass, options );
}

NICFilter<double>*
FilterFactory::makeFilterGen( double lowCutoff, double highCutoff,
 FilterType type, FilterOptions& options )
{
  resetTemporaryValues();

  // this is a refactoring of the original egi code. Rather than repeat
  // the same logic, consolidate it here with extra options to check what
  // kind of filter we really want and work with the appropriate values

  // we should talk with the EGI folks and see how this behemoth of a method
  // could be broken down into bits that are more self contained, maintainable
  // and testable

  // set up the initial variables for the computation, based on the filter type
  switch (type)
  {
    case Lowpass :
      m_passbandFreq1 = lowCutoff;
      m_stopbandFreq1 = m_passbandFreq1 + options.rolloff;
      m_passbandFreq2 = 0.0;
      m_stopbandFreq2 = 0.0;
      highCutoff = 0.0;
      break;
    case Highpass :
      m_passbandFreq2 = highCutoff;
      m_stopbandFreq2 = m_passbandFreq2 + options.rolloff;
      m_passbandFreq1 = 0.0;
      m_stopbandFreq1 = 0.0;
      lowCutoff = 0.0;
      break;
    case Bandstop :
      m_passbandFreq1 = lowCutoff;
      m_passbandFreq2 = highCutoff;
      m_stopbandFreq1 = m_passbandFreq1 + options.rolloff;
      m_stopbandFreq2 = m_passbandFreq2 - options.rolloff;
      break;
    case Bandpass :
      m_passbandFreq1 = lowCutoff;
      m_passbandFreq2 = highCutoff;
      m_stopbandFreq1 = m_passbandFreq1 - options.rolloff;
      m_stopbandFreq2 = m_passbandFreq2 + options.rolloff;
      break;
  }

  // convert edge frequencies to rad/sec
  m_passbandFreq1 *= (2 * m_pi);
  m_stopbandFreq1 *= (2 * m_pi);
  m_passbandFreq2 *= (2 * m_pi);
  m_stopbandFreq2 *= (2 * m_pi);

  // compute the filter length and beta for the kaiser window
  computeLengthAndBeta( lowCutoff, highCutoff, options );
#ifdef DEBUG
  cout << "m_length:" << m_filterLength <<
     " m_beta:" << m_beta << endl;
#endif
  // intemediate values
  double tau;
  double cutoff1;
  double cutoff2;

  // compute the cutoff values
  tau = ((double)(m_filterLength - 1))/2;
  cutoff1 = (m_stopbandFreq1 + m_passbandFreq1) / (2 * m_samplingRate);
  cutoff2 = (m_stopbandFreq2 + m_passbandFreq2) / (2 * m_samplingRate);

  double* bFilterCoefs = new double[ m_filterLength ];

  // a better design would call functions that computed the coefficients. the
  // switch statements are just big and ugly
  for ( int i = 0; i < m_filterLength; ++i )
  {
    if ( i == (int)(tau) )
    {
      switch( type )
      {
        case Lowpass :
          bFilterCoefs[i] = cutoff1 / m_pi;
          break;
        case Highpass :
          bFilterCoefs[i] = (m_pi - cutoff2) / m_pi;
          break;
        case Bandstop :
          bFilterCoefs[i] = (m_pi + cutoff1 - cutoff2) / m_pi;
          break;
        case Bandpass :
          bFilterCoefs[i] = (cutoff2 - cutoff1)/m_pi;
          break;
      }
#ifdef DEBUG
      cout << " " << bFilterCoefs[i];
#endif

    } else
    {
      double t = i - tau;
      switch( type )
      {
        case Lowpass :
          bFilterCoefs[i] = sin( cutoff1 * t ) / ( m_pi * t );
          break;
        case Highpass :
          bFilterCoefs[i] = ( sin( m_pi * t ) - 
                              sin( cutoff2 * t ) ) / 
                            ( m_pi * t );
          break;
        case Bandstop :
          bFilterCoefs[i] = ( sin( m_pi * t ) -
                              sin( cutoff2 * t ) +
                              sin( cutoff1 * t ) ) /
                            ( m_pi * t );
          break;
        case Bandpass:
          bFilterCoefs[i] = ( sin( cutoff2 * t ) - 
                              sin( cutoff1 * t) ) /
                            ( m_pi * t);
          break;
      }
#ifdef DEBUG
      cout << " " << bFilterCoefs[i];
#endif
    }
  }
#ifdef DEBUG
  cout << endl;
#endif
  double ii;
  double dFilterLength = (double)(m_filterLength);
  double* aCoefficients = new double[ m_filterLength ];
  double IoBeta = Io( m_beta );

  // compute the Kaiser window coefficients
  for ( int i = 0; i < (m_filterLength+1)/2; ++i )
  {
    ii = (double)(i);
    aCoefficients[i] = Io(2 * m_beta * sqrt(ii * (dFilterLength - ii - 1)) /
                          (dFilterLength - 1)) /
                       IoBeta;
    aCoefficients[m_filterLength - 1 - i] = aCoefficients[i];
  }

  // multiply window coefficients by the ideal coefficients
  for ( int i = 0; i < m_filterLength; ++i )
  {
    aCoefficients[i] *= bFilterCoefs[i];
  }

  // create and return the filter
  NICFilter<double>* filter = new ConvolutionFilter<double>( aCoefficients,
                                                     m_filterLength );

  delete [] aCoefficients;
  delete [] bFilterCoefs;
  return filter;
}

void
FilterFactory::resetTemporaryValues()
{
  m_passbandFreq1 = 0.0;
  m_passbandFreq2 = 0.0;
  
  m_stopbandFreq1 = 0.0;
  m_stopbandFreq2 = 0.0;

  m_filterLength = 0;
  m_beta = 0.0;
}

void
FilterFactory::computeLengthAndBeta( const double lowCutoff, 
                                     const double highCutoff,
                                     FilterOptions& options )
{
  double frequencyDelta = 0;
  double lowerFrequencyDelta;
  double upperFrequencyDelta;
  double stopbandError;
  double passbandError;
  double minError;
  double minDbError;

  // determine frequency delta
  if ( lowCutoff != 0.0 && highCutoff != 0.0 )
  {
    // bandstop and bandpass
    lowerFrequencyDelta = fabs ( m_stopbandFreq1 - m_passbandFreq1 ) / 
                          m_samplingRate;
    upperFrequencyDelta = fabs ( m_stopbandFreq2 - m_passbandFreq1 ) /
                          m_samplingRate;
    frequencyDelta = std::min( lowerFrequencyDelta, upperFrequencyDelta );
  }
  else if ( lowCutoff != 0.0 )
  {
    frequencyDelta = fabs( m_stopbandFreq1 - m_passbandFreq1 ) / 
                           m_samplingRate;
  }
  else if ( highCutoff != 0.0 )
  {
    frequencyDelta = fabs( m_stopbandFreq2 - m_passbandFreq2 ) / 
                           m_samplingRate;
  }

  // determine the stopband and passband errors
  double stopbandGain = convertToDb( options.stopbandGain );
  double passbandGain = convertToDb( options.passbandGain );

  stopbandError = pow( 10, 0.05 * stopbandGain );
  passbandError = 1 - pow( 10, 0.05 * passbandGain );

  // which is the smallest of the two errors?
  minError = std::min( stopbandError, passbandError );

  // compute the error in dB, then estimate the beta
  minDbError = -20 * log10( minError );
  if( minDbError > 50 )
  {
    m_beta = 0.1102 * ( minDbError - 8.7 );
  }
  else if ( minDbError > 21 )
  {
    m_beta = 0.5842 * pow((minDbError - 21), 0.4) +
             0.07886 * (minDbError - 21 );
  }
  else
  {
    m_beta = 0;
  }

  // compute the filter length
  if ( minDbError > 21 )
  {
    m_filterLength = (int) ceil( (minDbError - 7.95) / 
                               (2.285 * frequencyDelta) + 1 );
  }
  else
  {
    m_filterLength = (int) ceil( (5.794/frequencyDelta) + 1 );
  }

  // make the filter length odd
  if ( 0 == (m_filterLength%2) ) ++m_filterLength;
}

// Numeric computation of a Bessel Function
double
FilterFactory::Io( double value, const int maxTerms, const double delta )
{
  bool converge = false;
  double Iold = 1.0;
  double Inew = 0.0;
  double J = 1.0;
  double K = value / 2.0;

  // use series expansion definition of Bessel
  for ( int i = 1; (i < maxTerms) && (!converge); ++i )
  {
    J *= K/(double)(i);
    Inew = Iold + (J * J);
    if ( (Inew < Iold) < delta ) converge = true;
    Iold = Inew;
  }

  if (!converge) return 0.0;
  return Inew;
}

double
FilterFactory::convertToDb( double value )
{
  return 10 * log10( value );
}

#endif
// FILTERFACTORY_CPP_UNIVERSITY_OF_OREGON_NIC
