
/* Portable Object Compiler (c) 1997,98.  All Rights Reserved.
 *
 * DO NOT EDIT -- configure objc-3.3.1 powerpc-unknown-morphos
 */

#ifndef OBJCRT_CONFIG_H
#define OBJCRT_CONFIG_H

/* On some machines, the names _alloc, _error etc. are defined in a
 * system library.  Avoid name clash by using the following macros
 * in our sources, while not changing a thing on platforms where
 * this isn't a problem.
 *
 * Define '1' to use oc_objcInit, define '0' to use classical objcInit.
 */

#define OBJCRT_USE_PREFIXED_NAMES 0

/* The following is used in the c++ grammar
 *
 * Define '1' if your lex has a yyless() function.  Otherwise '0'.
 */

#define OBJCRT_USE_YYLESS 1

/*
 * For cross compiles with some versions of the Linux Stepstone objcc
 * (problem with assert.h on some Linuxes, or well, one of the problems!).
 *
 * Note that an undefined #pragma emits a warning on HP-UX cc.
 */

#define OBJCRT_LINUX 0

#ifdef __PORTABLE_OBJC__
#if OBJCRT_LINUX
#pragma OCbuiltInVar __PRETTY_FUNCTION__
#endif /* OBJCRT_LINUX */
#endif

/*
 * On some machines we don't have a stdarg.h header file.
 * If OBJCRT_USE_STDARG is 0, then we #include varargs.h (e.g. SunOS4)
 * va_start & co are needed for methods such as +sprintf:
 */

#define OBJCRT_USE_STDARG 1

#if OBJCRT_USE_STDARG
#include "stdarg.h"
#define OC_VA_LIST va_list
#define OC_VA_START(ap,larg) va_start(ap,larg)
#define OC_VA_ARG(ap,type) va_arg(ap,type)
#define OC_VA_END(ap) va_end(ap)
#else
#include "varargs.h"
#define OC_VA_LIST va_list
#define OC_VA_START(ap,larg) va_start(ap)
#define OC_VA_ARG(ap,type) va_arg(ap,type)
#define OC_VA_END(ap) va_end(ap)
#endif /* OBJCRT_USE_STDARG */

/*
 * stes 12/97
 * Some machines have a snprintf() that allows to check for
 * buffer overflow.  If we have this, use it in the String class.
 */

#define OBJCRT_USE_SNPRINTF 1

/*
 * stes 10/97
 * This should work everywhere, but let's take no risk
 *
 */

#define OBJCRT_USE_MEMSET 1

/*
 * stes 11/97
 * Define (on WIN32) as __declspec(dllexport) or similar,
 * when building an OBJCRT.DLL (compile with -DOBJCRTDLL)
 *
 */

#ifdef OBJCRTDLL
#define EXPORT 
#else
#define EXPORT /* null */
#endif /* OBJCRTDLL */

/*
 * For some cross-compiles, notably those with some Stepstone
 * all C messenger compilers, we want to prevent a clash between
 * our definition (which doesn't use SHR) and theirs.
 *
 * For all other compilers, including most Stepstone 3 arg messenger
 * compilers,  OBJCRT_PROTOTYPE_MESSENGER is defined as "1".
 */

#define OBJCRT_PROTOTYPE_MESSENGER 1

/*
 * See comment in objcrt.m.  For compilers that do not support common
 * storage of globals at all, this must be defined as '1'.
 */

#define OBJCRT_SCOPE_OBJCMODULES_EXTERN 0

/*
 * Compiled in path separator. (Module.m and objc.m)
 */
 
#define OBJCRT_DEFAULT_PATHSEPC "/"

/*
 * On the Macintosh (with metrowerks at least) we cannot make a call
 * to system() in the driver
 *
 */

#define OBJC_HAVE_SYSTEM_CALL 1

#endif /* OBJCRT_CONFIG_H */

