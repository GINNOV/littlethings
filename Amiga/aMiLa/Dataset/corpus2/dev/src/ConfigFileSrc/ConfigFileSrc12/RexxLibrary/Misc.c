/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Misc.c
**		$DESCRIPTION: Misc functions.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "Misc.h"

IMPORT struct DosLibrary	*DOSBase;
IMPORT struct Library		*RexxSysBase;
IMPORT struct ExecBase		*SysBase;

/**************************************************************************/

STRPTR SetRC_TRUE ( VOID ) { return (CreateArgstring ("1", 1)); }

STRPTR SetRC_FALSE ( VOID ) { return (CreateArgstring ("0", 1)); }

/**************************************************************************/

BOOL IsValidArg ( struct RexxMsg * RxMsg , UBYTE ArgNum )
{
	if ( ( (RxMsg->rm_Action & RXARGMASK) < ArgNum ) ||
			(RxMsg->rm_Args[ArgNum] == NULL) )
		return (FALSE);
	else
		return (TRUE);
}

/**************************************************************************/

STRPTR CreateNumArgStr ( ULONG Number )
{
	UBYTE	TmpStr[11];

	SPrintf (TmpStr, "%ld", Number);
	return (CreateArgstring (TmpStr, StrLen (TmpStr)));
}

/**************************************************************************/

VOID * GetAdrArg ( struct RexxMsg *RxMsg , UBYTE ArgNum )
{
	if ( IsValidArg (RxMsg, ArgNum) )
	{
		ULONG	Long;

		if ( StrToLong (RxMsg->rm_Args[ArgNum], (LONG *)&Long) != -1 )
			return ((VOID *)Long);
	}

	return (0);
}

/**************************************************************************/

VOID SetErrVar ( struct RexxMsg * RxMsg, UBYTE Func, UBYTE Error )
{
	RXCFStrConv	ErrConv;

	switch (Func)
	{
		case ERRFUNC_OPEN:	ErrOpenToStr  (&ErrConv, Error); break;
		case ERRFUNC_READ:	ErrReadToStr  (&ErrConv, Error); break;
		case ERRFUNC_WRITE:	ErrWriteToStr (&ErrConv, Error); break;
	}

#define RXCF_ERRCODE	"CFERRCODE"
#define RXCF_ERRSTR	"CFERRSTR"

//	SetRxVar (RxMsg, RXCF_ERRCODE, ErrConv.Str, ErrConv.Len);
	SetRxVar (RxMsg, "RC", ErrConv.Str, ErrConv.Len);
}

/**************************************************************************/

STATIC ULONG Tricky=0x16C04E75; /* MOVE.B D0,(A3)+ ; RTS */

VOID SPrintf (STRPTR Buffer, STRPTR Fmt, ...)
{ RawDoFmt (Fmt, (ULONG *)&Fmt+1, (void (*)())&Tricky, Buffer); }

/**************************************************************************/
