/** DoRev Header ** Do not edit! **
*
* Name             :  fileio.c
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  12-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 01-Jul-93    4  Steve Anichini       Support for v1 pref file works now. Ugly
* 26-Jun-93    3  Steve Anichini       Added Support for Version 1 of DropBox p
* 26-Jun-93    2  Steve Anichini       Fixed Illegal Address problem in LoadPre
* 21-Jun-93    1  Steve Anichini       First Release.
* 12-Jun-93    0  Steve Anichini       Beta Release 1.0
*
*** DoRev End **/

#include "DropBox.h"
#include "window.h"
#include "fileio.h"

extern BOOL FirstSave, modified;
extern LONG IconX, IconY;

struct Library *AslBase = NULL;
char preffile[DEFLEN]; 
char prefdir[DEFLEN];
char prefpat[DEFLEN];

ULONG LoadPrefs(char *pfile)
{
	struct IFFHandle *iff = NULL;
	struct DBNode *nd = NULL;
	struct PatNode *pnd = NULL;
	BPTR goofy;
	struct GenPref gprf;
	register int i;
	UBYTE *buf = NULL, *bob = NULL;
	struct ContextNode *cn = NULL;
	ULONG size = MAX_DENT, patnodes = 0;
	LONG list[] = {ID_DROP,ID_GPRF,ID_DROP,ID_DBSE, ID_DROP, ID_DENT};
	LONG ifer = 0;
		
	if(!(IFFParseBase = OpenLibrary("iffparse.library", DEF_LOWEST_REV)))
		return NO_IFFLIB;
		
	if(!(iff = AllocIFF()))
		return NO_FILE;
		
	if(!(goofy = Open(pfile, MODE_OLDFILE)))
	{
		FreeIFF(iff);
		return NO_FILE;
	}
	
	iff->iff_Stream = goofy;
	InitIFFasDOS(iff);
	if(OpenIFF(iff, IFFF_READ))
	{
		Close(goofy);
		FreeIFF(iff);
		return NO_FILE;
	}
	
	StopChunks(iff, list,3);
	
	ifer = ParseIFF(iff, IFFPARSE_SCAN);
	
	if(ifer)
	{
		CloseIFF(iff);
		Close(goofy);
		FreeIFF(iff);
		return NO_FILE;
	}
	
	if(!(cn = CurrentChunk(iff)))
	{
		CloseIFF(iff);
		Close(goofy);
		FreeIFF(iff);
		return NO_FILE;
	}

	ReadChunkBytes(iff, (UBYTE *)&gprf, cn->cn_Size);
			
	CleanDB();
	InitDB();
	
	switch(gprf.gp_Version)
	{
		
		case 0:
			
			MainPrefs = gprf; /* copy general preferences */
			/* Fix up window size */
			MainPrefs.gp_IOLeft = 0;
			MainPrefs.gp_IOTop  = 50;
			MainPrefs.gp_IOWidth = 640;
			MainPrefs.gp_IOHeight = 100;

			if(ParseIFF(iff, IFFPARSE_SCAN))
			{
				CloseIFF(iff);
				Close(goofy);
				FreeIFF(iff);
				return NO_FILE;
			}

			if(!(cn = CurrentChunk(iff)))
			{
				CloseIFF(iff);
				Close(goofy);
				FreeIFF(iff);
				return NO_FILE;
			}

			if(!(buf = AllocVec(cn->cn_Size, MEMF_PUBLIC)))
			{
				CloseIFF(iff);
				Close(goofy);
				FreeIFF(iff);
				return NO_MEMFILE;
			}

			bob = buf;

			ReadChunkBytes(iff,	buf, cn->cn_Size);

			for(i = 0; i < gprf.gp_Nodes ; i++)
			{
				if(nd = (struct DBNode *) NewNode(NT_DBNODE))
				{
					strcpy(nd->db_Name, buf);
					buf += strlen(nd->db_Name)+1;
					if((strlen(nd->db_Name)+1)%2)
						buf++;

					if(!(pnd = (struct PatNode *) NewNode(NT_PATNODE)))
						return NO_MEMFILE;
					strcpy(pnd->pat_Str, buf);
					buf += strlen(pnd->pat_Str)+1;
					if((strlen(pnd->pat_Str)+1)%2)
						buf++;
					pnd->pat_Flags = PFLG_NOFLAG;
					pnd->pat_Reserved = 0;
					AddNode((struct Node *)pnd,nd->db_Pats);

					strcpy(nd->db_Dest, buf);
					buf += strlen(nd->db_Dest)+1;
					if((strlen(nd->db_Dest)+1)%2)
						buf++;
					strcpy(nd->db_Com, buf);
					buf += strlen(nd->db_Com)+1;
					if((strlen(nd->db_Com)+1)%2)
						buf++;
					strcpy(nd->db_Template, buf);
					buf += strlen(nd->db_Template)+1;
					if((strlen(nd->db_Template)+1)%2)
						buf++;
					nd->db_Flags = *((ULONG *) buf);
					buf += sizeof(ULONG);
					if(nd->db_Flags & DFLG_SUPINPUT)
						nd->db_Flags |= DFLG_SUPOUTPUT;
				}
				else
					return NO_MEMFILE;

				AddNode((struct Node *)nd, DataBase);
			}

			FreeVec(bob);
			break;

		case 1:
			MainPrefs = gprf;

			ParseIFF(iff, IFFPARSE_SCAN);

			cn = CurrentChunk(iff);

			if(cn)
			{
				size = max(cn->cn_Size,MAX_DENT);

				if(!(buf = AllocVec(size, MEMF_PUBLIC)))
				{
					CloseIFF(iff);
					Close(goofy);
					FreeIFF(iff);
					return NO_MEMFILE;
				}
			}

			bob = buf;

			while(cn)
			{
				if(cn->cn_Size != ReadChunkBytes(iff, buf, cn->cn_Size))
				{
					FreeVec(bob);
					CloseIFF(iff);
					Close(goofy);
					FreeIFF(iff);
					return NO_FILE;
				}

				if(nd = (struct DBNode *) NewNode(NT_DBNODE))
				{
					strcpy(nd->db_Name, buf);
					buf += strlen(nd->db_Name)+1;
					if((strlen(nd->db_Name)+1)%2)
						buf++;
					strcpy(nd->db_Dest, buf);
					buf += strlen(nd->db_Dest)+1;
					if((strlen(nd->db_Dest)+1)%2)
						buf++;
					strcpy(nd->db_Com, buf);
					buf += strlen(nd->db_Com)+1;
					if((strlen(nd->db_Com)+1)%2)
						buf++;
					strcpy(nd->db_Template, buf);
					buf += strlen(nd->db_Template)+1;
					if((strlen(nd->db_Template)+1)%2)
						buf++;
					nd->db_Flags = *((ULONG *) buf);
					buf += sizeof(ULONG);
					if(nd->db_Flags & DFLG_SUPINPUT)
						nd->db_Flags |= DFLG_SUPOUTPUT;

					patnodes = *((ULONG *) buf);
					buf += sizeof(ULONG);
					for(i = 0; i < patnodes; i++)
					{
						if(!(pnd = (struct PatNode *) NewNode(NT_PATNODE)))
							return NO_MEMFILE;
						strncpy(pnd->pat_Str, buf,PATLEN);
						buf += PATLEN;
						pnd->pat_Flags = *((ULONG *)buf);
						buf += sizeof(ULONG);
						pnd->pat_Reserved = *((ULONG *)buf);
						buf += sizeof(ULONG);
						AddNode((struct Node *)pnd, nd->db_Pats);
					}
				}
				else
					return NO_MEMFILE;

				AddNode((struct Node *)nd,DataBase);

				if(ifer = ParseIFF(iff, IFFPARSE_SCAN))
				{
					FreeVec(bob);
					cn = NULL;
				}
				else
				{
					cn = CurrentChunk(iff);
					if(cn)
					{
						if (cn->cn_Size > size)
						{
							FreeVec(bob);
							size = cn->cn_Size;
							if(!(buf = AllocVec(size, MEMF_PUBLIC)))
							{
								CloseIFF(iff);
								Close(goofy);
								FreeIFF(iff);
								return NO_MEMFILE;
							}
							bob = buf;
						}
						else
							buf = bob;
					}
					else
						FreeVec(bob);
				}
			}
			break;
	} /* Switch */

	CloseIFF(iff);

	if(goofy)
		Close(goofy);

	FreeIFF(iff);

	if(IFFParseBase)
		CloseLibrary(IFFParseBase);

	return NO_ERROR;
}

ULONG SavePrefs(char *pfile)
{
	struct IFFHandle *iff = NULL;
	struct GenPref gprf;
	struct DBNode *nd = NULL;
	struct PatNode *pnd = NULL;
	BPTR goofy;
	ULONG len, temp;

	if(!(IFFParseBase = OpenLibrary("iffparse.library", DEF_LOWEST_REV)))
		return NO_IFFLIB;
	else
	{

		iff = AllocIFF();

		if(!(goofy = Open(pfile, MODE_NEWFILE)))
		{
			FreeIFF(iff);
			return NO_DIR;
		}

		iff->iff_Stream = goofy;

		InitIFFasDOS(iff);
		if(OpenIFF(iff, IFFF_WRITE))
		{
			Close(goofy);
			FreeIFF(iff);
			return NO_DIR;
		}

		PushChunk(iff, ID_DROP, ID_FORM, IFFSIZE_UNKNOWN);

		/* General Prefrences Chunk */
		PushChunk(iff, ID_DROP, ID_GPRF, sizeof(struct GenPref));

		gprf = MainPrefs;
		gprf.gp_Nodes = CountNodes(DataBase);
		gprf.gp_Version = GPRF_VERSION;
		gprf.reserved[0] = 0;
		gprf.reserved[1] = 0;
		gprf.reserved[2] = 0;

		WriteChunkBytes(iff, (UBYTE *)&gprf, sizeof(struct GenPref));

		PopChunk(iff);

		/* Database Chunk */

		nd = (struct DBNode *) DataBase->lh_Head;

		while(nd->db_Nd.ln_Succ)
		{
			PushChunk(iff, ID_DROP, ID_DENT, IFFSIZE_UNKNOWN);

			len = strlen(nd->db_Name)+1;
			len += len%2;
			WriteChunkBytes(iff, (UBYTE *) nd->db_Name, len*sizeof(char));
			len = strlen(nd->db_Dest)+1;
			len += len%2;
			WriteChunkBytes(iff, (UBYTE *) nd->db_Dest, len*sizeof(char));
			len = strlen(nd->db_Com)+1;
			len+= len%2;
			WriteChunkBytes(iff, (UBYTE *) nd->db_Com, len*sizeof(char));
			len = strlen(nd->db_Template)+1;
			len += len%2;
			WriteChunkBytes(iff, (UBYTE *) nd->db_Template, len*sizeof(char));
			WriteChunkBytes(iff, (UBYTE *) &(nd->db_Flags), sizeof(ULONG));
			temp = CountNodes(nd->db_Pats);
			WriteChunkBytes(iff, (UBYTE *) &temp, sizeof(ULONG));

			pnd = (struct PatNode *) nd->db_Pats->lh_Head;

			while(pnd->pat_Nd.ln_Succ)
			{
				WriteChunkBytes(iff, (UBYTE *) pnd->pat_Str, sizeof(char)*PATLEN+sizeof(ULONG)*2);

				pnd = (struct PatNode *) pnd->pat_Nd.ln_Succ;
			}

			nd = (struct DBNode *) nd->db_Nd.ln_Succ;
			PopChunk(iff);
		}

		PopChunk(iff);

		CloseIFF(iff);
		
		if(goofy)
			Close(goofy);
			
		FreeIFF(iff);
		
		if(IFFParseBase)
			CloseLibrary(IFFParseBase);
			
	}
	
	return NO_ERROR;
}

ULONG FileRequest(char *file, char *dir, char *pat, BOOL save, BOOL dirs)
{
	struct FileRequester *req = NULL;
	ULONG oldflags;
	
	if(!(AslBase = OpenLibrary("asl.library", DEF_LOWEST_REV)))
		return NO_ASLLIB;
	
	CleanWindow(DropBoxWnd);
	oldflags = DropBoxWnd->IDCMPFlags;
	ModifyIDCMP(DropBoxWnd, NULL);
		
	if(!(req = (struct FileRequester *) AllocAslRequestTags(ASL_FileRequest,
		ASL_Hail, (ULONG) FILEHAIL, ASL_Window, (ULONG) DropBoxWnd,
		ASL_File, (ULONG) (file?file:""), ASL_Dir, (ULONG) (dir?dir:""),
		ASL_Pattern, (ULONG) (pat?pat:""), ASL_FuncFlags,
		(save?FILF_SAVE:0)|FILF_PATGAD,
		ASL_ExtFlags1, (dirs?FIL1F_NOFILES:0),TAG_DONE)))
	{
		CloseLibrary(AslBase);
		ModifyIDCMP(DropBoxWnd, oldflags);
		return NO_FILEREQ;
	}

	if(!AslRequestTags((APTR)req, TAG_DONE)) 
	{
		FreeAslRequest((APTR)req);
		CloseLibrary(AslBase);
		ModifyIDCMP(DropBoxWnd, oldflags);
		return ASLCANCEL;
	}
	
	if(file)
		strcpy(file, (char *)req->rf_File);
	if(dir)
		strcpy(dir, (char *)req->rf_Dir);
	if(pat)
		strcpy(pat, (char *)req->rf_Pat);
	
	FreeAslRequest((APTR) req);
	CloseLibrary(AslBase);

	ModifyIDCMP(DropBoxWnd, oldflags);
		
	return NO_ERROR;
}

ULONG JustSave()
{
	char temp[DEFLEN];
	
	strcpy(temp, prefdir);
	AddPart(temp, preffile, DEFLEN);
	
	return SavePrefs(temp);
}

ULONG JustLoad()
{
	char temp[DEFLEN];
	
	strcpy(temp, prefdir);
	AddPart(temp, preffile, DEFLEN);
	
	return LoadPrefs(temp);
}

void PrefIO(BOOL save)
{
	LONG err = 0;
	
	if(err = FileRequest(preffile, prefdir, prefpat, save, FALSE))
	{
		if(err > 0)
			DisplayErr(err);
	}
	else
	{
		if(save)
			err = JustSave();
		else
			err = JustLoad();
			
		if(err)
			DisplayErr(err);
		else
			modified = FALSE;
	}
}

void InitIO(char *file, char *dir, char *pat)
{
	if(file)
		strcpy(preffile, file);
	else
		strcpy(preffile, FILEPREF);
		
	if(dir)
		strcpy(prefdir, dir);
	else
		strcpy(prefdir, DIRPREF);
		
	if(pat)
		strcpy(prefpat, pat);
	else
		strcpy(prefpat, PATPREF);
}
	
void GetDest(char *current)
{
	LONG err = 0;
	
	if(err = FileRequest(NULL, current, NULL, FALSE, TRUE))
	{
		if(err > 0)
			DisplayErr(err);
	}
}

void GetCom(char *current)
{
	LONG err = 0;
	char dir[DEFLEN], file[DEFLEN];
	char *temp;
	
	strcpy(dir, current);
	strcpy(file, FilePart(current));
	temp = FilePart(dir);
	*temp = '\0';
	
	if(err = FileRequest(file, dir, NULL, FALSE, FALSE))
	{
		if(err > 0)
			DisplayErr(err);
	}
	else
	{
		AddPart(dir, file, DEFLEN);
		strcpy(current, dir);
	}
}
	
