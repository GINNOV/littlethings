/* Automatically generated header (sfdc 1.10)! Do not edit! */
#ifndef PRAGMAS_VAMPIRE_PRAGMAS_H
#define PRAGMAS_VAMPIRE_PRAGMAS_H

/*
**   $VER: vampire_pragmas.h $Id: vampire_pragmas.h 770 2017-08-31 19:47:43Z henrik $ $Id: vampire_pragmas.h 770 2017-08-31 19:47:43Z henrik $
**
**   Direct ROM interface (pragma) definitions.
**
**   Copyright (c) 2001 Amiga, Inc.
**       All Rights Reserved
*/

#if defined(LATTICE) || defined(__SASC) || defined(_DCC)
#ifndef __CLIB_PRAGMA_LIBCALL
#define __CLIB_PRAGMA_LIBCALL
#endif /* __CLIB_PRAGMA_LIBCALL */
#else /* __MAXON__, __STORM__ or AZTEC_C */
#ifndef __CLIB_PRAGMA_AMICALL
#define __CLIB_PRAGMA_AMICALL
#endif /* __CLIB_PRAGMA_AMICALL */
#endif /* */

#if defined(__SASC_60) || defined(__STORM__)
#ifndef __CLIB_PRAGMA_TAGCALL
#define __CLIB_PRAGMA_TAGCALL
#endif /* __CLIB_PRAGMA_TAGCALL */
#endif /* __MAXON__, __STORM__ or AZTEC_C */

#ifdef __CLIB_PRAGMA_LIBCALL
 #pragma libcall VampireBase V_AllocExpansionPort 6 9002
#endif /* __CLIB_PRAGMA_LIBCALL */
#ifdef __CLIB_PRAGMA_AMICALL
 #pragma amicall(VampireBase, 0x6, V_AllocExpansionPort(d0,a1))
#endif /* __CLIB_PRAGMA_AMICALL */
#ifdef __CLIB_PRAGMA_LIBCALL
 #pragma libcall VampireBase V_FreeExpansionPort c 001
#endif /* __CLIB_PRAGMA_LIBCALL */
#ifdef __CLIB_PRAGMA_AMICALL
 #pragma amicall(VampireBase, 0xc, V_FreeExpansionPort(d0))
#endif /* __CLIB_PRAGMA_AMICALL */
#ifdef __CLIB_PRAGMA_LIBCALL
 #pragma libcall VampireBase V_EnableAMMX 12 001
#endif /* __CLIB_PRAGMA_LIBCALL */
#ifdef __CLIB_PRAGMA_AMICALL
 #pragma amicall(VampireBase, 0x12, V_EnableAMMX(d0))
#endif /* __CLIB_PRAGMA_AMICALL */

#endif /* PRAGMAS_VAMPIRE_PRAGMAS_H */
