/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Header.c
**		$DESCRIPTION: Functions for Header changes.
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *DOSBase;
IMPORT struct Library *RexxSysBase;
IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_GetOMode ***********************************
*
*   NAME
*        cf_GetOMode -- Get the openmode from the header.
*
*   SYNOPSIS
*        OMode = cf_GetOMode(Header)
*
*        OMODE cf_GetOMode(HEADER/N/A)
*
*   FUNCTION
*        This function gets the openmode from the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*
*   RESULT
*        OMode - openmode (see cf_Open()).
*
*   SEE ALSO
*        cf_Open()
*
******************************************************************************
*
*/

UWORD rxcf_GetOMode ( RX_FUNC_ARGS, CFHeader * Header )
{
	RXCFStrConv	OModeConv;

	OModeToStr  (&OModeConv, Header->OpenMode);
	*ResStr = CreateArgstring (OModeConv.Str, OModeConv.Len);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetWBufSize ********************************
*
*   NAME
*        cf_GetWBufSize -- Get the writebuffer size from the header.
*
*   SYNOPSIS
*        WBufSize = cf_GetWBufSize(Header)
*
*        WBUFSIZE cf_GetWBufSize(HEADER/N/A)
*
*   FUNCTION
*        This function gets the openmode from the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*
*   RESULT
*        WBufSize - writebuffer size.
*
******************************************************************************
*
*/

UWORD rxcf_GetWBufSize ( RX_FUNC_ARGS, CFHeader * Header )
{
	*ResStr = CreateNumArgStr (Header->WBufLength);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_GetPuddleSize ******************************
*
*   NAME
*        cf_GetPuddleSize -- Get the puddlesize from the header.
*
*   SYNOPSIS
*        PuddleSize = cf_GetPuddleSize(Header)
*
*        PUDDLESIZE cf_GetPuddleSize(HEADER/N/A)
*
*   FUNCTION
*        This function gets the puddlesize from the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*
*   RESULT
*        PuddleSize - puddlesize.
*
******************************************************************************
*
*/

UWORD rxcf_GetPuddleSize ( RX_FUNC_ARGS, CFHeader * Header )
{
	*ResStr = CreateNumArgStr (Header->PuddleSize);
	return (RC_OK);
}

/****** rexxconfigfile.library/cf_ChkHdrFlag *********************************
*
*   NAME
*        cf_ChkHdrFlag -- Check wheather a flag in the Header is set.
*
*   SYNOPSIS
*        IsSet = cf_ChkHdrFlag(Header,Flag)
*
*        BOOL cf_ChkHdrFlag(HEADER/N/A,FLAG/A)
*
*   FUNCTION
*        This function check wheather a flag in the Header is set.
*
*   INPUTS
*        Header - Pointer to the Header.
*        Flag - Flag to check:
*
*            HFLG_SHORT_FILE     -- File is in short format.
*            HFLG_ASCII_FILE     -- File is in ascii format.
*            HFLG_CHANGED        -- File is changed (this will be set, if
*                                   you use functions like cf_Add/Change/
*                                   Clone... on the open file).
*            HFLG_WRITE_BY_CLOSE -- Writes the file by use of cf_Close().
*
*   RESULT
*        IsSet - TRUE if the flags is set or FALSE if the flags not set.
*
*   SEE ALSO
*        cf_RemHdrFlag(), cf_AddHdrFlag()
*
******************************************************************************
*
*/

UWORD rxcf_ChkHdrFlag ( RX_FUNC_ARGS, CFHeader * Header )
{
	if ( RXARG2 )
	{
		UBYTE	Flag = StrToHdrFlag (RXARG2);
		if ( Flag == -1 ) return (RXERR_INVALID_ARG);
		if ( Header->Flags & Flag ) *ResStr = SetRC_TRUE ();
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_AddHdrFlag *********************************
*
*   NAME
*        cf_AddHdrFlag -- Add a flag to the Header.
*
*   SYNOPSIS
*        cf_AddHdrFlag(Header,Flag)
*
*        cf_AddHdrFlag(HEADER/N/A,FLAG/A)
*
*   FUNCTION
*        This function add a flag to the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*        Flag - Flag to add (see cf_ChkHdrFlag()).
*
*   SEE ALSO
*        cf_ChkHdrFlag(), cf_RemHdrFlag()
*
******************************************************************************
*
*/

UWORD rxcf_AddHdrFlag ( RX_FUNC_ARGS, CFHeader * Header )
{
	if ( RXARG2 )
	{
		UBYTE	Flag = StrToHdrFlag (RXARG2);
		if ( Flag == -1 ) return (RXERR_INVALID_ARG);
		Header->Flags |= Flag;
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_RemHdrFlag *********************************
*
*   NAME
*        cf_RemHdrFlag -- Remove a flag to the Header.
*
*   SYNOPSIS
*        cf_RemHdrFlag(Header,Flag)
*
*        cf_RemHdrFlag(HEADER/N/A,FLAG/A)
*
*   FUNCTION
*        This function remove a flag to the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*        Flag - Flag to remove (see cf_ChkHdrFlag()).
*
*   SEE ALSO
*        cf_ChkHdrFlag(), cf_AddHdrFlag()
*
******************************************************************************
*
*/

UWORD rxcf_RemHdrFlag ( RX_FUNC_ARGS, CFHeader * Header )
{
	if ( RXARG2 )
	{
		UBYTE	Flag = StrToHdrFlag (RXARG2);
		if ( Flag == -1 ) return (RXERR_INVALID_ARG);
		Header->Flags &= ~Flag;
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}

/****** rexxconfigfile.library/cf_SetWBufSize ********************************
*
*   NAME
*        cf_SetWBufSize -- Set the size of the writebuffer in the Header.
*
*   SYNOPSIS
*        cf_SetWBufSize(Header,NewSize)
*
*        cf_SetWBufSize(HEADER/N/A,NEWSIZE/A)
*
*   FUNCTION
*        This function set the size of the writebuffer in the Header.
*
*   INPUTS
*        Header - Pointer to the Header.
*        NewSize - New size of the writebuffer (2048 - X bytes).
*                  Note the size must be longword aligned.
*
*   SEE ALSO
*        cf_GetWBufSize()
*
******************************************************************************
*
*/

UWORD rxcf_SetWBufSize ( RX_FUNC_ARGS, CFHeader * Header )
{
	LONG	NewSize;

	if ( RXARG2  && (StrToLong (RXARG2, &NewSize) != -1) )
	{
		NewSize = ( NewSize == 0 ) || ( NewSize < 2048 )
						? 2048 : ( ( NewSize + 3 ) & ~3 );
		Header->WBufLength = NewSize;
		return (RC_OK);
	}

	return (RXERR_INVALID_ARG);
}
