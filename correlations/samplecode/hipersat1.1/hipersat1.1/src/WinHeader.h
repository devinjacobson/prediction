#ifndef WINHEADER_H_UNIVERSITY_OF_OREGON_NIC
#define WINHEADER_H_UNIVERSITY_OF_OREGON_NIC

// MinGW doesn't provide these constants

#ifndef __BIG_ENDIAN
#define __BIG_ENDIAN 4321
#endif

#ifndef __LITTLE_ENDIAN
#define __LITTLE_ENDIAN 1234
#endif

#ifndef __BYTE_ORDER
#define __BYTE_ORDER __LITTLE_ENDIAN
#endif

#define LITTLE_ENDIAN  __LITTLE_ENDIAN
#define BIG_ENDIAN     __BIG_ENDIAN
#define PDP_ENDIAN     __PDP_ENDIAN
#define BYTE_ORDER     __BYTE_ORDER

#endif
// WINHEADER_H_UNIVERSITY_OF_OREGON_NIC
