/*
**		$PROJECT: RexxConfigFile.library
**		$FILE: Open&Close.c
**		$DESCRIPTION: rxcf_Open() and rxcf_Close() functions
**
**		(C) Copyright 1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct Library *DOSBase;
IMPORT struct Library *CFBase;

/****** rexxconfigfile.library/cf_Open ***************************************
*
*   NAME
*        cf_Open -- Open a CF file.
*
*   SYNOPSIS
*        Header = cf_Open(Name [,Mode] [,Flags] [,PuddleSize])
*
*        HEADER/N cf_Open(NAME/A,OMODE,FLAGS,PUDDLESIZE)
*
*   FUNCTION
*        This function create a memory pool with a specify puddlesize or
*        default (2048 bytes), allocate pool memory for the header, open or
*        create a new CF file and check which format type has the file (ascii
*        or short format). And if the flag OFLG_READ_TOO set, the file will
*        be read too.
*
*   INPUTS
*        Name - Name and path of the CF file.
*        Mode - Openmodes:
*
*                OMODE_OLDFILE   - An existing file is opened. Did the file
*                                  not exists the function failed. (default)
*                OMODE_NEWFILE   - A new file will be create.
*                OMODE_READWRITE - Opens a file, but creates it if it didn't
*                                  exist.
*        Flags - extra flags:
*
*                OFLG_READ_TOO   - Reads the file directly after the
*                                  it is open. You didn't need use
*                                  cf_Read().
*
*        PuddleSize - Size of the puddle or NULL for default (2048 bytes).
*
*   RESULT
*        Header - a pointer to an initialized Header, or FALSE if the CF
*                 file could not be opened. In the case of a FALSE return,
*                 the RC var can be read to obtain more information on the
*                 failure.
*
*        RC (rexx variable) - contains an error string.
*
*                 OERR_UNKOWN     - Unkown failure.
*                 OERR_OPEN_FILE  - Couldn't open CF file.
*                 OERR_READ_FILE  - Couldn't read CF file.
*                 OERR_NO_FORMAT  - File isn't in CF format.
*                 OERR_NO_SIZE    - File hasn't a size.
*                 OERR_HEADER_MEM - No memory for Header.
*
*                 cf_Read() errors, only if the OFLG_READ_TOO flag set.
*
*                 RERR_FORMAT       - File has an error in the format
*                                     structure.
*                 RERR_UNKOWN_ITYPE - An unkown item type was found.
*
*   EXAMPLE
*        Header = cf_Open("SYS:test.cfg",,OFLG_READ_TOO)
*        If Header ~= '0' Then Do
*          ...
*          cf_Close(Header)
*        End
*        Else Do
*          Select
*            When RC = OERR_OPEN_FILE    Then EStr = "Couldn't open file!"
*            When RC = OERR_READ_FILE    Then EStr = "Couldn't read file!"
*            When RC = OERR_NO_FORMAT    Then EStr = "File isn't in format!"
*            When RC = OERR_NO_SIZE      Then EStr = "File hasn't a size!"
*            When RC = OERR_HEADER_MEM   Then EStr = "No memory for Header!"
*
*            When RC = RERR_FORMAT       Then EStr = "Error in the format!"
*            When RC = RERR_UNKOWN_ITYPE Then EStr = "Unkown item type!"
*            Otherwise EStr = "Unkown failure!"
*          End
*          Say "cf_Open:" EStr
*        End
*
*        ...
*        
*   SEE ALSO
*        cf_Close(), cf_Read(), cf_Write(), exec.library/CreatePool()
*
******************************************************************************
*
*/

BYTE OpenCount = 0;

UWORD rxcf_Open ( RX_FUNC_ARGS, STRPTR Name )
{
	ULONG	Error, PuddleSize;
	UBYTE	Mode	= CF_OMODE_OLDFILE;
	CFHeader	* Header;

	if ( IsValidArg (RxMsg, 2) )
	{
		Mode = StrToOMode (RXARG2);
		if ( Mode == -1 ) return (RXERR_INVALID_ARG);
	}

	if ( IsValidArg (RxMsg, 3) )
	{
		if ( !StrCmp (RXARG3, "OFLG_READ_TOO") )
			Mode |= CF_OFLG_READ_TOO;
		else	return (RXERR_INVALID_ARG);
	}

	if ( !( PuddleSize = GetLongArg(5) ) )
		PuddleSize = 0;

	if ( Header = cf_OpenPS (Name, Mode, &Error, PuddleSize) )
	{
		OpenCount ++;
		*ResStr = CreateNumArgStrP (Header);
	}
	else	SetErrVar (RxMsg, ERRFUNC_OPEN, Error);

	return (RC_OK);
}

/****** rexxconfigfile.library/cf_Close **************************************
*
*   NAME
*        cf_Close -- Close a CF file.
*
*   SYNOPSIS
*        cf_Close(Header)
*
*        cf_Close(HEADER/N/A)
*
*   FUNCTION
*        This function close the CF file, deletes the private memory pool
*        and if the HFLG_WRITE_BY_CLOSE and HFLG_CHANGED flags set, the
*        CF file will be write too.
*
*   INPUTS
*        Header - The Header of the file to close.
*
*   SEE ALSO
*        cf_Open(), cf_Read(), cf_Write()
*
******************************************************************************
*
*/

UWORD rxcf_Close ( RX_FUNC_ARGS, CFHeader * Header )
{
	OpenCount --;
	cf_Close (Header);
	return (RC_OK);
}
