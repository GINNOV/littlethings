/*
**		$PROJECT: ConfigFile.library
**		$FILE: StrConv.h
**		$DESCRIPTION: String converting functions header
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
**
*/

#ifndef STRCONV_H
#define STRCONV_H

//UBYTE StrCmp ( STRPTR , STRPTR );

RegCall STRPTR DecStrToLong ( REGA0 STRPTR , REGA1 LONG * );
RegCall STRPTR HexStrToLong ( REGA0 STRPTR , REGA1 LONG * );
RegCall STRPTR BinStrToLong ( REGA0 STRPTR , REGA1 LONG * );
//RegCall ULONG OctStrToLong ( REGA0 STRPTR );

RegCall STRPTR LongToDecStr ( REGD0 ULONG , REGA0 STRPTR );
//RegCall STRPTR LongToUnDecStr ( REGD0 ULONG , REGA0 STRPTR );
RegCall STRPTR LongToHexStr ( REGD0 ULONG , REGA0 STRPTR );
RegCall STRPTR LongToBinStr ( REGD0 ULONG , REGA0 STRPTR );
//RegCall STRPTR LongToOctStr ( REGD0 ULONG , REGA0 STRPTR );

#endif /* STRCONV_H */
