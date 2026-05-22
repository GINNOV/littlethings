/* DiskMaster II  command-parser
**
** 2.5.29
**
** 04-03-31 rri - Enhanced 'SetPattern' with a call to FilterStar().
**
** 2.5.31
**
** 04-10-17 rri - Fixed a warning with the GCC from the OS4 SDK.
**
** 05-03-27 rri - Added parsing for new command 'Clip'.
**
** 2.5.32
**
** 05-06-11 rri - New command 'Debug' which toggles the state of the new DMFLAG_DEBUG.
**                The purpose is to allow test-code to remain in the normal binary without
**                beeing an annoyance during everyday's use.
**
** 05-06-12 rri - Raised length of ActionBuf to 4100, just to make overflows even more unlikely.
**
** 2.6
**
** 05-06-17 jjt - ActionCmd() - Commented-out test for empty ActionArgs[1].
**                              When it's there "Add..." with no args won't open a req.
**
** 05-07-05 jjt - DoCmd() - Added "CmdReq" command.  Opens a req, and executes the input as a
**                          DM command.
**
** 05-07-17 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**
** 05-07-31 rri - Removed eight misplaced (uint32) casts for ToUpper().
**              - Raised the default values for 'OpenWindow's height, width, zoomh and zoomw options to 100.
**
** 05-08-05 rri - Bugfix: A direct 'Delete' as in "Delete ram:xx" caused an Enforcer-Hit
**              - Bugfix: A 'Find' without arguments caused an Enforcer-Hit.
**              - Bugfix: 'Rename' may have caused an Enforcer-Hit.
**
** 05-08-07 rri - Bugfix: A check for a dir-window path caused an Enforcer-Hit
**                        when there were no dir-windows.
**              - Bugifx: 'Check' caused an Enforcer-Hit when being called without
**                        arguments and no dir-windows - somewhat esoteric...
**
** 05-08-09 rri - Made sure 'Delete' only removes Assigns from the DEV/VOL/ASN list.
**
** 05-08-10 rri - Bugfix: 'Read' did not display directly given files in case
**                        the DEV/VOL/ASN list was displayed for the active window.
**                        Thanks for reporting to Lorence Lombardo!
**
** 05-08-11 rri - Removed most code for deleting files from DMRecurse()
**              - Bugfix: the FORCE-flag was not resetted so after deleting with
**                        this option subsequent moves deleted protected files.
**
** 05-08-20 jjt - DoCmd() - Added "DMPrefs" option.  Opens the DMPrefs requester.
**
** 05-11-05 jjt - DoCmd() - "HostScreen" sets DMP_UseHostScreen to TRUE.
**
** 05-11-07 jjt - DMRecurse() - Modified the call to View() (added ", NULL").
**              - DMRecurse() - Added RECURSE_SHOWA - calls ViewAsync().
**              - DoCmd() - Added "ViewA" option.  Asynchronous View.
**
** 05-11-12 jjt - DoCmd() - "NewScreen" sets DMP_UseHostScreen to FALSE.
**
** 05-11-13 jjt - DoCmd() - Replaced "ViewA" command with "Async" option.
**
** 05-11-21 jjt - Added DMREQ_HELPNODE tag to Button, CmdReq, BarFormat, SetFormat, and
**                TitleFormat requesters.
**
** 05-11-22 jjt - DoCmd() - "Confirm"'s requester has DMREQ_NOHELPBTN set.
**
** 05-11-23 jjt - Added DMREQ_HELPNODE tags to Find and Last requesters..
**
** 05-12-02 jjt - ParseArgs() - DM flags %C, %D, %N, %P, %R, and %S return quoted text.
**
** 05-12-07 jjt - Bugfix: ParseArgs() - "\" (escape char) handling was broken.
**              - Bugfix: ParseArgs() - Removed 05-12-02's uppercase flags "feature".
**              - ParseArgs() - New no-quote scheme.  %R never returns quoted text.
**
** 05-12-16 jjt - Bugfix: ParseArgs() - The "is there a next char?" test in the escape
**                char code looked ahead 1 char too far.
**              - ParseArgs() - "\ " (backslash space) results in a single backslash.
**
** 2.7
**
** 06-01-14 rri - Added struct DirInfo DInfo and initialisation
**                of it to DMSetFormat().
**
** 06-11-11 rri - Fix in DoCmd() - PrintDir() no longer needs an argument.
**
** 06-12-05 rri - Removed a line from ActionCmd() to query the state of the node - just clearing
**                the selection is easier.
** b2
**
** 06-12-09 rri - Made the 'Find' opened window a little higher and move it a little down.
**
** 06-12-10 rri - Installed and removed some test-code for 'NewDir' in DoCmd().
**              - Bugfix: changing a comment only triggered a re-sort if the sort-mode
**                        was sort-by-size -> changed that to sort-by-comment.
**                        This went unnoticed for at least three years and was found on source-level...
**              - Removed a dis_name() from ActionCmd().
**              - Added setup of DInfo.sorting to DMSetFormat().
** b3
**
** 06-12-12 rri - Redefined "Day" to "Date" and removed "Month" and "Year" options
**                in DMSetFormat().
**              - Set the bevel-image-width for the command-window "buttons" to lb->width-10.
**              - For empty command-window entries the bevel is set to it's nominal size + 4
**                to have small textless separators.
**
** 06-12-14 rri - Changed a DMFONTS_MAIN in RefreshCmdWin() to DMFONTS_CMDWIN.
**
** b4
**
** 06-12-17 rri - Fix - on 'Check' the display for the dirs was not refreshed.
**
** b6
**
** 06-12-21 rri - Set the var for LBNA_Selected in ActionCmd() to uint32.
**
** b7
**
** 07-01-02 rri - Switched from GetAttrs() to GetAttr() in RefreshCmdWin() as only one attribute
**                is required to ask for.
**
** b8
**
** 07-01-04 rri - Localised the lister-titles in DMSetFormat().
**              - Bugfix: The display-format requester can return with an empty string.
**                        Now the default "N S C" is used in such a case.
**
** 07-01-06 rri - Added a Busy(1)/Busy(0) pair to Action_Cmd() but removed it again since operations
**                also can't be cancelled then anymore.
**              - ActionCmd() sets the new flag DMFLAG_READONLY now.
**                Any lister that get's changed when the flag is set will be changed
**                to read-only by attach_list().
**                The flag is cleared and the lister are set to be selectable again
**                before ActionCmd() is left.
**
** 07-01-08 rri - RefreshCmdWin() and ActionCmd() use attach_list()/detach_list() list now.
**
** b9
**
** 07-01-21 rri - Added some experimental code to ActionCmd() to avoid jumping while processing
**                the selected entries - disabled for now again...
**
** b10
**
** 07-01-28 rri - Before going a level up or down the file-pattern is cleared now.
**
**
*/

#include "DM.h"

extern struct DirWindow *CDWin,*CmdWin,*DestWin,*DirWin[];
extern struct MsgPort *WinPort;
extern struct RexxMsg *rxMsg;
extern struct Screen *Screen,*MyScreen;
extern struct StringHistory PathHistory, CmdHistory;
extern struct TagItem reqtags_Ok[], reqtags_OkSkipCan[],  /* 2.5b13 jjt */
                      reqtags_Help[],   /* 2.6 jjt */
                      reqtags_HelpOk[], /* 2.6 jjt */
                      reqtags_HelpOkSkipCan[]; /* 2.6 jjt */
extern BPTR StdIO;

extern int   rexxErr;

extern BOOL  DMP_UseHostScreen;  /* 2.6 jjt */

extern UBYTE BarFormat[],
             dcPath[],
             DispFormat[],
             DisplayBuffer[],
             DMname[],
             g_readsearchpat[],
             Pattern[],
             PGadStr[],
             ReqStr[],
             *rexxStr,
             sbuff[],
             TitleFormat[],
             g_buttons[];  /* 2.5b10 jjt */

extern WORD  zooming[]; /* 2.5b13 rri */

extern LONG  Bar_Height, /* 2.5b13 rri */
             RexxOutstanding;

extern ULONG DWNum, /* 2.5RC10 rri */
             FLAGS, /* 2.5RC2 rri */
             NewWin_Flags; /* 2.5.23 gcc rri */

extern APTR CommentPool, /* 2.5.26 rri */
            NamePool, /* 2.5RC6 rri */
            StringPool; /* 2.5RC10 rri */

extern struct TextFont   *DMFonts[]; /* 2.7 rri */

BOOL ActionArgsUnquoted[62]; /* 2.6 jjt */

UBYTE *ActionArgs[62], /* 2.5RC10 rri */
      ActionBuf[4100], /* 2.5.32 rri */
      *command=0, /* 2.5RC10 rri */
      *DMcmt=0, /* 2.5.26 rri */
      selflagbuffer[10], /* 2.5RC2 rri */
      sPath[4096], /* 2.5RC6 rri */
      CmdReqBuf[2000]; /* 2.6 jjt */

int  PackOpt,
     RecurseDepth;

LONG BlkTotal,
     BPB,
     DirTotal;

ULONG entry_index; /* 2.5.23 rri */

struct DateStamp setStamp;
struct DirList   *WorkDlp;
struct TagItem CmdReqTags[]={{DMREQ_HISTORY, (ULONG) &CmdHistory},
                             {DMREQ_HELPNODE, (ULONG) "CmdReq"},  /* 2.6 jjt */
                             {TAG_END, 0}}; /* 2.6 jjt */


struct DirInfo DInfo; /* 2.7 rri */
void ParseArgs(UBYTE *buf); /* 2.5RC10 rri */


void DMSetFormat(UBYTE *str,UBYTE *fbuf,ULONG length)
{
  STRPTR helpnode;  /* 2.6 jjt */

if(str&&*str) DMstrncpy(fbuf,str,length); /* 2.5RC10 rri */

else
 {
  /* 2.6 jjt */
  if (fbuf == BarFormat) helpnode = "BarFormat";
  else if (fbuf == DispFormat) helpnode = "SetFormat";
  else if (fbuf == TitleFormat) helpnode = "TitleFormat";
  else helpnode = "Main";

  reqtags_Help[0].ti_Data = (LONG) helpnode;  /* 2.6 jjt */

  if(!DMReqTagList(msgReqFormat, fbuf, (ULONG) length, reqtags_Help)) return; /* 2.5b13 rri */ /* 2.6 jjt */
 }

if(fbuf==DispFormat)
 {
  /* 2.7 rri */
  UBYTE *dptr=DispFormat;
  int32 xx=0;

  if(DispFormat[0] == 0) /* 2.7b8 rri */
  {                      /* fallback in case the requester returns with an empty string */
   sprintf (DispFormat,"N S C");
  }

  while(*dptr && (xx < COLLUMNS_MAX))
   {
    switch(ToUpper(*dptr++))
     {
      case 'N': DInfo.titles[xx] = (STRPTR) msgListerName; /* 2.7b8 rri */
                DInfo.sorting[xx] = 0;
                xx++;
                break;
      case 'C': DInfo.titles[xx] = (STRPTR) msgListerComment; /* 2.7b8 rri */
                DInfo.sorting[xx] = 6;
                xx++;
                break;
      case 'S': DInfo.titles[xx] = (STRPTR) msgListerSize; /* 2.7b8 rri */
                DInfo.sorting[xx] = 2;
                xx++;
                break;
      case 'T': DInfo.titles[xx] = (STRPTR) msgListerTime; /* 2.7b8 rri */
                DInfo.sorting[xx] = 4;
                xx++;
                break;
      case 'D': DInfo.titles[xx] = (STRPTR) msgListerDate; /* 2.7b8 rri */
                DInfo.sorting[xx] = 4;
                xx++;
                break;
      case 'A': DInfo.titles[xx] = (STRPTR) msgListerFlags; /* 2.7b8 rri */
                DInfo.sorting[xx] = 0;
                xx++;
                break;
     }
   }
  DInfo.num = xx;

//  DebugPrintF("DMSetFormat() DInfo.num: %ld\n",DInfo.num); // test!

  /* 2.7 rri */

  RefreshWindows(); /* 2.5b7 rri */
 }
}


int CheckDestPath(void) /* 2.5b13 rri */
{
int i;

if(!ActionArgs[1]) return(0);

if(!ActionArgs[2])
 {
  struct TagItem checkdesttags[]={{DMREQ_HISTORY,(ULONG) &PathHistory},{TAG_MORE, 0}}; /* 2.5.26 rri */
  checkdesttags[1].ti_Data = (ULONG) reqtags_OkSkipCan; /* 2.5.26 rri */

  ActionArgs[2]=dcPath;
  dcPath[0]=0;
  if(DestWin) strcpy(dcPath,DestWin->Path);
  if(ActionArgs[1]==ActionArgs[2])
   {
    return(0);
   }
  i=DMReqTagList(msgReqDestPath, dcPath, 4000, checkdesttags); /* 2.5.26 rri */

  if (!i||i==2||!ActionArgs[2][0]) return(0); /* 2.5b13 rri */
 }

RecurseDepth=0; /* 2.5b13 rri */

return(1);
}


int addname(UBYTE *path,UBYTE *name,int len)
{
UBYTE *pt=path+len,ch;
int i=0;

if(len!=0&&(ch=path[len-1])!='/'&&ch!=':')
 {
  *pt++='/';
  ++i;
 }
 for( ; ( *pt++ = *name++ ) ; ++i ); /* 2.5.23 gcc rri */
 *pt=0;
 return len+i;
}


LONG get_blocks(long size,LONG bpb)
{
LONG data_blk,list_blk;

data_blk=(size+bpb-1)/bpb;   /* number of data blocks */
list_blk=(data_blk-1)/72;    /* number of file list blocks */
return(1+list_blk+data_blk); /* file header + list + data blocks */
}


int DMRecurse(int lenS,int lenD,int opt)
{
sFIB *info;
BPTR lock; /* 2.5b5 rri */
int  dir=0,reEx=0,i=0,
     x, /* 2.5RC10 rri */
     cpyok=1; /* 2.5b13 jjt */

if(!lenS) return(0);

if(!(lock=Lock(sPath,ACCESS_READ)))
 {
  return(0);
 }

FLAGS&=~DMFLAG_KEEPSEL; /* 2.5RC2 rri */

if(!(info=AllocDosObject(DOS_FIB,TAG_DONE) )) /* 2.5.28 rri */
 {
  FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
  goto RECERR;
 }

if(!Examine(lock,info))
 {
  FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
  goto RECERR;
 }

/* 2.5b9 rri */
if(!CDWin || !CDWin->Path[0]) /* is window showing DEVS/VOL/ASN list? */
 {
  FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
  goto RECERR;
 }

if(info->fib_DirEntryType>0&&!(FLAGS&DMFLAG_REC)&&!(FLAGS&DMFLAG_SINGLE)) /* 2.5RC2 rri */
 {
  if(lenD)
   {
    if (Stricmp(sPath,dcPath)!=0)
     {
      i=addname(dcPath,info->fib_FileName,lenD);
      if(opt==RECURSE_MOVE && (Stricmp(sPath,dcPath)!=0)) /* 2.5RC2 */
       {
        if(Rename(sPath,dcPath)) /* try to move-by-rename */
         {
          SmartAddEntry(dcPath);
          SmartRemEntry(sPath);
          UnLock(lock);
          goto EX;
         }
       }

      DMMakeDir(dcPath);
     }
   }
  if(opt==RECURSE_CHECK)
   {
    BlkTotal++;
    DirTotal++;
   }
  while(ExNext(lock,info)) /* enter next level */
   {
    RecurseDepth++;
    x=addname(sPath,info->fib_FileName,lenS); /* 2.5RC10 rri */
    ParseArgs(command); /* 2.5RC10 rri */
    if(DMRecurse(x,i,opt))
     {
      Examine(lock,info);
     }
    RecurseDepth--;
    if(CheckAbortKey()) goto RECERR;
   }
  dir=1;
 }

RECERR:

UnLock(lock);
sPath[lenS]=0;

if(FLAGS&DMFLAG_ABORT) goto EX; /* 2.5RC2 rri */

if(!(opt&3)) display(FilePart(sPath),0); /* 2.5RC10 rri */

if(!RecurseDepth||dir||DMMatch(info->fib_FileName,Pattern))
 {
  if(!dir && (opt&RECURSE_COPY))
   {
    cpyok=DMCopy(sPath,dcPath,info,opt); /* 2.5b13 rri */
   }
  if((opt==RECURSE_MOVE) && !(FLAGS&DMFLAG_ABORT) && cpyok) /* added cpyok test 2.5b13 jjt */
   {
    reEx = DMDelete(); /* 2.6 rri */
   }

  if(DMcmt) PoolFreeVec(DMcmt); /* 2.5.26 rri */
  DMcmt = CloneStr(info->fib_Comment,CommentPool); /* 2.5.26 rri */

  if((FLAGS&DMFLAG_REC)||!dir) switch(opt) /* 2.5RC2 rri */
   {
    case RECURSE_PROT: DMProtect(sPath,ActionArgs[2],info); break;
    case RECURSE_NOTE: DMComment(sPath,ActionArgs[2],info); break;
    case RECURSE_AUTO: AutoFiler(CmdWin,info->fib_FileName); break;
    case RECURSE_REN : DMRename(sPath); break;
    case RECURSE_EXEC: DOSExecute(); break;
    case RECURSE_PACK: DMPack(sPath, info, PackOpt); break; /*2.5b6 jjt */
    case RECURSE_READ: DMRead(sPath); break;  /* 2.5b6 jjt */
    case RECURSE_SHOW: View(sPath, NULL); break;  /* 2.6 jjt */
    case RECURSE_SHOWA: ViewAsync(sPath, NULL); break;  /* 2.6 jjt */
    case RECURSE_DATE: info->fib_Date.ds_Days=setStamp.ds_Days;
                       info->fib_Date.ds_Minute=setStamp.ds_Minute;
                       info->fib_Date.ds_Tick=0;
                       DMSetFileDate(sPath,info); break;
    case RECURSE_FIND:
         sprintf(sbuff,msgReqFind,info->fib_FileName); /* 2.5b13 rri */
         reqtags_HelpOkSkipCan[0].ti_Data = (LONG) "Find";  /* 2.6 jjt */
         if (DMReqTagList(sbuff, 0, 0, reqtags_HelpOkSkipCan) == 1)  /* 2.5b13 jjt */
          {
           GetParent(sPath,1);
           zooming[0]=CDWin->zoom[0];
           zooming[1]=CDWin->zoom[1];
           zooming[2]=CDWin->zoom[2];
           zooming[3]=CDWin->zoom[3];

           OpenDirWindow(sPath,CDWin->norm[0], /* 2.5b13 rri */
                               CDWin->norm[1]+40, /* 2.7 rri */
                               CDWin->norm[2],
                               160); /* 2.7 rri */
           FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
          }

         break;
    case RECURSE_CHECK: BlkTotal+=get_blocks(info->fib_Size,BPB);
                        DirTotal+=get_blocks(info->fib_Size,CDWin->BytesPerBlock); /* 2.5b5 rri */
    default: break;
   }
 }
EX:
 if(lenD) dcPath[lenD]=0;
 sPath[lenS]=0;
 if(info) FreeDosObject(DOS_FIB,info); /* 2.5.28 rri */
 return(reEx);
}


void StartRec(int type)
{
RecurseDepth=0;
if(ActionArgs[1])
 {
  DMRecurse(addname(sPath,ActionArgs[1],0),0,type);
 }
}


void DoCmd(struct DirWindow *dw)
{
struct Window *win;
int   h,l,t,w;
ULONG i,*CmdL;

if(!ActionArgs[0]) return;

StrToUpper(ActionArgs[0]); /* 2.5b7 rri */

CmdL=(ULONG *) ActionArgs[0]; /* 2.5RC10 rri */

switch(*CmdL)
 {
  case 0x41424f55: /* About */
                  About();
                  break;

 case 0x41444441: /* AddAutoCommand */
                  AddAutoCmd(ActionArgs[1]);
                  break;

  case 0x41444443: /* AddCommand */
                  AddCmd(dw,ActionArgs[1]);
                  break;

  case 0x4144444b: /* AddKeyCommand */
                  AddKeyCmd(ActionArgs[1]);
                  break;

  case 0x4144444d: /* AddMenuCommand */
                  AddMenuCmd(ActionArgs[1]);
                  if(!(FLAGS&DMFLAG_BATCH)) /* 2.5RC10 rri */
                   {
                    DMLayoutMenus();
                   }
                  break;

  case 0x41524348: /* Archiv */
                  DMArchive(ActionArgs[1],ActionArgs[2]);
                  FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                  break;

  case 0x4155544F: /* Auto */
                  if (!(FLAGS&DMFLAG_AUTOFILING)) /* 2.5RC2 rri */
                   {
                    StartRec(RECURSE_AUTO);
                   }
                  break;

  case 0x42415246: /* BarFormat */
                  DMSetFormat(ActionArgs[1],BarFormat,190);
                  break;

  case 0x42415443: /* Batch */
  case 0x4c4f4144: /* LoadConfig - Alias added in 2.5b1 */
                  GetCmdFile(dw,ActionArgs[1],0);
                  break;

  case 0x42555454:  /* Button */
                  if(!ActionArgs[1][0])
                   {
                    reqtags_Help[0].ti_Data = (LONG) "Button";  /* 2.6 jjt */
                    DMReqTagList(msgReqButton, PGadStr, 250, reqtags_Help); /* 2.5b13 rri */ /* 2.6 jjt */
                   }
                  else
                   {
                    DMstrncpy(PGadStr,ActionArgs[1],255);  /* 2.5RC10 rri */
                   }
                  break;

  case 0x43484543: /* Check */
                  if (CDWin) /* 2.6 rri */
                   {
                    CheckSpace();
                   }
                  break;

  case 0x43484743: /* ChgCmd */
                  FLAGS|=DMFLAG_CHGCMD; /* 2.5RC2 rri */
                  display(msgStatChgCmd,0); /* 2.5b13 rri */
                  break;

  case 0x43484F4F: /* Choose - 2.5b7 jjt (11.6.00) */
                   CMD_Choose(); /* 2.5b7 jjt (3.7.00) */
                   break;

  case 0x434c4950: /* Clip - 2.5.31 rri */
                   if (ActionArgs[1]) CMD_clip();
                   FLAGS|=DMFLAG_SINGLE;
                   break;

  case 0x434c4f53: /* CloseWindow */
                  if (ActionArgs[1]) StrToLong(ActionArgs[1],(LONG *)&DWNum); /* 2.5RC9 rri */
                  CloseDirWindow(DWNum);
                  break;

  case 0x434D4452: /* CmdReq */  /* 2.6 jjt */
                  if (DMReqTagList(msgReqCmdReq, CmdReqBuf, 2000, CmdReqTags))
                   {
                    ActionCmd(0, CmdReqBuf);
                   }
                  break;

  case 0x434f4c4f: /* Color */
                  SetColors();
                  break;

  case 0x434f4d4d: /* Comment */
                  StartRec(RECURSE_NOTE);
                   if(CDWin)
                    {
                     if(CDWin->Sorting==6||CDWin->Sorting==7) /* 2.7 rri */
                      {
                       FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                      }
                    }
                  break;

  case 0x434f4e46: /* Confirm */
                  if(!(FLAGS&DMFLAG_CONFIRM)&&!(FLAGS&DMFLAG_PATREQ)) /* 2.5RC2 rri */
                   {
                    struct TagItem confirmtags[]={{DMREQ_BUTTONS,(ULONG) g_buttons}, /* 2.5.26 rri */
                                                  {DMREQ_NOHELPBTN, TRUE},  /* 2.6 jjt */
                                                  {DMREQ_ABORT,0}, {TAG_END,0}};
                    h=0;
                    if(ActionArgs[4])
                     {
                      strcpy(ReqStr,ActionArgs[4]);
                      h=512;
                      rexxStr=ReqStr;
                     }
                    else rexxStr = 0; /* 2.5b10 jjt */
                    MakeBtnString(ActionArgs[2], 0, ActionArgs[3]);  /* 2.5b10 jjt */
                    DMReqTagList(ActionArgs[1], rexxStr,(ULONG) h, confirmtags); /* 2.5.26 rri */
                    if(!ActionArgs[4])
                     {
                      FLAGS|=DMFLAG_CONFIRM; /* 2.5RC2 rri */
                     }
                    }
                  if (FLAGS & DMFLAG_ABORT) rexxErr=1; /* 2.5.26 jjt */
                  break;

  case 0x434f5059: /* Copy */
                  if(!CheckDestPath()) break; /* 2.5b13 rri */
                  DMRecurse(addname(sPath,ActionArgs[1],0),addname(dcPath,ActionArgs[2],0),RECURSE_COPY);
                  FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                  FLAGS|=DMFLAG_WINTITLE; /* 2.5RC2 rri */
                  break;

  case 0x44454255: /* Debug */ /* 2.5.32 rri */
                  if(FLAGS & DMFLAG_DEBUG)
                   {
                    FLAGS &=~DMFLAG_DEBUG;
                   }
                  else FLAGS |= DMFLAG_DEBUG;
                  break;

  case 0x44454c45: /* Delete */
                  if(!CDWin || !CDWin->Path[0]) /* is window showing DEVS/VOL/ASN list? */
                   {
                    if (WorkDlp) /* argument is a selected dir-entry? */
                    {
                     if(WorkDlp->attr==DLT_DIRECTORY) /* entry is an Assign */
                      {
                       /* delete Assigns from the DEV/VOL/ASN list */
                       strcpy(sbuff,sPath);
                       sbuff[strlen(sbuff)-1]=0;
                       AssignLock(sbuff,0);
                       InitDir(CDWin,0);
                      }
                     break; /* do nothing else in DEV/VOL/ASN list */
                    }
                   }

                  FLAGS&=~DMFLAG_FORCE; /* 2.5RC2 rri */
                  if(ActionArgs[2]&&(Stricmp(ActionArgs[2],"FORCE")==0)) /* 2.5b7 rri */
                   {
                    FLAGS|=DMFLAG_FORCE; /* 2.5RC2 rri */
                   }

                  if (!WorkDlp) /* 2.6 rri */
                  {
                   if (ActionArgs[1])
                    {
                     addname(sPath,ActionArgs[1],0);
                    }
                   else
                    {
                     break; /* no target */
                    }
                  }

                  DMDelete(); /* 2.6 rri */

                  FLAGS&=~DMFLAG_FORCE; /* 2.6 rri */
                  FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                  break;

  case 0x44455345:  /* Deselect */
                  DMSelect(0);
                  break;

  case 0x4445564C:  /* DevList*/  /* 2.5b12 jjt*/
                  CMD_DevList();
                  break;

  case 0x4449524c: /* DirList */
                  if(rxMsg&&CDWin)
                   {
                    doDirList();
                   }
                  break;

  case 0x444D5052: /* DMPrefs */  /* 2.6 jjt */
                  DMPrefReq(0);
                  break;

  case 0x44555045: /* Dupe */
                  if(CDWin&&DestWin&&CDWin->Path[0]&&DestWin->Path[0]) /* 2.5RC6 rri */
                   {
                    Dupe();
                   }
                  break;

  case 0x45585041: /* Expand */ /* re-integrated with 2.5b6 rri */
                  i=DMFLAG_EXPAND;

                  if(ActionArgs[1])
                   {
                    if(ToUpper(ActionArgs[1][1])!='F') FLAGS|=i; /* 2.6 rri */
                    else FLAGS&=~i; /* 2.5RC2 rri */
                   }
                  else FLAGS^=i; /* 2.5RC2 rri */
                  break;

  case 0x45585445: /* Extern */
                  if(FLAGS&DMFLAG_LOOP) /* 2.5RC2 rri */
                   {
                    RecurseDepth=0;
                    DMRecurse(strlen(sPath),0,RECURSE_EXEC);
                   }
                  else
                   {
                    DOSExecute();
                   }
                  ReSort();
                  break;

  case 0x46494c45: /* Filestat */  /* 2.5b5 rri */
                  if (rxMsg)
                   {
                    Filestat();
                   }
                  break;

  case 0x46494e44: /* Find */
                 if(WorkDlp && WorkDlp->dir) /* 2.6 rri */
                  {
                   StartRec(RECURSE_FIND);
                  }
                 break;

  case 0x464f4e54: /* Font */
                  CMD_Font();  /* 2.5RC2 jjt */
                  break;

  case 0x47455448: /* GetHistory */  /* 2.5b11 jjt */
                  if (rxMsg) RXCMD_GetHistory();
                  break;

  case 0x47554900: /* GUI 2.5b7 rri */
                  if(ActionArgs[1])
                   {
                    Busy(1);
                   }
                  else
                   {
                    Busy(0);
                   }
                  break;

  case 0x48494445: /* HideDev */  /* 2.5b12*/
                   CMD_HideDev();
                   break;

  case 0x484f5354: /* Host */
                   GetHostScreen(ActionArgs[1]);
                   DMP_UseHostScreen = TRUE; /* 2.6 jjt */
                   break;

  case 0x49434f4e:  /* Icon */
                   if(ActionArgs[0][4]=='I') /* 2.5b7 rri */
                    {
                     Iconify();
                    }
                   else if(ActionArgs[1])
                         {
                          MakeIcon(ActionArgs[1]);
                         }
                    break;

  case 0x494e464f: /* Info */
                   if(ActionArgs[1]) InfoReq(ActionArgs[1]);
                   break;

  case 0x4c415354: /* Last */
                   if(DisplayBuffer[0])
                    {
                     reqtags_HelpOk[0].ti_Data = (LONG) "Last";  /* 2.6 jjt */
                     DMReqTagList(DisplayBuffer, 0, 0, reqtags_HelpOk); /* 2.5b13 jjt */
                    }
                   break;

  case 0x4c4f434b:  /* Lock */
                    if(!CDWin) break;
                    switch(ToUpper(ActionArgs[1][0])) /* 2.6 rri */
                     {
                      case 'S': CDWin->Flags|=DW_SOURCE;
                                CDWin->Flags&=~DW_DEST;
                                ShowDirection(CDWin,0);
                                break;
                      case 'D': CDWin->Flags|=DW_DEST;
                                CDWin->Flags&=~DW_SOURCE;
                                ShowDirection(CDWin,1);
                                break;
                     }
                    break;

  case 0x4d414b45: /* MakeDir */
                   DMMakeDir(ActionArgs[1]);
                   FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                   break;

  case 0x4d4f5645: /* Move */
                   if(!CheckDestPath()) break; /* 2.5b13 rri */
                   DMRecurse(addname(sPath,ActionArgs[1],0),addname(dcPath,ActionArgs[2],0),RECURSE_MOVE);
                   FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                   break;

  case 0x4d534700: /* Msg */
                   display(ActionArgs[1],ActionArgs[2]);
                   break;

  case 0x4e455744: /* NewDir */
                   if(CDWin)
                    {
                     if(ActionArgs[1])
                      {
                       CloneBuffer(CDWin,ActionArgs[1]); /* 2.5RC6 rri */
                       CDWin->Pattern[0]=0;
                       if(FindPattern(CDWin->Path))
                        {
                         Separate(CDWin);
                        }
                      }
                     else
                      {
                       CloneBuffer(CDWin,0); /* 2.5RC6 rri */
                      }
                     InitDir(CDWin,0);
                    }
                   break;

  case 0x4e455753: /* NewScreen */
                   if(!MyScreen) MyScreen=NewOpenScreen(1,DMname);
                   if(MyScreen)
                    {
                     Screen=MyScreen;
                     DMP_UseHostScreen = FALSE; /* 2.6 jjt */
                    }
                   break;

  case 0x4f50454e: /* OpenWindow */
                   RefreshCmdWin(dw);
                   if(ActionArgs[0][4]=='W')
                    {
                     /* 2.5RC4 rri */

                     UBYTE *ptr;

                     l=GetActionArg("LEFT", AATYPE_NUM, 0);
                     t=GetActionArg("TOP", AATYPE_NUM, 11);
                     w=GetActionArg("WIDTH", AATYPE_NUM, 100);
                     h=GetActionArg("HEIGHT", AATYPE_NUM, 100);

                     zooming[0]=GetActionArg("ZOOML", AATYPE_NUM, (LONG) l);
                     zooming[1]=GetActionArg("ZOOMT", AATYPE_NUM, (LONG) t);
                     zooming[2]=GetActionArg("ZOOMW", AATYPE_NUM, 100);
                     zooming[3]=GetActionArg("ZOOMH", AATYPE_NUM, 100);

                     if (GetActionArg("NODRAG",AATYPE_BOOL,0))
                      {
                       NewWin_Flags&= ~WFLG_DRAGBAR; /* 2.5.23 gcc rri */
                      }

                     if (GetActionArg("NOCLOSE",AATYPE_BOOL,0))
                      {
                       NewWin_Flags&= ~WFLG_CLOSEGADGET; /* 2.5.23 gcc rri */
                      }

                     ptr=(STRPTR) GetActionArg("PATH",AATYPE_STR,0);
                     if(ptr&&*ptr=='"') /* get rid of quotes around path */
                      { /* 2.5RC4 rri */
                       ptr++;
                       ptr[strlen(ptr)-1]=0;
                      }

                     if((i=GetActionArg("CMD",AATYPE_BOOL,0))) /* 2.5.23 gcc rri */
                      {
                       ptr=ActionArgs[i];
                      }

                     OpenDirWindow(ptr,l,t,w,h);

                     if (GetActionArg("ZOOMED",AATYPE_BOOL,0))
                      {
                       ZipWindow(CDWin->Window);
                      }

                     NewWin_Flags|=WFLG_DRAGBAR; /* 2.5.23 gcc rri */
                     NewWin_Flags|=WFLG_CLOSEGADGET; /* 2.5.23 gcc rri */
                    }
                   break;

  case 0x5041434B: /* PACK */
                   PackOpt=1;

  case 0x554E5041: /* UNPACK */
                   if(!ActionArgs[1]) break;
                   RecurseDepth=0;
                   if (!AArg2Str("TO", dcPath, 512, FALSE, sPath)) /* 2.5b6 jjt */
                    {
                     if (DMReqTagList(msgReqDestPath, dcPath, 512, reqtags_OkSkipCan) != 1) break;  /* 2.5b13 jjt */
                    }                                                                               /* 2.5b6 jjt */
                   DMRecurse(addname(sPath, ActionArgs[1], 0), 0, RECURSE_PACK);  /* 2.5b6 jjt */
                   PackOpt=0;
                   break;

  case 0x50415245: /* Parent */
                   /* 2.5RC6 rri */
                   if(CDWin&&CDWin->Path[0])
                    {
                     CDWin->Pattern[0] = 0; /* 2.7b10 rri - clear filter-pattern on destination */
                     strcpy(sbuff,CDWin->Path);
                     GetParent(sbuff,1);
                     CloneBuffer(CDWin,sbuff); /* 2.5RC6 rri */
                     InitDir(CDWin,0);
                    }
                   break;

  case 0x50454e53: /* Pens */
                   SetPens();
                   break;

  case 0x5052494e: /* PrintDir */
                   if(ToUpper(ActionArgs[0][5])=='D') /* 2.6 rri */
                    {
                     if(!CDWin) /* 2.7 rri */
                      {
                       FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
                       break;
                      }
                     PrintDir(); /* 2.5b9 rri */
                    }
                   break;

  case 0x50524f54: /* Protect */
                   StartRec(RECURSE_PROT);
                   break;

  case 0x51554945: /* Quiet */ /* 2.5b5 rri */
                   FLAGS|=DMFLAG_QUIET; /* 2.5RC2 rri */
                   break;

  case 0x51554954: /* Quit */
                   if(RexxOutstanding)
                    {
                     sprintf(sbuff,msgErrorArexx,RexxOutstanding);
                     DMReqTagList(sbuff, 0, 0, reqtags_Ok); /* 2.5b13 jjt */
                    }
                   else
                    {
                     FLAGS&=~DMFLAG_KEEPGOING; /* 2.5RC2 rri */
                    }
                   break;

  case 0x52454144: /* Read */
                   if(WorkDlp) /* target is a selected dir-entry */ /* 2.6 rri */
                    {
                     StartRec(RECURSE_READ);
                    }
                   else /* target is some directly given file */ /* 2.6 rri */
                    {
                     if(ActionArgs[1])
                      {
                       DMRead(ActionArgs[1]);
                      }
                    }
                   break;

  case 0x52454355: /* Recurse */
                   if(ToUpper(ActionArgs[1][1])=='F') FLAGS|=DMFLAG_REC; /* 2.6 rri */
                   else FLAGS&=~DMFLAG_REC; /* 2.5RC2 rri */
                   break;

  case 0x52454e41: /* Rename */
                   if ((FLAGS&DMFLAG_REC) && WorkDlp &&WorkDlp->dir==2&&WorkDlp->attr==DLT_VOLUME) /* 2.6 rri */
                    {
                     if (DMRelabel(WorkDlp->name,ActionArgs[1],ActionArgs[2]))
                      {
                       InitDir(CDWin,0);
                      } /* if (DMRelabel... */
                    } /* if (WorkDlp... */
                   else StartRec(RECURSE_REN);
                   FLAGS|=DMFLAG_RESORT; /* 2.5RC2 rri */
                   break;

  case 0x52455150: /* ReqPattern */
                   DMReqPat();
                   break;

  case 0x52455345: /* RESET */
                   FreeUserData(); /* 2.5RC10 rri */
                   return; /* 2.5RC2 rri */

  case 0x52455858: /* REXX */
                   SendRexx();
                   break;

  case 0x524f4f54: /* Root */
                   /* 2.5RC6 rri */
                   if(CDWin&&CDWin->Path[0])
                    {
                     dw->Pattern[0] = 0; /* 2.7b10 rri - clear filter-pattern on destination */
                     strcpy(sbuff,CDWin->Path);
                     GetParent(sbuff,0);
                     CloneBuffer(CDWin,sbuff); /* 2.5RC6 rri */
                     InitDir(CDWin,0);
                    }
                   break;

  case 0x53415645: /* Save */
                   SaveConfig();
                   break;

  case 0x53435242: /* Screen2Back */
                   WBenchToFront();
                   break;

  case 0x53435246: /* Screen2Front */
                   ScreenToFront(Screen);
                   break;

  case 0x53454c45: /* Select */
                   DMSelect(1);
                   break;

  case 0x53455444: /* SetDate */
                   DMSetDate();
                   break;

  case 0x5345544c: /* SetList */
                   if(rxMsg&&CDWin) doSetList(ActionArgs[1]);
                   break;

  case 0x53455446: /* SetFormat */
                   DMSetFormat(ActionArgs[1],DispFormat,20); /* 2.5RC10 rri */
                   break;

  case 0x53455450: /* SetPattern */
                   FLAGS|=DMFLAG_PATREQ; /* 2.5RC2 rri */
                   if(ActionArgs[1]) /* 2.5.29 rri */
                    {
                     UBYTE *patternbuffer;

                     if(( patternbuffer = FilterStar(ActionArgs[1]) ))
                      {
                       DMstrncpy(Pattern,patternbuffer,63);
                       PoolFreeVec(patternbuffer);
                      }
                    }
                   else Pattern[0]=0;
                   break;

  case 0x53455458: /* SetX */ /* 2.5b7 rri */
                   DMSet();
                   break;

  case 0x53494e47: /* Single */
                   FLAGS|=DMFLAG_SINGLE; /* 2.5RC2 rri */
                   break;

  case 0x534f5254: /* Sort */
                   if (ActionArgs[1]) Sort();
                   break;

  case 0x53544154: /* Status */
                   RexxStatus();
                   break;

  case 0x53544449: /* Stdio */
                   DoStdio(ActionArgs[1]);
                   break;

  case 0x53574150: /* Swap */
                   if(ActionArgs[0][4]=='S')
                    {
                     if (CDWin&&CDWin->Path[0]) SwapSelect();
                    }
                   else DoSwap();
                   break;

/* test! added 2003-04-21 rri
  case 0x54455354: // Test
                   i=0;
                   if(CmdWin)
                    {
                     while(i<CmdWin->FileCount)
                     {
                      if(CmdWin->DirList[i]->cmt)
                       {
                        kprintf("%s\n",CmdWin->DirList[i]->cmt);
                       }
                      i++;
                     }
                    }
                   kprintf("\n");
                   break;
*/
  case 0x5449544C: /* TitleFormat */
                   DMSetFormat(ActionArgs[1],TitleFormat,50); /* 2.4b19 rri */
                   break;

  case 0x554e4c4f: /* UnLock */
                   if(ActionArgs[1]&&ActionArgs[1][0]) UnLockAll(); /* 2.5RC10 rri */
                   else if(CDWin)
                         {
                          CDWin->Flags&=~(DW_DEST|DW_SOURCE);
                          ShowDirection(CDWin,0);
                         }
                   break;

  case 0x554e4d41: /* UnMark */
                   if(ActionArgs[1]&&(Stricmp(ActionArgs[1],"OFF")==0)) FLAGS|=DMFLAG_UNMARK; /* 2.5RC2 rri */
                   else FLAGS&=~DMFLAG_UNMARK; /* 2.5RC2 rri */
                   break;

  case 0x56494557: /* View */ /* 2.4 rri */
                   StartRec(GetActionArg("ASYNC", AATYPE_BOOL, 0) ? RECURSE_SHOWA : RECURSE_SHOW);  /* 2.6 jjt */
                   break;

  case 0x57414954: /* Wait */
                   {
                    LONG delay_time=0; /* 2.5.31 rri */

                    if (ActionArgs[1]) StrToLong(ActionArgs[1], &delay_time); /* 2.5RC10 rri */
                    if(delay_time)
                     {
                      Delay(delay_time * 50); /* 2.5b10 rri */
                     }
                    else if(StdIO)
                          {
                           if(!ActionArgs[1])
                            {
                             strcpy(sbuff,msgStatWait); /* 2.5b13 rri */
                             ActionArgs[1]=sbuff;  /* 2.5b13 rri */
                            }
                           Write(StdIO,ActionArgs[1],(LONG)strlen(ActionArgs[1])); /* 2.5b10 rri */
                           Read(StdIO,sbuff,1); /* 2.5b10 rri */
                          }
                         else WaitPort(WinPort);
                   }
                   break;

  case 0x57494e44: /* Window */
                   win=0;
                   if(!ActionArgs[1])
                    {
                     rexxErr=1;
                     break;
                    }
                   if(Stricmp(ActionArgs[1],"DEST")==0) /* 2.5b7 rri */
                    {
                     win=DestWin->Window;
                    }
                   else if(Stricmp(ActionArgs[1],"NEXT")==0) /* 2.5b7 rri */
                    {
                     i=DWNum+1; /* 2.5.23 gcc rri */
                     while(i!=DWNum) /* 2.5.23 gcc rri */
                      {
                       if(DirWin[i]&&!(DirWin[i]->Flags&DW_CMD)) /* 2.5.23 gcc rri */
                        {
                         win=DirWin[i]->Window; /* 2.5.23 gcc rri */
                         break;
                        }
                       i++; /* 2.5.23 gcc rri */
                       if(i>=DMMAXWINDOWS) i=0; /* 2.5.23 rri */
                      }
                    }
                   else for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
                    {
                     if(DirWin[i]) if(Stricmp(DirWin[i]->Path,ActionArgs[1])==0) /* 2.5.23 gcc rri */
                      {
                       win=DirWin[i]->Window; /* 2.5.23 gcc rri */
                       break;
                      }
                    }
                   if(win)
                    {
                     ActivateWindow(win);
                     FindDMWin(win); /* 2.5b6 rri */
                    }
                   else rexxErr=1;
                   break;

  case 0x57494e49: /* WinInfo */ /* 2.5b5 rri */
                   if (rxMsg)
                    {
                     WinInfo();
                    }
                   break;
 }
}


void RefreshCmdWin(struct DirWindow *dw)
{
 if(dw && (dw->Flags&DW_CMD) && (dw->Flags&DWFLAG_ADD))
 {
  CmdWin=dw;
  NewSize(dw);
  FindNewDirection(dw);
  ShowDirection(dw,2);
  dw->Flags&=~DWFLAG_ADD;
 }

 if (dw && dw->Flags&DW_CMD) /* 2.7 rri */
 {
  struct DirList **dl,*dlp;
  struct Image *cmd_button;
  uint32 size;
  int32 i;

  dl=dw->DirList;

  detach_list(dw); /* 2.7b8 rri */

  for(i=0;i < dw->FileCount;i++)
  {
   dlp=dl[i];
   size = DMFonts[DMFONTS_CMDWIN]->tf_YSize;

   GetListBrowserNodeAttrs(dlp->node, LBNCA_Image, (ULONG *)(void *) &cmd_button, TAG_DONE,0);

   if (!dlp->name) /* this is no entry, this is a separation-bar */
   {
    GetAttr(BEVEL_VertSize,cmd_button, &size); /* 2.7b7 rri */
   }
   SetAttrs(cmd_button, IA_Width, dw->dwgad[GID_List]->Width - 10,
                        IA_Height, size + 4,
                        TAG_END,0);
  }
 attach_list(dw,TRUE); /* 2.7b8 rri */
 }
}


ULONG MakePath(UBYTE *path, UBYTE *dest) /* 2.5RC3 jjt */
{
ULONG l, c;

/* Add "/" if necessary. */
strcpy(dest, path);
if ((l = strlen(dest)))
 {
  c = dest[l - 1];
  if ((c != ':') && (c != '/'))
   {
    dest[l++] = '/';
    dest[l] = 0;
   }
 }
return l;
}


void ParseArgs(UBYTE *buf) /* 2.5RC3 jjt */
{
BOOL  upperflag; /* 2.6 jjt */
UBYTE *aptr, *insptr, c;
ULONG aaidx, spcflg, qflg, l;

for (aaidx = 0; aaidx < 61; aaidx++)
{
  ActionArgs[aaidx] = NULL;
  ActionArgsUnquoted[aaidx] = FALSE;  /* 2.6 jjt */
}
aptr = ActionBuf;
aaidx = 0;
qflg = 0;
spcflg = 1;

do
 {
  c = *buf++;

  if (c&&!qflg) /* If not inside quoted text... */
   {
    if ((c <= 32) || (c == ',')) /* Skip spaces & chars of lesser ASCII value */
     {
      spcflg = 1;
      continue;
     }
   }
  if (spcflg)                    /* A space was encountered...              */
   {
    if (aaidx) *aptr++ = 0;      /* end the current ActionArg...            */
    ActionArgs[aaidx++] = aptr;  /* and set the addr of the next ActionArg. */
    spcflg = 0;
   }
  if (c == '\"') /* Found a quote. */
   {
    qflg ^= 1;
    continue;
   }
  if ((c == '^') && qflg) /* DMFlag inside quoted text, maybe. */
   {
    if (*buf == '%')
     {
      buf++;
      goto dmflag;
     }
   }
  if ((c == '%' && !qflg)) /* DMFlag, maybe. */
   {
    dmflag:

    insptr = NULL;  /* Points to text to insert into ActionBuf. */
    c = *buf++;
    upperflag = (c & 32) == 0;  /* Is flag uppercase? */ /* 2.6 jjt */
    c = ToUpper(c); /* 2.6 rri */
    switch (c)
     {
      case 'A': /* DM Port/Screen/Task name. */
                insptr = DMname;
                break;
      case 'B': /* No. of selected items. */
                if (CDWin)
                 {
                  /* stcl_d(selflagbuffer, CDWin->Sels); */
                  sprintf(selflagbuffer,"%ld",CDWin->Sels); /* 2.5.23 gcc rri */
                  insptr = selflagbuffer;
                 }
                break;
      case 'C': /* Selected item's comment. */ /* 2.5.26 */
                insptr = DMcmt;
                FLAGS|=DMFLAG_LOOP;
                break;
      case 'D': /* Dest dir. */
                if (DestWin&&DestWin->Path[0]) /* 2.5RC11 */
                 {
                  insptr = dcPath; /* 2.5RC10 rri */
                 }
                else FLAGS |= DMFLAG_ABORT;
                break;
      case 'N': /* Selected item's name. */
                if (CDWin)
                 {
                  /* create filename relative to current path */
                  insptr = sPath+strlen(CDWin->Path); /* 2.5RC10 rri */
                  if (*insptr == '/') insptr++; /* 2.5RC10 rri */
                  FLAGS|=DMFLAG_LOOP;
                 }
                else FLAGS|=DMFLAG_ABORT;
                break;
      case 'P': /* Source path. */
                if (CDWin&&CDWin->Path[0]) /* 2.5RC10 rri */
                 {
                  insptr = CDWin->Path;
                 }
                else FLAGS|=DMFLAG_ABORT;
                break;
      case 'R': /* Req. text. */
                insptr = ReqStr;
                if (upperflag) /* 2.6 jjt */
                {
                  ActionArgsUnquoted[aaidx-1] = TRUE;
                }
                break;
      case 'S': /* Full path of selected item */
                if (CDWin)
                 {
                  insptr = sPath;
                  FLAGS|=DMFLAG_LOOP;
                 }
                else FLAGS|=DMFLAG_ABORT;
                break;
      default:  buf--;  /* Not a flag, let the parser have it again. */
                if (qflg) *aptr++ = '^'; /* 2.5RC3 jjt */
                *aptr++ = '%';           /* 2.5RC3 jjt */
     }

    if (insptr && (l = strlen(insptr)))
     {
      /* Insert text into ActionBuf. */
      strcpy(aptr, insptr);
      aptr += l;
     }
    continue;
   }
  if (c == '\\') /* Escape char. */
   {
    if (*buf) /* Test that this isn't the end of the string */ /* 2.7 jjt */
     {
      c = *buf++;
      if (ToUpper(c) == 'N') /* The user wants a LF. */
       {
        c = 10;
       }
      else if (c == ' ') /* backslash space = backslash */ /* 2.7 jjt */
       {
        c = '\\';
       }
     }
   }
  *aptr++ = c;  /* Store char in ActionBuf. */
 } while (c);
}


/* split command-line into single commands */
void SplitLine(UBYTE *buf,struct DirWindow *dw) /* 2.5RC10 rri */
{
UBYTE c;
LONG n;
ULONG i,t,qflg;

if(command)
 {
  PoolFreeVec(command);
  command=0;
 }

i=0;

while(buf[i])
 {
  c=buf[i];

  if ((c <= 32)||(c==',')||(c==';')) /* Skip spaces, chars of lesser ASCII value, and commas. */
   {
    i++;
    continue;
   }

  n = CharPos(';',buf+i);
  t=0;

  if (n != -1) /* we have more than one command in this line */
   {
    qflg=0;
    while((c=buf[i+t])) /* find next ';' out of quotes */ /* 2.5.23 gcc rri */
     {
      if(c=='"')
       {
        qflg ^= 1;
        t++;
        continue;
       }
      if(c==';' && !qflg)
       {
        break;
       }
      t++;
     }
    if(qflg) /* only single quote - command invalid, cancel execution */
     {
      return;
     }
    if((command=PoolAllocVec(StringPool,(ULONG) t+2))) /* 2.5.23 gcc rri */
     {
      DMstrncpy(command,buf+i,(ULONG) t+1); /* DMstrncpy() 0-terminates! */
      if(command[t]==';') command[t]=0; /* line ends with "xxx;" ! */
     }
   }
  else /* single command, empty line or end of line */
   {
    if(c)
     {
      if((command=PoolAllocVec(StringPool,(ULONG) strlen(buf+i)+2))) /* 2.5.23 gcc rri */
       {
        DMstrncpy(command,&buf[i],(ULONG) strlen(buf+i)+1); /* DMstrncpy() 0-terminates! */
       }
     }
   }
  if(command) /* execute comand */
   {
    *ActionBuf=0;
    if (DestWin && !(FLAGS&DMFLAG_BATCH))
     {
      MakePath(DestWin->Path,dcPath);
     }
    ParseArgs(command);
    if (*ActionBuf && !(FLAGS & DMFLAG_ABORT))
     {
      DoCmd(dw);
      dw=CmdWin;
     }

    PoolFreeVec(command);
    command=0;
   }

  if(n != -1) /* we have more than one command in this line */
   {
    i += t;
    continue;
   }
  else        /* single command, empty line or end of line */
   {
    break;
   }
 }

if(command)
 {
  PoolFreeVec(command);
  command=0;
 }
}


void ActionCmd(ULONG num,UBYTE *buf) /* 2.5RC10 rri */
{
struct DirWindow *dw2;
struct DirList **dl,*dlp=0;
UBYTE xx,*ptr,*cmdline=0; /* 2.5.23 rri */
ULONG c,loop,dloop,destlocked,j;
LONG item/*,i*/; /* 2.5.23 gcc rri */
uint32 selectstate; /* 2.7 rri */

if(!buf) return;

ResetFlags();
rexxStr=0;
ReqStr[0]=0;

FLAGS&=~DMFLAG_KEEPSEL; /* 2.5RC2 rri */
FLAGS&=~DMFLAG_SKIP; /* 2.5RC2 rri */

ptr=buf;

/* 2.7b8 rri - make all listers read only */
/*
for(j=0;j<DMMAXWINDOWS;j++)
{
 dw2=DirWin[j];
 if(dw2&&!(dw2->Flags&DW_CMD))
 {
  SetGadgetAttrs(dw2->dwgad[GID_List], dw2->Window, NULL, GA_ReadOnly, TRUE, TAG_END,0);
 }
}
*/
FLAGS |= DMFLAG_READONLY; /* all listers that are changed after this will be
                             changed to read-only by attach_list() */

/* reworked and rewritten in 2.5RC10 rri */
c=0;
while(*ptr)
 {
  while(ptr[c]&&ptr[c]!=10) c++; /* seek end of line */

  if(*ptr!=';') /* ignore comments */
   {
    if(ToUpper(ptr[0])=='A'&&ToUpper(ptr[1])=='D') /* "Add..." */ /* 2.6 rri */
     {
      /* we need to split this into two strings */
      j=0;
      while(ptr[j]>' ')         /* copy all chars upto next space/tab/endline */
       {
        ActionBuf[j]=ptr[j];
        j++;
       }
      ActionBuf[j]=0;                /* 0-terminate */
      ActionArgs[0]=ActionBuf;       /* set to start of ActionBuf[] */
      j++;                           /* skip next char */
      ActionBuf[j]=0;                /* possible empty command */
      ActionArgs[1] = &ActionBuf[j]; /* set to address of ActionBuf[k] */
      while(ptr[j]&&j<c&&j<2040)     /* copy rest of line or 2040 chars max */
       {
        ActionBuf[j]=ptr[j];
        j++;
       }
      ActionBuf[j]=0;                /* 0-terminate */
/* 2.6 jjt
  When the following code is uncommented, then "Add..." with no args will not open
  a req. prompting for the cmd, menu, key, whatever.

  2.6 rri
  Removing this was indeed correct as this code has been added by mistake.
  Although this code may have been added to solve an Enforcer-Hit elsewhere...

*/
/*
      if(ActionArgs[1][0]==0)        // in case ActionArgs[1] ended up empty
       {                             // fill it with one space
        ActionArgs[1][0]=0x20;
        ActionArgs[1][1]=0;
       }
*/
      DoCmd(DirWin[num]);            /* execute command-line */
      if(CmdWin) num=CmdWin->Number;
      else num=254;
     }


    else /* normal operation */
     {
      if((cmdline=PoolAllocVec(StringPool,(ULONG) c+2))) /* 2.5.23 gcc rri */
       {
        DMstrncpy(cmdline,ptr,(ULONG) c+1); /* DMstrncpy() 0-terminates! */

        loop=0;
        dloop=0;
        destlocked=0;
        BlkTotal=0;
        item=0;
        j=0;

        while(cmdline[j])      /* check for flags */
         {
          /* make sure flag is outside of quotes - !BarFormat/!TitleFormat ... */
          if(cmdline[j]=='"') item=~item;
          /* ...or with a leading "^" - 2.5.26 rri */
          if(cmdline[j]=='%' && (cmdline[j-1]=='^'||item==0))
           {
            xx=ToUpper(cmdline[j+1]); /* 2.6 rri */
            if(xx=='D') dloop=1;
            if(xx=='S'||xx=='N'||xx=='C') loop=1; /* 2.5.26 rri */
           }
          j++;
         }
        item=0;

        if(loop) /* init CDWin as first source-window with files selected */
         {
          for(j=0;j<DMMAXWINDOWS;j++) /* 2.5.23 rri */
           {
            dw2=DirWin[j];
            if(dw2&&(dw2->Flags&DW_SOURCE)&&dw2->Sels)
             {
              CDWin=dw2;
              break;
             }
           }
         }

        sPath[0]=0;

        NEXTLOOP:      /* handle all selected entries in all source-dirs */

        if(CDWin&&CDWin->Path[0]) strcpy(sPath,CDWin->Path);

        DirTotal=0;

        if(loop)
         {
          if(!CDWin||CDWin->Flags&DW_DEST) /* stop execution in case there is no */
           {                               /* current dir-window with files      */
            if(cmdline) PoolFreeVec(cmdline);

            /* 2.7b8 rri - reset all listers to be selectable again */
            FLAGS &=~DMFLAG_READONLY;
            for(j=0;j<DMMAXWINDOWS;j++)
            {
             dw2=DirWin[j];
             if(dw2)
             {
              SetGadgetAttrs(dw2->dwgad[GID_List], dw2->Window, NULL, GA_ReadOnly, FALSE, TAG_END,0);
             }
            }

            return;                        /* selected or it's a dest-window     */
           }

          dl=CDWin->DirList;           /* traverse file-list to find next */
          while(item<CDWin->FileCount) /* selected entry and generate     */
           {                           /* full path to it in sPath        */
            dlp=dl[item];
            GetListBrowserNodeAttrs(dlp->node, LBNA_Selected, &selectstate, TAG_DONE, 0); /* 2.7 rri */

            if(selectstate != 0) /* 2.7 rri */
             {
              #if 0 // experimental code to avoid listview-jumping

              #ifdef __amigaos4__
              if (1)
              {
               uint32 bla,troet,fish,lb_top,lb_top2,lb_visible,lb_total;

               GetAttrs(CDWin->dwgad[GID_List], LISTBROWSER_Top, &lb_top,
                                      LISTBROWSER_VPropTotal, &lb_total,
                                      LISTBROWSER_VPropTop, &lb_top2,
                                      LISTBROWSER_VPropVisible, &lb_visible,
                                      TAG_END,0);

               bla = lb_total / CDWin->FileCount; // height of one entry
               if (lb_visible < lb_total) // more than one page
               {
                troet = bla * item; // position of file in list
                if (troet < lb_top2) // file on top of display?
                {
                 fish = item;
                 SetGadgetAttrs(CDWin->dwgad[GID_List], CDWin->Window, NULL, LISTBROWSER_Top, fish, TAG_END,0); /* 2.7 rri */
                }
                else if ((troet+bla) > (lb_top2+lb_visible) ) // file below display?
                {
                 fish = ((lb_top2 + (troet - (lb_top2 + lb_visible))) / bla) + 2;
                 SetGadgetAttrs(CDWin->dwgad[GID_List], CDWin->Window, NULL, LISTBROWSER_Top, fish, TAG_END,0); /* 2.7 rri */
                 Printf("item: %ld max: %ld top: %ld top2: %ld total: %ld visible: %ld "
                        "height: %ld position: %ld newtop: %ld\n",
                        item,CDWin->FileCount,lb_top,lb_top2,lb_total,lb_visible,bla,troet,fish);
                }

               }
              }
              #else
              GetAttr(LISTBROWSER_Top,CDWin->dwgad[GID_List], &lb_top);
              #endif

              #endif

              SetGadgetAttrs(CDWin->dwgad[GID_List], CDWin->Window, NULL, LISTBROWSER_MakeVisible, item, TAG_END,0); /* 2.7 rri */
//              while(item>(CDWin->Index+CDWin->Rows-1)) /* scroll down to entry */
//               {
//                Increment(CDWin,&CDWin->dn,(item-CDWin->Rows-CDWin->Index));
//               }
              AddPart(sPath,dlp->name, 4000);
              if(DMcmt) PoolFreeVec(DMcmt); /* 2.5.26 rri */
              DMcmt = CloneStr(dlp->cmt,CommentPool); /* 2.5.26 rri */
              break;
             }
            item++;
           }

          if(item>=CDWin->FileCount) /* end of file-list for current source-dir? */
           {
            CDWin->Sels=0;
            for(j=0;j<DMMAXWINDOWS;j++)  /* check if there is annother source-dir with */ /* 2.5.23 rri */
             {                           /* entries selected and make this CDWin       */
              dw2=DirWin[j];
              if(dw2&&(dw2->Flags&DW_SOURCE)&&dw2->Sels)
               {
                CDWin=dw2;
                item=0;
                goto NEXTLOOP; /* source-dir found, let's traverse this one */
               }
             }
            goto NEXTLINE; /* no more selected entries, let's start over ?? */
           }
         }
        WorkDlp=dlp;      /* make current source-entry globally available */
        entry_index=item;  /* 2.5.23 rri */ /* source-entry position global */

        if(CheckAbortKey())
         {
          rexxErr=1;
          FLAGS&=~DMFLAG_ABORT;
          display(msgStatAborted,0);
          break;
         }

        if(dloop) /* handle all dest-windows */
         {
          for(j=0;j<DMMAXWINDOWS;j++) /* 2.5.23 rri */
           {
            dw2=DirWin[j];
            if(dw2&&(dw2->Flags&DW_DEST))
             {
              DestWin=dw2;
              destlocked=1;
              SplitLine(cmdline,DirWin[num]);
              if(CmdWin) num=CmdWin->Number;
              else num=254;
              if(CheckAbortKey())
               {
                rexxErr=1;
                FLAGS&=~DMFLAG_ABORT;
                display(msgStatAborted,0);
                goto DIE;  /* we have to drop out of two loops at once... */
               }
/* why again? if(CDWin&&dlp->sel==1) AddPart(sPath,dlp->name, 4000); */
             }
           }
         }
        if(!destlocked) /* no flags/no dest operation */
         {
          SplitLine(cmdline,DirWin[num]);
          if(CmdWin) num=CmdWin->Number;
          else num=254;
         }

        if(loop&&CDWin&&dlp)        /* we care for all selected source-entries */
         {
          if(DirTotal&&dlp->dir==1)
           {
            dlp->size=DirTotal;
            update_entry(CDWin,dlp); /* 2.7 rri */
           }

          if(item<CDWin->FileCount && !(FLAGS&DMFLAG_UNMARK)&&!(FLAGS&DMFLAG_KEEPSEL)) /* 2.7 rri */
           {
            detach_list(CDWin);
            SetListBrowserNodeAttrs(dlp->node, LBNA_Selected, FALSE, TAG_DONE, 0); /* 2.7 rri */
            attach_list(CDWin,FALSE);
           }

          FLAGS|=DMFLAG_WINTITLE;    /* we have to refresh the window-title */
          dlp=0;
          if(!(FLAGS&DMFLAG_SINGLE))
           {
            item++;
            goto NEXTLOOP;  /* insert coin, try with next source-entry */
           }
         }
       }
     }
   }

  NEXTLINE:

  ptr+=c;
  if(*ptr) ptr++;
  while(*ptr&&*ptr<=' ') ptr++;
  c=0;
 }

DIE:

if(cmdline) PoolFreeVec(cmdline);

/* 2.7b8 rri - reset all listers to be selectable again */
FLAGS &=~DMFLAG_READONLY;
for(j=0;j<DMMAXWINDOWS;j++)
{
 dw2=DirWin[j];
 if(dw2)
 {
  SetGadgetAttrs(dw2->dwgad[GID_List], dw2->Window, NULL, GA_ReadOnly, FALSE, TAG_END,0);
 }
}

*g_readsearchpat = 0;
RefreshCmdWin(DirWin[num]); /* 2.5RC10 rri */

if(FLAGS&DMFLAG_RESORT) /* 2.5RC2 rri */
 {
  ReSort();
 }

if(FLAGS&DMFLAG_WINTITLE) /* 2.5RC2 rri */
 {
  WinTitle(CDWin);
 }

ResetFlags();
}

