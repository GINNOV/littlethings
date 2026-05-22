/******************************************************************************

   MODUL
      in_stddef.h

   DESCRIPTION

   RCS
      $Header: in_stddef.h,v 1.1 94/08/25 16:14:25 digulla Exp $

******************************************************************************/

#ifndef IN_STDDEF_H
#define IN_STDDEF_H

/***************************************
	       Includes
***************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#if !defined(VMS) && !defined(AMIGA)
#   include <memory.h>
#endif


/***************************************
	       Defines
***************************************/
/* Offset of a field in a structure */
#ifndef offsetof
#   define offsetof(TYPE, MEMBER) ((size_t) &(((TYPE) *)0)->(MEMBER))
#endif /* offsetof */
/* Number of entries in an static array */
#ifndef NUMARRAYENTRIES
#   define NUMARRAYENTRIES(array)       (sizeof ((array)) / sizeof (((array)[0])))
#endif /* NUMARRAYENTRIES */
#ifndef NEW
#   define NEW(x)       ((x *) malloc (sizeof (x)))
#endif


#if defined(__STDC__) || defined(__cplusplus) || defined(__GNUC__)
#   define ANSI_C
#else
#   ifndef _NO_PROTO
#	define _NO_PROTO
#   endif /* !_NO_PROTO */
#endif /* !STDC && !C++ */


/* OS-dependant things */
#if defined(sun) || defined(sparc) || defined(sun4)
#   define SUN_OS
#   define NEED_ALIGN4	    /* Struktur-Header muessen 4-Byte aligned sein */
#   ifndef HAS_STRDUP
#	define HAS_STRDUP
#   endif
#endif /* sun */
#if defined(__hpux) || defined(hpux) || defined(HPUX)
#   ifndef HPUX
#	define HPUX
#   endif
#   define NEED_ALIGN4	    /* Struktur-Header muessen 4-Byte aligned sein */
#   ifndef HAS_MEMMOVE
#	define HAS_MEMMOVE
#   endif
#   ifndef HAS_STRDUP
#	define HAS_STRDUP
#   endif
#endif /* __hpux */
#ifdef ultrix
#   define ULTRIX
#   define NEED_ALIGN8	    /* Struktur-Header muessen 8-Byte aligned sein */
#   ifndef HAS_MEMMOVE
#	define HAS_MEMMOVE
#   endif
#endif /* ultrix */
#ifdef i386
#   if defined (M_XENIX) && defined (M_SYSV)
/* #	   define SCO */
#	ifndef HAS_MEMMOVE
#	    define HAS_MEMMOVE
#	endif
#	ifndef HAS_STRDUP
#	    define HAS_STRDUP
#	endif
#   else
#	define Interactive
#	ifndef HAS_MEMMOVE
#	    define HAS_MEMMOVE
#	endif
#	ifndef HAS_STRDUP
#	    define HAS_STRDUP
#	endif
#   endif /* SCO oder Interactive */
#endif /* PC */
#ifdef VMS
#   ifndef HAS_MEMMOVE
#	define HAS_MEMMOVE
#   endif
#endif

#if defined(SUN_OS) || defined (HPUX) || defined (ULTRIX) || defined(unix) || defined(_unix) || defined(__unix)
#   ifndef UNIX
#	define UNIX
#   endif /* UNIX */
#endif

/* Gewisse Defines speziell fuer UNIX */
#if !defined(AMIGA)
#   define __geta4
#   define __saveds
#   define __asm
#   define REG(x)
#   if defined(NEED_ALIGN8) && !defined(NEED_ALIGN4)
#	define NEED_ALIGN4
#   endif /* Align8 definiert, aber Align4 nicht */
#else
#   ifdef __SASC
#	define REG(x)   register __ ## x
#   elif DICE
#	define REG(x)   __ ## x
#   else
#	error "Unknown compiler"
#   endif
#endif /* !AMIGA */

#if !defined(USE_VARARGS) && !defined(USE_STDARG)
#   ifndef ANSI_C
#	define USE_VARARGS
#   else /* ANSI_C */
#	define USE_STDARG
#   endif /* ANSI_C */
#endif /* neither var- nor stdarg. */

/* If we are lucky, we use GCC. In this case either stdarg AND varargs is ok */
#if defined(__GNUC__)
#   undef USE_STDARG
#   undef USE_VARARGS
#   define USE_STDARG
#endif /* GCC */


/* How to use functions with variable arguments:

    #ifdef ANSI_C
    int printf (const char * fmt VA_PARAM)      <---- KEIN KOMMA !!!!
    #else
    int printf (fmt VA_PARAM)                   <---- KEIN KOMMA !!!!
    char * fmt;
    VA_PROTO					<---- KEIN ';' !!!!
    #endif
    {
	va_list args;		// Mit dieser Variablen werden die
				// zusaetzlichen Parameter bearbeitet
	int	t;

	VA_START (args, fmt);   // Args-Liste init. Der erste freie Parameter
				// steht nach fmt !

	// Jetzt koennen die einzelnen Parameter mit VA_ARG() untersucht
	// werden. Dazu wird VA_ARG mit <args> und dem TYP des erwarteten
	// Parameters aufgerufen:

	    // in <fmt> %d gelesen : Wir erwarten einen Integer. VA_ARG()
	    // liest den naechsten Parameter aus der Liste.
	    t = VA_ARG (args, int);

	    // In t steht jetzt ein int und mit VA_ARG() kann nun der
	    // naechste Parameter gelesen werden.

	// VA_END() MUSS (!) immer aufgerufen werden. Es de-initilasiert
	// args. Dies ist von der jeweiligen Plattform abhaengig.
	VA_END (args);

	return (chars_emitted);
    } // dummy

*/
#ifndef va_start
#   ifdef USE_STDARG
#	include <stdarg.h>
#	ifdef ANSI_C
#	    define VA_PARAM	, ...
#	    define VA_PROTO
#	else /* !ANSI_C */
#	    ifndef HPUX
#		define VA_PARAM     , va_alist
#		define VA_PROTO     va_dcl
#	    else /* HPUX */
#		define VA_PARAM
#		define VA_PROTO
#	    endif /* HPUX */
#	endif /* !ANSI_C */
#	define VA_START(args,first)     va_start(args,first)
#   else /* !USE_STDARG */
#	include <varargs.h>
#	ifdef ANSI_C
#	    define VA_PARAM	, ...
#	    define VA_PROTO
#	else /* ANSI_C */
#	    define VA_PARAM	, va_alist
#	    define VA_PROTO	va_dcl
#	endif /* !ANSI_C */
#	define VA_START(args,first)     va_start(args)
#   endif /* !USE_STDARG */
#endif /* !va_start */
#ifndef VA_ARG
#   define VA_ARG(va,typ)       va_arg(va,typ)
#endif
#ifndef VA_END
#   define VA_END(va)           va_end(va)
#endif
#ifdef ANSI_C
#   define VA_PROTO1(t1,a1)                                                 \
	    (t1 a1 VA_PARAM)
#   define VA_PROTO2(t1,a1,t2,a2)                                           \
	    (t1 a1,t2 a2 VA_PARAM)
#   define VA_PROTO3(t1,a1,t2,a2,t3,a3)                                     \
	    (t1 a1,t2 a2,t3 a3 VA_PARAM)
#   define VA_PROTO4(t1,a1,t2,a2,t3,a3,t4,a4)                               \
	    (t1 a1,t2 a2,t3 a3,t4 a4 VA_PARAM)
#   define VA_PROTO5(t1,a1,t2,a2,t3,a3,t4,a4,t5,a5)                         \
	    (t1 a1,t2 a2,t3 a3,t4 a4,t5 a5 VA_PARAM)
#   define PROTO1(t1,a1)                                                    \
	    (t1 a1)
#   define PROTO2(t1,a1,t2,a2)                                              \
	    (t1 a1,t2 a2)
#   define PROTO3(t1,a1,t2,a2,t3,a3)                                        \
	    (t1 a1,t2 a2,t3 a3)
#   define PROTO4(t1,a1,t2,a2,t3,a3,t4,a4)                                  \
	    (t1 a1,t2 a2,t3 a3,t4 a4)
#   define PROTO5(t1,a1,t2,a2,t3,a3,t4,a4,t5,a5)                            \
	    (t1 a1,t2 a2,t3 a3,t4 a4,t5 a5)
#   define PROTO6(t1,a1,t2,a2,t3,a3,t4,a4,t5,a5,t6,a6)                      \
	    (t1 a1,t2 a2,t3 a3,t4 a4,t5 a5,t6 a6)
#else
#   define PROTO1(t1,a1)                                                    \
	    (a1) t1 a1;
#   define PROTO2(t1,a1,t2,a2)                                              \
	    (a1,a2) t1 a1; t2 a2;
#   define PROTO3(t1,a1,t2,a2,t3,a3)                                        \
	    (a1,a2,a3) t1 a1; t2 a2; t3 a3;
#   define PROTO4(t1,a1,t2,a2,t3,a3,t4,a4)                                  \
	    (a1,a2,a3,a4) t1 a1; t2 a2; t3 a3; t4 a4;
#   define PROTO5(t1,a1,t2,a2,t3,a3,t4,a4,t5,a5)                            \
	    (a1,a2,a3,a4,a5) t1 a1; t2 a2; t3 a3; t4 a4; t5 a5;
#   define PROTO5(t1,a1,t2,a2,t3,a3,t4,a4,t5,a5,t6,a6)                            \
	    (a1,a2,a3,a4,a5,a6) t1 a1; t2 a2; t3 a3; t4 a4; t5 a5; t6 a6;
#endif

/* HINT: Use this for all prototypes to make them work with both
   ANSI- and K&R-C. Use them like this:

extern int dummy P((char * a));

   Under ANSI, we'll get "(char * a)"; with K&R we'll find "()".
*/
#ifndef P
#   ifdef ANSI_C
#	define P(x)   x
#   else /* !ANSI_C */
#	define P(x)   ()
#   endif /* !ANSI_C */
#endif /* P already defined */


/* This is a small macro for fast debugging. Just write it in some
   lines and compile. The macro will tell the filename and the line. */
#ifdef DEBUG
#  ifdef ANSI_C
#     define DL      printf (__FILE__ ": %d\n", __LINE__);
#     define DLSL    printf (__FILE__ ": %d ", __LINE__);
#     define DENTER(name)  printf (__FILE__ ": %d ----> " name "\n", __LINE__);
#     define DLEAVE(name)  printf (__FILE__ ": %d <---- " name "\n", __LINE__);
#  else /* !ANSI_C */
#     define DL      printf ("%s: %d\n", __FILE__, __LINE__);
#     define DLSL    printf ("%s: %d ", __FILE__, __LINE__);
#     define DENTER(name)  printf ("%s: %d ----> %s\n", __FILE__, __LINE__, name);
#     define DLEAVE(name)  printf ("%s: %d <---- %s\n", __FILE__, __LINE__, name);
#  endif /* !ANSI_C */
#else /* !DEBUG */
#  define DL   ;
#  define DLSL ;
#endif /* !DEBUG */


/***************************************
	       typedefs
***************************************/


/***************************************
     Globale bzw. externe Variable
***************************************/


/***************************************
	       Prototypes
***************************************/


/***************************************
	  Machine Dependant
***************************************/
#ifdef AMIGA
#   include <exec/types.h>
#endif
#ifdef UNIX
#   include <unix.h>
#   ifndef CLIB_INLIB_PROTOS_H
#	include <clib/inlib_protos.h>
#   endif
#endif


#ifdef SUN_OS
#   include <os/sun.h>
#   include <strings.h> 	 /* strcasecmp()              trr, 14.01.94 */
#endif
#ifdef ULTRIX
#   include <os/ultrix.h>
#endif


#endif /* IN_STDDEF_H */

/******************************************************************************
*****  ENDE in_stddef.h
******************************************************************************/
