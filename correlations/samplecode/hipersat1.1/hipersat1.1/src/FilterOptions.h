#ifndef FILTEROPTIONS_H_UNIVERSITY_OF_OREGON_NIC
#define FILTEROPTIONS_H_UNIVERSITY_OF_OREGON_NIC

struct FilterOptions
{
  FilterOptions();
  FilterOptions( const FilterOptions& opts );

  double rolloff;
  double stopbandGain;
  double passbandGain;

  static const double minPassbandGain;
  static const double maxPassbandGain;
  static const double minStopbandGain;
  static const double maxStopbandGain;
  static const double minRolloff;
  static const double maxRolloff;

  void setToDefaults();
};



#endif
// FILTEROPTIONS_H_UNIVERSITY_OF_OREGON_NIC
