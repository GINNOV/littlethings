
/*
 * Portable Object Compiler (c) 1997,98,99,2000,01,04,14.  All Rights Reserved.
 * $Id: objcrt.h,v 1.9 2014/03/04 09:15:17 stes Exp $
 */

/*
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Library General Public License as published 
 * by the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#ifdef __PORTABLE_OBJC__

#ifndef __objcrt__
#define __objcrt__

#include <stdio.h>		/* FILE */
#include <stddef.h>		/* size_t */

#ifndef EXPORT
#define EXPORT			/* empty */
#endif

#ifndef EXTERNC
#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif
#endif


/* The "id" type is assumed to be defined by the compiler
 * (in the case of objc or objcc, by emitting a typedef)
 * This also allows for cross compiles with gcc in ObjC mode
 * because a definition here would redefine its builtin "id".
 */

/* The traditional Objective C types (see Brad Cox' book)
 */

typedef char *SEL;		/* Uniqued String for Selector */
typedef char *STR;		/* C, NULL-terminated, String */
typedef char BOOL;		/* Boolean */
typedef FILE *IOD;		/* I/O Device */
typedef id SHR;			/* type of class, for us, it's id */

#ifdef __cplusplus
typedef id (*IMP) (...);	/* Method pointer */
#else
typedef id (*IMP) ();		/* Method pointer */
#endif

typedef void (*ARGIMP) (id, SEL, void *);	/* dispatcher */

/* The traditional Objective C defines 
 */

#ifndef YES
#define YES (BOOL)1		/* Boolean TRUE */
#endif

#ifndef NO
#define NO (BOOL)0		/* Boolean FALSE */
#endif

#ifndef nil
#define nil (id)0		/* id of Nil instance */
#endif

/* C Messenger interface - try to be compatible */

/* msg tracing */
extern BOOL msgFlag;		/* message tracing */
extern FILE *msgIOD;		/* device for message tracing */
extern FILE *dbgIOD;		/* device for dbg() call */
extern BOOL allocFlag;		/* allocation tracing */
extern BOOL dbgFlag;		/* verbose dbg() calls */
extern BOOL noCacheFlag;	/* disable messenger caching */
extern BOOL noNilRcvr;		/* do not allow msg. to nil */

/* all in the name of backw. compat. */
#ifndef NAMEOF
#define NAMEOF(myObject) ([myObject name])
#endif

SEL EXPORT selUid (STR);
STR EXPORT selName (SEL);
void EXPORT dbg (char *fmt,...);
void EXPORT prnstack (FILE * file);
void EXPORT loadobjc (void *modPtr);
void EXPORT unloadobjc (void *modPtr);


/* our own (new) forwarding C messenger */
EXTERNC IMP EXPORT fwdimp (id, SEL, IMP);
EXTERNC IMP EXPORT fwdimpSuper (id, SEL, IMP);
EXTERNC void EXPORT fwdmsg (id, SEL, void *, ARGIMP);
EXTERNC id EXPORT selptrfwd (id, SEL, id, id, id, id);

/* refcount functions */
EXTERNC id EXPORT idincref (id obj);
EXTERNC id EXPORT idassign (id * lhs, id rhs);
EXTERNC id EXPORT iddecref (id obj);

extern id (*_fileIn) (FILE *);
extern BOOL (*_fileOut) (FILE *, id);
extern BOOL (*_storeOn) (STR, id);
extern id (*_readFrom) (STR);
void EXPORT setfilein (id (*f) (FILE *));
void EXPORT setfileout (BOOL (*f) (FILE *, id));

extern id (*_showOn) (id, unsigned);

void EXPORT *OC_Malloc (size_t);
void EXPORT *OC_MallocAtomic (size_t);
void EXPORT *OC_Calloc (size_t);
void EXPORT *OC_Realloc (void *, size_t);
void EXPORT *OC_Free (void *data);

#endif /* __objcrt__ */

#endif /* __PORTABLE_OBJC__ */
 
