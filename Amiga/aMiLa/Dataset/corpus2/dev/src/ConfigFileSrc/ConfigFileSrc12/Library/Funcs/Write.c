/*
**		$PROJECT: ConfigFile.library
**		$FILE: Write.c
**		$DESCRIPTION: cf_Write() function
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "StrConv.h"
#include "WriteBuffer.h"
#include "Read&Write.h"

IMPORT struct DosLibrary	* DOSBase;

VOID WriteShort ( iCFHeader * Header , WBHeader * WBH );
VOID WriteASCII ( iCFHeader * Header , WBHeader * WBH );

/****** configfile.library/cf_Write ******************************************
*
*   NAME
*        cf_Write -- Write a CF file new.
*
*   SYNOPSIS
*        Result = cf_Write(Header,WriteMode,ErrorCode);
*        D0                A0     D0        A1
*
*        BOOL cf_Write(CFHeader *,ULONG,ULONG *);
*
*   FUNCTION
*        This function writes the CF file new. Note is the CF_HFLG_CHANGED
*        flag in Header->Flags not set the file will be not writes new.
*
*   INPUTS
*        Header - The Header of the file to write.
*        WriteMode - Write modes and extra flags:
*
*                CF_WMODE_DEFAULT -- Writes the file in default format
*                                    from Header->Flags.
*                CF_WMODE_ASCII   -- Writes the file in ascii format.
*                CF_WMODE_SHORT   -- Writes the file in short format.
*
*                Extra write flags: (V2)
*
*                CF_WFLG_WRITE_ALWAYS -- cf_Write() checks not if the
*                                        CF_HFLG_CHANGED flag set and
*                                        writes always the file.
*
*        ErrorCode - Contain an errorcode if the function returns FALSE
*                    or NULL.
*
*                CF_WERR_UNKOWN        - Unkown failure.
*                CF_WERR_ALLOC_WBUFFER - No memory for WriteBuffer.
*
*   RESULT
*        Result - TRUE for success or in case of FALSE return, the ErrorCode
*                 var can be read to obtain more.
*
*   SEE ALSO
*        cf_Open(), cf_Close(), cf_Read(), <libraries/configfile.h>
*
******************************************************************************
*
*/

LibCall BOOL cf_Write ( REGA0 iCFHeader * Header , REGD0 ULONG Mode , REGA1 ULONG *ErrorCode )
{
	FuncDe(bug("cf_Write($%08lx,%ld,$%08lx)\n{\n", Header, Mode, ErrorCode));

	if ( ( Header->Flags & CF_HFLG_CHANGED ) || ( Mode & CF_WFLG_WRITE_ALWAYS ) )
	{
		WBHeader WBH;
		ULONG	Error;

		Mode &= ~0xFFFFFFFCL;

		Seek (Header->FileHandle, 0, OFFSET_BEGINNING);

		if ( AllocWBuffer (Header, &WBH) )
		{
			if ( ( Mode == CF_WMODE_DEFAULT ) || ( Mode > CF_WMODE_ASCII ) )
			{
				if ( Header->Flags & CF_HFLG_ASCII_FILE )
					Mode = CF_WMODE_ASCII;
				else if ( Header->Flags & CF_HFLG_SHORT_FILE )
					Mode = CF_WMODE_SHORT;
				else
					Mode = CF_WMODE_ASCII;
			}

			if ( Mode == CF_WMODE_ASCII )
				WriteASCII (Header, &WBH);
			else
				WriteShort (Header, &WBH);

			FreeWBuffer (&WBH);
			Header->Flags &= ~CF_HFLG_CHANGED;

			if ( WBH.TotalWrite && ( WBH.TotalWrite < Header->Length ) )
				SetFileSize (Header->FileHandle, WBH.TotalWrite, OFFSET_BEGINNING);

			Header->Length = WBH.TotalWrite;

			Seek (Header->FileHandle, 5, OFFSET_BEGINNING);

			FuncDe(bug("   return(TRUE)\n}\n"));
			return (TRUE);
		}
		else	Error = CF_WERR_ALLOC_WBUFFER;

OnError:
		if ( ErrorCode ) *ErrorCode = Error;
		FuncDe(bug("   return(FALSE) Error %ld\n}\n", Error));
	}

	return (FALSE);
}

VOID WriteShort ( iCFHeader * Header , WBHeader * WBH )
{
	iCFGroup		* GrpNode;
	iCFArgument	* ArgNode;
	iCFItem		* ItemNode;

	STRPTR BuffPtr = WBH->StartPtr;

#define WriteEnd()		CharInWBuff (CTRLB_END)
#define WriteSub()		CharInWBuff (CTRLB_SUB)

	StrInWBuff ("CFFT\0", 5);

	if ( GrpNode = cf_LockGrpList (Header) )
	{
		while ( GrpNode = cf_NextGroup (GrpNode) )
		{
			StrInWBuff (GrpNode->Name - 1, *(GrpNode->Name - 1) + 1);
			UpdWBuff();

			if ( ArgNode = cf_LockArgList (GrpNode) )
			{
				WriteSub();

				while ( ArgNode = cf_NextArgument (ArgNode) )
				{
					StrInWBuff (ArgNode->Name - 1, *(ArgNode->Name - 1) + 1);
					UpdWBuff();

					if ( ItemNode = cf_LockItemList (ArgNode) )
					{
						WriteSub();

						while ( ItemNode = cf_NextItem (ItemNode) )
						{
							if ( ItemNode->Type == CF_ITYP_STRING )
							{
								CharInWBuff (TYP_STRING);
								StrInWBuff (ItemNode->Contents.String - 1,
											*(ItemNode->Contents.String - 1) + 1);
							}
							else if ( ItemNode->Type == CF_ITYP_NUMBER )
							{
								UBYTE	TmpByte = (TYP_NUMBER | SType2Bin[ItemNode->SpecialType]);
								ULONG	Number  = ItemNode->Contents.Number;

								if ( Number < 0x100L )
								{
									CharInWBuff (TmpByte | NUM_BYTE);
									CharInWBuff (ItemNode->Contents.Number);
								}
								else if ( Number < 0x10000L )
								{
									CharInWBuff (TmpByte | NUM_WORD);
#ifdef _M68020
									*( (UWORD *)BuffPtr ) = Number;
									BuffPtr += 2;
#else
									{
										UBYTE *TmpWord = (UBYTE *)&Number;

										*BuffPtr++ = TmpWord[0];
										*BuffPtr++ = TmpWord[1];
									}
#endif
								}
								else
								{
									CharInWBuff (TmpByte);
#ifdef _M68020
									*( (ULONG *)BuffPtr ) = Number;
									BuffPtr += 4;
#else
									{
										UBYTE *TmpLong = (UBYTE *)&Number;

										*BuffPtr++ = TmpLong[0];
										*BuffPtr++ = TmpLong[1];
										*BuffPtr++ = TmpLong[2];
										*BuffPtr++ = TmpLong[3];
									}
#endif
								}
							}
							else if ( ItemNode->Type == CF_ITYP_BOOL )
							{
								UBYTE TmpByte = (TYP_BOOL | SType2Bin[ItemNode->SpecialType]);

								if ( ItemNode->Contents.Bool )
									TmpByte |= BOOL_TRUE;

								CharInWBuff (TmpByte);
							}

							UpdWBuff();
						}

						WriteEnd();
						cf_UnlockItemList (ArgNode);
					}
				}

				WriteEnd();
				cf_UnlockArgList (GrpNode);
			}
		}

		WriteEnd();
		cf_UnlockGrpList (Header);
	}

	Header->Flags	&= ~CF_HFLG_ASCII_FILE;
	Header->Flags	|= CF_HFLG_SHORT_FILE;

	WBH->LastPtr = BuffPtr;
}

VOID WriteASCII ( iCFHeader * Header , WBHeader * WBH )
{
	iCFGroup		* GrpNode;
	iCFArgument	* ArgNode;
	iCFItem		* ItemNode;

	BOOL		Point		= FALSE;
	STRPTR	BuffPtr	= WBH->StartPtr;

	StrInWBuff ("CFFT\n", 5);
	
	if ( GrpNode = cf_LockGrpList (Header) )
	{
		while ( GrpNode = cf_NextGroup (GrpNode) )
		{
			CharInWBuff('\n');
			CharInWBuff('[' );
			StrInWBuff (GrpNode->Name, *(GrpNode->Name - 1));
			CharInWBuff(']' );
			CharInWBuff('\n');
			CharInWBuff('\n');

			UpdWBuff();

			if ( ArgNode = cf_LockArgList (GrpNode) )
			{	
				while ( ArgNode = cf_NextArgument (ArgNode) )
				{
					StrInWBuff (ArgNode->Name, *(ArgNode->Name - 1));
					UpdWBuff();

					if ( ItemNode = cf_LockItemList (ArgNode) )
					{
						CharInWBuff('=');

						while ( ItemNode = cf_NextItem (ItemNode) )
						{
							if ( Point ) CharInWBuff(',');

							if ( ItemNode->Type == CF_ITYP_STRING )
							{
								CharInWBuff('\"');
								StrInWBuff (ItemNode->Contents.String,
													*(ItemNode->Contents.String - 1));
								CharInWBuff('\"');
	
								Point = TRUE;
							}
							else if ( ItemNode->Type == CF_ITYP_NUMBER )
							{
								if ( ItemNode->SpecialType == CF_STYP_NUM_DEC )
									BuffPtr = LongToDecStr (ItemNode->Contents.Number, BuffPtr);

								else if ( ItemNode->SpecialType == CF_STYP_NUM_HEX )
									BuffPtr = LongToHexStr (ItemNode->Contents.Number, BuffPtr);

								else if ( ItemNode->SpecialType == CF_STYP_NUM_BIN )
									BuffPtr = LongToBinStr (ItemNode->Contents.Number, BuffPtr);

								Point = TRUE;	
							}
							else if ( ItemNode->Type == CF_ITYP_BOOL )
							{
								ULONG		BoolLen;
								STRPTR	BoolStr;

								if ( ItemNode->SpecialType == CF_STYP_BOOL_TRUE )
								{
									if ( ItemNode->Contents.Bool )
										{ BoolStr = "TRUE";  BoolLen = 4; }
									else
										{ BoolStr = "FALSE"; BoolLen = 5; }
								}
								else if ( ItemNode->SpecialType == CF_STYP_BOOL_YES )
								{
									if ( ItemNode->Contents.Bool )
										{ BoolStr = "YES";	BoolLen = 3; }
									else
										{ BoolStr = "NO";		BoolLen = 2; }
								}
								else 
								{
									if ( ItemNode->Contents.Bool )
										{ BoolStr = "ON";		BoolLen = 2; }
									else
										{ BoolStr = "OFF";	BoolLen = 3; }
								}

								StrInWBuff (BoolStr, BoolLen);

								Point = TRUE;
							}

							UpdWBuff();
						}

						cf_UnlockItemList (ArgNode);
						Point = 0;
					}

					CharInWBuff('\n');
				}

				cf_UnlockArgList (GrpNode);
			}
		}
			
		cf_UnlockGrpList (Header);
	}

	Header->Flags	&= ~CF_HFLG_SHORT_FILE;
	Header->Flags	|= CF_HFLG_ASCII_FILE;

	WBH->LastPtr = BuffPtr;
}
