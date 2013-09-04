#ifndef FILTEROPTIONS_CPP_UNIVERSITY_OF_OREGON_NIC
#define FILTEROPTIONS_CPP_UNIVERSITY_OF_OREGON_NIC

#include "FilterOptions.h"

// a data class for the filter options.

FilterOptions::FilterOptions()
{
  setToDefaults();
}

FilterOptions::FilterOptions( const FilterOptions& opts )
: rolloff( opts.rolloff ), stopbandGain( opts.stopbandGain ),
  passbandGain( opts.passbandGain )
{
}

void 
FilterOptions::setToDefaults()
{
  rolloff = 2.0;
  stopbandGain = 0.01;
  passbandGain = 0.99;
}

const double FilterOptions::minPassbandGain = 50.0; 
const double FilterOptions::maxPassbandGain = 99.9; 
const double FilterOptions::minStopbandGain = 0.1;
const double FilterOptions::maxStopbandGain = 49.9; 
const double FilterOptions::minRolloff = 0.3;
const double FilterOptions::maxRolloff = 10.0; 

#endif
// FILTEROPTIONS_CPP_UNIVERSITY_OF_OREGON_NIC
