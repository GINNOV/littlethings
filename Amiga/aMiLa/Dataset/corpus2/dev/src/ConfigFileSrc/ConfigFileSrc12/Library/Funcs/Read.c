/*
**		$PROJECT: ConfigFile.library
**		$FILE: Read.c
**		$DESCRIPTION: cf_Read() function
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

#include "StrConv.h"
#include "WriteBuffer.h"
#include "Read&Write.h"

IMPORT struct ExecBase		* SysBase;
IMPORT struct DosLibrary	* DOSBase;

ULONG ReadShort ( STRPTR, iCFHeader * );
ULONG ReadASCII ( STRPTR, iCFHeader * );

/****** configfile.library/cf_Read *******************************************
*
*   NAME
*        cf_Read -- Read a CF file.
*
*   SYNOPSIS
*        Result = cf_Read(Header,ErrorCode);
*        D0               A0     A1
*
*        BOOL cf_Read(CFHeader *,ULONG *);
*
*   FUNCTION
*        This function clears all nodes and read the CF file new. The
*        CF_HFLG_CHANGED flag in Header->Flags will be clear.
*
*   INPUTS
*        Header - The Header of the file.
*
*        ErrorCode - Contains an errorcode if the function returns FALSE
*                    or NULL.
*
*                CF_RERR_UNKOWN       - Unkown failure.
*                CF_RERR_BUFFER_MEM   - No memory for buffer.
*                CF_RERR_READ_FILE    - Couldn't read the file.
*                CF_RERR_FORMAT       - File has an error in the format
*                                       structure. (V2)
*                CF_RERR_UNKOWN_ITYPE - An unkown item type was found. (V2)
*
*   RESULT
*        Result - TRUE for success or in case of FALSE return, the ErrorCode
*                 var can be read to obtain more.
*
*   SEE ALSO
*        cf_Open(), cf_Close(), cf_Write(), <libraries/configfile.h>
*
******************************************************************************
*
*/

LibCall BOOL cf_Read ( REGA0 iCFHeader * Header, REGA1 ULONG * ErrorCode )
{
	APTR	Buffer;
	ULONG	Error, Len = Header->Length;

	FuncDe(bug("cf_Read($%08lx,$%08lx)\n{\n", Header, ErrorCode));

	if ( Len > 5 )
	{
		Len -= CF_IDENT_LEN;

		if ( Buffer = MyAllocPooled (Header->MemPool, Len) )
		{
			Seek (Header->FileHandle, 5, OFFSET_BEGINNING);		

			if ( Read (Header->FileHandle, Buffer, Len - 1) != -1 )
			{
				if ( Header->ExtFlags & CF_EFLG_ALREADY_READ )
					cf_ClearGrpList(Header);

				Error =	Header->Flags & CF_HFLG_SHORT_FILE ?
							ReadShort (Buffer, Header) :
							ReadASCII (Buffer, Header);

				if ( !Error )
				{
					MyFreePooled (Header->MemPool, Buffer, Len);

					Header->Flags		&= ~CF_HFLG_CHANGED;
					Header->ExtFlags	|= CF_EFLG_ALREADY_READ;

					FuncDe(bug("   return(TRUE)\n}\n"));
					return (TRUE);
				}

				cf_ClearGrpList(Header);
			}
			else	Error = CF_RERR_READ_FILE;

			MyFreePooled (Header->MemPool, Buffer, Len);
		}
		else	Error = CF_RERR_BUFFER_MEM;
	}
	else
	{
		FuncDe(bug("   return(TRUE)\n}\n"));
		return (TRUE);
	}

	if ( ErrorCode ) *ErrorCode = Error;

	FuncDe(bug("   return(FALSE) Error %ld\n}\n", Error));
	return (FALSE);
}

ULONG ReadShort ( STRPTR Buffer, iCFHeader * Header )
{
	iCFGroup		*GrpNode;
	iCFArgument	*ArgNode;
	iCFItem		*ItemNode;

	REGISTER STRPTR	Ptr		= Buffer;
	STRPTR				EndAdr	= Buffer + (Header->Length - CF_IDENT_EXTLEN);
	UBYTE					Type, Ext, StrLen, StructLen;

#ifndef _M68020
	UBYTE  TmpArry[sizeof (ULONG)];
#endif

	do
	{
		if ( *Ptr )
		{
			StrLen = *Ptr;
			Ptr++;

			GrpNode = NewGrp (Header, Ptr, StrLen);
			Ptr += StrLen;

			if ( *Ptr == CTRLB_SUB )
			{
				Ptr++;

				do
				{
					if( *Ptr )
					{
						StrLen = *Ptr;
						Ptr++;

						ArgNode = NewArg (GrpNode, Ptr, StrLen);
						Ptr += StrLen;

						if( *Ptr == CTRLB_SUB )
						{
							Ptr++;

							do
							{
								if( *Ptr == CTRLB_END )	{ Ptr++; break; }

								Type	= ( *Ptr & TYP_MASK );

								if( Type == TYP_STRING )
								{
									Ptr++;
									StructLen	= sizeof (iCFItem) + 2 + *Ptr;
									StrLen		= *Ptr;
									Ptr++;

									ItemNode = MyAllocPooled (Header->MemPool, StructLen);

									ItemNode->SpecialType= 0;
									ItemNode->Type			= CF_ITYP_STRING;
									ItemNode->ArgNode		= ArgNode;
									ItemNode->StructSize	= StructLen;
									ItemNode->ExtFlags	= 0;

									ItemNode->Contents.String	= (STRPTR)
										( (ULONG) ItemNode + sizeof (iCFItem) );
									ItemNode->Contents.String[0]			= StrLen;
									ItemNode->Contents.String ++;
									ItemNode->Contents.String[StrLen]	= 0;

									MemCpy (ItemNode->Contents.String, Ptr, StrLen);

									AddTail ((struct List *) &ArgNode->ItemList,
										(struct Node *) ItemNode);

									Ptr += StrLen;

									continue;
								}
	
								ItemNode = MyAllocPooled (Header->MemPool, sizeof(iCFItem));

								Ext	= ( *Ptr & NUM_MASK );

								ItemNode->SpecialType	= Bin2SType[( *Ptr & STYP_MASK ) >> 3];
								ItemNode->ArgNode			= ArgNode;
								ItemNode->StructSize		= sizeof(iCFItem);
								ItemNode->ExtFlags		= 0;

								Ptr++;

								if ( Type == TYP_NUMBER )
								{
									ItemNode->Type	= CF_ITYP_NUMBER;

									if ( Ext == NUM_BYTE )
									{
										ItemNode->Contents.Number	= (ULONG) (*Ptr);

										Ptr += sizeof(UBYTE);
									} 
									else if ( Ext == NUM_WORD )
									{
#ifdef _M68020
										ItemNode->Contents.Number	= (ULONG) *( (UWORD *) Ptr );
										Ptr += sizeof (UWORD);
#else
										TmpArry[0] = *Ptr++; TmpArry[1] = *Ptr++;

										ItemNode->Contents.Number	= (ULONG) *( (UWORD *) &TmpArry );
#endif
									}
									else
									{
#ifdef _M68020
										ItemNode->Contents.Number	= (ULONG) *( (ULONG *) Ptr );
										Ptr += sizeof (ULONG);
#else
										TmpArry[0] = *Ptr++; TmpArry[1] = *Ptr++;
										TmpArry[2] = *Ptr++; TmpArry[3] = *Ptr++;

										ItemNode->Contents.Number	= (ULONG) *( (ULONG *) &TmpArry );
#endif
									}
								}
								else if ( Type == TYP_BOOL )
								{
									ItemNode->Type					= CF_ITYP_BOOL;
									ItemNode->Contents.Bool		= 
													( Ext == BOOL_TRUE) ? TRUE : FALSE;
								}
								else
								{
									MyFreePooled (Header->MemPool, ItemNode, sizeof (iCFItem));
									return (CF_RERR_UNKOWN_ITYPE);
								}

								AddTail ((struct List *) &ArgNode->ItemList,
												(struct Node *) ItemNode);
							}
							while ( Ptr != EndAdr );
						}
					}
					else
					{
						Ptr++;
						break;
					}
				}
				while ( Ptr != EndAdr );
			}
		}
		else break;
	}
	while ( Ptr != EndAdr );

	return (NULL);
}

ULONG ReadASCII ( STRPTR Buffer, iCFHeader * Header )
{
	iCFGroup		*GrpNode;
	iCFArgument	*ArgNode;
	iCFItem		*ItemNode;

	REGISTER STRPTR	Ptr		= Buffer;
	STRPTR				EndAdr	= Buffer + Header->Length - CF_IDENT_EXTLEN,
							LinePtr, StartPtr;
	APTR					MemPool	= Header->MemPool;
	UWORD					Line		= 2, StrLen;

#define	EQUAL			'='
#define	GRP_START	'['
#define	GRP_END		']'
#define	STR_CHAR		'"'

#define	CHAR_QUOTES	0x22

#define	CHAR_LINEFEED	'\n'
#define	CHAR_NEXTITEM	','

#define	GetLine()		Line
#define	GetColumn()		Ptr - LinePtr + 1

#define	IsNameChar()	( CType[*Ptr] & CT_NAME_CHARS )
#define	IsStringChar()	( CType[*Ptr] & CT_STRING_CHARS )
#define	IsSpaceChar()	( CType[*Ptr] & CT_SPACE_CHARS )
#define	IsBoolChar()	( CType[*Ptr] & CT_BOOL )

	*EndAdr = CHAR_LINEFEED;

	LinePtr = Ptr;

	while ( Ptr < EndAdr )
	{
		while ( IsSpaceChar() )	Ptr++;

		if ( *Ptr == CHAR_LINEFEED )
		{
			Ptr ++;
			while ( *Ptr == CHAR_LINEFEED )
				{ Line ++; Ptr ++; }
			LinePtr = Ptr;
		}
		else if ( *Ptr == GRP_START )
			break;
		else if ( IsNameChar() )
		{
			GrpNode = NewGrp (Header, "", 0);
			if ( !GrpNode ) return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
			break;
		}
		else
			return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
	}

	while ( Ptr < EndAdr )
	{
		while ( IsSpaceChar() )	Ptr++;

		if ( *Ptr == CHAR_LINEFEED )
		{
			Ptr++;
			while ( *Ptr == CHAR_LINEFEED )
				{ Line ++; Ptr ++; }
			LinePtr = Ptr;
		}
		else if ( *Ptr == GRP_START )
		{
			Ptr++;

			while ( IsSpaceChar() )	Ptr++;

			StartPtr = Ptr;

			while ( IsNameChar() )	Ptr++;

			StrLen = Ptr - StartPtr;

			while ( IsSpaceChar() )	Ptr++;

			if ( *Ptr != GRP_END )
				return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL

			Ptr ++;

			while ( IsSpaceChar() )	Ptr++;

			if ( *Ptr != CHAR_LINEFEED ) 
				return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
			
			Ptr ++;

			while ( *Ptr == CHAR_LINEFEED )
				{ Line ++; Ptr ++; }

			LinePtr = Ptr;

			if ( StrLen )
				GrpNode = NewGrp (Header, StartPtr, StrLen);
			else
				GrpNode = NewGrp (Header, "", 0);

			if ( !GrpNode )
				return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
		}
		else if ( IsNameChar() )
		{
			StartPtr = Ptr;

			while ( IsNameChar() )	Ptr++;

			StrLen = Ptr - StartPtr;

			while ( IsSpaceChar() )	Ptr++;

			if ( *Ptr == EQUAL )
			{
				if ( !( ArgNode = NewArg (GrpNode, StartPtr, StrLen) ) )
					return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL

				Ptr ++;

				while ( Ptr < EndAdr )
				{
					while ( IsSpaceChar() )	Ptr++;

					if ( *Ptr == STR_CHAR )			// string item type
					{
						UWORD	 NodeLen = sizeof (iCFItem) + 2;

						StartPtr = ++Ptr;
						while ( IsStringChar() ) Ptr++;

						NodeLen += StrLen = Ptr-StartPtr;

						if ( *Ptr != STR_CHAR )			return (CF_RERR_FORMAT);
						if ( StrLen > CF_MAX_STRLEN )	return (CF_RERR_FORMAT);

						Ptr ++;

						ItemNode = MyAllocPooled (MemPool, NodeLen);

						ItemNode->SpecialType	= 0;
						ItemNode->Type				= CF_ITYP_STRING;

						ItemNode->ArgNode			= ArgNode;
						ItemNode->StructSize		= NodeLen;
						ItemNode->ExtFlags		= 0;

						ItemNode->Contents.String		= (STRPTR) ( (ULONG) ItemNode + sizeof (iCFItem) );
						ItemNode->Contents.String[0]	= StrLen;
						ItemNode->Contents.String ++;
						ItemNode->Contents.String[StrLen]	= 0;

						MemCpy (ItemNode->Contents.String, StartPtr, StrLen);

						AddTail ((struct List *) &ArgNode->ItemList, (struct Node *) ItemNode);
					}
					else
					{
						if ( !( ItemNode = MyAllocPooled (MemPool, sizeof (iCFItem)) ) )
							return (CF_RERR_FORMAT);

						ItemNode->ArgNode			= ArgNode;
						ItemNode->StructSize		= sizeof (iCFItem);
						ItemNode->ExtFlags		= 0;

						if ( IsBoolChar() )
						{
							ItemNode->Type	= CF_ITYP_BOOL;

							if ( *Ptr    == 'T' && Ptr[1] == 'R' &&
									Ptr[2] == 'U' && Ptr[3] == 'E' )	// TRUE bool item type
							{
								ItemNode->SpecialType	= CF_STYP_BOOL_TRUE;
								ItemNode->Contents.Bool	= TRUE;
								Ptr += 4;
							}
							else if ( *Ptr   == 'F' && Ptr[1] == 'A' &&
										 Ptr[2] == 'L' && Ptr[3] == 'S' &&
										 Ptr[4] == 'E')		// FALSE bool item type
							{
								ItemNode->SpecialType	= CF_STYP_BOOL_TRUE;
								ItemNode->Contents.Bool	= FALSE;
								Ptr += 5;
							}
							else if ( *Ptr   == 'Y' && Ptr[1] == 'E' &&
										 Ptr[2] == 'S' )		// YES bool item type
							{
								ItemNode->SpecialType	= CF_STYP_BOOL_YES;
								ItemNode->Contents.Bool	= TRUE;
								Ptr += 3;
							}
							else if ( *Ptr == 'N' && Ptr[1] == 'O' )	// NO bool item type
							{
								ItemNode->SpecialType	= CF_STYP_BOOL_YES;
								ItemNode->Contents.Bool	= FALSE;
								Ptr += 2;
							}
							else if ( *Ptr == 'O' )	// ON bool item type
							{
								ItemNode->SpecialType	= CF_STYP_BOOL_ON;
								Ptr ++;

								if ( *Ptr == 'N' )	// OFF bool item type
								{
									ItemNode->Contents.Bool	= TRUE;
									Ptr ++;
								}
								else if ( *Ptr == 'F' && Ptr[1] == 'F' )	// ON bool item type
								{
									ItemNode->Contents.Bool	= FALSE;
									Ptr += 2;
								}
								else goto UnkownItem;
							}
							else goto UnkownItem;
						}
						else if ( ( ( *Ptr >= '0' ) && ( *Ptr <= '9' ) ) ||
							( *Ptr == '-' ) )	// DEC number item type
						{
							ItemNode->Type					= CF_ITYP_NUMBER;
							ItemNode->SpecialType		= CF_STYP_NUM_DEC;
							Ptr = DecStrToLong (Ptr, &ItemNode->Contents.Number);
						}
						else if ( *Ptr == '$' )		// HEX number item type
						{
							ItemNode->Type					= CF_ITYP_NUMBER;
							ItemNode->SpecialType		= CF_STYP_NUM_HEX;
							Ptr = HexStrToLong (Ptr, &ItemNode->Contents.Number);
						}
						else if ( *Ptr == '%' )		// BIN number item type
						{
							ItemNode->Type					= CF_ITYP_NUMBER;
							ItemNode->SpecialType		= CF_STYP_NUM_BIN;
							Ptr = BinStrToLong (Ptr, &ItemNode->Contents.Number);
						}
						else
						{
UnkownItem:
							MyFreePooled (MemPool, ItemNode, sizeof (iCFItem));
							return (CF_RERR_UNKOWN_ITYPE);
						}

						AddTail ((struct List *) &ArgNode->ItemList, (struct Node *) ItemNode);
					}

					while ( IsSpaceChar() )	Ptr++;

					if ( *Ptr == CHAR_LINEFEED )
					{
						Ptr++;
						while ( *Ptr == CHAR_LINEFEED )
							{ Line ++; Ptr ++; }
						LinePtr = Ptr;
						break;
					}
					else if ( *Ptr == CHAR_NEXTITEM )
						Ptr ++;
					else return (CF_RERR_FORMAT);
				}
			}
			else if ( *Ptr == CHAR_LINEFEED )
			{
				if ( !( ArgNode = NewArg (GrpNode, StartPtr, StrLen) ) )
					return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL

				Ptr ++;

				while ( *Ptr == CHAR_LINEFEED )
					{ Line ++; Ptr ++; }

				LinePtr = Ptr;
			}
			else
				return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
		}
		else
		{
			return (CF_RERR_FORMAT);	// CF_RERR_LEXICAL
		}
	}

	return(NULL);
}
