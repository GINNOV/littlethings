/*
**	Expands wild card arguments found in the command line.
**	Written by Olaf Barthel <olsen@sourcery.han.de>
**		Public Domain
**
**	:ts=4
*/

#include <dos/dosextens.h>
#include <dos/dosasl.h>

#include <exec/memory.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/dos_pragmas.h>

#include <stdlib.h>
#include <string.h>

#define MAX_FILENAME_LEN 512

typedef struct NameNode
{
	struct NameNode	*Next;
	char			*Name;
	BOOL			 Wild;
} NameNode;

extern struct ExecBase		*SysBase;
extern struct DosLibrary	*DOSBase;

static int
compare(char **a,char **b)
{
	return(strcmp(*a,*b));
}

int
expand_args(int argc,char **argv,int *_argc,char ***_argv,int all,int sort)
{
	struct AnchorPath *Anchor;
	LONG Error;

	*_argc = argc;
	*_argv = argv;

	if(DOSBase->dl_lib.lib_Version < 37)
		return(0);

	if(Anchor = (struct AnchorPath *)AllocVec(sizeof(struct AnchorPath) + MAX_FILENAME_LEN,MEMF_ANY | MEMF_CLEAR))
	{
		NameNode *Root;
		LONG NamePlus;
		LONG NameTotal;
		LONG i;

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
				NameNode	*Node;
				LONG		 Result;

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
					Error = ERROR_NO_FREE_STORE;
			}
		}

		if(!Error && NamePlus)
		{
			char **Index;

			if(Index = (char **)malloc(sizeof(char *) * (NameTotal + 1)))
			{
				NameNode *Node;
				char **LastWild;

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
				Error = ERROR_NO_FREE_STORE;
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
		Error = ERROR_NO_FREE_STORE;

	if(Error)
	{
		PrintFault(Error,FilePart(argv[0]));

		return(-1);
	}
	else
		return(0);
}
