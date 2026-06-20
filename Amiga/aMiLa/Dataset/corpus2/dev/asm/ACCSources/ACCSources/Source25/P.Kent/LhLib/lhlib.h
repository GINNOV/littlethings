/* $Revision Header * Header built automatically - do not edit! *************
 *
 *	(C) Copyright 1990 by Holger P. Krekel & Olaf 'Olsen' Barthel
 *
 *	Name .....: lhlib.h
 *	Created ..: Tuesday 10-Jul-90 21:31
 *	Revision .: 0
 *
 *	Date            Author          Comment
 *	=========       ========        ====================
 *	22-Jul-90       Olsen           Pragmas & ENCODEEXTRA
 *	10-Jul-90       Olsen           Created this file!
 *
 * $Revision Header ********************************************************/

#ifndef _LHLIB_H
#define _LHLIB_H 1

#ifndef	EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif	/* EXEC_LIBRARIES_H */

	/* Name of lh.library */

#define LH_NAME		"lh.library"

	/* Lowest revision currently in use. */

#define LH_VERSION	1

	/* Additional amount of memory required for data compression. */

#define ENCODEEXTRA(n) ((n + 7) >> 3)

	/* Standard LhBuffer structure as used by LhEncode/LhDecode. */

struct LhBuffer
{
	APTR	lh_Src;		/* Source data. */
	ULONG	lh_SrcSize;	/* Size of source data. */

	APTR	lh_Dst;		/* Destination data. */
	ULONG	lh_DstSize;	/* Size of destination data. */

	APTR	lh_Aux;		/* Auxilary buffer (private!) */
	ULONG	lh_AuxSize;	/* Size of auxilary buffer (private!) */

	ULONG	lh_Reserved;	/* Reserved for future extension. */
};

	/* Do the prototypes & pragma calls. */

#ifdef __NO_PROTOS
#undef __NO_PROTOS
#endif	/* __NO_PROTOS */

#ifdef AZTEC_C

#ifndef __VERSION
#define __VERSION 360
#endif	/* __VERSION */

#if __VERSION < 500
#define __NO_PROTOS	1
#define __NO_PRAGMAS	1
#endif	/* __VERSION */

#endif	/* AZTEC_C */

#ifdef __NO_PROTOS
#define __ARGS(x) ()
#else
#define __ARGS(x) x
#endif	/* __NO_PROTOS */

	/* Function prototypes. */

struct LhBuffer	*	CreateBuffer __ARGS((LONG OnlyDecode));
VOID			DeleteBuffer __ARGS((struct LhBuffer *));

ULONG			LhEncode __ARGS((struct LhBuffer *));
ULONG			LhDecode __ARGS((struct LhBuffer *));

	/* Function pragmas. */

#ifndef __NO_PRAGMAS

#ifdef AZTEC_C
#pragma amicall(LhBase, 0x1e, CreateBuffer(d0))
#pragma amicall(LhBase, 0x24, DeleteBuffer(a0))
#pragma amicall(LhBase, 0x2a, LhEncode(a0))
#pragma amicall(LhBase, 0x30, LhDecode(a0))
#else	/* LATTICE */
#pragma libcall LhBase CreateBuffer 1e 1
#pragma libcall LhBase DeleteBuffer 24 801
#pragma libcall LhBase LhEncode 2a 801
#pragma libcall LhBase LhDecode 30 801
#endif	/* AZTEC_C */

#endif	/* __NO_PRAGMAS */

#endif	/* _LHLIB_H */
