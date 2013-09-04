#ifndef FILTERFACTORY_H_UNIVERSITY_OF_OREGON_NIC
#define FILTERFACTORY_H_UNIVERSITY_OF_OREGON_NIC

#include "NICFilter.h"
#include "FilterOptions.h"

// A factory class used to create coefficients for
// different filter types. The various filter types
// share quite a bit of code in construction, with
// different initial conditions. The previous code
// used a cut and past approach for making the different
// filter types. This class refactored that original
// design and traded extra logic for code duplication
class FilterFactory
{
public:
  FilterFactory( long numSamples, int samplingRate );

  NICFilter<double>* makeLowpass( double lowCutoff, FilterOptions& options );
  NICFilter<double>* makeHighpass( double highCutoff, FilterOptions& options );

  NICFilter<double>* makeBandpass( double lowCutoff, double highCutoff,
    FilterOptions& options );
  NICFilter<double>* makeBandstop( double lowCutoff, double highCutoff,
    FilterOptions& options );

private:

  enum FilterType
  {
    Bandpass,
    Bandstop,
    Lowpass,
    Highpass
  };

  NICFilter<double>* makeFilterGen( double lowCutoff, double highCutoff,
    FilterType type, FilterOptions& options );


  void resetTemporaryValues();
  void computeLengthAndBeta( const double lowCutoff, 
                             const double highCutoff,
                             FilterOptions& options );

  // modified Bessel function of the first kind
  double Io( double value, const int maxTerms = 100, 
    const double delta = 1e-15 );

  double convertToDb( double value );

  long m_numSamples;
  int m_samplingRate;

  // in using the factory methods, these are temporary variables
  double m_passbandFreq1;
  double m_passbandFreq2;

  double m_stopbandFreq1;
  double m_stopbandFreq2;

  int m_filterLength;
  double m_beta;

  const double m_pi;
};

#endif
// FILTERFACTORY_H_UNIVERSITY_OF_OREGON_NIC
