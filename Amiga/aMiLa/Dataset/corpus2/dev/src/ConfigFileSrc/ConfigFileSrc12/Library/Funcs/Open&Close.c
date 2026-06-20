/*
**		$PROJECT: ConfigFile.library
**		$FILE: Open&Close.c
**		$DESCRIPTION: cf_Open() and cf_Close() functions
**
**		(C) Copyright 1996-1997 Marcel Karas
**			 All Rights Reserved.
*/

IMPORT struct ExecBase		* SysBase;
IMPORT struct DosLibrary	* DOSBase;

/****** configfile.library/cf_Open *******************************************
*
*   NAME
*        cf_Open -- Open a CF file.
*
*   SYNOPSIS
*        Header = cf_Open(Name,Mode,ErrorCode);
*        D0               A0   D0   A1
*
*        CFHeader * cf_Open(STRPTR,ULONG,ULONG *);
*
*   FUNCTION
*        This function create a memory pool with the default size of 2048
*        bytes, allocate pool memory for the header, open or create a new
*        CF file and check which format type has the file (ascii or short
*        format). And if the flag CF_OFLG_READ_TOO set, the file will be
*        read too.
*
*   INPUTS
*        Name - Name and path of the CF file.
*        Mode - Open modes for the file:
*	
*                CF_OMODE_OLDFILE   - An existing file is opened. Did the
*                                     file not exists the function failed. 
*                CF_OMODE_NEWFILE   - A new file will be create.
*                CF_OMODE_READWRITE - Opens a file, but creates it if it
*                                     didn't exist.
*
*                Extra open flags: (V2)
*
*                CF_OFLG_READ_TOO   - Reads the file directly after the
*                                     it is open. You didn't need use
*                                     cf_Read().
*
*        ErrorCode - Contains an errorcode if the function return FALSE 
*                    or NULL.
*
*                CF_OERR_UNKOWN     - Unkown failure.
*                CF_OERR_OPEN_FILE  - Couldn't open CF file.
*                CF_OERR_READ_FILE  - Couldn't read CF file.
*                CF_OERR_NO_FORMAT  - File is no in CF format.
*                CF_OERR_NO_SIZE    - File has no size.
*                CF_OERR_HEADER_MEM - No memory for Header.
*
*                If the CF_OFLG_READ_TOO flag set:
*
*                CF_RERR_FORMAT       - File has an error in the format
*                                       structure. (V2)
*                CF_RERR_UNKOWN_ITYPE - An unkown item type was found. (V2)
*
*   RESULT
*        Header - a pointer to an initialized CFHeader structure, or NULL if
*                 the CF file could not be opened. In the case of a NULL
*                 return, the ErrorCode var can be read to obtain more
*                 information on the failure.
*
*   EXAMPLE
*        ULONG Error;
*        CFHeader *myHeader;
*
*        if(myHeader = cf_Open("DH0:misc/text1.cfg",CF_OMODE_NEWFILE,&Error))
*        {
*           ...
*           cf_Close(Header);
*        }
*        else
*        {
*           switch(Error)
*           {
*              case CF_OERR_OPEN_FILE:  CleanUp ("Couldn't open CF file.");
*              case CF_OERR_READ_FILE:  CleanUp ("Couldn't read CF file.");
*              case CF_OERR_NO_FORMAT:  CleanUp ("File is no in CF format.");
*              case CF_OERR_NO_SIZE:    CleanUp ("File has no size.");
*              case CF_OERR_HEADER_MEM: CleanUp ("No memory for Header.");
*              default:                 CleanUp ("Unkown failure.");
*           }
*        }
*        
*        ...
*        
*   NOTES
*        If you want to open a CF file with a specify puddlesize, use the
*        cf_OpenPS() function.
*
*   SEE ALSO
*        cf_Close(), cf_Read(), cf_Write(), <libraries/configfile.h>,
*        cf_OpenPS(), exec.library/CreatePool()
*
******************************************************************************
*
*/

SLibCall iCFHeader * cf_Open ( REGA0 STRPTR Name , REGD0 ULONG Mode ,
	REGA1 ULONG *ErrorCode )
{ return (cf_OpenPS (Name, Mode, ErrorCode, 0)); }

/****** configfile.library/cf_OpenPS *****************************************
*
*   NAME
*        cf_OpenPS -- Open a CF file with the specified puddlesize. (V2)
*
*   SYNOPSIS
*        Header = cf_OpenPS(Name,Mode,ErrorCode,PuddleSize);
*        D0                 A0   D0   A1        D1
*
*        CFHeader * cf_Open(STRPTR,ULONG,ULONG *,ULONG);
*
*   FUNCTION
*        This function create a memory pool with a specify puddlesize,
*        allocate pool memory for the header, open or create a new CF file
*        and check which format type has the file (ascii or short format).
*        And if the flag CF_OFLG_READ_TOO set, the file will be read too.
*
*   INPUTS
*        Name - Name and path of the CF file.
*        Mode - Openmode for the file.
*        ErrorCode - Contains an errorcode if the function return FALSE
*                    or NULL.
*        PuddleSize - Size of the puddle or NULL for default (2048 bytes).
*
*   RESULT
*        Header - a pointer to an initialized CFHeader, or NULL if the CF
*                 file could not be opened. In the case of a NULL return,
*                 the ErrorCode var can be read to obtain more information 
*                 on the failure.
*
*   EXAMPLE
*        CFHeader *myHeader;
*
*        if(myHeader = cf_OpenPS("HD3:sys.cfg",CF_OMODE_NEWFILE,0,4096))
*        {
*           ...
*           cf_Close(Header);
*        }
*        
*        ...
*        
*   SEE ALSO
*        cf_Close(), cf_Read(), cf_Write(), <libraries/configfile.h>,
*        cf_Open(), exec.library/CreatePool()
*
******************************************************************************
*
*/

LibCall iCFHeader * cf_OpenPS ( REGA0 STRPTR Name , REGD0 ULONG Mode ,
	REGA1 ULONG * ErrorCode , REGD1 ULONG PuddleSize )
{
	APTR	MemPool;
	ULONG	Error, MemSize = AvailMem (MEMF_LARGEST);

	FuncDe(bug("cf_Open(\"%ls\",%ld,$%08lx,%ld)\n{\n", Name, Mode, ErrorCode, PuddleSize));

	PuddleSize = !PuddleSize || ( PuddleSize < 256 ) ? MemSize / 100 : PuddleSize;

	if ( MemPool = MyCreatePool (MEMF_ANY, PuddleSize, PuddleSize) )
	{
		iCFHeader * Header;
		BPTR	FH;
		UBYTE	Cnt, ReadToo = FALSE;

		Header = MyAllocPooled (MemPool, sizeof (struct iCFHeader));

		if ( Mode & CF_OFLG_READ_TOO )
			ReadToo = TRUE;

		Mode &= ~0xFFFFFFFCL;

		if ( FH = Open (Name, OModes[Mode]) )
		{
			NewList ((struct List *) &Header->GroupList);

			Header->OpenMode		= Mode;
			Header->WBufLength	= MemSize / 10;
			Header->Flags			= 0;
			Header->FileHandle	= FH;
			Header->PuddleSize	= PuddleSize;
			Header->MemPool		= MemPool;
			Header->ArryNum		= 0;
			Header->ExtFlags		= 0;

			if ( Mode == CF_OMODE_NEWFILE )
			{
				Header->Length = 0;
				Header->Flags |= CF_HFLG_ASCII_FILE;

				goto OnReturn;
			}
			else
			{
				if ( ( Header->Length = GetFileSize (FH) ) || ( Mode == CF_OMODE_READWRITE ) )
				{
					if ( ( Header->Length < 4 ) && ( Mode == CF_OMODE_READWRITE ) )
					{
						Header->Flags |= CF_HFLG_ASCII_FILE;

						goto OnReturn;
					}
					else
					{
						__aligned UBYTE Array[CF_IDENT_EXTLEN];
						UBYTE		Format;
						ULONG	*	ID;

						if ( !( Read (FH, Array, ( sizeof(ULONG) + sizeof(UBYTE) )) == -1 ) )
						{
							ID = (ULONG *) Array;

							if ( *ID == CF_IDENT ) // 'CFFT' -> ConfigFileFormaT
							{
								Format = Array[4];

								if ( Format == 0x0A )
									Header->Flags |= CF_HFLG_ASCII_FILE;
								else if ( Format == 0x00 )
									Header->Flags |= CF_HFLG_SHORT_FILE;
								else
								{
									Error = CF_OERR_UNKOWN;
									goto OnError;
								}

								if ( ReadToo && !cf_Read (Header, &Error) )
								{
									if ( ( Error != CF_RERR_FORMAT ) && 
											( Error != CF_RERR_UNKOWN_ITYPE ) )
										Error = CF_OERR_READ_FILE;

									goto OnError;
								}
OnReturn:
								FuncDe(bug("   return($%08lx)\n}\n", Header));
								return (Header);
							}
							else	Error = CF_OERR_NO_FORMAT;
						}
						else	Error = CF_OERR_READ_FILE;
					}
				}
				else	Error = CF_OERR_NO_SIZE;
			}
OnError:			
			Close (FH);
		}
		else	Error = CF_OERR_OPEN_FILE;

		MyDeletePool (MemPool);
	}
	else	Error = CF_OERR_HEADER_MEM;

	if ( ErrorCode ) *ErrorCode = Error;
	FuncDe(bug("   return(%ld)\n}\n", Error));
	return (NULL);
}

/****** configfile.library/cf_Close ******************************************
*
*   NAME
*        cf_Close -- Close a CF file.
*
*   SYNOPSIS
*        cf_Close(Header);
*                 A0
*
*        VOID cf_Close(CFHeader *);
*
*   FUNCTION
*        This function close the CF file, deletes the private memory pool
*        and if the CF_HFLG_WRITE_BY_CLOSE and CF_HFLG_CHANGED flags set,
*        the CF file will be write too.
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

LibCall VOID cf_Close( REGA0 iCFHeader * Header )
{
	FuncDe(bug("cf_Close($%08lx)\n{\n", Header));

	if ( Header->Flags & CF_HFLG_WRITE_BY_CLOSE )
		cf_Write(Header,CF_WMODE_DEFAULT,0);

	Close (Header->FileHandle);
	MyDeletePool (Header->MemPool);

	FuncDe(bug("}\n"));
}
