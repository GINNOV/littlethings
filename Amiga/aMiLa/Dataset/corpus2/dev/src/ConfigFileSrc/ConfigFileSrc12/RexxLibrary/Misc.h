/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Misc.h
**		$DESCRIPTION: Header file of Misc.c.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef MISC_H
#define MISC_H 1

STRPTR SetRC_TRUE ( VOID );
STRPTR SetRC_FALSE ( VOID );

BOOL IsValidArg ( struct RexxMsg *, UBYTE );

STRPTR CreateNumArgStr ( ULONG );
#define CreateNumArgStrP(CFNode)	CreateNumArgStr ((ULONG)CFNode)

VOID * GetAdrArg ( struct RexxMsg *, UBYTE );
#define GetLongArg(ArgNum)	(ULONG)GetAdrArg (RxMsg,ArgNum)

#define ERRFUNC_OPEN		0
#define ERRFUNC_READ		1
#define ERRFUNC_WRITE	2

VOID SetErrVar ( struct RexxMsg *, UBYTE, UBYTE );

VOID SPrintf (STRPTR, STRPTR, ...);

#endif /* MISC_H */
