/* DiskMaster2 general commands module
**
** 2.5.29
**
** 04-03-30 rri - Raised requester-string length for 'Select' to 100 to allow
**                more complicated patterns to match with.
**
** 04-03-31 rri - 'Select' uses FilterStar() directly now to process the pattern only once.
**              - 'ReqPattern' stores already FilterStar() processed Pattern[] now.
**              - ResetFlags() resets Pattern[] to "#?" now.
**
** 2.5.30
**
** 04-08-08 rri - Bugfix: 'Swap' failed to clear empty dirs.
**                Thanks for reporting to Michel Bagmeijer <303dmx@hetnet.nl>!
**
** 2.5.31
**
** 04-12-22 rri - Removed "use30" checking code - DM2 goes V39+!
**
** 05-03-26 rri - Removed unused var "FuckingTopaz".n
**              - Added switch for "timeplus" to 'SetX'.
**
** 05-03-27 rri - Added new command 'Clip' - CMD_clip().
**
** 2.6
**
** 05-07-31 rri - Raised default values for zooming width and height to 100.
**              - Removed comments from header older than 2.5.29.
**
** 05-08-12 rri - Almost completely rewrote 'Archive'. For the 68k version a command-string
**                of less than 511 chars is generated, for the OS4-PPC version it's less than 3800 chars.
**                In addition using "#" for the name argument suppresses the target-requester thus making
**                this command better suitable for generic multi-select actions.
**
** 05-08-19 rri - Modified 'Archive' to use the copy-buffer for the command-line string which means it can
**                grow to 128K now. For 3.5/3.9/different Shells a new flag has been introduced that
**                is set thru 'SetX' and which allows to get past 511 chars with the 68K version as well.
**              - Added option "longcmd" to 'SetX'.
**              - Modified "timeplus" option in 'SetX' to use the new flag DMFLAG_TIMEPLUS.
**
** 05-09-12 jjt - DMSet() - Added "WheelMult" and "DragDelay" options.
**
** 05-11-08 jjt - AddCmd(), AddAutoCmd() - Added context help to the reqs.
**              - DMSet() - Added SetX Guide.
**
** 05-11-21 jjt - Added a DMREQ_HELPNODE tag to ReqPattern, Select, and ChangeCommand requesters.
**
** 05-11-23 jjt - DMSet() - Added "ReqHideHelp" option.
**              - Bugfix: DMSelect() the helpnode is correctly set to either Select or Deselect.
**              - Added a DMREQ_HELPNODE to Archive,
**
** 05-11-27 rri - Bugfix: If defx and defy are not set, DMP_UseWinScale is set
**                        to FALSE to singal DMPrefs to not activate scaling.
**                        Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**              - Bugfix: The "COMMENT" option for 'Select', introduced with 2.5b13,
**                        fed MatchPatternNoCase() with NULL-strings for empty comments.
**
** 05-11-27 jjt - DMSet() - Changes DMP_UseWinScale to TRUE when defx and defy aren't zero.
**
** 2.7
**
** 06-09-17 rri - CMD_Font() - update Reaction gadgets with new fonts
**
** 06-10-08 rri - Adding FlushLayoutDomainCache() in CMD_Font() makes the Reaction gadgets
**                actually resize when changing their fonts.
**
** 06-11-11 rri - Adapted DMSelect() and DMArchive() to use ListBrowser.gadget
**
** 06-12-05 rri - Removed some debug-output from DMArchive().
**
** b3
**
** 06-12-14 rri - Added DMFONTS_CMDWIN to FontKeywords[].
**              - Added ta_cmdwin.
**              - Added updating of DMFONTS_CMDWIN to CMD_Font().
**
** b4
**
** 06-12-16 rri - Conditionally removed the var "drag_delay" from the OS4 build.
**
** b6
**
** 06-12-21 rri - Set the var for LBNA_Selected in DMArchive() to uint32.
**
** b7
**
** 06-12-26 rri - Added DMFONTS_READER to FontKeywords[].
**
** 06-12-28 rri - Removed a few obsolete FontToAttr() calls.
**                DMTextAttrs[] is always updated by DMOpenFont() now.
**              - Removed Menu_TAttr as it already is part of DMTextAttrs[].
**
** 06-12-30 rri - Modified dwcopy() and DoSwap() for use with Reaction based windows.
**
** 07-01-02 rri - DoSwap() was not updating the path-gadgets correctly.
**              - Switched from GetAttrs() to GetAttr() in DoSwap() as only one
**                tag is requested anyways.
**              - DoSwap() was crashing with dev/vol/asn-lists now -> removed the whole
**                special-handling, with ListBrowser.gadget the whole display is swapped by
**                tossing the list-pointers around...
**
** b8
**
** 07-01-06 rri - Added clearing of DMFLAG_READONLY to ResetFlags().
**
** 07-01-08 rri - DMArchive(), DMSelect() and DoSwap() use attach_list()/detach_list() now.
**
** b9
**
** 07-01-10 rri - Fix: 'Swap' does not trigger to re-sort a DEV/VOL/ASN-list anymore.
**                     Thanks to Javier de las Rivas for the report!
**              - DoSwap() does not copy the lists anymore but rather initialises a
**                new list at the target and moves the nodes from the source to it.
**
** 07-01-17 rri - Replaced the old-C-style array init ( {0} ) of changed[] in CMD_Font()
**                with a call to memset().
**
** 07-01-21 rri - Replaced a call to Examine() in GetCmdFile() by a call to ExamineObjectTags().
**
** b10
**
** 07-01-28 rri - Removed the alternative set of colors for the commands in EditCmd() from the OS4-build.
**              - Removed the alternative set of colors for the commands in ParseCmd1() from the OS4-build.
**
** b12
**
** 08-08-30 rri - Removed a warning with GCC 4.2.3 in DMReqPat() where I introduced an if(Pattern)
**                with 2.5.29 but meant to do an if(*Pattern) to check if the string is empty or not
**
**
*/


#include "DM.h"


extern struct DirWindow  *CDWin,*CmdWin,*DestWin,*DirWin[];
extern struct DirList    *WorkDlp;
extern struct Screen     *Screen,*MyScreen;
extern struct TextFont   *DMFonts[];  /* 2.5RC2 jjt */
extern struct TextAttr   DMTextAttrs[];  /* 2.7 rri */
extern struct MsgPort    *WinPort; /* 2.5RC10 rri */
extern struct TagItem    reqtags_Help[];  /* 2.6 jjt */


/* 2.5.32 rri */
extern struct Library  *IFFParseBase;
#ifdef __amigaos4__
extern struct IFFParseIFace   *IIFFParse;
#endif
extern UBYTE * command;

extern BOOL  Req_ShowHelpBtn, /* 2.6 jjt */
             DMP_UseWinScale; /* 2.6 rri */

extern UBYTE
             *ActionArgs[],
             ActionBuf[],
             DMname[],
             *Globuff,
             g_buttons[],  /* 2.5b10 jjt */
             PGadStr[],
             sbuff[],
             sPath[],
             *Strap; /* 2.5.24 rri */


extern WORD  zooming[]; /* 2.5b13 rri */

extern UWORD Pens20[]; /* 2.5RC10 rri */

extern LONG  BackPen, /* 2.5b12 rri */
             Base_Str_Len, /* 2.5.23 rri */
             Bar_Height, /* 2.5b13 rri */
             DirPen, /* 2.5b12 rri */
             FilePen, /* 2.5b12 rri */
             Globuff_size, /* 2.6 rri */
             IconX,
             IconY,
             separator, sizes, /* 2.5RC8 rri */
             SelectPen; /* 2.5b12 rri */

extern ULONG DWNum,
             FLAGS, /* 2.5RC2 rri */
             Screen_Height, /* 2.5b13 rri */
             Screen_Width, /* 2.5b13 rri */
             ShowDev, /* 2.5b12 jjt */
             UserColors; /* 2.5b11 rri */

extern STRPTR DiskMaster2Guide;  /* 2.6 jjt */

extern APTR StringPool; /* 2.5b12 jjt */
extern APTR NamePool; /* 2.5.24 rri */

extern uint32 wheel_multiply;

#ifndef __amigaos4__ /* 2.7 rri - obsolete with Reaction */
extern uint32 drag_delay;  /* 2.6 jjt */
#endif

BPTR StdIO;

UBYTE
      *AppIconPath, /* 2.5b13 rri */
      *AutoCmdStr[255], /* 2.5RC6 rri */
      dcPath[4096], /* 2.5RC6 rri */
      DOSPassStr[4096], /* 2.5RC10 rri */
      Pattern[64], /* 2.5RC4 rri */
      ReqStr[700],
      *DevHide_List[DEVHIDELIST_MAX],  /* 2.5b12 jjt*/
      FontKeywords[][15]={"DIRWIN", "DIRGAD", "REQTEXT", "REQBUTTONS",
                          "MENU", "CMDWIN", "READER"}; /* 2.7 rri */

LONG digits=5, /* 2.5.23 rri */
     Notify=0; /* 2.5.23 rri */

ULONG defx=0, defy=0, /* 2.5.24 rri */
      DevHide_Count = 0;  /* 2.5b12 jjt */

sFIB Fib;


void DoStdio(UBYTE *str)
{

if(StdIO)
 {
  Close(StdIO);
  StdIO=0;
 }

if(Stricmp(str,"CLOSE")==0) return; /* 2.5b7 rri */

if(MyScreen)
 {
  DMstrcat(str,"/SCREEN"); /* 2.5RC9 rri */
  DMstrcat(str,DMname); /* 2.5RC9 rri */
 }

StdIO=Open(str,MODE_OLDFILE);
}


void GetParent(UBYTE *path,int parent) /* 2.5b6 rri */
{
BPTR lockcurrent,lockresult;
UBYTE *ptr=path+strlen(path);

for(;ptr>=path;ptr--)
 {
  if(*ptr==':')
   {
    ptr++;
    if(*ptr) /*  path was root+1 dir */
     {
      *ptr=0;
      break;
     }
    else /* path already was root */
     {
      if((lockcurrent=Lock(path,ACCESS_READ))) /* 2.5.23 gcc rri */
       {
        lockresult=ParentDir(lockcurrent);
        UnLock(lockcurrent);
        if (lockresult)
         {
          NameFromLock(lockresult,path,512);
          UnLock(lockresult);
          ptr=path+strlen(path)-1; /* 2.5b7 rri */
          if((*ptr==':')||parent) /* 2.5b9 rri */
           {
            break;
           }
         }
        else if (!lockresult&&(IoErr()==0))
         {
          path[0]=0;
          break;
         }
       }
      else /* path not valid anymore */ /* 2.5b13 rri */
       {
        path[0]=0;
        break;
       }
     }
   }
  if(parent&&*ptr=='/') /* if !parent the loop will run `till root */
   {
    *ptr=0;
    break;
   }
 }
}


/* 2.6 rri */
void DMArchive(UBYTE *cmd,UBYTE *name)
{
struct DirList **dl,*dlp;
UBYTE  *ptr,*ptr2, *ptr3;
BPTR   lock; /* 2.5b5 rri */
int32  i,cnt,maxlength;
uint32 selectstate; /* 2.7 rri */

if(!CDWin) return;

if(!GetGlobuff())
 {
  FLAGS|=DMFLAG_ABORT;
  return;
 }

#ifdef __amigaos4__
maxlength = Globuff_size - 500; /* under AmigaOS4 there is no limit to the command-line length */
#else
if(FLAGS & DMFLAG_LONGCMD)
 {
  maxlength = Globuff_size - 500; /* for different Shells and 3.9 there is no limit */
 }
else
 {
  maxlength = 511; /* for OS 3.1 there is a limit of 511 chars */
 }
#endif

if(!name || *name==0)
 {
  name=dcPath;
  strcpy(name,CDWin->Path);
  if(*(name+strlen(name)-1)!=':' && *(name+strlen(name)-1)!='/') DMstrcat(name,"/"); /* 2.5RC9 rri */
  reqtags_Help[0].ti_Data = (LONG) "Archive";  /* 2.6 jjt */
  if(!DMReqTagList(msgReqArchive, name, 512, reqtags_Help)) return;  /* 2.5b13 rri */
 }

dl=CDWin->DirList;

strcpy(Globuff,cmd);
if(name[0] != '#') /* magic-cookie to suppress the target-requester */
 {
  DMstrcat(Globuff," ");
  QuoteCat(Globuff,name);
 }

ptr = Globuff + strlen(Globuff);
ptr3 = ptr2 = ptr;

i = 0;
cnt = 0;

while(i < CDWin->FileCount)
{
 dlp=dl[i++];
 if (dlp)
 {
  GetListBrowserNodeAttrs(dlp->node, LBNA_Selected, &selectstate, TAG_DONE, 0); /* 2.7 rri */
  if(selectstate != 0) /* 2.7 rri */
  {
   DMstrcat(ptr," ");
   QuoteCat(ptr,dlp->name); /* add one space plus the filename to the command-line string */
   ptr = ptr + strlen(ptr); /* push the string-pointer ahead */
   cnt++;                   /* increase the out-of-loop-action counter */

   if(strlen(Globuff) > (uint32) maxlength)
   {
    cnt=0;                  /* reset the out-of-loop-action counter */
    *ptr2 = 0;              /* cut-off the entry added last */
    WinTitle(CDWin);        /* re-think window-title */
    DOSStart(8192,Globuff); /* start the command */
    *ptr3 = 0;              /* cut-off the arguments from our string */
    ptr = ptr2 = ptr3;      /* reset the string-pointers */
    i--;                    /* go back one dir-entry */
   }
   else /* no overflow occured */
   {
    detach_list(CDWin); /* 2.7b8 rri */
    SetListBrowserNodeAttrs(dlp->node, LBNA_Selected, FALSE, TAG_DONE, 0); /* 2.7 rri */
    attach_list(CDWin,FALSE); /* 2.7b8 rri */
    ptr2 = ptr; /* push the pointer to the last added entry ahead */
   }
  }
 }
}

if(cnt)
 {
  WinTitle(CDWin);
  DOSStart(8192,Globuff);
 }

if((lock=Lock(name,ACCESS_READ))) /* 2.5.23 gcc rri */
 {
  UnLock(lock);
  SmartAddEntry(name);
 }
}


void DMSelect(int sel)
{
struct DirList **dl,*dlp;
int i,c=1,comment;
BOOL selectstate;

selectstate = sel ? TRUE : FALSE;

FLAGS|=DMFLAG_PATREQ; /* 2.5RC2 rri */

if((comment=GetActionArg("COMMENT", AATYPE_BOOL, 0))) /* 2.5.23 gcc rri */
 {
  ActionArgs[comment]=0;
 }

if(!ActionArgs[1])
 {
  ActionArgs[1]=sbuff;
  sbuff[0]='*';
  sbuff[1]=0;
  reqtags_Help[0].ti_Data = (LONG) (sel ? "Select" : "Deselect");  /* 2.6 jjt */
  if(!DMReqTagList(msgReqSelect, sbuff, 100, reqtags_Help)) return;  /* 2.6 jjt */
 }
if(!CDWin) return;

dl=CDWin->DirList;

detach_list(CDWin); /* 2.7b8 rri */

while (ActionArgs[c])
 {
  UBYTE *patternbuffer;

  if(( patternbuffer = FilterStar(ActionArgs[c]) )) /* 2.5.29 rri */
   {
    for(i=0;i<CDWin->FileCount;i++)
     {
      dlp=dl[i];
      if(comment) /* 2.5b13 rri */
       {
        if (dlp->cmt != 0 ) /* 2.6 rri */
         {
          if(DMMatch(dlp->cmt,patternbuffer))
          {
           SetListBrowserNodeAttrs(dlp->node, LBNA_Selected, selectstate, TAG_DONE, 0); /* 2.7 rri */
          }
         }
       }
      else if(DMMatch(dlp->name,patternbuffer))
           {
            SetListBrowserNodeAttrs(dlp->node, LBNA_Selected, selectstate, TAG_DONE, 0); /* 2.7 rri */
           }
     }
    PoolFreeVec(patternbuffer);
   }
  c++;
 }

attach_list(CDWin,FALSE); /* 2.7b8 rri */
WinTitle(CDWin);
}


void DMReqPat()
{
struct TagItem patreqtags[]={{DMREQ_BUTTONS,(ULONG) g_buttons},{DMREQ_ABORT,0},{DMREQ_HELPNODE,(ULONG)"ReqPattern"},{TAG_END,0}}; /* 2.5.26 rri */ /* 2.6 jjt */

if(FLAGS&DMFLAG_PATREQ) return; /* 2.5RC2 rri */
if(WorkDlp&&!WorkDlp->dir) return;

if(ActionArgs[2]) /* 2.5.29 rri */
 {
  UBYTE *patternbuffer;

  if(( patternbuffer = FilterStar(ActionArgs[2]) ))
   {
    DMstrncpy(Pattern,patternbuffer,63);
    PoolFreeVec(patternbuffer);
   }
 }

if(!ActionArgs[1]) /* 2.5b13 rri */
 {
  strcpy(ReqStr,msgReqPattern);
  ActionArgs[1]=ReqStr;
 }
if(!ActionArgs[5]) /* 2.5b13 rri */
 {
  strcpy(sbuff,msgGadSkip);
  ActionArgs[5]=sbuff;
 }

MakeBtnString(ActionArgs[3], ActionArgs[5], ActionArgs[4]);  /* 2.5b10 jjt */

if(DMReqTagList(ActionArgs[1], Pattern, 63, patreqtags) == 1) /* 2.5.26 rri */
 {
  FLAGS|=DMFLAG_PATREQ; // 2.5RC2 rri

  if(*Pattern) // 2.7b12 rri
   {
    UBYTE *patternbuffer;

    if(( patternbuffer = FilterStar(Pattern) ))
     {
      DMstrncpy(Pattern,patternbuffer,63);
      PoolFreeVec(patternbuffer);
     }
   }
 }
}


void AddAutoCmd(UBYTE *str) /* 2.5RC10 rri */
{
ULONG i=0;

if(*str==0)
 {
  sbuff[0]=0;
  reqtags_Help[0].ti_Data = (LONG) "AddAutoCmd";  /* 2.6 jjt */
  if(!DMReqTagList(msgReqAddAuto, sbuff, 512, reqtags_Help)) return;  /* 2.5b13 rri */
  str=sbuff;
 }

while(AutoCmdStr[i]) i++; /* find next free autocmd */

if(Strnicmp(str,"TEXT",4)==0) i=253; /* 2.5b7 rri */
if(Strnicmp(str,"DEFAULT",7)==0) i=254; /* 2.5b7 rri */

if(AutoCmdStr[i])
 {
  PoolFreeVec(AutoCmdStr[i]); /* 2.5RC10 rri */
  AutoCmdStr[i]=0;
 }

if(i<255&&!AutoCmdStr[i]) /* 2.5RC6 rri */
 {
  AutoCmdStr[i] = CloneStr(str,StringPool); /* 2.5RC10 rri */
 }
}


void AddCmd(struct DirWindow *dw,UBYTE *buf)
{
struct DirList **dl,*dlp;
int x; /* 2.5b13 rri */

if(!dw)
 {
 /* 2.5b13 rri */
  x=Screen_Width/5;
  zooming[0]=x*2;
  zooming[1]=Bar_Height+1;
  zooming[2]=100; /* 2.6 rri */
  zooming[3]=100; /* 2.6 rri */
  OpenDirWindow("CMD",x*2,(int) Bar_Height+1,x,(int) Screen_Height);

  dw=CmdWin;
 }
if(!dw) return;

if(!buf||*buf==0)
 {
  buf=ActionBuf;
  *buf=0;
  reqtags_Help[0].ti_Data = (LONG) "AddCmd";  /* 2.6 jjt */
  if(!DMReqTagList(msgReqCmd, buf, 512, reqtags_Help)) return; /* 2.5b13 rri */ /* 2.6 jjt */
 }
if(!(dw->Flags&(DWFLAG_ADD|DW_CMD))) FreeDirTable(dw);
if(!AllocDlp(dw)) return;
dw->Flags=DW_CMD;
dl=dw->DirList;
dlp=dl[dw->FileCount++];
ParseCmd1(dlp,buf);
dw->Flags|=DWFLAG_ADD;
}


void EditCmd(struct DirWindow *dw,int ni)
{
struct DirList **dl=dw->DirList,*dlp=dl[ni];
UBYTE *ptr=dlp->cmt;

FLAGS&=~DMFLAG_CHGCMD; /* 2.5RC2 rri */

if(dlp->name) /* 2.5.24 rri */
 {
  #ifdef __amigaos4__ /* 2.7b10 rri */
  sprintf(ActionBuf,"%s, %lx%lx, %s",
               dlp->name,dlp->attr&0xf,(dlp->attr>>4)&0xf,ptr);
  #else
  sprintf(ActionBuf,"%s, %lx%lx, %lx%lx, %s",
               dlp->name,dlp->attr&0xf,(dlp->attr>>4)&0xf,
               (dlp->attr>>8)&0xf,(dlp->attr>>12)&0xf,ptr); /* 2.5b12 rri */
  #endif
}
else *ActionBuf=0;

reqtags_Help[0].ti_Data = (LONG) "AddCmd";  /* 2.6 jjt */
if(!DMReqTagList(msgReqCmd, ActionBuf, 512, reqtags_Help)) return;  /* 2.5b13 rri */ /* 2.6 jjt */
if(ptr)
 {
  PoolFreeVec(dlp->cmt); /* 2.5b10 rri */
 }
dlp->cmt=0;
ParseCmd1(dlp,ActionBuf);
}


void dwcopy(struct DirWindow *source,struct DirWindow *dest) /* 2.5.26 rri */
{
ULONG c;
#ifndef __amigaos4__
struct Node * node;
#endif


dest->PathDate     = source->PathDate;
dest->DirList      = source->DirList;
dest->Fib          = source->Fib;
dest->DM2NotifyReq = source->DM2NotifyReq;
/* 2.7b7 rri */
//dest->SExt         = source->SExt;
//dest->dir_str      = source->dir_str;
//dest->dir_gad.SpecialInfo=(APTR)&dest->dir_str;

NewList(&dest->dwgadlist);

#ifdef __amigaos4__ /* 2.7b9 rri */
MoveList(&dest->dwgadlist,&source->dwgadlist);
#else
while((node = RemHead(&source->dwgadlist)) != NULL)
{
 AddTail(&dest->dwgadlist,node);
}
#endif

dest->MaxFile      = source->MaxFile;
dest->FileCount    = source->FileCount;
dest->Sels         = source->Sels;
dest->Path         = source->Path;
for(c=0;c<32;c++)
 {
  dest->Pattern[c] = source->Pattern[c];
 }
dest->DirLock      = source->DirLock;
}

void DoSwap()
{
LONG wincounter; /* 2.5RC6 rri */
struct DirWindow *dwsource=CDWin;
struct DirWindow *dwdest=DestWin;
struct DirWindow *winbuffer;
uint32 len_s, len_d;

if(!dwsource||!dwdest) return;

if (ActionArgs[1])
 {
  StrToLong(ActionArgs[1],&wincounter); /* 2.5RC9 rri */
  if(DirWin[wincounter]&&!(DirWin[wincounter]->Flags&DW_CMD)&&!(DirWin[wincounter]==CDWin))
  {
   dwdest=DirWin[wincounter];
  }
 }

/* 2.5.26 rri */
if((winbuffer=AllocMem(sizeof (*winbuffer),MEMF_ANY | MEMF_CLEAR))) /* 2.5.28 rri */
 {
  /* 2.7b7 rri - disable the dirlists, will be re-enabled by the following ReSort() */
  detach_list(dwsource); /* 2.7b8 rri */
  detach_list(dwdest); /* 2.7b8 rri */

  CopyMem(dwsource,winbuffer,sizeof (*winbuffer));
  dwcopy(dwdest,dwsource);
  dwcopy(winbuffer,dwdest);
  FreeMem(winbuffer,sizeof(*winbuffer));

  GetAttr(STRINGA_MaxChars,dwsource->dwgad[GID_String], &len_s);
  GetAttr(STRINGA_MaxChars,dwdest->dwgad[GID_String], &len_d);

  /* 2.7b7 rri - update the swapped path's */
  SetGadgetAttrs(dwsource->dwgad[GID_String], dwsource->Window, NULL,
                       STRINGA_TextVal, dwsource->Path,
                       STRINGA_MaxChars, len_d,
                       TAG_END,0);
  SetGadgetAttrs(dwdest->dwgad[GID_String], dwdest->Window, NULL,
                       STRINGA_TextVal, dwdest->Path,
                       STRINGA_MaxChars, len_s,
                       TAG_END,0);
 }

/*
if(dwsource->Path[0]==0)
 {
  FreeDirTable(dwsource);
  GetDevList(dwsource);
 }
else dwsource->Flags|=DWFLAG_RESORT; // set re-sort flag

if(dwsource->FileCount == 0) NewSize(dwsource);

if(dwdest->Path[0]==0)
 {
  FreeDirTable(dwdest);
  GetDevList(dwdest);
 }
else dwdest->Flags|=DWFLAG_RESORT;

if(dwdest->FileCount == 0) NewSize(dwdest);
*/

/* 2.7b7 rri - copied the whole list, no need to do anything else */
if(dwsource->Path[0] == 0) /* 2.7b9 rri */
 {
  attach_list(dwsource, TRUE);
 }
else dwsource->Flags|=DWFLAG_RESORT; /* set re-sort flag */

if(dwdest->Path[0] == 0) /* 2.7b9 rri */
 {
  attach_list(dwdest, TRUE);
 }
else dwdest->Flags|=DWFLAG_RESORT;

ReSort();
}


int UnLockAll()
{
struct DirWindow *dw;
int i;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&(dw->Flags&(DW_DEST|DW_SOURCE)))
   {
    dw->Flags&=~(DW_DEST|DW_SOURCE);
    ShowDirection(dw,4);
   }
 }
ShowDirection(CDWin,0);
ShowDirection(DestWin,1);
return(0);
}


void ResetFlags()
{
FLAGS&=~(DMFLAG_ABORT | /* 2.5RC2 */
         DMFLAG_ATTR |
         DMFLAG_AUTOFILING |
         DMFLAG_CONFIRM |
         DMFLAG_LOOP |
         DMFLAG_PATREQ |
         DMFLAG_QUIET |
         DMFLAG_REC |
         DMFLAG_RESORT |
         DMFLAG_SINGLE |
         DMFLAG_UNMARK |
         DMFLAG_READONLY | /* 2.7b8 rri */
         DMFLAG_WINTITLE );

FLAGS|=DMFLAG_TESTWARN; /* 2.5RC2 jjt */

 Pattern[0]='#'; /* 2.5.29 rri */
 Pattern[1]='?'; /* 2.5.29 rri */
 Pattern[2]=0;
}


void GetCmdFile(struct DirWindow *dw,UBYTE *name,LONG size)
{
#ifndef __amigaos4__ /* 2.7b9 rri */
sFIB *fib=(&Fib); /* 2.5b10 rri */
#endif
BPTR lock=0; /* 2.5b5 rri */

if(!name||*name==0||!(lock=Lock(name,ACCESS_READ))) /* 2.5.24 rri */
 {
  name=DMFileReq(Strap,0,FALSE); /* 2.5.27 rri */
  if(*name)
   {
    if(Strap) PoolFreeVec(Strap);
    if((Strap=PoolAllocVec(NamePool,(ULONG) (strlen(name)+10) )))
     {
      strcpy(Strap,name);
     }
    else
     {
      Strap=NULL;
      return;
     }
   }
  else
   {
    return;
   }
 }
if(lock) UnLock(lock);

if(size<=0)
 {
#ifdef __amigaos4__ /* 2.7b9 rri */
  struct ExamineData *dat;

  if(( dat = ExamineObjectTags(EX_StringName, name,
                               EX_DataFields, 0,
                               TAG_END)))
  {
   size = (int32) dat->FileSize;
   FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
  }
#else
  if(!(lock=Lock(name,ACCESS_READ))) return;
  if(Examine(lock,fib)) size=fib->fib_Size;
  UnLock(lock);
#endif
 }
if(size<=0) return;

strcpy(dcPath,name); /* 2.5.24 rri */

if(!GetGlobuff()) return;

FLAGS|=DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */

if((lock=Open(dcPath,MODE_OLDFILE))) /* 2.5.23 gcc rri */
 {
  if(dw) CmdWin=dw;
  if(Read(lock,Globuff,size)>0)
   {
    FLAGS|=DMFLAG_BATCH; /* 2.5RC2 rri */
    if(CmdWin) size=CmdWin->Number; /* 2.5RC10 rri */
    else size=254; /* 2.5RC10 rri */
    ActionCmd(size,Globuff); /* 2.5RC10 rri */
    FLAGS&=~DMFLAG_BATCH; /* 2.5RC2 rri */
    DMLayoutMenus(); /* 2.5RC10 rri */
   }
  Close(lock);
 }
FLAGS&=~DMFLAG_KEEPGLOBAL; /* 2.5RC2 rri */

/* 2.5RC10 rri */
Forbid();
if(!FindPort(DMname))
 {
  AddPort(WinPort);
 }
Permit();
}


void AutoFiler(struct DirWindow *dw,UBYTE *name)
{
BPTR fh; /* 2.5b5 rri */
int i,len2,j,k,lenB; /* 2.5b7 rri */
UBYTE *ptr,*ptr2,*ptr3;

/* 2.5RC10 rri */
strcpy(sPath,CDWin->Path); /* CDWin is always valid as either an entry was */
AddPart(sPath,name,4000);  /* double-clicked or supplied by DMRecurse... */

ResetFlags();

FLAGS|=DMFLAG_AUTOFILING; /* 2.5RC2 rri */

if(!(fh=Open(sPath,MODE_OLDFILE))) return;
lenB=Read(fh,sbuff,500); /* 2.5b7 rri */
Close(fh);

for(i=0;i<lenB;i++) /* 2.5b7 rri */
 {
  if (sbuff[i]==0)
   {
    sbuff[i]=1;
   }
 }

for(i=0;i<255;i++) /* 2.5RC6 rri */
 if((ptr=AutoCmdStr[i])) /* 2.5.23 gcc rri */
  {
   ptr2=dcPath;
   len2=0;
   *ptr2=0;

   while(*ptr&&*ptr!=',')
    {
     *ptr2++ = *ptr++;
     len2++;
    }

   ptr++;
   ptr2--;

   while(len2>0&&*ptr2<=' ') /* cut-off spaces and control-chars from the end */
    {                        /* of the pattern-string */
     ptr2--;
     len2--;
    }

   ptr2++;
   *ptr2=0;

   if(len2<=0) j=1;
   else
    {
     ParsePatternNoCase(dcPath,ReqStr,500); /* 2.5b8 rri */
     if (!(j=MatchPatternNoCase(ReqStr,sbuff))) /* 2.5b8 rri */
      {
       if(Stricmp(dcPath,"TEXT")==0) /* 2.5b7 rri */
        {
         k=lenB-1; /* 2.5b7 rri */
         while(k) if(sbuff[k--]==1) break; /* 2.5b7 rri */
         if(!k) j=1;
        }
       else if(Stricmp(dcPath,"DEFAULT")==0) j=1; /* 2.5b7 rri */
      }
    }
   ptr2=dcPath;
   len2=0;
   *ptr2=0;
   ptr3=ptr;
   while(*ptr3&&*ptr3!=',') /* 2.5b9 rri */
    {
     *ptr2++ = *ptr3++;
     len2++;
    }
   if(*ptr3==',')
    {
     ptr2--;
     ptr=ptr3+1;
     while(len2>0&&*ptr2<=' ')
      {
       ptr2--;
       len2--;
      }
     ptr2++;
     *ptr2=0;
     if(len2>0&&j)
      {
       ParsePatternNoCase(dcPath,ReqStr,500); /* 2.5b9 rri */
       j=MatchPatternNoCase(ReqStr,name);
      }
    }
   if(j)
    {
     SplitLine(ptr,dw); /* 2.5R10 rri */
     if(FLAGS&DMFLAG_RESET) return; /* 2.5RC2 rri */
     break;
    }
  }

/*
if(FLAGS&DMFLAG_RESORT)
 {
  InitDir(dw,0);
  dw->Flags|=DWFLAG_RESORT;
  ReSort();
 }
*/

/* CloseRead(); */ /* 2.5b8 jjt */
ReSort();
WinTitle(CDWin);
ResetFlags();
}


void ParseCmd1(struct DirList *dlp,UBYTE *buf)
{
UBYTE cmdnamebuffer[31]; /* 2.5b10 rri */
UBYTE *ptr=cmdnamebuffer; /* 2.5b10 rri */
int i=30, c;

/*
dlp->name = name of command
dlp->dir  = 3 - special cookie
dlp->attr = colors
dlp->cmt  = command-line itself
*/

dlp->dir=3;

while(*buf&&*buf!=','&&i--) *ptr++ = *buf++; /* copy 30 chars max */ /* 2.5RC10 rri */

*ptr-- = 0;

while(*ptr==' '||*ptr==9) *ptr--=0; /* eliminate SPACE`s/TAB`s at the end */

#ifdef __amigaos4__ /* 2.7b10 rri */
dlp->attr=0x0002;
#else
dlp->attr=0x2002; /* 2.5b12  rri */
#endif

if(*buf==',')
 {
  buf++;

  buf=SkipWhite(buf);

/* 2.5b12 rri */
  if(buf[2]==','||buf[2]==' ') /* if only two charaters follow */
   {
    c = Char2Nibble((ULONG) *buf);
    if(c>15) c=0; /* 2.5RC9 rri */
    dlp->attr=c;
    buf++;
    c = Char2Nibble((ULONG) *buf);
    if(c>15) c=0; /* 2.5RC9 rri */
    dlp->attr = (c << 4) | dlp->attr;
    buf++;
   }

  buf=SkipWhite(buf);

  if(*buf==',')
   {
    buf++;
    buf=SkipWhite(buf);
   }

  if(buf[2]==','||buf[2]==' ') /* if only two charaters follow */
   {
    #ifdef __amigaos4__ /* 2.7b10 rri - ignore the alternative set of colors */
    buf+=2;
    #else
    c = Char2Nibble((ULONG) *buf);
    if(c>15) c=0; /* 2.5RC9 rri */
    dlp->attr= (c << 8) | dlp->attr;
    buf++;
    c = Char2Nibble((ULONG) *buf);
    if(c>15) c=0; /* 2.5RC9 rri */
    dlp->attr = (c << 12) | dlp->attr;
    buf++;
    #endif
   }
  #ifndef __amigaos4__ /* 2.7b10 rri */
  else
   {
    dlp->attr=((dlp->attr&0x0f)<<12)|((dlp->attr&0x0f0)<<4)|dlp->attr; /* 0010 -> 0110 */
   }
  #endif
/* 2.5b12 rri */

  buf=SkipWhite(buf);

  if(*buf==',')
   {
    buf++;
    buf=SkipWhite(buf);
   }

  ptr=sbuff;

  i=0;

  while(*buf>10&&i<512)
   {
    *ptr++ = *buf++;
    i++;
   }
  *ptr=0;

  dlp->name = CloneStr(cmdnamebuffer, StringPool); /* 2.5rc6 rri */

  if(i)
   {
    dlp->cmt = CloneStr(sbuff, StringPool); /* 2.5rc6 rri */
   }
 }
}


void DMSet() /* 2.5b7 rri */
{
ULONG i,c,x; /* 2.5b12 */
LONG a; /* 2.5.23 rri */
STRPTR guide;  /* 2.6 jjt */

defx = GetActionArg("defx", AATYPE_NUM, 0); /* 2.5.24 rri */
defy = GetActionArg("defy", AATYPE_NUM, 0); /* 2.5.24 rri */

if (defx != 0 && defy != 0) /* 2.6 rri */ /* 2.6 jjt */
{
 DMP_UseWinScale = TRUE;
}

IconX = GetActionArg("IconX", AATYPE_NUM, NO_ICON_POSITION); /* 2.5b9 rri */
IconY = GetActionArg("IconY", AATYPE_NUM, NO_ICON_POSITION); /* 2.5b9 rri */

if (GetActionArg("notify",AATYPE_BOOL,0)) /* 2.5b9 rri */
 {
  Notify=1;
 }

if (GetActionArg("timeplus",AATYPE_BOOL,0)) /* 2.5.31 rri */
 {
  if(FLAGS & DMFLAG_TIMEPLUS) /* 2.6 rri */
   {
    FLAGS &= ~DMFLAG_TIMEPLUS;
   }
  else FLAGS |= DMFLAG_TIMEPLUS;

  ResortAll();
 }

if (GetActionArg("longcmd",AATYPE_BOOL,0)) /* 2.6 rri */
 {
  FLAGS |= DMFLAG_LONGCMD;
 }

if (GetActionArg("UserColors",AATYPE_BOOL,0)) /* 2.5b11 rri */
 {
  i=UserColors; /* old value */
  UserColors = GetActionArg("UserColors", AATYPE_NUM, 4);
  if (UserColors<4) UserColors=4; /* 2.5b11 rri */

  if(MyScreen) /* 2.5.31 rri */
   {
    if(UserColors>i) /* no problem if there are now more of it */
     {
      AllocPens();
     }
    if(UserColors<i) /* whoopie, we have to free some pens... */
     {
      for(c=UserColors;c<i;c++)
       {
        x = ( 1 << ( GetBitMapAttr(MyScreen->RastPort.BitMap,BMA_DEPTH) ) ) - 1; /* 2.5RC10 rri */
        if(c==17||c==18||c==19||                          /* protect pointer */
           c==(x-Pens20[BACKGROUNDPEN]) ||  /* cursor */ /* 2.5RC10 rri */
           c==(x-Pens20[TEXTPEN])       ||  /* and cursor over text*/ /* 2.5RC10 rri */
           c==(x-Pens20[HIGHLIGHTTEXTPEN])) /* some other pen ?? */ /* 2.5RC10 rri */
         {
          continue;
         }
        /* protect the GUI-pens: */
        for(x=0;x<49;x++) /* 2.5RC10 rri */
         {
          if(c==Pens20[x])
           {
            x=42;
            break;
           }
         }
        if(x==42)
         {
          continue;
         }
        ReleasePen(Screen->ViewPort.ColorMap,c);
       }
     }
   }
 }

i=0;

if (GetActionArg("digits",AATYPE_BOOL,0))
 {
  Base_Str_Len=10; /* 2.5b9 rri */
  digits = GetActionArg("digits", AATYPE_NUM, 5);
  if (digits<4) digits=4; /* 2.5RC10 rri */
  if (digits>9) digits=9;

  for (a=1;a<digits;a++) /* 2.5.23 rri */
   {
    Base_Str_Len*=10;
   }
  Base_Str_Len--;
  i=1; /* 2.5RC8 rri */
 }
if (GetActionArg("BPen",AATYPE_BOOL,0)) /* 2.5b12 rri */
 {
  BackPen = GetActionArg("BPen", AATYPE_NUM, (LONG) Pens20[BACKGROUNDPEN]);
  if (BackPen>28) BackPen=Pens20[BACKGROUNDPEN];
  i=1;
 }
if (GetActionArg("DPen",AATYPE_BOOL,0)) /* 2.5b12 rri */
 {
  DirPen = GetActionArg("DPen", AATYPE_NUM, (LONG) Pens20[HIGHLIGHTTEXTPEN]);
  if (DirPen>28) DirPen=Pens20[HIGHLIGHTTEXTPEN];
  i=1;
 }
if (GetActionArg("FPen",AATYPE_BOOL,0)) /* 2.5b12 rri */
 {
  FilePen = GetActionArg("FPen", AATYPE_NUM, (LONG) Pens20[TEXTPEN]);
  if (FilePen>28) FilePen=Pens20[TEXTPEN];
  i=1;
 }
if (GetActionArg("SPen",AATYPE_BOOL,0)) /* 2.5b12 rri */
 {
  SelectPen = GetActionArg("SPen", AATYPE_NUM, (LONG) Pens20[FILLPEN]);
  if (SelectPen>28) SelectPen=Pens20[FILLPEN];
  i=1;
 }
if (GetActionArg("separator",AATYPE_BOOL,0)) /* 2.5RC8 rri */
 {
  separator=(GetActionArg("separator",AATYPE_NUM,0x2e)&0x7f);
  if((separator&0x7f)<0x20) separator=0x2e;
  i=1;
 }
if (GetActionArg("sizes",AATYPE_BOOL,0)) /* 2.5RC8 rri */
 {
  sizes=GetActionArg("sizes",AATYPE_NUM,1);
  if(sizes<1 || sizes>3) sizes=1; /* 2.5.23 rri */
  i=1;
 }

if(i==1) /* 2.5b12 rri */
 {
  RefreshWindows(); /* 2.5RC8 rri */
 }

if (GetActionArg("AppIcon",AATYPE_BOOL,0)) /* 2.5b13 rri */
 {
  UBYTE *appstr;
  appstr=(UBYTE *) GetActionArg("AppIcon", AATYPE_STR, 0);

  if(appstr!=0 && *appstr !=0 ) /* 2.5.26 rri */
   {
    if(AppIconPath)
     {
      PoolFreeVec(AppIconPath);
      AppIconPath=0;
     }
    AppIconPath=CloneStr(appstr,StringPool); /* 2.5.26 rri */
    if(strlen(AppIconPath)>5 &&
       Stricmp(AppIconPath+(strlen(AppIconPath)-5),".info")==0) /* 2.5b13 rri */
        {
         AppIconPath[strlen(AppIconPath)-5]=0;
        }
   }
 }

/* SetX DragDelay */  /* 2.6 jjt */
#ifndef __amigaos4__ /* 2.7 rri - obsolete with Reaction */
i = GetActionArg("DragDelay", AATYPE_NUM, (LONG) 5);
i = (i < 3) ? 3 : (i > 9) ? 9 : i;  /* 3 < i < 9 */
drag_delay = i * 1000;
#endif

/* SetX WheelMult */  /* 2.6 jjt */
i = GetActionArg("WheelMult", AATYPE_NUM, (LONG) 3);
wheel_multiply = (i < 1) ? 1 : (i > 5) ? 5 : i;  /* 1 < i < 5 */

/* SetX Guide */  /* 2.6 jjt */
if ( (guide = (STRPTR) GetActionArg("Guide", AATYPE_STR, 0) ) )
 {
  PoolFreeVec(DiskMaster2Guide);
  DiskMaster2Guide = CloneStr(guide, StringPool);
 }

/* SetX ReqHideHelp */  /* 2.6 jjt */
if (GetActionArg("ReqHideHelp", AATYPE_BOOL, 0))
 {
  Req_ShowHelpBtn = FALSE;
 }

}


void CMD_DevList(void) {  /* 2.5b12 jjt */
  ShowDev = 0;
  if (GetActionArg("DEV", AATYPE_BOOL, 0)) ShowDev = SHOWDEV_DEV;
  if (GetActionArg("VOL", AATYPE_BOOL, 0)) ShowDev |= SHOWDEV_VOL;
  if (GetActionArg("ASN", AATYPE_BOOL, 0)) ShowDev |= SHOWDEV_ASN;
  if (ShowDev == 0) ShowDev = SHOWDEV_ALL;
  RefreshDevLists();
}


void CMD_Font(void)
{
UBYTE *fname;
ULONG idx, i, size, changed[DMFONTS_SCREEN];

memset(changed,0,sizeof (changed)); /* 2.7b9 rri */

/* --- Handle newer args --- */
for (idx=DMFONTS_MAIN; idx < DMFONTS_SCREEN; idx++)
 {
  changed[idx] = 0;  /* 2.5RC2 jjt */
  i = (LONG) GetActionArg(FontKeywords[idx], AATYPE_BOOL, 0);  /* i + 1 = font size */
  if (i)
   {
    fname = (UBYTE *) GetActionArg(FontKeywords[idx], AATYPE_STR, 0);
    if(ActionArgs[i+1]) StrToLong(ActionArgs[i+1],(LONG *) &size); /* 2.5RC10 rri */
    else size=8;
    changed[idx] = DMOpenFont(idx, fname, size);
   }
 }

/* --- Update whatever needs updating :-) --- */
if (changed[DMFONTS_MAIN]||changed[DMFONTS_DIRGAD]||changed[DMFONTS_CMDWIN]) /* 2.7 rri */
 {
  for (i=0; i<DMMAXWINDOWS; i++) /* 2.5.23 rri */
   {
    if(DirWin[i])
     {
      SetFont(DirWin[i]->Window->RPort, DMFonts[DMFONTS_MAIN]);

      /* 2.7 rri */
      if (DirWin[i]->Flags&DW_CMD)
      {
       SetGadgetAttrs(DirWin[i]->dwgad[GID_List], DirWin[i]->Window, NULL, GA_TextAttr, &DMTextAttrs[DMFONTS_CMDWIN], TAG_END,0);
      }
      else
      {
       SetGadgetAttrs(DirWin[i]->dwgad[GID_List], DirWin[i]->Window, NULL, GA_TextAttr, &DMTextAttrs[DMFONTS_MAIN], TAG_END,0);
      }
      SetGadgetAttrs(DirWin[i]->dwgad[GID_String], DirWin[i]->Window, NULL, GA_TextAttr, &DMTextAttrs[DMFONTS_DIRGAD], TAG_END,0);
      SetGadgetAttrs(DirWin[i]->dwgad[GID_BParent], DirWin[i]->Window, NULL, GA_TextAttr,&DMTextAttrs[DMFONTS_DIRGAD], TAG_END,0);
      RefreshCmdWin(DirWin[i]);
      FlushLayoutDomainCache(DirWin[i]->dwgadmain);
      RethinkLayout(DirWin[i]->dwgadmain,DirWin[i]->Window, NULL, TRUE );
     }
   }
 }

if (changed[DMFONTS_MENU])
 {
// 2.7 rri - already done in DMOpenFont()! FontToAttr(DMFonts[DMFONTS_MENU], &Menu_TAttr);
  DMLayoutMenus(); /* 2.5RC10 rri */
 }
}


void CMD_HideDev(void) {  /* 2.5b12 jjt */
  STRPTR sptr;
  ULONG  append, i, l;

  append = GetActionArg("ADD", AATYPE_BOOL, 0);
  if (append == 0) {
    /* --- Clear the list. --- */
    for (i=0; i < DevHide_Count; i++) PoolFreeVec(DevHide_List[i]);
    DevHide_Count = 0;
  }

  for (i=1; (DevHide_Count < DEVHIDELIST_MAX) && ActionArgs[i]; i++) {
    if (i != append) {
      sptr = CloneStr(ActionArgs[i], StringPool);
      if (sptr) {
        for (l = strlen(sptr) - 1; l > 0; l--) {
          /* --- Remove/end at ":" --- */
          if (sptr[l] == ':') {
            sptr[l] = 0;
            break;
          }
        }

        DevHide_List[DevHide_Count] = sptr;
        DevHide_Count++;
      }
    }
  }

  RefreshDevLists();
}


#include <datatypes/textclass.h>

void CMD_clip(void) /* 2.5.31 rri */
{
uint32 x;
struct IFFHandle *iffhndl=0;

sbuff[0] = 0;

for (x=1;ActionArgs[x];x++) /* generate string for clibboard-entry */
{
 DMstrcat(sbuff,ActionArgs[x]);
 DMstrcat(sbuff," ");
 if (strlen(sbuff) > 3000) /* limit amount of data generated */
 {
  break;
 }
}

#ifdef __amigaos4__
if (LibOpen("iffparse", &IFFParseBase, 36, (uint32) &IIFFParse)) iffhndl = AllocIFF();
#else
if (LibOpen("iffparse", &IFFParseBase, 36)) iffhndl = AllocIFF();
#endif

if (iffhndl)
 {
  if ((iffhndl->iff_Stream = (ULONG) OpenClipboard(0)))
   {
    InitIFFasClip(iffhndl);
    if(OpenIFF(iffhndl, IFFF_WRITE) == 0)
     {
      if (PushChunk(iffhndl, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN) == 0)
       {
        if (PushChunk(iffhndl, ID_FTXT, ID_CHRS, IFFSIZE_UNKNOWN) == 0)
         {
          WriteChunkBytes(iffhndl,sbuff, (uint32) strlen(sbuff) );
          PopChunk(iffhndl);
         }
        PopChunk(iffhndl);
       }
      CloseIFF(iffhndl);
     }
    CloseClipboard((struct ClipboardHandle *) iffhndl->iff_Stream);
   }
  FreeIFF(iffhndl);
 }

}


/*
void MultiSelect(int p)
{
struct DirList **dl,*dlp;
int    i=0,c=0;

dl=CDWin->DirList;
while(c<30||i<CDWin->FileCount)
 {
  dlp=dl[i++];
  if(dlp&&dlp->sel==1)
   {
    dlp->sel=0;
    c++;
    ActionArgs[p++] = dlp->name;
   }
 }
if(c)
 {
  dis_files(CDWin);
  WinTitle(CDWin);
 }
}
*/
