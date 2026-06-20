/*
 *	File:					BuilderIO.h
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef BUILDERIO_H
#define BUILDERIO_H

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "ProjectIO.h"
#include "TASK_Code.h"
#include "TASK_About.h"
#include "Designer_AREXX.h"
#include "Asl.h"
#include "List.h"
#include <clib/iffparse_protos.h>
#include <libraries/iffparse.h>
#include "myinclude:MyIFFfunctions.h"
#include "myinclude:Exists.h"

/*** DEFINES *************************************************************************/
#define ID_MAIN	MAKE_ID('M','A','I','N')
#define ID_ARHA	MAKE_ID('A','R','H','A')
#define ID_TEMP	MAKE_ID('T','E','M','P')
#define ID_TYPE	MAKE_ID('T','Y','P','E')
#define ID_AUTH	MAKE_ID('A','U','T','H')
#define ID_COPY	MAKE_ID('C','O','P','Y')
#define ID_VERS	MAKE_ID('V','E','R','S')
#define ID_PNAM	MAKE_ID('P','N','A','M')

#define ID_COMM	MAKE_ID('C','O','M','M')
#define ID_ARGU	MAKE_ID('A','R','G','U')

#define ID_ARGA	MAKE_ID('A','R','G','A')
#define ID_ARGK	MAKE_ID('A','R','G','K')
#define ID_ARGN	MAKE_ID('A','R','G','N')
#define ID_ARGS	MAKE_ID('A','R','G','S')
#define ID_ARGT	MAKE_ID('A','R','G','T')
#define ID_ARGM	MAKE_ID('A','R','G','M')
#define ID_ARGF	MAKE_ID('A','R','G','F')

/*** GLOBALS *************************************************************************/
struct PrefHeader PrefHdrChunk={VERSION,0,0};

/*** FUNCTIONS ***********************************************************************/
ULONG GetFlags(UBYTE *argument)
{
	ULONG flags=0L;
	register UBYTE *a=argument;

	while(*a!='\0')
	{
		if(*a=='/')
		{
			register UBYTE *c=a+1;

			switch(*c)
			{
				case 'A':
					SETBIT(flags, ALWAYS);
					break;
				case 'K':
					SETBIT(flags, KEYWORD);
					break;
				case 'N':
					SETBIT(flags, NUMBER);
					break;
				case 'S':
					SETBIT(flags, SWITCH);
					break;
				case 'T':
					SETBIT(flags, TOGGLE);
					break;
				case 'M':
					SETBIT(flags, MULTIPLE);
					break;
				case 'F':
					SETBIT(flags, FINAL);
					break;
			}
		}
		++a;
	}
	return flags;
}

void writeArguments(struct IFFHandle *iff, struct List *list)
{
	register struct Node *node;

	for(every_node)
		myWriteChunkText(iff, ID_ARGU, node->ln_Name);
}

LONG WriteIFF(struct List *list, UBYTE *file)
{
	register struct Node *node;
	struct IFFHandle *iff;
	LONG error;

#ifdef MYDEBUG_H
	DebugOut("WriteIFF");
#endif

	if(iff=AllocIFF())
	{
		if(iff->iff_Stream=Open(file, MODE_NEWFILE))
		{
			InitIFFasDOS(iff);
			if(!(error=OpenIFF(iff, IFFF_WRITE)))
			{
				PushChunk(iff, ID_PREF, ID_FORM, IFFSIZE_UNKNOWN);

				myWriteChunkStruct(iff, ID_PRHD, (APTR)&PrefHdrChunk, sizeof(struct PrefHeader));

				myWriteChunkData(iff, ID_ARHA, (APTR)&code.arexxhandler);
				myWriteChunkData(iff, ID_MAIN, (APTR)&code.main);
				myWriteChunkData(iff, ID_TEMP, (APTR)&code.templates);
				myWriteChunkData(iff, ID_TYPE, (APTR)&code.handle);
				myWriteChunkText(iff, ID_AUTH, code.author);
				myWriteChunkText(iff, ID_COPY, code.copyright);
				myWriteChunkText(iff, ID_VERS, code.version);
				myWriteChunkText(iff, ID_PNAM, code.portname);

				for(every_node)
				{
					myWriteChunkText(iff, ID_COMM, node->ln_Name);
					writeArguments(iff, ((struct CommandNode *)node)->argumentlist);
				}
				PopChunk(iff);

				CloseIFF(iff);
			}
			Close(iff->iff_Stream);
		}
		FreeIFF(iff);
	}
	return error;
}

__stackext LONG readData(struct IFFHandle *iff, struct List *list, BYTE append)
{
	struct ContextNode	*cn;
	struct CommandNode	*command=NULL;
	struct Node					*argument;
	UBYTE								name[MAXCHARS];
	LONG								error;
	register BYTE				success=TRUE,
											read=(append==FALSE);

#ifdef MYDEBUG_H
	DebugOut("ReadIFF");
#endif

	while(success)
	{
		error=ParseIFF(iff, IFFPARSE_RAWSTEP);
		if(error==IFFERR_EOC)
			continue;
		else if(error)
			break;

		if(cn=CurrentChunk(iff))
		{
			switch(cn->cn_ID)
			{
				case ID_MAIN:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.main, cn->cn_Size);
					break;
				case ID_ARHA:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.arexxhandler, cn->cn_Size);
					break;
				case ID_TEMP:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.templates, cn->cn_Size);
					break;
				case ID_TYPE:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.handle, cn->cn_Size);
					break;
				case ID_AUTH:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.author, cn->cn_Size);
					break;
				case ID_COPY:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.copyright, cn->cn_Size);
					break;
				case ID_VERS:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.version, cn->cn_Size);
					break;
				case ID_PNAM:
					if(read)
						ReadChunkBytes(iff, (APTR)&code.portname, cn->cn_Size);
					break;
				case ID_COMM:
					ReadChunkBytes(iff, (APTR)&name, cn->cn_Size);
					success=(BYTE)(command=AddCommandNode(list, NULL, name));
					break;
				case ID_ARGU:
					if(command)
					{
						ReadChunkBytes(iff, (APTR)&name, cn->cn_Size);
						if(success=(BYTE)(argument=AddNode(command->argumentlist, NULL, name)))
							argument->ln_Pri=GetFlags(argument->ln_Name);
					}
					break;
				default:
					error=IFFERR_NOTIFF;
					success=FALSE;
					break;
			}
		}
	}
	return error;
}

LONG ReadIFF(struct List *list, UBYTE *file, BYTE append)
{
	struct IFFHandle		*iff;
	struct ContextNode	*cn;
	struct PrefHeader		header;
	LONG								error=0;

#ifdef MYDEBUG_H
	DebugOut("ReadIFF");
#endif
	if(iff=AllocIFF())
	{
		if(iff->iff_Stream=Open(file, MODE_OLDFILE))
		{
			InitIFFasDOS (iff);
			if(!(error=OpenIFF(iff, IFFF_READ)))
			{
				ParseIFF(iff, IFFPARSE_RAWSTEP);
				if(cn=CurrentChunk(iff))
				{
					if(cn->cn_ID!=ID_FORM & cn->cn_Type!=ID_PREF)
						error=IFFERR_NOTIFF;
					else
					{
						ParseIFF(iff, IFFPARSE_RAWSTEP);
						cn=CurrentChunk(iff);
						if(cn->cn_ID!=ID_PRHD)
							error=IFFERR_NOTIFF;
						else
						{
							ReadChunkBytes(iff, (APTR)&header, cn->cn_Size);
							error=readData(iff, list, append);
						}
					}
				}
				else
					error=IFFERR_NOTIFF;
				CloseIFF(iff);
			}
			Close(iff->iff_Stream);
		}
		else
			FailRequest(mainTask.window, MSG_NOTFOUND, (APTR)file, NULL);
		FreeIFF(iff);
	}
	if(error==IFFERR_NOTIFF)
		FailRequest(mainTask.window, MSG_IFFERROR2, NULL);
	else if(error<IFFERR_NOMEM)
		FailRequest(mainTask.window, MSG_IFFERROR1, NULL);
	return error;
}

LONG ReadProject(struct List *list, UBYTE *file, BYTE force)
{
	LONG	error=IFFERR_EOF;
#ifdef MYDEBUG_H
	DebugOut("ReadProject");
#endif

	egLockAllTasks(eg);
	if(ConfirmActions(MSG_OPEN, force))
	{
		DetachList(commands, mainTask.window);
		DetachList(arguments, mainTask.window);
		ClearList(list);
		error=ReadIFF(list, file, FALSE);
		GetFirstCommand();
		GetFirstArgument();
		UpdateMainTask(FALSE);
		UpdateAboutTask();
		env.changes=0;
	}
	egUnlockAllTasks(eg);
	SetAllPointers();
	return error;
}

LONG OpenProject(struct List *list, UBYTE *file, BYTE force)
{
	LONG	error=IFFERR_EOF;

#ifdef MYDEBUG_H
	DebugOut("OpenProject");
#endif

	egLockAllTasks(eg);
	if(ConfirmActions(MSG_OPEN, force))
		if(FileRequest(	mainTask.window,
										MSG_OPENPROJECT,
										file,
										NULL,
										NULL,
										MSG_OPEN))
		{
			if(record)
				AddARexxMacroCommand(	macro,
															ER_Command,	"OPEN",
															ER_Argument, (KeepContents() ? file:NULL),
															TAG_DONE);
			env.changes=0;
			ReadProject(list, file, FALSE);
			UpdateMainTask(FALSE);
			UpdateCodeTask();
			UpdateAboutTask();
			MakeMainTitle();
		}
	egUnlockAllTasks(eg);
	SetAllPointers();
	return error;
}

LONG AppendProject(struct List *list, UBYTE *file)
{
	LONG	error=IFFERR_EOF;

#ifdef MYDEBUG_H
	DebugOut("AppendProject");
#endif

	egLockAllTasks(eg);
	if(FileRequest(mainTask.window,
									MSG_APPENDPROJECT,
									file,
									NULL,
									NULL,
									MSG_APPEND))
	{
		DetachList(commands, mainTask.window);
		DetachList(arguments, mainTask.window);
		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,	"APPEND '%s'",
														ER_Argument, (KeepContents() ? file:NULL),
														TAG_DONE);
		error=ReadIFF(list, file, FALSE);
		UpdateMainTask(FALSE);
		UpdateAboutTask();
		++env.changes;
	}
	egUnlockAllTasks(eg);
	SetAllPointers();
	return error;
}

LONG SaveProject(struct List *list, UBYTE *file)
{
	LONG error;

#ifdef MYDEBUG_H
	DebugOut("SaveProject");
#endif

	egLockAllTasks(eg);
	error=WriteIFF(list, file);
	if(record)
		AddARexxMacroCommand(	macro,
													ER_Command,	"SAVE",
													TAG_DONE);
	MakeMainTitle();
	egUnlockAllTasks(eg);
	SetAllPointers();
	env.changes=0;

	return error;
}

LONG SaveProjectAs(struct List *list, UBYTE *file)
{
	LONG error;

#ifdef MYDEBUG_H
	DebugOut("SaveProjectAs");
#endif

	egLockAllTasks(eg);
	if(FileRequest(	mainTask.window,
									MSG_SAVEPROJECT,
									file,
									FRF_DOSAVEMODE,
									NULL,
									MSG_SAVE))
		if(OverwriteFile(file))
		{
			if(record)
				AddARexxMacroCommand(	macro,
															ER_Command,	"SAVE AS '%s'",
															ER_Argument, (KeepContents() ? file:NULL),
															TAG_DONE);
			error=WriteIFF(list, file);
		}
	MakeMainTitle();
	egUnlockAllTasks(eg);
	SetAllPointers();
	return error;
}

LONG LastSaved(struct List *list, UBYTE *file, BYTE force)
{
	LONG error;

#ifdef MYDEBUG_H
	DebugOut("LastSaved");
#endif

	egLockAllTasks(eg);
	if(ConfirmActions(MSG_RESTORE, force))
	{
		DetachList(commands, mainTask.window);
		DetachList(arguments, mainTask.window);
		ClearList(commandlist);
		error=ReadIFF(list, file, FALSE);
		GetFirstCommand();
		GetFirstArgument();
		UpdateMainTask(FALSE);
		UpdateCodeTask();
		UpdateAboutTask();
		env.changes=0;

		if(record)
			AddARexxMacroCommand(	macro,
														ER_Command,		"OPEN '%s'",
														ER_Argument,	file,
														TAG_DONE);
	}
	egUnlockAllTasks(eg);
	SetAllPointers();
	return error;
}

BYTE OverwriteFile(UBYTE *file)
{
	register BYTE overwrite=TRUE;

	if(env.acknowledge && Exists(file))
		overwrite=egRequest(mainTask.window,
												NAME,
												egGetString(MSG_OVERWRITE),
												egGetString(MSG_OKCANCEL),
												(APTR)file,
												NULL);
	return overwrite;
}
#endif
