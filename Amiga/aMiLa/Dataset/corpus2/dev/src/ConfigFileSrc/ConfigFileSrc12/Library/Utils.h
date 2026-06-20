/*
**		$PROJECT: ConfigFile.library
**		$FILE: Utils.h
**		$DESCRIPTION: Header file of Utils.c.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef UTILS_H
#define UTILS_H 1

LONG GetFileSize ( BPTR );

STRPTR NewStr ( APTR, UBYTE );
VOID DelStr ( APTR, STRPTR );
STRPTR DupStr ( APTR, STRPTR );
//STRPTR DupStrF ( STRPTR );

#define IsMListEmpty(x) \
	( ((x)->mlh_TailPred) == (struct Node *)(x) )


#ifdef CF_FUNC_DEBUG
#define FuncDe(a)	a
#else
#define FuncDe(a)
#endif

#ifdef CF_STEP_DEBUG
#define StepDe(a)	a
#else
#define StepDe(a)
#endif

SaveDS VOID bug ( STRPTR , ... );

APTR DEBAllocPooled ( APTR, ULONG );
APTR DEBCreatePool ( ULONG, ULONG, ULONG );
VOID DEBDeletePool ( APTR );
VOID DEBFreePooled ( APTR, APTR, ULONG );

#endif /* UTILS_H */
