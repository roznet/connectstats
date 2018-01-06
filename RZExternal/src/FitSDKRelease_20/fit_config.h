////////////////////////////////////////////////////////////////////////////////
// The following FIT Protocol software provided may be used with FIT protocol
// devices only and remains the copyrighted property of Dynastream Innovations Inc.
// The software is being provided on an "as-is" basis and as an accommodation,
// and therefore all warranties, representations, or guarantees of any kind
// (whether express, implied or statutory) including, without limitation,
// warranties of merchantability, non-infringement, or fitness for a particular
// purpose, are specifically disclaimed.
//
// Copyright 2016 Dynastream Innovations Inc.
////////////////////////////////////////////////////////////////////////////////


#if !defined(FIT_CONFIG_H)
#define FIT_CONFIG_H


#if defined(__cplusplus)
   extern "C" {
#endif

//#define FIT_USE_STDINT_H // Define to use stdint.h types. By default size in bytes of integer types assumed to be char=1, short=2, long=4.

#define FIT_LOCAL_MESGS     16 // 1-16. Sets maximum number of local messages that can be decoded. Lower to minimize RAM requirements.
#define FIT_ARCH_ENDIAN     FIT_ARCH_ENDIAN_LITTLE   // Set to correct endian for build architecture.

#define FIT_CONVERT_CHECK_CRC // Define to check file crc.
#define FIT_CONVERT_CHECK_FILE_HDR_DATA_TYPE // Define to check file header for FIT data type.  Verifies file is FIT format before starting decode.
#define FIT_CONVERT_TIME_RECORD // Define to support time records (compressed timestamp).
//#define FIT_CONVERT_MULTI_THREAD // Define to support multiple conversion threads.

#if defined(__cplusplus)
   }
#endif

#endif // !defined(FIT_CONFIG_H)
