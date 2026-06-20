/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*	___________________

	ABackup Prefs
	utility.c

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 05-Sep-93
	Modified: 22-Apr-95
	___________________
*/

#include "headers.h"
#include "utility.h"

STATIC BOOL	MkDir			(STRPTR);
STATIC WORD	GetWidthFromID	(ULONG);

//______________________________________________________________________________

struct Node *
FindDevNode(struct MinList *plist, UWORD num)

{
	struct Node *nn;
	UWORD i;

	for (i = 0,nn = (struct Node *)plist->mlh_Head;nn->ln_Succ; i++,nn = nn->ln_Succ)
		if (i == num) return(nn);

	return(NULL);
}

/*************************************************************************/

STATIC VOID
SwapNodes( struct List *pList , struct Node *pFirst, struct Node *pSecond )

{
  struct Node *pFPred, *pSPred ;

  /* get the preds of the two nodes */
  pFPred = pFirst->ln_Pred ;
  if ( ! pFPred->ln_Succ ) pFPred = NULL ;
  pSPred = pSecond->ln_Pred ;
  if ( ! pSPred->ln_Succ ) pSPred = NULL ;

  /* remove the second node, and insert it after the pred of the first */
  Remove( pSecond ) ;
  Insert( pList , pSecond , pFPred ) ;

  /* remove the first node, and insert it after the old pred of the second */
  if ( pSPred != pFirst )
  {
    Remove( pFirst ) ;
    Insert( pList , pFirst , pSPred ) ;
  }
}

//______________________________________________________________________________

VOID
SortDevList( struct MinList *plist , LONG deb , LONG fin )

{
  LONG i, j, k ;
  struct Node *v, *w, *x ;

  i = deb ;
  j = fin ;
  k = (deb + fin) >> 1 ;

  do
  {
    v = FindDevNode( plist , k ) ;
    if ( ! v ) return ;

    while ( w = FindDevNode( plist , i ) )
    {
      if ( stricmp( w->ln_Name , v->ln_Name ) >= 0 ) break ;
      i++ ;
    }
    if ( ! w ) break ;

    while ( x = FindDevNode( plist , j ) )
    {
      if ( stricmp( v->ln_Name , x->ln_Name ) >= 0 ) break ;
      j-- ;
    }
    if ( ! x ) break ;

    if ( w != x )
      SwapNodes( (struct List *)plist , w , x ) ;

    i++ ;
    j-- ;
  }
  while ( (i < k) && (j > k) ) ;

  if ( deb < j ) SortDevList( plist , deb , j ) ;
  if ( i < fin ) SortDevList( plist , i , fin ) ;
}

//______________________________________________________________________________

VOID
StringToList(struct MinList *minlist,STRPTR string)

/* Converts a string of names into a list */

{
	UBYTE	i,j,name[256];

	NewList ((struct List *)minlist);

	for (i = 0; string[i]; i += j + (string[i+j] ? 1 : 0)) {
		for (j = 0; string[i+j] && string[i+j] != ','; j++) ;
		strncpy(name,&string[i],j);
		name[j] = '\0';
		AddName(minlist,name);
	}
}

//______________________________________________________________________________

UWORD
ListToString(struct MinList *minlist,STRPTR string)

/* Converts a list of names into a string */

{
	UWORD		pos = 0;
	struct Node	*nn;

	string[0] = '\0';
	for (nn = (struct Node *)minlist->mlh_Head;
	     nn->ln_Succ;
	     nn = nn->ln_Succ,pos++) {
		if (pos) strcat(string,",");
		strcat(string,nn->ln_Name);
	}
	return(pos);
}

//______________________________________________________________________________

BOOL
AddName (struct MinList *minlist,STRPTR name)
{
	struct NameNode *namenode;

	if (namenode = AllocVec(sizeof(struct NameNode),MEMF_CLEAR)) {
		strcpy(namenode->nn_Data,name);
		namenode->nn_Node.ln_Name = namenode->nn_Data;
		namenode->nn_Node.ln_Type = NT_USER;
		namenode->nn_Node.ln_Pri  = 0;
		AddTail((struct List *)minlist,(struct Node *)namenode);
		return(TRUE);
	}

	WARNING(MSG_WARN_MEMORY);
	return(FALSE);
}
//______________________________________________________________________________

VOID
FreeMinList (struct MinList *minlist,BOOL all)
{
	struct NameNode *nn,*wn;

	wn = (struct NameNode *)(minlist->mlh_Head);

	while (nn = (struct NameNode *)(wn->nn_Node.ln_Succ)) {
		FreeVec(wn);
		wn = nn;
	}

	if (all)
		FreeVec(minlist);
	else
		NewList((struct List *)minlist);
}
//______________________________________________________________________________

VOID
SetCycle (UWORD id,struct TagItem *tags,UBYTE max,BOOL direction)
{
	if (direction == FORWARD)
		tags[1].ti_Data += (tags[1].ti_Data<max)?1:-tags[1].ti_Data;
	else
		tags[1].ti_Data -= tags[1].ti_Data?1:-max;
	GT_SetGadgetAttrsA(Gads[id],Win,NULL,tags);
}
//______________________________________________________________________________

BOOL
Access (STRPTR name)
{
	BPTR	lock;

	if (lock = Lock(name,ACCESS_READ)) {
		UnLock(lock);
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

__inline STATIC BOOL
MkDir (STRPTR name)
{
	BPTR	lock;

	if (lock = CreateDir(name)) {
		UnLock(lock);
		return TRUE;
	}
	return FALSE;
}
//______________________________________________________________________________

VOID
CheckAccess (UWORD gadID,STRPTR oldname,BYTE type)
{
	STRPTR	name = GDST_BUF;

	if (type == CHECKNONE || NOT name || Access(name)
	 || (type == CHECKDIR
		&& Notify(MSG_REQUEST,GetStr(MSG_CREATEDIR),MSG_YES_NO,&name)
		&& MkDir(name))) strcpy(oldname,name);

	SetGad(gadID,GTST_String,(ULONG)oldname);
}
//______________________________________________________________________________

LONG
CheckPubScreen (STRPTR name)
{
	struct Screen	*scr;

	if (scr = LockPubScreen(name)) {
		UnlockPubScreen(name,NULL);
		return(GetVPModeID(&(scr->ViewPort)));
	}
	return(INVALID_ID);
}
//______________________________________________________________________________

UWORD
CheckFont (STRPTR name,UWORD size)
{
	if (size<5) WARNING(MSG_WARN_FONT_TOO_SHORT);
	else if (DiskfontBase) {
		struct TextAttr ta;
		struct TextFont *tf;

		ta.ta_Name	= name;
		ta.ta_YSize	= size;
		ta.ta_Style	= FS_NORMAL;
		ta.ta_Flags	= NULL;

		if (tf = OpenDiskFont(&ta)) {
			UWORD	width;

			CloseFont(tf);

			if (width = GetWidthFromID(PRF_DISPLAYID)) {
				if (80*tf->tf_XSize > width+1) {
					WARNING(MSG_WARN_FONT_TOO_WIDE);
					return NULL;
				}
			}
			return(tf->tf_YSize);
		}
		else Notify(MSG_WARNING,GetStr(MSG_WARN_OPEN_FONT),MSG_RESUME,&name);
	}
	else WARNING(MSG_WARN_OPEN_DISKFONT);
	return NULL;
}
//_____________________________________________________________________________

__inline STATIC WORD
GetWidthFromID (ULONG ID)
{
	struct DimensionInfo	diminfo;

	// read a screen's visible width:
	if (GetDisplayInfoData(NULL,(STRPTR)&diminfo,sizeof(diminfo),DTAG_DIMS,ID))
		 return(diminfo.Nominal.MaxX);
	else return NULL;
}
//______________________________________________________________________________

LONG
Notify (WORD title,STRPTR text,WORD gadgets,STRPTR *args)
{
	struct EasyStruct	nes;
	struct Requester	req;
	LONG	rc;
	BOOL	success = FALSE;

	nes.es_StructSize	= sizeof(struct EasyStruct);
	nes.es_Flags		= 0L;
	nes.es_Title		= GetStr(title);
	nes.es_TextFormat	= text;
	nes.es_GadgetFormat	= GetStr(gadgets);

	// using a requester to block window input:
	if (Win) {
		if (IntuitionBase->LibNode.lib_Version >= 39)
			SetWindowPointerA(Win,BusyTags);
	//	else SetPointer(Win,BusyPtr,16,16,-6,0);

		InitRequester(&req);
		success = Request(&req,Win);
	}

	rc = EasyRequestArgs(Win,&nes,NULL,args);

	if (Win) {
		if (success) EndRequest(&req,Win);
		ClearPointer(Win);
	}

	return(rc);
}
//______________________________________________________________________________

VOID
NotifyError(WORD text,STRPTR name)
{
	STRPTR	args[3];
	UBYTE	errmsg[81];

	args[0] = GetStr(text);
	args[1] = name;
	args[2] = Fault(IoErr(),NULL,errmsg,80L)? errmsg: NULL;

	Notify(MSG_ERROR,"%s\n%s\n%s",MSG_RESUME,args);
}

// Tab size: 4
