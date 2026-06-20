/*
**		$PROJECT: ConfigFile.library
**		$FILE: ALibStuff.h
**		$DESCRIPTION: Functions prototypes of the AmigaLib.
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef ALIB_STUFF_H
#define ALIB_STUFF_H 1

VOID NewList ( struct List *list );

/*
__stdargs APTR LibAllocPooled (APTR, ULONG);
__stdargs APTR LibCreatePool (ULONG, ULONG, ULONG);
__stdargs VOID LibDeletePool (APTR);
__stdargs VOID LibFreePooled (APTR, APTR, ULONG);
*/

RegCall APTR AsmAllocPooled (REGA0 APTR, REGD0 ULONG, REGA6 struct ExecBase *);
RegCall APTR AsmCreatePool (REGD0 ULONG, REGD1 ULONG, REGD2 ULONG, REGA6 struct ExecBase *);
RegCall VOID AsmDeletePool (REGA0 APTR, REGA6 struct ExecBase *);
RegCall VOID AsmFreePooled (REGA0 APTR, REGA1 APTR, REGD0 ULONG, REGA6 struct ExecBase *);

#endif /* ALIB_STUFF_H */
