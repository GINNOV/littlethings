/*
 * Amiga specific support code for cxref
 *
 * Written by Olaf Barthel <olsen@sourcery.han.de>
 *     Public Domain
 *
 * :ts=4
 */

/******************************************************************************/

#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <dos/dosasl.h>

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>

extern struct Library *	SysBase;
extern struct Library *	DOSBase;

/******************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stat.h>
#include <dos.h>

/******************************************************************************/

#define MAX_FILENAME_LEN 1024

/******************************************************************************/

typedef struct NameNode
{
	struct NameNode	*	Next;
	char *				Name;
	BOOL				Wild;
} NameNode;

/******************************************************************************/

static int
compare(char **a,char **b)
{
	return(stricmp(*a,*b));
}

/******************************************************************************/

int
expand_args(int argc,char **argv,int *_argc,char ***_argv,int all,int sort)
{
	struct AnchorPath *Anchor;
	LONG Error;

	*_argc = argc;
	*_argv = argv;

	if(DOSBase->lib_Version < 37)
		return(0);

	if(Anchor = (struct AnchorPath *)AllocVec(sizeof(struct AnchorPath) + MAX_FILENAME_LEN,MEMF_ANY | MEMF_CLEAR))
	{
		NameNode *	Root;
		LONG		NamePlus;
		LONG		NameTotal;
		LONG		i;

		Root		= NULL;
		NamePlus	= 0;
		NameTotal	= 0;
		Error		= 0;

		Anchor->ap_Strlen		= MAX_FILENAME_LEN;
		Anchor->ap_BreakBits	= SIGBREAKF_CTRL_C;

		for(i = 0 ; !Error && i < argc ; i++)
		{
			if(i && ParsePatternNoCase(argv[i],Anchor->ap_Buf,MAX_FILENAME_LEN) == 1)
			{
				NameNode *	Node;
				LONG		Result;

				Result = MatchFirst(argv[i],Anchor);

				while(!Result)
				{
					if(Anchor->ap_Info.fib_DirEntryType < 0)
					{
						if(Node = (NameNode *)malloc(sizeof(NameNode) + strlen(Anchor->ap_Buf) + 1))
						{
							Node->Name = (char *)(Node + 1);
							Node->Next = Root;
							Node->Wild = TRUE;

							strcpy(Node->Name,Anchor->ap_Buf);

							Root = Node;

							NamePlus++;
							NameTotal++;
						}
						else
						{
							Result = ERROR_NO_FREE_STORE;
							break;
						}
					}

					if(all && Anchor->ap_Info.fib_DirEntryType > 0)
					{
						if(Anchor->ap_Flags & APF_DIDDIR)
							Anchor->ap_Flags &= ~APF_DIDDIR;
						else
							Anchor->ap_Flags |= APF_DODIR;
					}

					Result = MatchNext(Anchor);
				}

				if(Result != ERROR_NO_MORE_ENTRIES)
					Error = Result;
			}
			else
			{
				NameNode *Node;

				if(Node = (NameNode *)malloc(sizeof(NameNode)))
				{
					Node->Name = argv[i];
					Node->Next = Root;
					Node->Wild = FALSE;

					Root = Node;

					NameTotal++;
				}
				else
				{
					Error = ERROR_NO_FREE_STORE;
				}
			}
		}

		if(!Error && NamePlus)
		{
			char **Index;

			if(Index = (char **)malloc(sizeof(char *) * (NameTotal + 1)))
			{
				NameNode *	Node;
				char **		LastWild;

				*_argc = NameTotal;
				*_argv = Index;

				Index = &(Index[NameTotal]);

				*Index-- = NULL;

				Node		= Root;
				LastWild	= NULL;

				while(Node)
				{
					if(sort)
					{
						if(Node->Wild)
						{
							if(!LastWild)
								LastWild = Index;
						}
						else
						{
							if(LastWild)
							{
								if((ULONG)LastWild - (ULONG)Index > sizeof(char **))
									qsort(Index + 1,((ULONG)LastWild - (ULONG)Index) / sizeof(char **),sizeof(char *),compare);

								LastWild = NULL;
							}
						}
					}

					*Index-- = Node->Name;

					Node = Node->Next;
				}
			}
			else
			{
				Error = ERROR_NO_FREE_STORE;
			}
		}

		if(Error || !NamePlus)
		{
			NameNode *Node,*Next;

			Node = Root;

			while(Node)
			{
				Next = Node->Next;

				free(Node);

				Node = Next;
			}
		}

		FreeVec(Anchor);
	}
	else
	{
		Error = ERROR_NO_FREE_STORE;
	}

	if(Error)
	{
		PrintFault(Error,FilePart(argv[0]));

		return(-1);
	}
	else
	{
		return(0);
	}
}

/******************************************************************************/

FILE *
popen_execvp(char** command)
{
	char tempName[40];
	struct DateStamp stamp;
	ULONG secs;

	FILE * result = NULL;
	char *cmd;
	int len,i;

	DateStamp(&stamp);
	secs = (stamp.ds_Days * 24 * 60 + stamp.ds_Minute) * 60 + (stamp.ds_Tick / TICKS_PER_SECOND);

	sprintf(tempName,"pipe:%08lx.%08lx",FindTask(NULL),secs);

	len = 1 + strlen(" >") + strlen(tempName);
	for(i = 0 ; command[i] != NULL ; i++)
		len += strlen(command[i]) + 1;

	cmd = (char *)malloc(len);
	if(cmd != NULL)
	{
		BPTR in,out;

		for(i = 0 ; command[i] != NULL ; i++)
		{
			if(i == 0)
			{
				strcpy(cmd,command[i]);
			}
			else
			{
				strcat(cmd," ");
				strcat(cmd,command[i]);
			}
		}

		strcat(cmd," >");
		strcat(cmd,tempName);

		in = Open("NIL:",MODE_OLDFILE);
		out = Open("CONSOLE:",MODE_NEWFILE);

		if(in != NULL && out != NULL)
		{
			LONG rc;

			rc = SystemTags(cmd,
				SYS_UserShell,	TRUE,
				SYS_Input,	in,
				SYS_Output,	out,
				SYS_Asynch,	TRUE,
			TAG_DONE);

			if(rc == -1)
			{
				Close(in);
				Close(out);
			}

			in = NULL;
			out = NULL;

			if(rc != 0)
			{
				fprintf(stderr,"cxref: Can not fork for the cpp command.\n");
				exit(1);
			}

			result = fopen(tempName,"rb");
			if(result == NULL)
			{
				fprintf(stderr,"cxref: Can not pipe for the cpp command.\n");
				exit(1);
			}
		}
		else
		{
			if(in != NULL)
				Close(in);

			if(out != NULL)
				Close(out);

			fprintf(stderr,"cxref: Can not pipe for the cpp command.\n");
			exit(1);
		}

		if(in != NULL)
			Close(in);

		if(out != NULL)
			Close(out);
	}

	if(cmd != NULL)
		free(cmd);

	return(result);
}

int
pclose_execvp(FILE* f)
{
	fclose(f);
	return(0);
}

/******************************************************************************/

FILE *
amiga_fopen(char *name,const char *mode)
{
	if(!strncmp(name,"./",2) || !strncmp(name,"..",2))
		name += 2;

	return(fopen(name,mode));
}

int
amiga_stat(char *name, struct stat *statstruct)
{
	if(!strncmp(name,"./",2) || !strncmp(name,"..",2))
		name += 2;

	return(stat(name,statstruct));
}

int
amiga_mkdir(char *name)
{
	if(!strncmp(name,"./",2) || !strncmp(name,"..",2))
		name += 2;

	return(mkdir(name));
}

int
amiga_lstat(char *name, struct stat *statstruct)
{
	if(!strncmp(name,"./",2) || !strncmp(name,"..",2))
		name += 2;

	return(lstat(name,statstruct));
}

int
amiga_unlink(char *name)
{
	if(!strncmp(name,"./",2) || !strncmp(name,"..",2))
		name += 2;

	return(unlink(name));
}

int
amiga_rename(char *oldname,char *newname)
{
	if(!strncmp(oldname,"./",2) || !strncmp(oldname,"..",2))
		oldname += 2;

	if(!strncmp(newname,"./",2) || !strncmp(newname,"..",2))
		newname += 2;

	return(rename(oldname,newname));
}
