/*
**		$PROJECT: ConfigFile.library
**		$FILE: WriteBuffer.c
**		$DESCRIPTION: The WriteBuffer system
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "WriteBuffer.h"

IMPORT struct DosLibrary	* DOSBase;
IMPORT struct ExecBase		* SysBase;

BOOL AllocWBuffer ( iCFHeader * Header , WBHeader * WBH )
{
	if ( WBH->StartPtr = MyAllocPooled (Header->MemPool, Header->WBufLength + 256) )
	{
		WBH->MemPool	= Header->MemPool;
		WBH->TotalWrite= 0;
		WBH->FH			= Header->FileHandle;

		WBH->EndPtr		= WBH->StartPtr + Header->WBufLength;
		WBH->LastPtr	= WBH->StartPtr;

		return (TRUE);
	}
	
	return (FALSE);
}

VOID FreeWBuffer ( WBHeader * WBH )
{
	if ( WBH->StartPtr != WBH->LastPtr )
		WBH->TotalWrite += Write (WBH->FH, WBH->StartPtr, WBH->LastPtr - WBH->StartPtr);

	MyFreePooled (WBH->MemPool, WBH->StartPtr, (WBH->EndPtr - WBH->StartPtr) + 256);
}

VOID WriteWBuffer ( WBHeader * WBH , STRPTR NewPtr )
{ WBH->TotalWrite += Write (WBH->FH, WBH->StartPtr, NewPtr - WBH->StartPtr); }
