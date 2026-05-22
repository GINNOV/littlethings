/*
**		$PROJECT: ConfigFile.library
**		$FILE: WriteBuffer.h
**		$DESCRIPTION: The WriteBuffer system header
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
**
*/

#ifndef WBUFFER_H
#define WBUFFER_H

typedef struct
{
	STRPTR	StartPtr;
	APTR		MemPool;
	ULONG		TotalWrite;
	BPTR		FH;
	STRPTR	EndPtr;
	STRPTR	LastPtr;
} WBHeader;

BOOL AllocWBuffer ( iCFHeader * , WBHeader * );
VOID FreeWBuffer  ( WBHeader * );
VOID WriteWBuffer ( WBHeader * , STRPTR );

#define CharInWBuff(Char)		*BuffPtr++ = Char
#define StrInWBuff(Str,Len)	MemCpy (BuffPtr,Str,Len); BuffPtr += Len

#define UpdWBuff()	if ( BuffPtr > WBH->EndPtr ) { \
		WriteWBuffer (WBH, BuffPtr); BuffPtr = WBH->StartPtr; }

#endif /* WBUFFER_H */
