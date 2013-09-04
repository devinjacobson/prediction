#ifndef FILTERCONSTANTS_H_UNIVERSITY_OF_OREGON_NIC
#define FILTERCONSTANTS_H_UNIVERSITY_OF_OREGON_NIC

// Constants used in the construction of different filters
namespace EGIFilterConstants
{
  enum FilterType
  {
    lowpass,
    highpass,
    bandpass,
    bandstop,
    notch,
    lowpass_notch,
    highpass_notch,
    bandpass_notch,
    bandstop_notch,
    none
  };

  enum 
  {
    /// Basic error bitmappings

    // Errors involving the relationship between cutoff values
    useless_notch            = 0x0001, // notch already cut off by stop band
    notch_below_3hz          = 0x0002, // notch below 3 Hz
    bandpass_too_small       = 0x0004, // bandpass width is < 1.0 Hz

    // Errors involving interaction with the filter options and sampling rate
    notch_above_nyquist      = 0x0008, // notch >= Nyquist from rolloff of 3.0
    bandstop_too_small       = 0x0010, // bandstop width <= 2 * rolloff
    lowpass_above_nyquist    = 0x0020, // lowpass filt. >= Nyquist from rolloff

    // warning only (code should adjust rolloff to be highpass - 0.01)
    warn_highpass_below_rolloff = 0x0040, // highpass filt. <= rolloff

    /// Masks used for determining if an error is fatal
    fatal_notch = useless_notch |
                  notch_below_3hz |
                  notch_above_nyquist,

    fatal_band  = bandpass_too_small |
                  bandstop_too_small |
                  lowpass_above_nyquist
  };

} // end namespace EGIFilterConstants

#endif
// FILTERCONSTANTS_H_UNIVERSITY_OF_OREGON_NIC
