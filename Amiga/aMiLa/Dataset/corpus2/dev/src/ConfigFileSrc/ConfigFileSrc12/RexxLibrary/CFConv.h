/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: CFConv.h
**		$DESCRIPTION: Functions for conversion between cf and rxcf.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

#ifndef CF_CONV_H
#define CF_CONV_H

typedef struct
{
	STRPTR	Str;
	UBYTE		Len;
} RXCFStrConv;

typedef struct
{
	ULONG	Contents;
	UBYTE	Type;
	UBYTE	SType;
} RXCFItemConv;

VOID ErrOpenToStr 	( RXCFStrConv *, UBYTE );
VOID ErrReadToStr		( RXCFStrConv *, UBYTE );
VOID ErrWriteToStr	( RXCFStrConv *, UBYTE );

VOID TypeToStr 		( RXCFStrConv *, UBYTE );
VOID STypeNumToStr	( RXCFStrConv *, UBYTE );
VOID STypeBoolToStr	( RXCFStrConv *, UBYTE );

VOID OModeToStr	( RXCFStrConv *, UBYTE );

BYTE StrToOMode		( STRPTR );
WORD StrToHdrFlag 	( STRPTR );
WORD StrToType			( STRPTR );
WORD StrToSTypeNum	( STRPTR );
WORD StrToSTypeBool	( STRPTR );

BOOL ConvItemStrings ( struct RexxMsg *, RXCFItemConv *, ULONG, UBYTE, UBYTE);

#endif /* CF_CONV_H */
