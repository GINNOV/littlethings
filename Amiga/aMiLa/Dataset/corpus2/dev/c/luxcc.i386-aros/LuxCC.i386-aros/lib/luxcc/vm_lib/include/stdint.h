#ifndef _STDINT_H
#define _STDINT_H

/* Exact integral types.  */

/* Signed.  */
typedef signed char         int8_t;
typedef short int           int16_t;
typedef int                 int32_t;
#ifdef __LP64__
typedef long int            int64_t;
#else
typedef long long int       int64_t;
#endif


/* Unsigned.  */
typedef unsigned char       uint8_t;
typedef unsigned short int  uint16_t;
typedef unsigned int        uint32_t;
#ifdef __LP64__
typedef unsigned long int   uint64_t;
#else
typedef unsigned long long int uint64_t;
#endif


/* Small types.  */

/* Signed.  */
typedef signed char         int_least8_t;
typedef short int           int_least16_t;
typedef int                 int_least32_t;
#ifdef __LP64__
typedef long int            int_least64_t;
#else
typedef long long int       int_least64_t;
#endif
/* Unsigned.  */
typedef unsigned char       uint_least8_t;
typedef unsigned short int  uint_least16_t;
typedef unsigned int        uint_least32_t;
#ifdef __LP64__
typedef unsigned long       uint_least64_t;
#else
typedef unsigned long long  uint_least64_t;
#endif


/* Fast types.  */

/* Signed.  */
typedef signed char         int_fast8_t;
#ifdef __LP64__
typedef long int            int_fast16_t;
typedef long int            int_fast32_t;
typedef long int            int_fast64_t;
#else
typedef int                 int_fast16_t;
typedef int                 int_fast32_t;
typedef long long int       int_fast64_t;
#endif
/* Unsigned.  */
typedef unsigned char       uint_fast8_t;
#ifdef __LP64__
typedef unsigned long int   uint_fast16_t;
typedef unsigned long int   uint_fast32_t;
typedef unsigned long int   uint_fast64_t;
#else
typedef unsigned int        uint_fast16_t;
typedef unsigned int        uint_fast32_t;
typedef unsigned long long int uint_fast64_t;
#endif


/* Types for `void *' pointers.  */
#ifdef __LP64__
typedef long int            intptr_t;
typedef unsigned long int   uintptr_t;
#else
typedef int                 intptr_t;
typedef unsigned int        uintptr_t;
#endif


/* Largest integral types.  */
#ifdef __LP64__
typedef long int            intmax_t;
typedef unsigned long int   uintmax_t;
#else
typedef long long int       intmax_t;
typedef unsigned long long int uintmax_t;
#endif


/* Limits. */

/* Minimum of signed integral types.  */
# define INT8_MIN       (-128)
# define INT16_MIN      (-32768)
# define INT32_MIN      (-2147483647-1)
#ifdef __LP64__
# define INT64_MIN      (-9223372036854775807L-1L)
#else
# define INT64_MIN      (-9223372036854775807LL-1LL)
#endif
/* Maximum of signed integral types.  */
# define INT8_MAX       (127)
# define INT16_MAX      (32767)
# define INT32_MAX      (2147483647)
#ifdef __LP64__
# define INT64_MAX      (9223372036854775807L)
#else
# define INT64_MAX      (9223372036854775807LL)
#endif

/* Maximum of unsigned integral types.  */
# define UINT8_MAX      (255)
# define UINT16_MAX     (65535)
# define UINT32_MAX     (4294967295U)
#ifdef __LP64__
# define UINT64_MAX     (18446744073709551615UL)
#else
# define UINT64_MAX     (18446744073709551615ULL)
#endif


/* Minimum of signed integral types having a minimum size.  */
# define INT_LEAST8_MIN     (-128)
# define INT_LEAST16_MIN    (-32768)
# define INT_LEAST32_MIN    (-2147483647-1)
#ifdef __LP64__
# define INT_LEAST64_MIN    (-9223372036854775807L-1L)
#else
# define INT_LEAST64_MIN    (-9223372036854775807LL-1LL)
#endif
/* Maximum of signed integral types having a minimum size.  */
# define INT_LEAST8_MAX     (127)
# define INT_LEAST16_MAX    (32767)
# define INT_LEAST32_MAX    (2147483647)
#ifdef __LP64__
# define INT_LEAST64_MAX    (9223372036854775807L)
#else
# define INT_LEAST64_MAX    (9223372036854775807LL)
#endif

/* Maximum of unsigned integral types having a minimum size.  */
# define UINT_LEAST8_MAX    (255)
# define UINT_LEAST16_MAX   (65535)
# define UINT_LEAST32_MAX   (4294967295U)
#ifdef __LP64__
# define UINT_LEAST64_MAX   (18446744073709551615UL)
#else
# define UINT_LEAST64_MAX   (18446744073709551615ULL)
#endif


/* Minimum of fast signed integral types having a minimum size.  */
#define INT_FAST8_MIN       (-128)
#ifdef __LP64__
#  define INT_FAST16_MIN    (-9223372036854775807L-1L)
#  define INT_FAST32_MIN    (-9223372036854775807L-1L)
#else
#  define INT_FAST16_MIN    (-2147483647-1)
#  define INT_FAST32_MIN    (-2147483647-1)
#endif
#ifdef __LP64__
# define INT_FAST64_MIN     (-9223372036854775807L-1L)
#else
# define INT_FAST64_MIN     (-9223372036854775807LL-1LL)
#endif
/* Maximum of fast signed integral types having a minimum size.  */
#define INT_FAST8_MAX       (127)
#ifdef __LP64__
#  define INT_FAST16_MAX    (9223372036854775807L)
#  define INT_FAST32_MAX    (9223372036854775807L)
#else
#  define INT_FAST16_MAX    (2147483647)
#  define INT_FAST32_MAX    (2147483647)
#endif
#ifdef __LP64__
# define INT_FAST64_MAX     (9223372036854775807L)
#else
# define INT_FAST64_MAX     (9223372036854775807LL)
#endif

/* Maximum of fast unsigned integral types having a minimum size.  */
#define UINT_FAST8_MAX     (255)
#ifdef __LP64__
#  define UINT_FAST16_MAX   (18446744073709551615UL)
#  define UINT_FAST32_MAX   (18446744073709551615UL)
#else
#  define UINT_FAST16_MAX   (4294967295U)
#  define UINT_FAST32_MAX   (4294967295U)
#endif
#ifdef __LP64__
# define UINT_FAST64_MAX (18446744073709551615UL)
#else
# define UINT_FAST64_MAX (18446744073709551615ULL)
#endif


/* Values to test for integral types holding `void *' pointer.  */
#ifdef __LP64__
#  define INTPTR_MIN        (-9223372036854775807L-1L)
#  define INTPTR_MAX        (9223372036854775807L)
#  define UINTPTR_MAX       (18446744073709551615UL)
#else
#  define INTPTR_MIN        (-2147483647-1)
#  define INTPTR_MAX        (2147483647)
#  define UINTPTR_MAX       (4294967295U)
#endif


/* Minimum for largest signed integral type.  */
#ifdef __LP64__
# define INTMAX_MIN     (-9223372036854775807L-1L)
#else
# define INTMAX_MIN     (-9223372036854775807LL-1LL)
#endif
/* Maximum for largest signed integral type.  */
#ifdef __LP64__
# define INTMAX_MAX     (9223372036854775807L)
#else
# define INTMAX_MAX     (9223372036854775807LL)
#endif

/* Maximum for largest unsigned integral type.  */
#ifdef __LP64__
# define UINTMAX_MAX        (18446744073709551615UL)
#else
# define UINTMAX_MAX        (18446744073709551615ULL)
#endif


/* Limits of other integer types.  */

/* Limits of `ptrdiff_t' type.  */
#if __LP64__
#  define PTRDIFF_MIN       (-9223372036854775807L-1L)
#  define PTRDIFF_MAX       (9223372036854775807L)
#else
#  define PTRDIFF_MIN       (-2147483647-1)
#  define PTRDIFF_MAX       (2147483647)
#endif

/* Limit of `size_t' type.  */
#if __LP64__
#  define SIZE_MAX      (18446744073709551615UL)
#else
#  define SIZE_MAX      (4294967295U)
#endif

#endif
