/* DiskMaster II Rename/Comment/Protect/Filedate/Copy/Move/MakeDir/MakeIcon
**
**
** 2.5.29
**
** 04-04-02 rri - Removed some debug-output from View() I placed there sometime back
**                and forgot why I did so...
**              - Replaced two "#ifdef __PPC__" with "#ifdef __amigaos4__".
**
** 2.5.31
**
** 04-10-31 rri - Changed two LibOpen() calls to the new format.
**
** 04-12-22 rri - Bumped the minimum version-number for two libs to 39 -> DM2 goes V39+!
**
** 2.5.32
**
** 05-06-12 rri - To check if a file already exists for the 'WARN' option of 'Copy'/'Move' DiskMaster2
**                now tries to get an exclusive Lock() on the destination file.
**                This Lock() should only fail if either the file does not exist or is in use.
**                If the file is in use further action is prevented and the source-file remains selected.
**                Additionally the reason for failure of that Lock() is printed in a requester if the
**                debug-output has been enabled with the 'Debug' command.
**                This 'Debug' command acts as a toggle-switch and is left out of the docs on purpose.
**              - Made SmartAddEntry() somewhat smarter, this was nearly the original code...
** 2.6
**
** 05-07-31 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**              - Removed two new warnings with the OS4 SDK 51.10.
**              - Removed one misplaced (uint32) cast for ToUpper().
**              - Changed back all the "2.6" references that were "2.5.32" comments...
**
** 05-08-10 rri - New function DMDelete() implemented.
**
** 05-08-12 rri - Removed a useless DoFileFormat() line from SmartAddEntry().
**              - Removed three warnings in DMDelete() for Fault() lines.
**
** 05-08-19 rri - Changed one DOSStart() call in DOSExecute().
**              - Modifed DOSStart() to use a pointer for the argument-string.
**
** 05-08-20 rri - Modified DMDelete() to make use of CurrentDir() when deleting directories,
**                this speeds up things a little since the overhead for DeletFile() itself is reduced.
**
** 05-09-10 rri - Fix: DMDelete() could not delete dirs given as absolute argument because
**                of them beeing Lock()'ed in the process.
**              - Made SmartRemEntry() smarter. Instead of calling dis_name() for this it just
**                clears out one entries line itself.
**
** 05-11-07 jjt - Added ViewAsync() and ViewAProc() (support function).  Asynchronous View().
**              - Modified View() to accept a node arg.
**
** 05-11-08 jjt - ViewA_ global vars are protected by a semaphore.  Keeps DM and Read processes
**                from potentially writing them at the same time.
**
** 05-11-14 jjt - Bugfix: ViewAsync(), ViewAProc() - Wait()ed and Signal()ed using the
**                signal bit number.  Should be "1 << ViewA_Signal".
**              - Renamed ViewA_Signal to ViewA_SignalBit.
**
** 05-11-18 jjt - Removed (commented-out) references to ViewA_Line.
**              - InfoReq() - Added "Async" option.
**              - Added InfoAProc() - child proces that calls WBInfo().
**              - ViewAsync(), ViewAProc() - Replaced signaling code with a polling loop.
**                Simpler, saves bytes, and will likely loop only once or twice.
**
** 05-11-20 rri - Removed two warnings with NULL versus 0 and GCC4/OS4 includes.
**
** 05-11-23 jjt - Added a DMREQ_HELPNODE tag to Rename (& Relabel & Copy/Move Rename),
**                Comment, and MakeDir.
**
** 05-11-25 jjt - InfoAProc(), ViewAProc() - Inc/dec ProcessCount var when starting/stopping.
**
** 2.7
**
** 06-09-10 rri - Experimentally removed the limit to fonts with fixed width
**                from DMOpenFont().
**
** 06-11-11 rri - Modified SmartRemEntry(), Dupe(), SwapSelect(), PrintDir() to use ListBrowser.
**              - Bugfix: PrintDir() no longer expects a filename as first argument
**                        since it was not even using it.
**              - Removed the limitation to fonts with fixed width completely from DMOpenFont().
**
** 06-11-29 rri - Modified SmartAddEntry() to use ListBrowser.
**
** 06-12-01 rri - Modified SmartRemEntry() to only hide nodes, not free them - the resort does that.
**
** b2
**
** 06-12-10 rri - Replaced a dis_name() call in SmartRename() by an update_entry() call.
**
** b6
**
** 06-12-21 rri - Set the vars for LBNA_Selected in Dupe(), SwapSelect() and
**                PrintDir() to uint32.
**
** b7
**
** 06-12-26 rri - DMOpenFont() limits DMFONTS_READER to fixed-width.
**
** 06-12-28 rri - Added update of DMTextAttrs[id] to DMOpenFont().
**
** 06-12-30 rri - Modified some old-style "timeval" vars to "TimeVal" as this was changed to that
**                name in the OS4-SDK for use with Timer.device.
**              - Updated a RefreshGadgets() call in SmartRename() to refresh the new dir-gadget.
**
** 07-01-02 rri - Removed obsolete var TOPOFFSET.
**              - Removed AddNewDlp() since it was a one-liner and only called once...
**              - Rewrote the core of 'PrintDir' - the data is now taken from the ListBrowser
**                instead of trying to build a new table based on otherwise obsolete structures.
**
** b8
**
** 07-01-05 rri - Updated UpdateDlp() to use examindedata2dlp() with OS4.
**
** 07-01-08 rri - SmartRemEntry(), Dupe(), SwapSelect() and PrintDir() use
**                attach_list()/detach_list() now.
**
**
** b9
**
** 07-01-21 rri - Fixed typo, examindedata2dlp() -> examinedata2dlp()...
**              - 'Rename' allows 256 characters for the name now.
**              - Replaced an Examine() in 'Rename' by NameFromLock()/DevNameFromLock()
**                for the OS4-build.
**              - Replaced the first Examine() in 'Delete' with ExamineObjectTags()
**                for the OS4-build.
**
** b10
**
** 07-01-28 rri - Added use of BumpRevisionLength() to ParseCpMvArgs() but disabled it again
**                as the not localised "Copy_x_of_..." looked way too odd.
**
** b11
**
** 07-02-25 rri - There is a problem with 'Copy', sometimes it drops dead at 100%.
**                It does of course not happen when you try to reproduce it...
**              - Added an additional "break" to DMCopy(), seemed to be more safe this way.
**
** 07-02-27 rri - Bugfix: On some systems renaming entries made them disappear from the list.
**                        Thanks to Colin Ward and Arkadiusz Hucko for the reports!
**
** 07-03-01 rri - Copied complete DMRename() from 2.5b8 for a test with A.Hucko.
**              - Bugfix: a change to the OS4 version in 2.7b9 of 'Rename' caused files
**                        to disappear from the list when renamed when volume-names
**                        were used for the paths instead of device-names.
**                        Thanks to Colin Ward and Arkadiusz Hucko for the reports!
**
** b12
**
** 08-08-29 rri - Adjusted the read_size() in DMCopy() to always fall within
**                multiples of 16 KB.
**
**
**
*/


#include "DM.h"


extern struct DateStamp setStamp; /* 2.5b10 rri */
extern struct DirWindow *DirWin[],*DestWin,*CDWin;
extern struct FileInfoBlock Fib;
extern struct Library   *AslBase;
extern struct Screen    *Screen;
extern struct StringHistory PathHistory;  /* 2.5b10 jjt */
extern struct Process *process;  /* 2.6 jjt */

extern struct TagItem reqtags_Ok[], /* 2.5.32 rri */
                      /*reqtags_OkSkipCan[],*/  /* 2.5b13 jjt */
                      reqtags_Help[],  /* 2.6 jjt */
                      reqtags_HelpOkSkipCan[];  /* 2.6 jjt */

extern struct Library *WorkbenchBase;

extern struct TDat TimerData; /* 2.5RC3 rri */

extern struct DirList *WorkDlp; /* 2.6 rri */

extern struct DirInfo DInfo; /* 2.7b7 rri */

extern UBYTE *ActionArgs[],
             dcPath[],
             DOSPassStr[],
             g_buttons[], /* 2.5b13 rri */
             *Globuff,
             Pattern[],
             sbuff[],
             ScreenTitle[],
             sPath[],
             Version[],
             FontKeywords[][15];  /* 2.5RC2 jjt */

extern BPTR StdIO;

extern LONG BackPen, /* 2.6 rri */
            BlkTotal,
            BPB,
            Globuff_size;

extern ULONG FLAGS; /* 2.5b10 rri */

extern APTR NamePool; /* 2.5b10 rri */
extern APTR StringPool; /* 2.6 rri */
extern APTR CommentPool; /* 2.7b8 rri */

extern struct TextFont *DMFonts[];  /* 2.5RC2 jjt */
extern struct TextAttr DMTextAttrs[]; /* 2.7 rri */


struct InfoData InfoData;

struct Library *AmigaGuideBase;

/* struct Process *ViewA_CallingProc; */ /* 2.6 jjt */
struct SignalSemaphore ViewA_Semaphore;  /* 2.6 jjt */

#ifdef __amigaos4__ /* 2.5.26 rri */
struct AmigaGuideIFace *IAmigaGuide = NULL;
#endif

BOOL   ViewA_Wait, InfoA_Wait;  /* 2.6 jjt */
LONG   ProtBuff;  /* 2.5RC9 jjt */
       /*ViewA_SignalBit;*/  /* 2.6 jjt */
uint32 ProcessCount=0;  /* 2.6 jjt */
STRPTR ViewA_File=NULL, ViewA_Node=NULL,  /* 2.6 jjt */
       InfoA_File=NULL;  /* 2.6 jjt */
BPTR   InfoA_Lock=0;  /* 2.6 rri */


void UpdateDlp(struct DirList *dlp,UBYTE *name);
// 2.7b7 rri void AddNewDlp(struct DirWindow *dw,UBYTE *name);
ULONG ParseCpMvArgs(UBYTE *s, UBYTE *dest, int move);  /* 2.5b13 jjt */
void ViewAProc(void); /* 2.6 jjt */
void InfoAProc(void); /* 2.6 jjt */


int DMRelabel(UBYTE *dev,UBYTE *name,UBYTE *new)
{
UBYTE  *ptr=name,*ptr2=sbuff+1;

if(*dev==0) return(0);

if(!new)
 {
  if(ptr) while(*ptr&&*ptr!=':') *ptr2++=(*ptr++); /* 2.5b10 rri */
  *ptr2=0;
  sprintf(sbuff+52,msgReqRelabel,dev); /* 2.5b13 rri */
  reqtags_Help[0].ti_Data = (LONG) "Rename";  /* 2.6 jjt */
  if(!DMReqTagList(sbuff+52, sbuff+1, 31, reqtags_Help) || !sbuff[1]) return(0);  /* 2.6 jjt */
 }
else strcpy(sbuff+1,new);
sbuff[0]=(UBYTE)strlen(sbuff+1);
return Relabel(dev,sbuff+1);
}


void DMRename(UBYTE *old)
{
UBYTE *ptr,*new=ActionArgs[2];
BPTR  lock; /* 2.5b5 rri */

if(!old) return;

if(!new)
 {
  strcpy(dcPath,old);
  new=dcPath;
  ptr=new+strlen(new)-1;
  while(ptr>new&&*ptr!='/'&&*ptr!=':') ptr--;
  reqtags_HelpOkSkipCan[0].ti_Data = (LONG) "Rename";  /* 2.6 jjt */
  if (DMReqTagList(msgReqRename, ptr+1, 256, reqtags_HelpOkSkipCan) != 1) return;  /* 2.7b9 rri */ /* 2.6 jjt */
 }

if((lock=Lock(old,ACCESS_READ))) /* 2.5.23 rri */
 {
  UnLock(lock); /* 2.5b6 rri */
  if(!Rename(old,new)) FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */

  else
   {
    ptr=new+strlen(new)-1; /* place the pointer at the end of the string */

    while(!(lock=Lock(new,ACCESS_READ))&&*ptr!=':') /* 2.5b6 rri */
     {
      *ptr=0; /* Lock() wasn`t sucessfull, shorten string by */
      ptr--;  /* one char and try again */
     }

    if(!lock) /* if Lock() wasn`t sucessfull at all, leave DMRename() */
     {
      FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
      return;
     }

    /* 2.7b11 rri */
    NameFromLock(lock,sbuff,4096);
    DMstrncpy(FilePart(new), FilePart(sbuff), 4090);
    ptr = PathPart(new);

    UnLock(lock);

    if(Strnicmp(new,old,(ptr-new))) /* 2.5C6 rri */
    {
     SmartRemEntry(old);
     SmartAddEntry(new);
    }
    else
    {
     SmartRename(old,new);
    }

   }
 }
}


void SmartRename(UBYTE *old,UBYTE *new)
{
struct DirWindow *dw;
struct DirList **dl;
UBYTE *ptr;
LONG i,j,len; /* 2.5b10 rri */

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(!dw) continue;
  len=strlen(dw->Path);
  if(Strnicmp(old,dw->Path,len)) continue; /* 2.5RC6 rri */
  if(Stricmp(old,dw->Path)==0) /* 2.5b7 rri */
   {
    CloneBuffer(dw,new); /* 2.5RC6 rri */
    RefreshGadgets(dw->dwgad[GID_String],dw->Window,0); /* 2.7b7 rri */
    continue;
   }
  ptr=old+len; dl=dw->DirList;
  if(dw->FileCount&&dl[0]->dir>1) continue; /* rename dev/cmd file */
  if(*ptr=='/')
   {
    ptr++;
    len++;
   }
  while(*ptr) if(*ptr++=='/') break;
  if(*ptr) continue;
  ptr=old+len;

  for(j=0;j<dw->FileCount;j++)
   if(Stricmp(ptr,dl[j]->name)==0) /* 2.5b7 rri */
    {
     PoolFreeVec(dl[j]->name); /* 2.5b10 rri */
     dl[j]->name = CloneStr(new+len, NamePool); /* 2.5b10 rri */
     update_entry(dw,dl[j]); /* 2.7 rri */
     dw->Flags|=DWFLAG_RESORT;
     break;
    }
 }
}


void DMComment(UBYTE *name,UBYTE *str,sFIB *fib)
{
if(!name) return;
if(!str)
 {
  str=fib->fib_Comment;
  sprintf(sbuff,msgReqComment,fib->fib_FileName); /* 2.5b13 rri */
  reqtags_HelpOkSkipCan[0].ti_Data = (LONG) "Comment";  /* 2.6 jjt */
  if (DMReqTagList(sbuff, str, 80, reqtags_HelpOkSkipCan) != 1) return;  /* 2.5b13 jjt */
 }
if (Stricmp(str,"##")==0) /* 2.5b7 rri */
 {
  *str=0;
 }

if(!SetComment(name,str)) FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
else SmartAddEntry(name);
}


void DMProtect(UBYTE *name,UBYTE *str,sFIB *fib)
{
LONG    choice, /* 2.5RC9 jjt */
        x,incl=(-1); /* 2.5b10 rri */
UBYTE   c;

if(!name) return;
if(!(FLAGS&DMFLAG_ATTR)) /* 2.5RC2 rri */
 {
  ProtBuff = fib->fib_Protection;  /* 2.5RC9 jjt */

  if(str)
   {
    ProtBuff ^= 15;  /* Reverse RWED bits */  /* 2.5RC9 jjt */
    while((c=ToUpper(*str++))) /* 2.6 rri */
    {
      x=0;
      switch(c)
      {
        case '+': incl=1; break;
        case '-': incl=0; break;
        case 'H': x=128; break;
        case 'S': x=64; break;
        case 'P': x=32; break;
        case 'A': x=16; break;
        case 'R': x=8; break;
        case 'W': x=4; break;
        case 'E': x=2; break;
        case 'D': x=1; break;
        case 'G': FLAGS|=DMFLAG_ATTR; /* 2.5RC2 rri */
        default : break;
      }
      if(incl<0&&x){ProtBuff=0; incl=1;} /* 2.5RC9 jjt */
      if (x) {                           /* 2.5RC9 jjt */
        if (incl) ProtBuff |= x;         /* 2.5RC9 jjt */
        else ProtBuff &= ~x;             /* 2.5RC9 jjt */
      }
    }
    ProtBuff ^= 15;  /* RWED bits back to normal. */  /* 2.5RC9 jjt */
   }
  else
   { /* 2.5RC9 jjt */
    struct TagItem protreqtags[]={{DMREQ_BUTTONS,0},{DMREQ_PROTREQ, (ULONG) &ProtBuff}, /* 2.5.26 rri */
                                  {DMREQ_ABORT, 0},{TAG_END,0}};
    protreqtags[0].ti_Data = (ULONG) msgGadProtect; /* 2.5.26 rri */
    sprintf(sbuff, msgReqProtect, fib->fib_FileName);
    choice = DMReqTagList(sbuff, 0, 0, protreqtags); /* 2.5.26 rri */
    if (choice == 2)
     {
      FLAGS |= DMFLAG_ATTR;
      choice = 1;
     }
    if (choice != 1) return;
   }
 }

if(!SetProtection(name, ProtBuff)) FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
else SmartAddEntry(name);
}


void DMSetFileDate(UBYTE *dir,sFIB *fib)
{
 SetFileDate(dir,&fib->fib_Date);
 SmartAddEntry(dir);
}


void SmartRemEntry(UBYTE *name)
{
struct DirWindow *dw;
struct DirList **dl,*dlp;
UBYTE  *ptr;
LONG i,j,len; /* 2.5b10 rri */

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(!dw) continue;
  len=strlen(dw->Path);
  if(Strnicmp(name,dw->Path,len)) continue; /* 2.5RC6 rri */ /* do we have a window with this path? */

  ptr=name+len;
  dl=dw->DirList;

  if(dw->FileCount&&dl[0]->dir>1) continue; /* impossible condition! */

  if(*ptr==0) /* we just a killed a dir that was displayed by a different window... */
   {
    CloneBuffer(dw,0); /* 2.5RC6 rri */
    InitDir(dw,0);
    continue;
   }

  if(*ptr=='/') ptr++;               /* skip "/" */
  while(*ptr) if(*ptr++=='/') break; /* check if dw->Path is only a part of name */
  if(*ptr) continue;                 /* ?? at this point *ptr must be 0 */

  ptr=name+len;             /* we have dw->Path followed by only a filename */
  if(*ptr=='/') ptr++;      /* skip "/" */

  for(j=0;j<dw->FileCount;j++)
   {
    dlp=dl[j];
    if(dlp&&(Stricmp(ptr,dlp->name)==0)) /* 2.5b7 rri */ /* this is our entry */
     {
      dlp->sel=2;
      dlp->dir=(-1);
      dw->Flags|=DWFLAG_RESORT;

      /* 2.7 rri */
      detach_list(dw); /* 2.7b8 rri */
      SetListBrowserNodeAttrs(dlp->node, LBNA_Flags, LBFLG_HIDDEN, TAG_DONE, 0);
      attach_list(dw,FALSE); /* 2.7b8 rri */
      break;
     }
   }
 }
}


void SmartAddEntry(UBYTE *name)
{
struct DirWindow *dw;
struct DirList  **dl;
int32 i,j; /* 2.7 rri */

/* 2.5.32 rri */
UBYTE *path,*file;

path=CloneStr(name, NamePool);
file=CloneStr(FilePart(name), NamePool);
*PathPart(path)=0;

if(FLAGS & DMFLAG_DEBUG) /* 2.5.32 rri */
{
 sprintf(sbuff,"%s\n%s\n%s",name,path,file);
 DMReqTagList(sbuff,0,0,reqtags_Ok);
}


for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  /* find the dir-window with the same path as included in the *name */
  dw=DirWin[i];
  if(!dw) continue;
  if(Stricmp(path,dw->Path) != 0) continue; /* 2.5.32 rri */ /* check if the name's path matches the window's path */

  /* found a matching dir-window */

  dl=dw->DirList;
  if(dw->FileCount && dl[0]->dir>1) continue; /* we have entries but these are not files or dirs -> *very* unlikely... */

  for(j=0;j<dw->FileCount;j++) /* browse thru the file-list */
   {
    if(Stricmp(file,dl[j]->name)==0) /* check if a file of that name already exists, case independant! */ /* 2.5.32 rri */
     {
      PoolFreeVec(dl[j]->name); /* 2.5b10 rri */
      dl[j]->name=0;
      if(dl[j]->cmt) PoolFreeVec(dl[j]->cmt); /* 2.5.26 rri */
      dl[j]->cmt=0; /* 2.5.26 rri */
      UpdateDlp(dl[j],name);
      update_entry(dw,dl[j]); /* 2.7 rri */
      dw->Flags|=DWFLAG_RESORT;
      break;
     }
   }

  if(j==dw->FileCount) /* we need to add a new entry to the list */
   {
    if(AllocDlp(dw)) UpdateDlp(dw->DirList[dw->FileCount++],name);
//    AddNewDlp(dw,name);
    append_entry(dw,dl[j]); /* 2.7 rri */
//    Increment(dw,&dw->dn,1);
    dw->Flags|=DWFLAG_RESORT;
   }

 }
PoolFreeVec(path);
PoolFreeVec(file);
}


void UpdateDlp(struct DirList *dlp,UBYTE *name)
{
/* 2.7b8 rri - OS4 style object-scanning, supports 64 bit file-sizes */
#ifdef __amigaos4__
struct ExamineData *dat;

if(( dat = ExamineObjectTags(EX_StringName, name, TAG_END)))
{
 examinedata2dlp(dlp,dat); /* 2.7b9 rri */
 FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
}

#else
sFIB *fib=(&Fib); /* 2.5b10 rri */
BPTR lock; /* 2.5b5 rri */

if((lock=Lock(name,ACCESS_READ))) /* 2.5.23 gcc rri */
 {
  if(Examine(lock,fib))
   {
    Fib2Dlp(dlp,fib);
   }
  UnLock(lock);
 }
#endif
}


/* 2.7b7 rri
void AddNewDlp(struct DirWindow *dw,UBYTE *name)
{
 if(AllocDlp(dw)) UpdateDlp(dw->DirList[dw->FileCount++],name);
}
*/


ULONG ParseCpMvArgs(UBYTE *s, UBYTE *dest, int move) /* 2.5b13 jjt */
{
LONG  newer;
BPTR  fIn, fOut;
#ifdef __amigaos4__
struct ExamineData *destdat,*sourcedat;
#endif

sFIB  srcfib, destfib, *dfptr;


if (Stricmp(s, dest) == 0) /* Src = Dest?   */
 {
  if (move==3)                /* Move - Exit.  */
   {
    FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
    return 0;
   }
  else
  {
   #if 0 /* 2.7b10 rri - transforms the name to "Copy_x_of_..." - not localised though */
   strcpy(sbuff,FilePart(dest));
   BumpRevisionLength(FilePart(dest), sbuff, 300);
   #endif
   DMstrcat(dest, ".BAK"); /* Copy - Append ".BAK". */ /* 2.5RC9 rri */
  }
 }

if (GetActionArg("RENAME", AATYPE_BOOL, 0))
 {
  rename:
  reqtags_HelpOkSkipCan[0].ti_Data = (LONG) "xrename";  /* 2.6 jjt */
  if (DMReqTagList(msgReqRename, FilePart(dest), 107, reqtags_HelpOkSkipCan) != 1) return 0;  /* 2.5b13 jjt */
 }

if((fOut=Lock(dest,EXCLUSIVE_LOCK))) /* Dest exists and is writeable? */ /* 2.5.32 rri */
 {

  if(( destdat = ExamineObjectTags(EX_FileLockInput, fOut, TAG_END))) // test!
  {
   FreeDosObject(DOS_EXAMINEDATA,destdat); /* Free data when done */
  }


  dfptr = (Examine(fOut, &destfib)) ? &destfib : (sFIB *) NULL;
  UnLock(fOut);

  if((fIn = Lock(s, ACCESS_READ))) /* 2.5.23 gcc rri */
   {
    Examine(fIn, &srcfib);
    UnLock(fIn);
   }

  if (GetActionArg("NEWER", AATYPE_BOOL, 0))
   {
    newer = dfptr ? CompareDates(&destfib.fib_Date, &srcfib.fib_Date) : 0;
    if (newer<=0) return 0;
   }

  else if (FLAGS&DMFLAG_SKIP) /* 2.5RC2 rri */
   {
    FLAGS|=DMFLAG_KEEPSEL; /* 2.5RC2 rri */
    return 0;
   }

  else if ((FLAGS&DMFLAG_TESTWARN) && GetActionArg("WARN", AATYPE_BOOL, 0)) /* 2.5RC2 rri */
   {
    switch(REQ_FileExists(&srcfib, dfptr)) /* 2.5b13 rri */
     {
      case 0: return 0;
      case 2: FLAGS&=~DMFLAG_TESTWARN; break; /* 2.5RC2 rri */
      case 3: goto rename;
      case 4: FLAGS|=DMFLAG_SKIP; FLAGS|=DMFLAG_KEEPSEL; return 0; /* 2.5RC2 rri */
      case 5: FLAGS|=DMFLAG_KEEPSEL; return 0; /* 2.5RC2 rri */
     }
   }

  if (GetActionArg("FORCE", AATYPE_BOOL, 0)) SetProtection(dest, 0);
 }
else /* getting an exclusive lock was not possible */ /* 2.5.32 rri */
 {
  int32 error,len;
  UBYTE test[200];

  error = IoErr();

  if(FLAGS & DMFLAG_DEBUG) /* print the reason why Lock() failed on request */
   {
    len = Fault(error, 0, test, 100);
    if(len != 0)
     {
      DMReqTagList(test,0,0,reqtags_Ok);
     }
   }

  if(error == ERROR_OBJECT_IN_USE) /* if the file does exist but is not accessable, stop further action */
  {
   FLAGS|=DMFLAG_KEEPSEL;
   return 0;
  }
 }

return 1;
}



ULONG DMCopy(UBYTE *s,UBYTE *dest,sFIB *fib,int opt)
{
UBYTE *ptr;
LONG  i=0, /* 2.5RC4 rri vbcc */
      cp,  /* 2.5b13 jjt */
      bufend, /* 2.5.23 gcc rri */
      status, /* 2.5.23 rri */
      onepercent; /* 2.5RC2 rri */
BPTR  fIn,fOut; /* 2.5b5 rri */

#ifdef __amigaos4__ /* 2.6 rri */
uint32 read_size,rate=0;
#else
int32 read_size,rate=0;
#endif


AddPart(dest, FilePart(s), 4000); /* 2.5RC10 rri */

cp = ParseCpMvArgs(s, dest, opt); /* 2.5b13 rri */

if(!cp)
 {
  return 0; /* 2.5b13 rri */
 }
if (cp)  /* 2.5b13 jjt */
 {
  if(!Globuff) /* 2.5b7 rri */
   {
    if(!GetGlobuff())
     {
      return 0;
     }
   }
  read_size=Globuff_size; /* 2.5RC2 rri */
  if(opt==RECURSE_MOVE)
   {
    if(Rename(s,dest)) /* try to move-by-rename */
     {
      SmartAddEntry(dest);
      SmartRemEntry(s);
      return 0; /* DMRecurse won't need to delete the file */
     }
   }
  sprintf(sbuff,(opt==RECURSE_MOVE) ? msgStatMoving : msgStatCopying,FilePart(s)); /* 2.5RC10 rri */
  bufend=strlen(sbuff); /* 2.5.23 gcc rri */
  display(sbuff,0); /* 2.5RC3 rri */
  if((fIn=Open(s,MODE_OLDFILE))) /* 2.5.23 gcc rri */
   {
    if((fOut=Open(dest,MODE_NEWFILE))) /* 2.5.23 gcc rri */
     {
      struct TimeVal timev1,timev2; /* 2.7b7 rri */
      status=1;

      /* 2.5RC2 rri */
      /* This part does a speed-check with a small block (4K) if the file
         in question is bigger than 16K.
         On slow drives (4k * 1000000 / micro-secs needed = bytes/secs) with bytes/secs
         < 40960 bytes the read-size is adapted to the data-rate to have the following
         progress-display updated more often during file-copying.
         At 40960 bytes per second the 128 KB buffer would be full every 3.2 seconds which
         means that this is the maximum refresh-rate for this case.
         For modem connections - e.g. using FTP: - I have around 4k per second - 32 seconds
         refresh-rate - just awfull.
         So the read-size is lowered to the data-rate to have the display updated
         once every second. It won't get smaller than 4k though.
      */
      if(fib->fib_Size>32768)
       {
        GetSysTime(&timev2);
        i=Read(fIn,Globuff,4096);
        if(i)
         {
          status=Write(fOut,Globuff,i);
         }
        GetSysTime(&timev1);
        SubTime(&timev1,&timev2);
        timev1.Microseconds += timev1.Seconds * 1000000; /* 2.7b7 ri */
        if(timev1.Microseconds > 80000) /* 2.7b7 rri */
         {
          rate = (1000000 / timev1.Microseconds) * 4096; /* 2.7b12 rri */
          if(read_size > rate)
           {
            rate /= 16384; // 2.7b12 rri
            if (rate == 8) // 2.7b12 rri
            {
             rate--;
            }
            read_size = rate * 16384; // 2.7b12 rri
           }
          if (read_size<16384) read_size=16384; //2.7b12 rri
         }
        rate=4096;
       }
      cp = ((4*read_size)<fib->fib_Size) ? 1 : 0; /* recylced var ! */
      onepercent=fib->fib_Size/100;
      GetSysTime(&timev1);
      /* 2.5RC2 */

      while((status>0&&(i=Read(fIn,Globuff,read_size))>0)&&(!(FLAGS&DMFLAG_ABORT))) /* 2.5RC2 rri */
       {
        CheckAbortKey();
        status=Write(fOut,Globuff,i);
        /* 2.5RC2 rri */ /* simple progress-display */
        if(cp)
         {
          rate+=i;
          GetSysTime(&timev2);
          if ((timev2.Seconds - timev1.Seconds) > 0 || rate==fib->fib_Size) /* 2.7b7 rri */
           {
            sprintf(sbuff+bufend," - %ld %%%%",rate/onepercent); /* 2.5.23 gcc rri */
            display(sbuff,0);
            GetSysTime(&timev1);
           }
         }

        if(status!=i) /* 2.5b9 rri */
         {
          status=(-1); /* 2.5b10 rri */
          break; /* 2.7b11 rri */
         }
       }
      Close(fOut);

      if(status==-1||i==-1||(FLAGS&DMFLAG_ABORT)) /* 2.5RC2 rri */
       {
/* modified but removed in 2.5b9 - rri
        Fault(IoErr(),NULL,Globuff,FAULT_MAX);
        display(Globuff,0);

Display() is useless here as it will be overwritten instantly
by "Operation Aborted" when Abort=1 is returned...
*/
        DeleteFile(dest);
        FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
       }
      else
       {
        if(fib->fib_Comment[0]) SetComment(dest,fib->fib_Comment);
        if(fib->fib_Protection) SetProtection(dest,fib->fib_Protection);
        DMSetFileDate(dest,fib);
       }
      ptr = FilePart(dest);
      *ptr=0;
     }
    else
     {
      FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
     }
    Close(fIn);
   }
  else
   {
    FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
   }
 }

//Printf("leaving copy...\n"); // test!

return (ULONG) ((FLAGS&DMFLAG_ABORT) == 0); /* 2.5RC2 rri */
}


void DMMakeDir(UBYTE *name)
{
ULONG n; /* 2.5.26 rri */
BPTR lock; /* 2.5b5 rri */
UBYTE *ptr;

if((n=GetActionArg("ICON", AATYPE_BOOL, 0)) == 1) /* 2.5RC2 jjt */
 {
  name=0;
  n = 2;
 }

if(!name)
 {
  struct TagItem mkdirtags[]={{DMREQ_BUTTONS,(ULONG) g_buttons}, /* 2.5.26 rri */
                              {DMREQ_HISTORY,(ULONG) &PathHistory},
                              {DMREQ_HELPNODE,(ULONG) "Makedir"},  /* 2.6 jjt */
                              {DMREQ_DEFBTN, 0},{TAG_END,0}};
  mkdirtags[2].ti_Data = n; /* 2.5.26 rri */
  name=sPath;
  if(*name==0) return;
  ptr=name+strlen(name)-1;
  if(*ptr++!=':')
   {
    *ptr++='/';
    *ptr=0;
   }
  MakeBtnString(0, msgGadIcon, 0);  /* 2.5RC2 jjt  */
  n=DMReqTagList(msgReqMakeDir, name, 4000, mkdirtags); /* 2.5.26 rri */
  if(!n) return; /* 2.5b10 jjt */
 }

if((lock=Lock(name,ACCESS_READ))) /* 2.5.23 gcc rri */
 {
  UnLock(lock);
 }

else if((lock=CreateDir(name))) /* 2.5.23 gcc rri */
 {
  UnLock(lock);
  SmartAddEntry(name);
  if(n==2)
   {
    MakeIcon(name);
    DMstrcat(name,".info"); /* 2.5RC9 rri */
    SmartAddEntry(name);
   }
 }
else FLAGS|=DMFLAG_ABORT; /* 2.5RC2 rri */
}


void MakeIcon(UBYTE *name)
{
struct DiskObject *dob;
UBYTE  *ptr;

ptr=name+strlen(name);
if(Stricmp((ptr-5),".info")!=0) /* 2.5b13 rri */
 {
  if((dob=GetDiskObjectNew(name))) /* 2.5.23 gcc rri */
   {
    PutDiskObject(name,dob);
    FreeDiskObject(dob);
   }
 }
}


void Dupe(void)
{
UBYTE  *ptr;
struct DirList **Source,**Dest;
int     i=1,c,comment=0,date=0,name=0,size=0,state;
uint32 select = 1; /* 2.7 rri */
uint32 selected;

while(ActionArgs[i])
 {
  ptr=ActionArgs[i];
  switch(*ptr)
   {
    case 'c':
    case 'C': comment = 1;
              break;
    case 'd':
    case 'D': date = 1;
              break;
    case 'n':
    case 'N': name = 1;
              break;
    case 's':
    case 'S': size = 1;
              break;
    case '-': select = 0;
              break;
   }
  i++;
 }

Source=CDWin->DirList;
Dest=DestWin->DirList;

if (comment||date||name||size)
 {
  detach_list(CDWin); /* 2.7b8 rri */

  for(i=0;i<CDWin->FileCount;i++)
   {
    GetListBrowserNodeAttrs(Source[i]->node, LBNA_Selected, &selected, TAG_DONE, 0); /* 2.7 rri */

    if (selected != select) /* 2.7 rri */
     {
      for(c=0;c<DestWin->FileCount;c++)
       {
        state=0;

        if(comment)
         {
          if (Source[i]->cmt&&Dest[c]->cmt)
           {
            if (Stricmp(Source[i]->cmt,Dest[c]->cmt)==0) /* 2.5b7 rri */
             {
              state+=comment;
             }
           }
         }
        if (date)
         {
          if (CompareDates(&Source[i]->ds,&Dest[c]->ds)==0)
           {
            state+=date;
           }
         }
        if (name)
         {
          if(Stricmp(Source[i]->name,Dest[c]->name)==0) /* 2.5b7 rri */
           {
            state+=name;
           }
         }
        if (size&&(Source[i]->dir<1)&&(Dest[c]->dir<1))
         {
          if (Source[i]->size==Dest[c]->size)
           {
            state+=size;
           }
         }
        if (state==(comment+date+name+size))
         {
          SetListBrowserNodeAttrs(Source[i]->node, LBNA_Selected, select, TAG_DONE, 0); /* 2.7 rri */
         }
       } /* endfor (c... */
     } /* endif (Source... */
   } /* endfor (i... */
  attach_list(CDWin,FALSE); /* 2.7b8 rri */
  } /* endif (comment||date... */
WinTitle(CDWin);
}


/* 2.7 rri */
void SwapSelect(void)
{
struct DirList **Source;
int32 i;
BOOL select = TRUE;
uint32 selected;

Source=CDWin->DirList;

detach_list(CDWin); /* 2.7b8 rri */
for(i=0;i<CDWin->FileCount;i++)
 {
  GetListBrowserNodeAttrs(Source[i]->node, LBNA_Selected, (uint32) &selected, TAG_DONE, 0);
  if (selected != 0)
  {
   select = FALSE;
  }
  else
  {
   select = TRUE;
  }
  SetListBrowserNodeAttrs(Source[i]->node, LBNA_Selected, select, TAG_DONE, 0);
 }
attach_list(CDWin,FALSE); /* 2.7b8 rri */
WinTitle(CDWin);
}


ULONG DMOpenFont(ULONG idx, STRPTR name, ULONG size) {  /* 2.5RC2 jjt */
  UBYTE  fname[256], title[100];
  ULONG ok=FALSE, success=FALSE, fixedw;
  struct FontRequester *freq=NULL;
  struct TextAttr attr;
  struct TextFont *font=NULL;

  fixedw = (idx == DMFONTS_READER); /* 2.7 rri */

  if (DiskfontBase) {
    if (!name || *name == 0) {
      if (AslBase) {
        sprintf(title, "Font: %s", FontKeywords[idx]);
        name=GetTFName(DMFonts[idx]); /* 2.5RC4 rri */
        size=DMFonts[idx]->tf_YSize; /* 2.5RC4 rri */
        freq = AllocAslRequest (ASL_FontRequest, NULL);
        if (freq)
         {
          Busy(1); /* 2.5.24 rri */
          if (AslRequestTags(freq, ASLFO_Screen,         Screen,
                                   ASLFO_TitleText,      title,
                                   ASLFO_MaxHeight,      24,
                                   ASLFO_InitialName, name, /* 2.5RC4 rri */
                                   ASLFO_InitialSize, size, /* 2.5RC4 rri */
                                   ASLFO_FixedWidthOnly, fixedw,
                                   TAG_DONE))
           {
            CopyMem(&freq->fo_Attr, &attr, sizeof (struct TextAttr));
            ok = TRUE;
           }
          Busy(0); /* 2.5.24 rri */
         }
      }
    }
    else {
      strcpy(fname, name);
      if (strlen(fname)<5 || (Stricmp(fname+strlen(fname)-5,".font") != 0)) DMstrcat(fname, ".font"); /* 2.5RC9 rri */
      attr.ta_Name =  fname;
      attr.ta_YSize = size;
      attr.ta_Style = FS_NORMAL;
      attr.ta_Flags = 0; /* 2.5RC4 rri vbcc */
      ok = TRUE;
    }

    if (ok) font = OpenDiskFont(&attr);


    if (font && fixedw) {
      // --- Reject proportional fonts when needed ---
      if (font->tf_Flags & FPF_PROPORTIONAL) {
        display(msgErrorPropFont,0); // 2.5b13 rri
        CloseFont(font);
        font = NULL;
      }
    }


    if (font) {
      if (DMFonts[idx]) CloseFont(DMFonts[idx]);
      DMFonts[idx] = font;
      FontToAttr(DMFonts[idx], &DMTextAttrs[idx]); /* 2.7 rri */
      success = TRUE;
    }

    if (freq) FreeAslRequest(freq);
  }

  return success;
}


void View(UBYTE *file, STRPTR node) /* 2.5RC10 rri */
{
struct NewAmigaGuide *NewGuide; /* 2.5.23 gcc rri */
UBYTE *path,*name;
BPTR lock;
AMIGAGUIDECONTEXT Context;

#ifdef __amigaos4__ /* 2.5.29 rri */
if(!AmigaGuideBase) LibOpen("amigaguide", &AmigaGuideBase, 39, (uint32) &IAmigaGuide); /* 2.5.31 rri */
#else
if(!AmigaGuideBase) LibOpen("amigaguide", &AmigaGuideBase, 39); /* 2.5.31 rri */
#endif

if(AmigaGuideBase)
 {
  if((NewGuide=PoolAllocVec(NamePool,sizeof(struct NewAmigaGuide)))) /* 2.5.23 gcc rri */
   {
    path=CloneStr(file, NamePool);
    name=CloneStr(FilePart(file), NamePool);
    *PathPart(path)=0;
    if((lock=Lock(path,ACCESS_READ))) /* 2.5.23 gcc rri */
     {
      NewGuide->nag_Name = (STRPTR) name;
      NewGuide->nag_Lock = lock;
      NewGuide->nag_Screen = Screen;
      NewGuide->nag_Node = node;  /* 2.6 jjt */

      /* Open the AmigaGuide client */
      if((Context=OpenAmigaGuideA(NewGuide,NULL))) /* 2.5.23 gcc rri */
       {
        CloseAmigaGuide(Context); /* Close the AmigaGuide client */
       }
      UnLock(lock);
     }
    PoolFreeVec(path);
    PoolFreeVec(name);
    PoolFreeVec(NewGuide); /* 2.5.23 gcc rri */
   }
 }

}


void InfoReq(UBYTE *file)
{
UBYTE  *ptr;

ptr=file+strlen(file);
if(Stricmp((ptr-5),".info")==0) /* 2.5b13 rri */
 {
  ptr[-5]=0;
 }

#ifdef __amigaos4__ /* 2.5.26 rri */
if (!LibOpen("workbench", &WorkbenchBase, 39, (uint32) &IWorkbench)) return; /* 2.5.31 rri */
#else
if (!LibOpen("workbench", &WorkbenchBase, 39)) return;  /* 2.5.31 rri */
#endif
if(CDWin&&CDWin->Path[0])
 {
  InfoA_Lock = Lock(CDWin->Path, ACCESS_READ); /* 2.6 jjt */
  InfoA_File = file;  /* 2.6 jjt */
 }
else /* 2.5b13 rri */
 {
  if ((InfoA_Lock = Lock(CDWin->Path, ACCESS_READ))) /* 2.6 jjt */
  {
    if (NameFromLock(InfoA_Lock, sbuff, 500))  /* 2.6 jjt */
    {
      InfoA_File = sbuff;  /* 2.6 jjt */
    }
    else
    {
      UnLock(InfoA_Lock);
      InfoA_Lock = 0; /* 2.6 rri */
    }
  }
 }

  if (InfoA_Lock)  /* 2.6 jjt */
  {
    if (GetActionArg("ASYNC", AATYPE_BOOL, 0))
    {
      /* Run asynchronously... */
      InfoA_Wait = TRUE;

      CreateNewProcTags(NP_Entry, (ULONG) InfoAProc,
                        NP_Name, (ULONG) "DMInfo",
                        TAG_END);

      /* Poll until InfoAProc() has copies of the InfoA_ vars. */
      while (InfoA_Wait)
      {
        Delay(5);
      }
    }
    else
    {
      /* Run synchronously... */
      WBInfo(InfoA_Lock, InfoA_File, Screen);
      UnLock(InfoA_Lock);
    }
  }
}


SAVEDS void InfoAProc(void)  /* 2.6 jjt */
{
  BPTR lock;
  STRPTR file;

  /* New process, started by InfoReq(), that calls WBInfo() */

  ProcessCount++;  /* 2.6 jjt */

  lock = InfoA_Lock;
  file = CloneStr(InfoA_File, NamePool);

  InfoA_Wait = FALSE;

  WBInfo(lock, file, Screen);
  UnLock(lock);
  PoolFreeVec(file);

  ProcessCount--;  /* 2.6 jjt */
}


void DOSExecute(void) /* 2.5b9 rri */
{
UBYTE *ptr=DOSPassStr;
int StackSize=8192,i=1;

if (GetActionArg("s=",AATYPE_BOOL,0)==i) /* if arg "s=" is first arg then */
 {
  StackSize=GetActionArg("s",AATYPE_NUM,8192); /* check if for the stack-option */
  i++;
 }

if (StackSize<8192)
 {
  StackSize=8192;
 }

*ptr=0;

if(DOSParse(ptr,msgReqDOSExec,i))
 {
  DOSStart(StackSize,ptr); /* 2.6 rri */
 }
}


void DOSStart(int StackSize, UBYTE *argstring) /* 2.6 rri */
{
BPTR ext_path=0; /* 2.5RC4 rri vbcc */

if(CDWin&&CDWin->Path[0])
 {
  ext_path = Lock(CDWin->Path, ACCESS_READ);
 }

SystemTags(argstring, /* 2.6 rri */
           SYS_Input, StdIO?StdIO:Input(),
           SYS_Output, NULL,
           SYS_UserShell, TRUE,
           NP_CurrentDir, ext_path,
           NP_StackSize, StackSize,
           TAG_END);
}


void CheckSpace(void)
{
BPTR lock;
struct BaseConvert checkbase;

if(!CDWin->Path[0])
 {
  if((lock=Lock(ActionArgs[1],ACCESS_READ))) /* 2.5.23 gcc rri */
   {
    Info(lock,&InfoData);
    CDWin->BytesPerBlock=InfoData.id_BytesPerBlock;
    UnLock(lock);
   }
 }

if(DestWin&&DestWin->BytesPerBlock)
 {
  BPB=DestWin->BytesPerBlock;
 }
else
 {
  BPB=CDWin->BytesPerBlock;
 }
if(!BPB)
 {
  return;
 }

StartRec(RECURSE_CHECK);

/*

BlkTotal++; - per sub-dir +1
BlkTotal+=get_blocks(info->fib_Size,BPB);

LONG get_blocks(long size,LONG bpb)
{
LONG data_blk,list_blk;

data_blk=(size+bpb-1)/bpb;   // number of data blocks
list_blk=(data_blk-1)/72;    // number of file list blocks
return(1+list_blk+data_blk); // file header + list + data blocks
}

*/



checkbase.BlocksFree=BlkTotal;
checkbase.BytesPerBlock=BPB;
ConvertBase(&checkbase);

strcpy(sbuff,checkbase.String); /* 2.5b13 rri */

if(DestWin)
 {
  if(BlkTotal>DestWin->BlocksFree)
   {
    sprintf(ScreenTitle,msgErrorCheckSpace,sbuff); /* 2.5b13 rri */
   }
  else
   {
    checkbase.BlocksFree=DestWin->BlocksFree-BlkTotal;
    ConvertBase(&checkbase);
    sprintf(ScreenTitle,msgStatCheckSpace,sbuff,checkbase.String); /* 2.5b13 rri */
   }
 }

display(ScreenTitle,0);
FLAGS|=DMFLAG_WINTITLE; /* 2.5RC2 rri */
}


void PrintDir(void) /* 2.5b9 rri */
{
BPTR PrintFileHandle;
struct DirList **PrintList;
uint32 selectstate; /* 2.7 rri */

/* 2.5.27 rri */
LONG i;
UBYTE *name=ActionArgs[1];

uint32 xsize,chars,justification; /* 2.7b7 rri */
int32 x;

if(!name||*name==0)
 {
  name=DMFileReq(0,CDWin->Path,TRUE);
 }

if(!name||*name==0)
 {
  FLAGS|=DMFLAG_ABORT;
  return;
 }

PrintList=CDWin->DirList;

xsize = DMFonts[DMFONTS_MAIN]->tf_XSize;

if(GetGlobuff()) /* we always need a clear buffer so we call the function... */
 {
  if((PrintFileHandle=Open(name,MODE_NEWFILE))) /* 2.5.27 rri */
   {
    sprintf(Globuff,msgStatPrintDir,CDWin->Path); /* 2.5b13 rri */
    detach_list(CDWin); /* 2.7b8 rri */
    for(i=0;i<CDWin->FileCount;i++)
     {
      GetListBrowserNodeAttrs(PrintList[i]->node, LBNA_Selected, &selectstate, TAG_DONE, 0); /* 2.7 rri */
      if (selectstate != 0) /* 2.7 rri */
       {
        /* 2.7b7 rri */
        for (x=0;x<DInfo.num;x++)
        {
         STRPTR text;

         chars = (CDWin->dwgadcollumn[x].ci_Width / xsize);

         GetListBrowserNodeAttrs(PrintList[i]->node, LBNA_Column, x,
                                       LBNCA_Text, (ULONG *)(void *) &text,
                                       LBNCA_Justification, &justification,
                                       TAG_DONE,0);

         if (justification == LCJ_RIGHT)
         {
          sprintf(sbuff,"%*s ",(int)chars,text);
         }
         else
         {
          sprintf(sbuff,"%-*s ",(int)chars,text);
         }
         DMstrcat(Globuff,sbuff); /* 2.5RC9 rri */
         }
        DMstrcat(Globuff,"\n"); /* 2.5RC9 rri */
        SetListBrowserNodeAttrs(PrintList[i]->node, LBNA_Selected, FALSE, TAG_DONE, 0); /* 2.7 rri */
       }
     }
    attach_list(CDWin,FALSE); /* 2.7b8 rri */
    Write(PrintFileHandle,Globuff,(LONG)strlen(Globuff)); /* 2.5b10 rri */
    Close(PrintFileHandle);
   }
 }
WinTitle(CDWin);
}


void DMSetDate()
{
DateStamp(&setStamp);
StartRec(RECURSE_DATE);
}


/*
   The parameters for DMDelete() are initialised elsewhere:
   sPath - the path+name of the entry to be deleted
   WorkDlp - a pointer to a struct DirList for a selected entry
*/

int32 DMDelete(void) /* 2.6 rri */
{
#ifdef __amigaos4__
struct ExamineData *dat;
#endif
sFIB *info;


BPTR lock,olddir;
int32 error,retcode=0;
struct DirList tempDlp;

if (CheckAbortKey())
 {
  FLAGS|=DMFLAG_ABORT;
  return 0;
 }
if (FLAGS & DMFLAG_ABORT)
 {
  return 0;
 }

if (!WorkDlp) /* requested to delete a file/dir/lock that is no dir-entry */
 {
  if(DeleteFile(sPath)) /* the most simple case, the user provided a not protected file to delete or */
   {                    /* an empty dir, a hardlink or a softlink */
    display(msgStatDeleted,FilePart(sPath)); /* inform user */
    return 1;
   }
  else /* now we need more information... */
   {
    error = IoErr();

    switch (error)
     {
      case ERROR_DIRECTORY_NOT_EMPTY:
      case ERROR_DELETE_PROTECTED:

              #ifdef __amigaos4__
              if(( dat = ExamineObjectTags(EX_StringName, sPath, TAG_END)))
               {
                WorkDlp = &tempDlp;
                examinedata2dlp(WorkDlp,dat);
                FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
                retcode = DMDelete();
               }
              break;
              #else
              if((lock=Lock(sPath,ACCESS_READ)))
               {
                if((info=AllocDosObject(DOS_FIB,TAG_DONE) ))
                 {
                  if(Examine(lock,info))
                   {
                    UnLock(lock); /* we have to free it or we can't delete it... */
                    lock = 0;
                    WorkDlp = &tempDlp;
                    Fib2Dlp(WorkDlp,info);
                    retcode = DMDelete();
                   }
                  FreeDosObject(DOS_FIB,info);
                 }
                if(lock) UnLock(lock); /* in case AllocDosObject() or Examine() fail... */
               }
              break;
              #endif
      default:
            Fault(error,(STRPTR) msgErrorDelete,sbuff,70);
            display(sbuff,0);
     };
   }
  return retcode;
 }

if (WorkDlp && !WorkDlp->dir) /* requested to delete a dir-entry that is no dir */
 {
  if(FLAGS&DMFLAG_FORCE)
   {
    SetProtection(sPath,0);
   }
  if(!(DeleteFile(sPath)))
   {
    error = IoErr();
    Fault(error,(STRPTR) msgErrorDelete,sbuff,70);
    display(sbuff,0);
    if (error != ERROR_DELETE_PROTECTED && FLAGS&DMFLAG_FORCE)
     {
      SetProtection(sPath,WorkDlp->attr); /* restore protection-bits */
     }
    return 0;
   }
  else
   {
    SmartRemEntry(sPath);
    display(msgStatDeleted,FilePart(sPath));
    return 1;
   }
 }

if( WorkDlp && WorkDlp->dir && !(FLAGS&DMFLAG_REC) && !(FLAGS&DMFLAG_SINGLE) ) /* requested to delete a dir-entry that is a dir */
 {
  if(DeleteFile(sPath)) /* when this is a success, the dir was a hard-linked or empty anyways */
   {
    SmartRemEntry(sPath); /* remove entry from list */
    display(msgStatDeleted,FilePart(sPath)); /* inform user */
    return 1;
   }

  if((lock=Lock(sPath,ACCESS_READ)))
   {
    int32 protectbits = WorkDlp->attr;
    error = 0;
    if((info=AllocDosObject(DOS_FIB,TAG_DONE) ))
     {
      if(Examine(lock,info))
       {
        UBYTE *path;

        path=CloneStr(sPath, StringPool); /* secure orginal argument */

        olddir = CurrentDir(lock); /* make that dir our new home */

        while(ExNext(lock,info))
         {
          strcpy(sPath,info->fib_FileName);
          WorkDlp = &tempDlp;
          Fib2Dlp(WorkDlp,info);
          DMDelete();
         }
        error = IoErr();
        strcpy(sPath,path);
        PoolFreeVec(path);

        CurrentDir(olddir); /* restore old home-dir */
       }
      FreeDosObject(DOS_FIB,info);
     }
    UnLock(lock);

    if (error == ERROR_NO_MORE_ENTRIES)
     {
      if(FLAGS&DMFLAG_FORCE)
       {
        SetProtection(sPath,0);
       }
      if(DeleteFile(sPath))
       {
        SmartRemEntry(sPath);
        display(msgStatDeleted,FilePart(sPath));
        return 1;
       }
      else
       {
        error = IoErr();
        Fault(error,(STRPTR) msgErrorDelete,sbuff,70);
        display(sbuff,0);
        if (error != ERROR_DELETE_PROTECTED && FLAGS&DMFLAG_FORCE)
         {
          SetProtection(sPath,protectbits); /* restore protection-bits */
         }
        return 0;
       }
     }
   }
 }
return 0;
}


void ViewAsync(STRPTR file, STRPTR node)  /* 2.6 jjt */
{
  /* Asynchronous View()
     Puts <file>, and <node> into global vars,
     and starts a new process, ViewAProc(), that will call View().
  */

  ObtainSemaphore(&ViewA_Semaphore); /* Protect ViewA_ globals */

  ViewA_Wait = TRUE;
/*
  ViewA_SignalBit = AllocSignal(-1);
  ViewA_CallingProc = (struct Process *) FindTask(NULL);
*/

  ViewA_File = file;
  ViewA_Node = node;

/*    SetSignal(0L, ViewA_SignalBit); */

  CreateNewProcTags(NP_Entry, (ULONG) ViewAProc,
                    NP_Name, (ULONG) "DMView",
                    TAG_END);

  /* Wait until ViewAProc() has its own copies of the ViewA_ vars... */
  while(ViewA_Wait)
  {
    Delay(5);
  }
/*
  if (ViewA_SignalBit != -1)
  {
    Wait(1L << ViewA_SignalBit); // 2.6 jjt
    FreeSignal(ViewA_SignalBit);
  }
  else
  {
    Delay(50);
  }
*/

  ReleaseSemaphore(&ViewA_Semaphore);
}


SAVEDS void ViewAProc()  /* 2.6 jjt */
{
  STRPTR file, node;

  /* This is a new process, started by ViewAsync(), that calls View() */

  ProcessCount++;  /* 2.6 jjt */

  file = CloneStr(ViewA_File, NamePool);
  node = CloneStr(ViewA_Node, NamePool);

  /* Signal that we have our own copies of the globals; it's safe for ViewAsync() to exit. */
  ViewA_Wait = FALSE;
/*
  if (ViewA_SignalBit != -1)
  {
    Signal((struct Task*) ViewA_CallingProc, 1L << ViewA_SignalBit);
  }
*/

  View(file, node);

  PoolFreeVec(file);
  PoolFreeVec(node);

  ProcessCount--;  /* 2.6 jjt */
}

