/* config.h -- platform and local configuration file
 * Copyright (C) 1998 FastIO Systems, All Rights Reserved.
 * For conditions of use, license, and distribution, see LICENSE.txt or LICENSE.pdf.

    - ZLIB_COMPRESS_PATH has to be present but the content string does not matter
    because zlib/flate compression is now internal to the library.
*/


/* ==== PLATFORM DEFINE: ========================================================================== */
/* Generally, you do not have to touch below, as platform defines are done in Makefile.* or relies
   on predefined symbols of preprocessor/compiler/environment.
*/

/* #define NEXTSTEP         1 */        /* NEXTSTEP and OPENSTEP */
/* #define BSDI             1 */        /* BSDI BSD/OS 3.1/gcc 2.7.2.1 */
/* #define FreeBSD          1 */        /* FreeBSD 2.2.7-STABLE/gcc 2.7.2.1 */
/* #define Linux            1 */        /* Linux 2.0.34 (Red Hat 5.1)/gcc 2.7.2.3 */
/* #define SunOS5x          1 */        /* SunOS 5.4 / (SUNWspro/SC4.0) */
/* #define MacOS8           1 */        /* MacOS 8._ or earlier with CodeWarrier */
/* #define MacOSX           1 */        /* MacOS X Server (Rhapsody), MacOS X */
/* #define Windows          1 */        /* Not Used -- We now use _WIN32 */
/* #define UNIX             1 */
/* ================================================================================================ */

/* #define EXT_ZLIBCOMP         1 */    /* enable if you use external zlibcomp command */


#ifdef UNIX
#define PLATFORM_NAME           "Unix Generic"
#define PDF_VIEWER_COMMAND      "/usr/local/Acrobat3/bin/acroread"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define TEMP_DIRECTORY          "/tmp/"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#endif

#ifdef WARPUP
#define PLATFORM_NAME           "Amiga PPC (WarpUP)"
#define PDF_VIEWER_COMMAND      "c:xpdf"
#define ZLIB_COMPRESS_PATH      "c:"
#define TEMP_DIRECTORY          "t:"
#define BINARY_WRITE            "wb"
#define BINARY_READ         "rb"
#endif

/* MacOS 8.x and earlier with Metrowerks CodeWarrier IDE (tested with 1.7.4) */
#if defined(__MWERKS__) || defined(THINK_C)
  #define MacOS8
#endif

#ifdef MacOS8
#define PLATFORM_NAME           "MacOS 8 or earlier"
#define PDF_VIEWER_COMMAND      ""
#define ZLIB_COMPRESS_PATH      ""
#define TEMP_DIRECTORY          ""
#define BINARY_WRITE            "wb"
#define BINARY_READ         "rb"
#endif

/* NEXTSTEP 3.2, 3.3, and OPENSTEP 4.2 */
#ifdef NEXTSTEP
#define PLATFORM_NAME           "NEXTSTEP or OPENSTEP"
#define PDF_VIEWER_COMMAND      "/usr/bin/open"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* BSDI BSD/OS 3.1/gcc 2.7.2.1 */
#ifdef BSDI
#define PLATFORM_NAME           "BSDI BSD/OS 3.1"
#define PDF_VIEWER_COMMAND      "/usr/contrib/bin/gs"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* FreeBSD 2.2.7/gcc 2.7.2.1 */
#ifdef FreeBSD
#define PLATFORM_NAME           "FreeBSD"
#define PDF_VIEWER_COMMAND      "/usr/local/bin/gs"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* Linux 2.0.34 (Red Hat 5.1)/gcc 2.7.2.3 */
/* Acrobat Reader 3.0x for Linux works beautifully. */
#ifdef Linux
#define PLATFORM_NAME           "Linux"
#define PDF_VIEWER_COMMAND      "/usr/local/Acrobat3/bin/acroread"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* SunOS 5.4 / (SUNWspro/SC4.0) */
#ifdef SunOS5x
#define PLATFORM_NAME           "SunOS5.x"
#define PDF_VIEWER_COMMAND      "/usr/local/Acrobat3/bin/acroread"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* MacOS X is Unix */
#ifdef MacOSX
#define PLATFORM_NAME           "MacOS X (Server)"
#define PDF_VIEWER_COMMAND      "/usr/bin/open"
#define TEMP_DIRECTORY          "/tmp/"
#define ZLIB_COMPRESS_PATH      "/usr/local/bin/zlibcomp"
#define BINARY_WRITE            "w"
#define BINARY_READ         "r"
#define UNIX                1
#endif

/* Windows NT/95/98 (VC++ 5.0) */
#if defined(_WIN32) || defined(WIN32)
#define PLATFORM_NAME           "Windows 9x/NT"
#define PDF_VIEWER_COMMAND      "open"      /* with YB/Windows -- Not used. */
#define TEMP_DIRECTORY          "\\Temp\\"
#define ZLIB_COMPRESS_PATH      "\\Bin\\zlibcomp"
#define BINARY_WRITE            "wb"
#define BINARY_READ         "rb"
#endif


/* -------------------------------------------------------------------------- */

