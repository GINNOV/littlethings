/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Read.c
**		$DESCRIPTION: rxcf_Read() and rxcf_Write() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_Read ***************************************
*
*   NAME
*        cf_Read -- Read a CF file.
*
*   SYNOPSIS
*        Result = cf_Read(Header)
*
*        BOOL cf_Read(HEADER/N/A)
*
*   FUNCTION
*        This function clears all nodes and read the CF file new. The
*        HFLG_CHANGED flag in Header will be clear.
*
*   INPUTS
*        Header - The Header of the file.
*
*   RESULT
*        Result - TRUE for success or in case of FALSE return, the RC var
*                 can be read to obtain more.
*
*        RC (rexx variable) - contains an error string.
*
*                 RERR_UNKOWN       - Unkown failure.
*                 RERR_BUFFER_MEM   - No memory for buffer.
*                 RERR_READ_FILE    - Couldn't read the file.
*                 RERR_FORMAT       - File has an error in the format
*                                     structure.
*                 RERR_UNKOWN_ITYPE - An unkown item type was found.
*
*   SEE ALSO
*        cf_Open(), cf_Close(), cf_Write()
*
******************************************************************************
*
*/

UWORD rxcf_Read ( RX_FUNC_ARGS, CFHeader * Header )
{
	ULONG	Error;

	if ( cf_Read ((CFHeader *)Header, &Error) )
			*ResStr = SetRC_TRUE ();
	else	SetErrVar (RxMsg, ERRFUNC_READ, Error);

	return (RC_OK);
}

/****** rexxconfigfile.library/cf_Write **************************************
*
*   NAME
*        cf_Write -- Write a CF file new.
*
*   SYNOPSIS
*        Result = cf_Write(Header [,WriteMode])
*
*        BOOL cf_Write(HEADER/N/A,WMODE,FLAGS)
*
*   FUNCTION
*        This function writes the CF file new. Note is the HFLG_CHANGED
*        flag in Header flags not set the file will be not writes new.
*
*   INPUTS
*        Header - The Header of the file to write.
*        WMode - Write modes:
*
*                WMODE_DEFAULT -- Writes the file in default format
*                                 from Header.
*                WMODE_ASCII   -- Writes the file in ascii format.
*                WMODE_SHORT   -- Writes the file in short format.
*
*        Flags - Flags:
*
*                WFLG_WRITE_ALWAYS -- cf_Write() checks not if the
*                                     HFLG_CHANGED flag set and
*                                     writes always the file.
*
*   RESULT
*        Result - TRUE for success or in case of FALSE return, the RC var
*                 can be read to obtain more.
*
*        RC (rexx variable) - contains an error string.
*
*                 WERR_UNKOWN        - Unkown failure.
*                 WERR_ALLOC_WBUFFER - No memory for WriteBuffer.
*
*   SEE ALSO
*        cf_Open(), cf_Close(), cf_Read()
*
******************************************************************************
*
*/

UWORD rxcf_Write ( RX_FUNC_ARGS, CFHeader * Header )
{
	ULONG	Error;
	UBYTE	Mode = CF_WMODE_DEFAULT;

	if ( IsValidArg (RxMsg, 2) )
	{
		if ( !StrCmp (RXARG2, "WMODE_ASCII") )
			Mode = CF_WMODE_ASCII;
		else if ( !StrCmp (RXARG2, "WMODE_SHORT") )
			Mode = CF_WMODE_SHORT;
		else	return (RXERR_INVALID_ARG);
	}

	if ( IsValidArg (RxMsg, 3) )
	{
		if ( !StrCmp (RXARG3, "WFLG_WRITE_ALWAYS") )
			Mode |= CF_WFLG_WRITE_ALWAYS;
		else	return (RXERR_INVALID_ARG);
	}

	if ( cf_Write (Header, Mode, &Error) )
			*ResStr = SetRC_TRUE ();
	else	SetErrVar (RxMsg, ERRFUNC_WRITE, Error);

	return (RC_OK);
}
