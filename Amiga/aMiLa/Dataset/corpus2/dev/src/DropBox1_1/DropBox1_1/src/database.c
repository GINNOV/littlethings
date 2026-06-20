/** DoRev Header ** Do not edit! **
*
* Name             :  database.c
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  11-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 03-Jul-93    5  Steve Anichini       Near total rewrite of database functions
* 01-Jul-93    4  Steve Anichini       Made CopyDBNode() a macro
* 01-Jul-93    3  Steve Anichini       Added support for SOURCEDIR 
										and SOURCEFILE for CreateCommand()
* 21-Jun-93    2  Steve Anichini       First Release.
* 12-Jun-93    1  Steve Anichini       Beta Release 1.0
* 11-Jun-93    0  Steve Anichini       None.
*
*** DoRev End **/


#include "DropBox.h"

/* State Machine Defines */
#define SM_START 1
#define SM_ACHAR 2
#define SM_LBRA  3
#define SM_RBRA  4
#define SM_BCHAR 5
#define SM_CHAR  6
#define SM_END   7
#define SM_ERROR 8

struct List *DataBase = NULL;

struct List *MyNewList(ULONG type)
{
	struct List *temp = NULL;
	
	if(!(temp = (struct List *) AllocVec(sizeof(struct List), MEMF_PUBLIC)))
		return NULL;
		
	NewList(temp);
	
	temp->lh_Type = type;
	
	return temp;
}

void InitDB()
{	
	if(!(DataBase = MyNewList(NT_DBNODE)))
		leave(NO_DATABASE);			
}

void CleanList(struct List *list)
{
	struct Node *temp = NULL;

	if(list)
	{
		while(!IsEmpty(list))
			if(temp = RemoveNode(NULL,list))
				FreeNode(temp);
		
		FreeVec((UBYTE *)list);
	}	
}

void FreeNode(struct Node *nd)
{
	switch(nd->ln_Type)
	{
		case NT_PATNODE:
			FreeVec((UBYTE *)nd);
			break;
			
		case NT_DBNODE:
			CleanList(((struct DBNode *)nd)->db_Pats);
			FreeVec((UBYTE *)nd);
			break;
			
		default:
			break;
	}
}	
				
struct Node *NewNode(ULONG type)
{
	struct Node *temp;
	struct List *list;

	switch(type)
	{
		case NT_DBNODE:
			if(temp = (struct Node *) AllocVec(sizeof(struct DBNode), MEMF_PUBLIC))
				if(list = MyNewList(NT_PATNODE))
					FillDBNode((struct DBNode *) temp, "--Unamed--", "", "",
							"", DFLG_SUPOUTPUT|DFLG_SUPINPUT, list);
				else
				{
					FreeVec((UBYTE *)temp);
					temp = NULL;
				}
			break;
			
		case NT_PATNODE:
			if(temp = (struct Node *) AllocVec(sizeof(struct PatNode), MEMF_PUBLIC))
				FillPatNode((struct PatNode *)temp, "#?.", PFLG_NOFLAG);
			break;
	
		default:
			temp = NULL;
			break;
	}
	
	return temp;
}	
void InsertNode(struct Node *nd, struct Node *where, struct List *list)
{
	if(where->ln_Pred)
		 Insert(list, nd, where->ln_Pred);
	else
		AddHead(list, nd);
}

struct Node *RemoveNode(struct Node *node, struct List *list)
{
	if(node)
	{
		Remove(node);
		
		return node;
	}
	else
		return RemTail(list);
}

void FillDBNode(struct DBNode *node, char *name, char *dest,
						char *com, char *template, ULONG flags, struct List *pats)
{
	strcpy(node->db_Name, name);
		
	node->db_Nd.ln_Type = NT_DBNODE;
	node->db_Nd.ln_Pri = 0;
	node->db_Nd.ln_Name = node->db_Name;
		
	strcpy(node->db_Pat, "") ; /* Null string for compat. */
	strcpy(node->db_Dest, dest);
	strcpy(node->db_Com, com);
	strcpy(node->db_Template, template);
		
	node->db_Flags = flags;
	node->db_Pats = pats;
}	

void FillPatNode(struct PatNode *node, char *pat, ULONG flags)
{
	strcpy(node->pat_Str, pat);
	
	node->pat_Nd.ln_Type = NT_PATNODE;
	node->pat_Nd.ln_Pri = 0;
	node->pat_Nd.ln_Name = node->pat_Str;
	
	node->pat_Flags = flags;
	node->pat_Reserved = 0;
}

void CopyDBNode(struct DBNode *dest, struct DBNode *src)
{
	struct List *list = NULL;
	struct PatNode *pn = NULL, *pn2;
	
	FillDBNode(dest, dest->db_Name,src->db_Dest,
		src->db_Com, src->db_Template,src->db_Flags, NULL);
	
	if(src->db_Pats)
		if(list = MyNewList(NT_PATNODE))
		{
			pn = (struct PatNode *) src->db_Pats->lh_Head;
			
			while(pn->pat_Nd.ln_Succ)
			{
				if(pn2 = (struct PatNode *)NewNode(NT_PATNODE))
				{
					FillPatNode(pn2, pn->pat_Str, pn->pat_Flags);
					AddTail(list, (struct Node *)pn2);
				}
				
				pn = (struct PatNode *)pn->pat_Nd.ln_Succ;
			}
			
			dest->db_Pats = list;
		}
}
	
struct List *FindDBNode(char *file)
{
	struct DBNode *temp;
	struct PatNode *temp2;
	char pat[DEFLEN];
	struct List *list = NULL;
	struct DBNode *new = NULL;
	BOOL found;
	
	if(!(list = MyNewList(NT_DBNODE)))
		return NULL;
	
	temp = (struct DBNode *) DataBase->lh_Head;
		
	while(temp->db_Nd.ln_Succ)
	{
		if(temp->db_Pats)
		{
			temp2 = (struct PatNode *) temp->db_Pats->lh_Head;
			
			found = FALSE;
			while(!found && (temp2->pat_Nd.ln_Succ))
			{
				ParsePatternNoCase(temp2->pat_Str, pat, DEFLEN);
				
				if(MatchPatternNoCase(pat, file))
				{
					found = TRUE;
					
					if(!(new = (struct DBNode *) NewNode(NT_DBNODE)))
					{
						if(IsEmpty(list))
						{
							CleanList(list);
							list = NULL;
						}
						return list;
					}
					
					CopyDBNode(new, temp);
					strcpy(new->db_Name, temp->db_Name);
					AddTail(list, (struct Node *)new);
				}
				else
					temp2 = (struct PatNode *) temp2->pat_Nd.ln_Succ;
			}
			
		}
	
		temp = (struct DBNode *) temp->db_Nd.ln_Succ;
	}
	
	if(!IsEmpty(list))
		return list;
	else
	{
		CleanList(list);
		return NULL;
	}
}

int SetState(int cur, char c)
{
	switch(cur)
	{
		case SM_START:
			if(c != '[')
			{
				if(c != ']')
					return SM_ACHAR;
				else
					return SM_ERROR;
			}
			else
				return SM_LBRA;
			break;

		case SM_ACHAR:
			if(c == '[')
				return SM_LBRA;
			else
				if(c == ']')
					return SM_ERROR;
				else
					if(c != '\0')
						return SM_ACHAR;
					else
						return SM_END;
			break;

		case SM_LBRA:
			if((c != '[') && (c != ']'))
				return SM_BCHAR;
			else
				return SM_ERROR;
			break;

		case SM_BCHAR:
			if(c != ']')
				return SM_ERROR;
			else
				return SM_RBRA;
			break;

		case SM_RBRA:
			if((c != '[') && (c != ']'))
			{
				if(c != '\0')
					return SM_CHAR;
				else
					return SM_END;
			}
			else
				return SM_ERROR;
			break;

		case SM_ERROR:
			return SM_ERROR;
			break;
	}

	return SM_START;
}

ULONG ParseToken(struct DBNode *node, struct WBArg *warg, char *com, char *tok)
{
	char *temp, reallytemp[2];
	int state;
	char storage[DEFLEN], dir[DEFLEN];

	NameFromLock(warg->wa_Lock, dir, DEFLEN);
	AddPart(dir, warg->wa_Name, DEFLEN);
	strcpy(storage, dir);
	*(PathPart(storage)) = '\0'; /*For SOURCEDIR */

	temp = tok;
	reallytemp[1] = '\0';

	if(*temp)
    	state = SM_START;
	else
        state = SM_END;

	while(state != SM_END)
	{
		switch(state)
		{
			case SM_START:
				break;

			case SM_ACHAR:
				reallytemp[0] = *temp;
				strcat(com, reallytemp);
			case SM_LBRA:
				temp++;
				break;

			case SM_BCHAR:
				if(!strnicmp(temp, COM,strlen(COM)))
				{
					strcat(com, "\"");
					strcat(com, node->db_Com);
					strcat(com, "\"");
					temp += strlen(COM);
				}
				else
					if(!strnicmp(temp, DEST1, strlen(DEST1)))
					{
						strcat(com, "\"");
						strcat(com, node->db_Dest);
						if(node->db_Flags&DFLG_CREATE)
						{
							// Pray the stack doesn't overflow!!!
							char *t2, name[DEFLEN], thetemp[DEFLEN]; 
							
							strcpy(name, warg->wa_Name);
							t2 = strrchr(name, '.');
							if(t2)
								*t2 = '\0';
							strcpy(thetemp, "");
							AddPart(thetemp, name, DEFLEN*2);
							AddPart(thetemp, "a", DEFLEN*2);
							t2 = FilePart(thetemp);
							if(t2)
								*t2 = '\0';
							strcat(com, thetemp);
						}
						strcat(com, "\"");
						temp += strlen(DEST1);
					}
					else
						if(!strnicmp(temp, SOURCE, strlen(SOURCE)))
						{
							if(!strnicmp(temp, SOURCEDIR, strlen(SOURCEDIR)))
							{
								strcat(com, "\"");
								strcat(com, storage);
								strcat(com, "\"");
								temp += strlen(SOURCEDIR);
							}
							else
								if(!strnicmp(temp, SOURCEFILE, strlen(SOURCEFILE)))
								{
									strcat(com, "\"");
									strcat(com, warg->wa_Name);
									strcat(com, "\"");
									temp += strlen(SOURCEFILE);
								}
								else /* SOURCE */
								{
									strcat(com, "\"");
									strcat(com, dir);
									strcat(com, "\"");
									temp += strlen(SOURCE);
								}
						}
						else
							return PT_COMUNKNOWN;
				break;
				
			case SM_RBRA:
				temp++;
				break;
					
			case SM_CHAR:
				strcat(com, temp);
				break;
				
			case SM_ERROR:
				return PT_BADTOKEN;
				
		} /* end of switch */
		
		state = SetState(state, *temp);
	}
	
	strcat(com, " ");
	
	return NO_ERROR;
}
			
ULONG CreateCommand(struct DBNode *node, struct WBArg *warg, char *com)
{
	char str[DEFLEN];
	char *tok[64];
	int numtoks = 0, i;
	ULONG err = NO_ERROR;
	
	strcpy(str, node->db_Template);
	
	tok[numtoks] = strtok(str, " ");
	while(tok[numtoks])
	{
		numtoks++;
		tok[numtoks] = strtok(NULL, " ");
	}
	
	strcpy(com, "");
	
	for(i = 0; i < numtoks; i++)
		if(err = ParseToken(node, warg, com, tok[i]))
			return err;
	
	return err;
}

struct Node *OrdToPtr(UWORD ord, struct List *list)
{
	int i = 0;
	struct Node *temp;
	BOOL found = FALSE;
	
	temp = list->lh_Head;
	
	while(temp->ln_Succ && !found)
		if(i == ord)
			found = TRUE;
		else
		{
			i++;
			temp = temp->ln_Succ;
		}
		
	if(!found)
		return NULL;
	else
		return temp;
}
	
UWORD PtrToOrd(struct Node *ptr, struct List *list)
{
	UWORD i = 0;
	struct Node *temp;
	BOOL found = FALSE;
	
	temp = list->lh_Head;
	
	while(temp->ln_Succ && !found)
		if( ptr == temp)
			found = TRUE;
		else
		{
			i++;
			temp = temp->ln_Succ;
		}
		
	if(!found)
		return ~0;
	else
		return i;
}
		
ULONG CountNodes(struct List *list)
{
	ULONG i = 0;
	struct Node *temp;
	
	temp = list->lh_Head;
	
	while(temp->ln_Succ)
	{
		i++;
		temp = temp->ln_Succ;
	}
		
	return i;
}

ULONG Sort(struct List **list)
{
	struct List *new = NULL;
	struct Node *nd = NULL, *nd2 = NULL, *pred;
	BOOL found;
	
	if(!(new = MyNewList((*list)->lh_Type)))
		return NO_MEM;
	else
	{
		nd = (*list)->lh_Head;
		
		while(nd->ln_Succ)
		{
			Remove(nd);
			
			if(IsEmpty(new))
				AddHead(new, nd);
			else
			{
				pred = NULL;
				nd2 = new->lh_Head;
				found = FALSE;
				
				while(nd2->ln_Succ && !found)
					if(stricmp(nd->ln_Name, nd2->ln_Name) <= 0)
					{
						Insert(new, nd, pred);
						found = TRUE;
					}
					else
					{
						pred = nd2;
						nd2 = nd2->ln_Succ;
					}
					
				if(!found)
					AddTail(new, nd);
			}
			
			nd =  (*list)->lh_Head;
			
		}
		
		FreeVec((UBYTE *)(*list));
		*list = new;
		
		return NO_ERROR;
	}
}
				
				
						
