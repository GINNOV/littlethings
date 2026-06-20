/* $Revision Header * Header built automatically - do not edit! *************
 *
 *	(C) Copyright 1990 by Holger P. Krekel & Olaf 'Olsen' Barthel
 *
 *	Name .....: LhEncode.c
 *	Created ..: Wednesday 11-Jul-90 19:40
 *	Revision .: 0
 *
 *	Date            Author          Comment
 *	=========       ========        ====================
 *	11-Jul-90       Olsen           Created this file!
 *
 * $Revision Header ********************************************************/

	/* ARP cli template and help information. */

char *CLI_Template	= "FROM,TO,N=NoQuery/S,F=Faster/S,H=Header/S";
char *CLI_Help		= "\n\33[33m\33[1mLhEncode \33[0m\33[31m© Copyright 1990 by Holger P. Krekel & Olaf Barthel,\n\
           All rights reserved.\n\n\
Usage: \33[1mLhEncode\33[0m [File or wildcard pattern] [File/directory name]\n\
                [FASTER] [HEADER] [NOQUERY]\n";

	/* Argument vector offsets. */

#define ARG_FROM	1
#define ARG_TO		2
#define ARG_NOQUERY	3
#define ARG_FASTER	4
#define ARG_HEADER	5

	/* Global and shared data. */

struct Library		*LhBase;
struct timerequest	*TimeRequest;
struct MsgPort		*TimePort;
struct Device		*TimerBase;
struct FileRequester	*FileRequester;
struct LhBuffer		*LhBuffer;
BYTE			 Faster,Header,Query = TRUE;
ULONG			 TotalSecs = 0,TotalMicros = 0;
LONG			 TotalRatio,NumEntries = 0;

	/* Linked list of file names. */

struct NameLink		 *RootLink;
char			**NameList;
LONG			  NumNames = 0;

	/* Function prototypes. */

extern int		 SubCmp();
LONG			 StrCmp(char **Str1,char **Str2);
BYTE			 BuildList(VOID);
VOID			 FreeLinks(VOID);
BYTE			 ScanDir(char *Pattern);
LONG			 GetFileSize(char *Name);
BYTE			 SetRawMode(BYTE Mode);
BYTE			 Encode(char *Src,char *Dst);
VOID			 main(int argc,char **argv);

	/* Stub routines. */

LONG Chk_Abort(VOID)	{ return(0); }
VOID _wb_parse(VOID)	{}

	/* Assembly language fragment to be used by the QSort
	 * routine.
	 */

#asm
	xdef	_SubCmp

_SubCmp:movem.l	d2-d7/a2-a6,-(sp)
	movem.l	a0/a1,-(sp)

	jsr	_geta4#
	jsr	_StrCmp

	add.w	#8,sp

	movem.l	(sp)+,d2-d7/a2-a6
	rts
#endasm

	/* StrCmp():
	 *
	 *	Compare two strings ignoring case (international).
	 */

LONG
StrCmp(char **Str1,char **Str2)
{
	char *a = *Str1,*b = *Str2;

	for( ; ToUpper(*a) == ToUpper(*b) ; a++, b++)
	{
		if(!(*a))
			return(0);
	}

	return(ToUpper(*a) - ToUpper(*b));
}

	/* BuildList():
	 *
	 *	Build an array of string pointers to be passed to the
	 *	QSort function by scanning a linked list of names.
	 */

BYTE
BuildList()
{
	struct NameLink	*TempLink;

	for(TempLink = RootLink ; TempLink ; TempLink = TempLink -> Next)
		NumNames++;

	if(NameList = (char **)ArpAlloc(NumNames * sizeof(char *)))
	{
		NumNames = 0;

		for(TempLink = RootLink ; TempLink ; TempLink = TempLink -> Next)
		{
			if(NameList[NumNames] = (char *)ArpAlloc(strlen(TempLink -> Name) + 1))
				strcpy(NameList[NumNames++],TempLink -> Name);
			else
				return(FALSE);
		}

		return(QSort(NameList,NumNames,sizeof(char *),SubCmp));
	}

	return(FALSE);
}

	/* FreeLinks():
	 *
	 *	Free the linked list of names created by the directory
	 *	scanner.
	 */

VOID
FreeLinks()
{
	struct NameLink *TempLink,*LastLink = NULL;

	for(TempLink = RootLink ; TempLink ; TempLink = LastLink)
	{
		LastLink = TempLink -> Next;

		FreeMem(TempLink,sizeof(struct NameLink));
	}
}

	/* ScanDir():
	 *
	 *	Scan a directory for a given pattern and build a linked
	 *	list of the names.
	 */

BYTE
ScanDir(char *Pattern)
{
	struct NameLink	*LastLink = NULL;
	char		*Temp;

	while(Temp = scdir(Pattern))
	{
		if(SetSignal(0,0) & SIGBREAKF_CTRL_C)
		{
			SetSignal(0,SIGBREAKF_CTRL_C);

			Puts("\n*** BREAK: LhEncode\a");

			return(FALSE);
		}

		if(SetSignal(0,0) & SIGBREAKF_CTRL_D)
		{
			SetSignal(0,SIGBREAKF_CTRL_D);
			return(TRUE);
		}

		if(RootLink)
		{
			struct NameLink *NextLink;

			if(NextLink = (struct NameLink *)AllocMem(sizeof(struct NameLink),MEMF_PUBLIC | MEMF_CLEAR))
			{
				LastLink -> Next = NextLink;

				strcpy(NextLink -> Name,Temp);

				LastLink = NextLink;
			}
			else
				return(TRUE);
		}
		else
		{
			if(RootLink = (struct NameLink *)AllocMem(sizeof(struct NameLink),MEMF_PUBLIC | MEMF_CLEAR))
			{
				strcpy(RootLink -> Name,Temp);

				LastLink = RootLink;
			}
			else
				return(TRUE);
		}
	}

	return(TRUE);
}

	/* GetFileSize():
	 *
	 *	Asks the DOS to return the length of a given file.
	 */

LONG
GetFileSize(char *Name)
{
	struct FileInfoBlock	*FileInfo;
	BPTR			 FileLock;
	LONG			 FileSize = 0;

	if(FileInfo = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock),MEMF_PUBLIC))
	{
		if(FileLock = Lock(Name,ACCESS_READ))
		{
			if(Examine(FileLock,FileInfo))
				FileSize = FileInfo -> fib_Size;

			UnLock(FileLock);
		}

		FreeMem(FileInfo,sizeof(struct FileInfoBlock));
	}

	return(FileSize);
}

	/* SetRawMode():
	 *
	 *	Toggles between raw (single character) and 'cooked'
	 *	(line input) data input from a console window.
	 */

BYTE
SetRawMode(BYTE Mode)
{
	LONG Args[7];

	if(Mode)
		Args[0] = DOSTRUE;
	else
		Args[0] = DOSFALSE;

	return(SendPacket(ACTION_SCREEN_MODE,Args,(struct MsgPort *)((struct Process *)SysBase -> ThisTask) -> pr_ConsoleTask));
}

	/* Encode():
	 *
	 *	Encode a file for later usage (by any application or
	 *	by LhDecode).
	 */

BYTE
Encode(char *Src,char *Dst)
{
	BPTR		 In,Out;
	LONG		 FromSize;
	LONG		*From,*To;

	LONG		 Secs,Micros;
	BYTE		 Ratio;

	struct timeval	 Req1,Req2;

	char		 TempName[MaxInputBuf];
	BPTR		 CheckLock;

	Printf("%-31.31s ",BaseName(Src));

		/* How long is our source file? */

	if(!(FromSize = GetFileSize(Src)))
	{
		Printf("\33[33munable to examine file (Error %ld)\33[31m\a\n",IoErr());

		return(TRUE);
	}

		/* Allocate memory for the source buffer. */

	if(!(From = AllocMem(FromSize,MEMF_PUBLIC)))
	{
		Printf("\33[33mout of memory (Error 103)\33[31m\a\n");

		return(TRUE);
	}

		/* Allocate memory for the destination buffer.
		 * Note: must be 1/8 larger than the source buffer.
		 */

	if(!(To = AllocMem(FromSize + ENCODEEXTRA(FromSize),MEMF_PUBLIC|MEMF_CLEAR)))
	{
		FreeMem(From,FromSize);

		Printf("\33[33mout of memory (Error 103)\33[31m\a\n");

		return(TRUE);
	}

		/* Open the file for reading. */

	if(!(In = Open(Src,MODE_OLDFILE)))
	{
		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		Printf("\33[33munable to open file (Error %ld)\33[31m\a\n",IoErr());

		return(TRUE);
	}

		/* Read the data to be encoded. */

	if(Read(In,From,FromSize) != FromSize)
	{
		LONG Error = IoErr();

		Close(In);

		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		Printf("\33[33munable to read file (Error %ld)\33[31m\a\n",Error);

		return(TRUE);
	}

	Close(In);

		/* Initialize the LhBuffer structure. */

	LhBuffer -> lh_Src	= From;
	LhBuffer -> lh_SrcSize	= FromSize;
	LhBuffer -> lh_Dst	= To;

	Printf("\33[33m%07ld\33[31m Encode ",FromSize);

		/* If 'faster' encoding selected, disable interrupts
		 * and system DMA.
		 */

	if(Faster)
	{
		custom . dmacon = BITCLR|DMAF_ALL;
		Disable();
		custom . color[0] = 0;
	}

		/* Remember starting time. */

	DoIO(TimeRequest);

	Req1 = TimeRequest -> tr_time;

		/* Encode the data. */

	LhEncode(LhBuffer);

		/* Remember finishing time. */

	DoIO(TimeRequest);

	Req2 = TimeRequest -> tr_time;

		/* Reenable DMA and interrupts. */

	if(Faster)
	{
		custom . dmacon = BITSET|DMAF_ALL;
		Enable();
	}

		/* Subtract both time values. */

	SubTime(&Req2,&Req1);

		/* Calculate time and compression ration. */

	Ratio	= 100 - (100 * LhBuffer -> lh_DstSize) / FromSize;

	Secs	= Req2 . tv_secs;
	Micros	= Req2 . tv_micro / 10000;

	Printf("\33[33m%02ld%%\33[31m %02ld:%02ld:%02ld ",(Ratio < 0 ? 0 : Ratio),Secs / 60,Secs % 60,Micros);

		/* File didn't gain any size -> exit. */

	if(LhBuffer -> lh_DstSize >= FromSize)
	{
		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		Printf("\33[33m-------\33[31m \33[1moverflow!\33[0m\a\n");

		return(TRUE);
	}

		/* Add them for the statistics. */

	TotalRatio	+= Ratio;

	TotalSecs	+= Secs;
	TotalMicros	+= Micros;

	NumEntries++;

		/* ^C pressed = abort. */

	if(SetSignal(0,0) & SIGBREAKF_CTRL_C)
	{
		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		SetSignal(0,SIGBREAKF_CTRL_C);
		Puts("\n*** BREAK: LhEncode\a");

		return(FALSE);
	}

		/* Check if we are about to overwrite an existing file. */

	if(Query)
	{
		if(CheckLock = Lock(Dst,ACCESS_READ))
		{
			UnLock(CheckLock);

			SetRawMode(TRUE);

			Printf("\2331A\n\23332C\233KOverwrite (\33[33mN\33[31mo/\33[33mY\33[31mes/\33[33mC\33[31mhange) ? ");

				/* Read a character. */

Ask:			if(Read(((struct Process *)SysBase -> ThisTask) -> pr_CIS,TempName,1) > 0)
			{
				if(toupper(TempName[0]) == 'Y')
				{
					Printf("\2331A\n\23332C\233K\33[33m%07ld\33[31m Encode \33[33m%02ld%%\33[31m %02ld:%02ld:%02ld ",FromSize,(Ratio < 0 ? 0 : Ratio),Secs / 60,Secs % 60,Micros);

					SetRawMode(FALSE);

					goto GoOn;
				}

				if(toupper(TempName[0]) == 'N' || !TempName[0] || TempName[0] == '\n')
					goto Nope;

				if(toupper(TempName[0]) != 'C')
					goto Ask;

					/* Ask for a new name to save the file
					 * under.
					 */

				Printf("\2331A\n\233KNew Name: %s\2331A\n\23310C",Dst);

				SetRawMode(FALSE);

				ReadLine(TempName);

				if(!TempName[0] || TempName[0] == '\n')
				{
					strcpy(TempName,Dst);
					Printf("\2331A\233K");
				}

				Dst = TempName;

				Printf("\2331A\n\233K%-31.31s \33[33m%07ld\33[31m Encode \33[33m%02ld%%\33[31m %02ld:%02ld:%02ld ",BaseName(Dst),FromSize,(Ratio < 0 ? 0 : Ratio),Secs / 60,Secs % 60,Micros);

				goto GoOn;
			}

				/* Free the buffers and return. */

Nope:			FreeMem(From,FromSize);
			FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

			Printf("\2331A\n\23332C\33[1m\233KSkipped\33[0m\n");

			SetRawMode(FALSE);

			return(TRUE);
		}
	}

		/* Open the output file. */

GoOn:	if(!(Out = Open(Dst,MODE_NEWFILE)))
	{
		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		Printf("\33[33m\nERROR:\33[31m Unable to open file (Error %ld)\a\n",IoErr());

		return(TRUE);
	}

		/* Add a size header. */

	if(Header)
	{
		ULONG TempSize = FromSize | 0xFF000000;

			/* Write header, note: size can occupy max. 24
			 * bits.
			 */

		if(Write(Out,&TempSize,sizeof(ULONG)) != sizeof(ULONG))
		{
			LONG Error = IoErr();

			Close(Out);

			FreeMem(From,FromSize);
			FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

			Printf("\33[33m\nERROR:\33[31m Unable to save file (Error %ld)\a\n",Error);

			DeleteFile(Dst);

			return(TRUE);
		}
	}

		/* Write the file to disk. */

	if(Write(Out,To,LhBuffer -> lh_DstSize) != LhBuffer -> lh_DstSize)
	{
		LONG Error = IoErr();

		Close(Out);

		FreeMem(From,FromSize);
		FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

		Printf("\33[33m\nERROR:\33[31m Unable to save file (Error %ld)\a\n",Error);

		DeleteFile(Dst);

		return(TRUE);
	}

	Close(Out);

		/* Free the buffers and return. That was pretty painless,
		 * wasn't it?
		 */

	FreeMem(From,FromSize);
	FreeMem(To,FromSize + ENCODEEXTRA(FromSize));

	Printf("\33[33m%07ld\33[31m Done.\n",LhBuffer -> lh_DstSize);

	return(TRUE);
}

VOID
main(int argc,char **argv)
{
	char Match[DSIZE],TempName[DSIZE * 5 + FCHARS],TempName2[DSIZE * 5 + FCHARS],TempName3[DSIZE * 5 + FCHARS],*ToFile;
	BYTE Success = RETURN_FAIL;

	if(!argc)
		exit(-1);

	Enable_Abort = FALSE;

		/* Faster decompression? */

	if(argv[ARG_FASTER])
		Faster = TRUE;
	else
		Faster = FALSE;

		/* Put a 8 + 24 bit size header in front of the
		 * compressed file?
		 */

	if(argv[ARG_HEADER])
		Header = TRUE;
	else
		Header = FALSE;

		/* Don't ask before overwriting a file? */

	if(argv[ARG_NOQUERY])
		Query = FALSE;

		/* If the destination argument is omitted, we'll assume
		 * that we will decompress into the current directory.
		 */

	if(argv[ARG_TO])
		ToFile = argv[ARG_TO];
	else
	{
		if(PathName(((struct Process *)SysBase -> ThisTask) -> pr_CurrentDir,TempName3,DSIZE * 5))
			ToFile = TempName3;
		else
		{
			Puts("\33[1mLhEncode:\33[0m Destination file/directory name required.\a");
			exit(RETURN_ERROR);
		}
	}

	Puts("\n\33[33m\33[1mLhEncode \33[0m\33[31m© Copyright 1990 by Holger P. Krekel & Olaf Barthel,\n           All rights reserved.\n");

		/* Open lh.library (most important call in this program). */

	if(LhBase = (struct Library *)ArpOpenLibrary(LH_NAME,LH_VERSION))
	{
			/* Create an LhBuffer for data compression. */

		if(LhBuffer = (struct LhBuffer *)CreateBuffer(FALSE))
		{
			if(FileRequester = ArpAllocFreq())
			{
				if(TimePort = CreatePort(NULL,0))
				{
					if(TimeRequest = (struct timerequest *)CreateExtIO(TimePort,sizeof(struct timerequest)))
					{
							/* Open the timer.device, we will need it for
							 * stopwatch functions.
							 */

						if(!OpenDevice(TIMERNAME,UNIT_VBLANK,TimeRequest,0))
						{
							TimerBase = TimeRequest -> tr_node . io_Device;

							TimeRequest -> tr_node . io_Command = TR_GETSYSTIME;

								/* We got a source argument, no need to call the
								 * ARP file requester.
								 */

							if(argv[ARG_FROM])
							{
								struct FileInfoBlock	*FileInfo;
								BPTR			 FileLock;
								BYTE			 IsDir = FALSE,GotIt = FALSE,IsWild;

										/* Check if destination is a file or
										 * a directory.
										 */

								if(FileInfo = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock),MEMF_PUBLIC))
								{
									if(FileLock = Lock(ToFile,ACCESS_READ))
									{
										GotIt = TRUE;

										if(Examine(FileLock,FileInfo))
											IsDir = (FileInfo -> fib_DirEntryType > 0);

										UnLock(FileLock);
									}

									FreeMem(FileInfo,sizeof(struct FileInfoBlock));
								}

										/* Check if source is a plain file name
										 * or a wildcard expression.
										 */

								IsWild = PreParse(argv[ARG_FROM],Match);

										/* Strange... */

								if(IsWild && !GotIt)
								{
									Puts("\33[1mLhEncode:\33[0m Unable to find destination directory!\a");
									goto Quit;
								}

										/* Send a bunch of files to a single file? */

								if(IsWild && !IsDir)
								{
									Puts("\33[1mLhEncode:\33[0m Destination is not a directory!\a");
									goto Quit;
								}

										/* Source is a plain file. */

								if(!IsWild)
								{
									Puts("\33[33mEncoding\33[31m - press \33[1mCTRL-C\33[0m to abort.\n");

									Puts("File Name                       Size    Mode    %  Time     Result \n------------------------------- ------- ------ --- -------- -------");

									strcpy(TempName,ToFile);

									if(IsDir)
										TackOn(TempName,BaseName(argv[ARG_FROM]));

									if(Encode(argv[ARG_FROM],TempName))
										Success = RETURN_OK;
								}
								else
								{
									LONG i;

									Success = RETURN_OK;

									Printf("\33[33mScanning\33[31m - press \33[1mCTRL-D\33[0m to stop, \33[1mCTRL-C\33[0m to abort... ");

											/* Source is a wildcard expression,
											 * start the directory scanner.
											 */

									if(!ScanDir(argv[ARG_FROM]))
										exit(RETURN_WARN);

									Printf("Sorting.\n");

											/* Convert the linked list and sort
											 * it.
											 */

									BuildList();

									Puts("\2331A\233K\33[33mEncoding\33[31m - press \33[1mCTRL-C\33[0m to abort.\n");

									Puts("File Name                       Size    Mode    %  Time     Result \n------------------------------- ------- ------ --- -------- -------");

									for(i = 0 ; i < NumNames ; i++)
									{
										strcpy(TempName,ToFile);

										if(IsDir)
											TackOn(TempName,BaseName(NameList[i]));

										if(!Encode(NameList[i],TempName))
										{
											Success = RETURN_FAIL;
											break;
										}
									}

									FreeLinks();

									if(!Success)
									{
										TotalSecs	+= TotalMicros / 100;
										TotalMicros	%= 100;

										Printf("\n\33[33mTotal Ratio\33[31m %02ld%%, \33[33mTotal Time\33[31m %02ld:%02ld:%02ld\n",TotalRatio / NumEntries,TotalSecs / 60,TotalSecs % 60,TotalMicros);
									}
								}

								Puts("");
							}
							else
							{
								Success = RETURN_OK;

								Puts("File Name                       Size    Mode    %  Time     Result \n------------------------------- ------- ------ --- -------- -------");

									/* We didn't get a source file and a destination directory,
									 * so let's bring up the ARP file requester.
									 */

								for(;;)
								{
									FileRequester -> fr_Hail = "Select file to encode";

									FileRequester -> fr_File[0] = 0;

									if(!FileRequest(FileRequester))
										break;

									strcpy(TempName,FileRequester -> fr_Dir);
									TackOn(TempName,FileRequester -> fr_File);

									strcpy(FileRequester -> fr_File,"Directories only!");

									FileRequester -> fr_Hail = "Select destination directory";

									if(!FileRequest(FileRequester))
										break;

									strcpy(TempName2,FileRequester -> fr_Dir);
									TackOn(TempName2,BaseName(TempName));

									Encode(TempName,TempName2);
								}
							}

Quit:							CloseDevice(TimeRequest);
						}
						else
							Puts("\33[1mLhEncode:\33[0m Unable to open timer.device!\a");

						DeleteExtIO(TimeRequest);
					}
					else
						Puts("\33[1mLhEncode:\33[0m Out of memory!\a");

					DeletePort(TimePort);
				}
				else
					Puts("\33[1mLhEncode:\33[0m Unable to create MsgPort!\a");
			}
			else
				Puts("\33[1mLhEncode:\33[0m Unable to allocate Arp Filerequester!\a");

			DeleteBuffer(LhBuffer);
		}
		else
			Puts("\33[1mLhEncode:\33[0m Out of memory!\a");
	}
	else
		Printf("\33[1mLhDecode:\33[0m You need \"%s\" V%ld.0 or higher!\a\n",LH_NAME,LH_VERSION);
	
	exit(Success);
}
