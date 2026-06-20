/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: CFConv.c
**		$DESCRIPTION: Functions for conversion between cf and rxcf.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *DOSBase;

VOID ErrOpenToStr ( RXCFStrConv * ErrCode , UBYTE CFErr )
{
	switch (CFErr)
	{
		case CF_OERR_OPEN_FILE:		ErrCode->Str	= "OERR_OPEN_FILE";
											ErrCode->Len	= 14; break;
		case CF_OERR_READ_FILE:		ErrCode->Str	= "OERR_READ_FILE";
											ErrCode->Len	= 14; break;
		case CF_OERR_NO_FORMAT:		ErrCode->Str	= "OERR_NO_FORMAT";
											ErrCode->Len	= 14; break;
		case CF_OERR_NO_SIZE:		ErrCode->Str	= "OERR_NO_SIZE";
											ErrCode->Len	= 12; break;
		case CF_OERR_HEADER_MEM:	ErrCode->Str	= "OERR_HEADER_MEM";
											ErrCode->Len	= 15; break;

		case CF_RERR_FORMAT:			ErrCode->Str	= "RERR_FORMAT";
											ErrCode->Len	= 11; break;
		case CF_RERR_UNKOWN_ITYPE:	ErrCode->Str	= "RERR_UNKOWN_ITYPE";
											ErrCode->Len	= 17; break;

		default:							ErrCode->Str	= "OERR_UNKOWN";
											ErrCode->Len	= 11; break;
	}
}

VOID ErrReadToStr ( RXCFStrConv * ErrCode , UBYTE CFErr )
{
	switch (CFErr)
	{
		case CF_RERR_BUFFER_MEM:	ErrCode->Str	= "RERR_BUFFER_MEM";
											ErrCode->Len	= 15; break;
		case CF_RERR_READ_FILE:		ErrCode->Str	= "RERR_READ_FILE";
											ErrCode->Len	= 14; break;
		case CF_RERR_FORMAT:			ErrCode->Str	= "RERR_FORMAT";
											ErrCode->Len	= 11; break;
		case CF_RERR_UNKOWN_ITYPE:	ErrCode->Str	= "RERR_UNKOWN_ITYPE";
											ErrCode->Len	= 17; break;

		default:							ErrCode->Str	= "RERR_UNKOWN";
											ErrCode->Len	= 11; break;
	}
}

VOID ErrWriteToStr ( RXCFStrConv * ErrCode , UBYTE CFErr )
{
	switch (CFErr)
	{
		case CF_WERR_ALLOC_WBUFFER:ErrCode->Str	= "WERR_ALLOC_WBUFFER";
											ErrCode->Len	= 18; break;

		default:							ErrCode->Str	= "WERR_UNKOWN";
											ErrCode->Len	= 11; break;
	}
}

VOID TypeToStr ( RXCFStrConv * TypeConv , UBYTE Type )
{
	switch (Type)
	{
		case CF_ITYP_STRING:	TypeConv->Str	= "ITYP_STRING";
									TypeConv->Len	= 11; break;
		case CF_ITYP_NUMBER:	TypeConv->Str	= "ITYP_NUMBER";
									TypeConv->Len	= 11; break;
		case CF_ITYP_BOOL:	TypeConv->Str	= "ITYP_BOOL";
									TypeConv->Len	=  9; break;

		default:					TypeConv->Str	= "ITYP_UNKOWN";
									TypeConv->Len	= 11; break;
	}
}

VOID STypeNumToStr ( RXCFStrConv * STypeConv , UBYTE SType )
{
	switch (SType)
	{
		case CF_STYP_NUM_DEFAULT:	STypeConv->Str	= "STYP_NUM_DEFAULT";
											STypeConv->Len	= 16; break;
		case CF_STYP_NUM_DEC:		STypeConv->Str	= "STYP_NUM_DEC";
											STypeConv->Len	= 12; break;
		case CF_STYP_NUM_HEX:		STypeConv->Str	= "STYP_NUM_HEX";
											STypeConv->Len	= 12; break;
		case CF_STYP_NUM_BIN:		STypeConv->Str	= "STYP_NUM_BIN";
											STypeConv->Len	= 12; break;

		default:							STypeConv->Str	= "STYP_UNKOWN";
											STypeConv->Len	= 11; break;
	}
}

VOID STypeBoolToStr ( RXCFStrConv * STypeConv , UBYTE SType )
{
	switch (SType)
	{
		case CF_STYP_BOOL_DEFAULT:	STypeConv->Str	= "STYP_BOOL_DEFAULT";
											STypeConv->Len	= 17; break;
		case CF_STYP_BOOL_TRUE:		STypeConv->Str	= "STYP_BOOL_TRUE";
											STypeConv->Len	= 14; break;
		case CF_STYP_BOOL_YES:		STypeConv->Str	= "STYP_BOOL_YES";
											STypeConv->Len	= 14; break;
		case CF_STYP_BOOL_ON:		STypeConv->Str	= "STYP_BOOL_ON";
											STypeConv->Len	= 14; break;

		default:							STypeConv->Str	= "STYP_UNKOWN";
											STypeConv->Len	= 11; break;
	}
}

VOID OModeToStr ( RXCFStrConv * OModeConv , UBYTE OMode )
{
	switch (OMode)
	{
		case CF_OMODE_OLDFILE:		OModeConv->Str	= "OMODE_OLDFILE";
											OModeConv->Len	= 13; break;
		case CF_OMODE_NEWFILE:		OModeConv->Str	= "OMODE_NEWFILE";
											OModeConv->Len	= 13; break;
		case CF_OMODE_READWRITE:	OModeConv->Str	= "OMODE_READWRITE";
											OModeConv->Len	= 15; break;

		default:							OModeConv->Str	= "OMODE_UNKOWN";
											OModeConv->Len	= 12; break;
	}
}

BYTE StrToOMode ( STRPTR OModeStr )
{
	if ( !StrCmp (OModeStr, "OMODE_OLDFILE") )
		return (CF_OMODE_OLDFILE);
	else if ( !StrCmp (OModeStr, "OMODE_NEWFILE") )
		return (CF_OMODE_NEWFILE);
	else if ( !StrCmp (OModeStr, "OMODE_READWRITE") )
		return (CF_OMODE_READWRITE);

	return (-1);
}

WORD StrToHdrFlag ( STRPTR FlagStr )
{
	if ( !StrCmp (FlagStr, "HFLG_SHORT_FILE") )
		return (CF_HFLG_SHORT_FILE);
	else if ( !StrCmp (FlagStr, "HFLG_ASCII_FILE") )
		return (CF_HFLG_ASCII_FILE);
	else if ( !StrCmp (FlagStr, "HFLG_CHANGED") )
		return (CF_HFLG_CHANGED);
	else if ( !StrCmp (FlagStr, "HFLG_WRITE_BY_CLOSE") )
		return (CF_HFLG_WRITE_BY_CLOSE);

	return (-1);
}

WORD StrToType ( STRPTR TypeStr )
{
	if ( !StrCmp (TypeStr, "ITYP_STRING") )
		return (CF_ITYP_STRING);
	else if ( !StrCmp (TypeStr, "ITYP_NUMBER") )
		return (CF_ITYP_NUMBER);
	else if ( !StrCmp (TypeStr, "ITYP_BOOL") )
		return (CF_ITYP_BOOL);

	return (-1);
}

WORD StrToSTypeNum ( STRPTR STypeStr )
{
	if ( !StrCmp (STypeStr, "STYP_NUM_DEFAULT") )
		return (CF_STYP_NUM_DEFAULT);
	else if ( !StrCmp (STypeStr, "STYP_NUM_DEC") )
		return (CF_STYP_NUM_DEC);
	else if ( !StrCmp (STypeStr, "STYP_NUM_HEX") )
		return (CF_STYP_NUM_HEX);
	else if ( !StrCmp (STypeStr, "STYP_NUM_BIN") )
		return (CF_STYP_NUM_BIN);

	return (-1);
}

WORD StrToSTypeBool ( STRPTR STypeStr )
{
	if ( !StrCmp (STypeStr, "STYP_BOOL_DEFAULT") )
		return (CF_STYP_BOOL_DEFAULT);
	else if ( !StrCmp (STypeStr, "STYP_BOOL_TRUE") )
		return (CF_STYP_BOOL_TRUE);
	else if ( !StrCmp (STypeStr, "STYP_BOOL_YES") )
		return (CF_STYP_BOOL_YES);
	else if ( !StrCmp (STypeStr, "STYP_BOOL_ON") )
		return (CF_STYP_BOOL_ON);

	return (-1);
}

BOOL ConvItemStrings ( struct RexxMsg * RxMsg, RXCFItemConv * ItemConv,
					ULONG ContentsNum, UBYTE TypeNum, UBYTE STypeNum )
{
	UBYTE	Result = FALSE;

	if ( TypeNum && IsValidArg (RxMsg, TypeNum) )
	{
		ItemConv->Type = StrToType (RXARG(TypeNum));
		if ( ItemConv->Type == -1 ) return (FALSE);
		Result = TRUE;
	}
	else	ItemConv->Type = CF_ITYP_STRING;

	if ( STypeNum && IsValidArg (RxMsg, STypeNum) )
	{
		if ( ItemConv->Type == CF_ITYP_NUMBER )
			ItemConv->SType = StrToSTypeNum  (RXARG(STypeNum));
		else if ( ItemConv->Type == CF_ITYP_BOOL )
			ItemConv->SType = StrToSTypeBool (RXARG(STypeNum));
		else	ItemConv->SType = CF_STYP_NUM_DEFAULT;

		if ( ItemConv->SType == -1 ) return (FALSE);
		Result = TRUE;
	}
	else	ItemConv->SType = CF_STYP_NUM_DEFAULT;

	if ( ContentsNum && IsValidArg (RxMsg, ContentsNum) )
	{
		if ( ItemConv->Type == CF_ITYP_STRING )
			ItemConv->Contents = (ULONG)RXARG(ContentsNum);
		else
		{
			if ( StrToLong (RXARG(ContentsNum),
					(LONG *)&ItemConv->Contents) == -1 )
				return (FALSE);
		}
		Result = TRUE;
	}
	else	ItemConv->Contents = 0;

	return (Result);
}

