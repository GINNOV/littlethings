/* DMSupport.c - generic support sub-routines
**
** 2.5.29
**
** 04-03-30 rri - Rewritten DMMatch(), should be bullet-proof now,
**                next step should be to increase it's speed...
**
** 04-03-31 rri - FilterStar() is back, created from parts of the new DMMatch().
**              - Simplified DMMatch(), patterns are always filtered.
**              - Enhanced Separate() to use FilterStar() on dw->Pattern.
**
** 04-04-02 rri - Replaced two "#ifdef __PPC__" with "#ifdef __amigaos4__".
**
** 04-04-03 rri - Small correction in FilterStar() - changed "index" to "findex".
**
** 2.5.30
**
** 04-08-16 rri - The parent-button of the command-window is updated less often now.
**
** 2.5.31
**
** 04-12-22 rri - Removed LibAllocPooled() and LibFreePooled() -> DM2 goes V39+.
**
** 2.6
**
** 05-07-31 rri - Removed three misplaced (uint32) casts for ToUpper().
**              - Removed comments from header older than 2.5.29.
**
** 05-11-23 jjt - DOSParse() - Added a DMREQ_HELPNODE tag.
**
** 05-11-25 jjt - FreeUserData() - Tests that all async Info and View processes have
**                been stopped.
**                Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**              - FreeUserData() - Changed the "Close all windows" req to use warnreqtags.
**                Ideally, this will prevent clever people from opening Help windows/processes.
**
** 05-11-26 rri - Localised new close-windows requester.
**              - Renamed Startup.DM in DiskMaster2.prefs
**
** 05-12-07 jjt - DOSParse() - Checks ActionArgsUnquoted[] array before quoting strings.
**
** 2.7
**
** 05-12-15 jjt - FreeUserData() - Key commands are freed by a call to FreeKeyCmds() in
**                DMKey.c.
**
** 05-12-17 jjt - Added FreeStringArray() - Frees arrays of CloneStr()'ed strings.
**              - FreeUserData() - Key and AutoCommands are freed by a call to FreeStringArray().
**
** 05-12-23 jjt - FreeStringArray() - Changed "strarray" arg to a "UBYTE *".  Should quiet a
**                GCC warning.
**
** 06-09-17 rri - RefreshWindows() builds a new struct ColumnInfo in dw->dwgadcollumn
**
** 06-11-11 rri - Removed a dis_files() call from RefreshWindows()
**
** 06-12-03 rri - Moved some lines around in FreeUserData().
**              - Removed some debug-code from FindDMWin().
**              - FreeUserData() checks now if WinPort is installed and only clears it
**                instead of removing it. Removal is done by DM2main() now.
**
** 06-12-04 rri - Replaced some test-code in BootBatch() with the real code again.
**              - Removed debug-output from FindDMWin().
** b2
**
** 06-12-09 rri - Re-installed the dis_files() call in RefreshWindows() since refreshing after
**                changing the display-options did not work anymore.
**
** 06-12-10 rri - Removed a check for Reaction windows from CloneBuffer().
**              - Removed updating of the path-gadget from CloneBuffer() - InitDir() does that now.
**              - Added CIF_DRAGGABLE in RefreshWindows() to make the collumn-titles clickable.
**
** b7
**
** 06-12-30 rri - Modified CloneBuffer() to not poke into some gadgets directly anymore but
**                to properly update the new Reaction string-path-gadget.
**
** 07-01-02 rri - Added a window-pointer to a SetGadgetAttrs() call in CloneBuffer() to be sure
**                that the string-gadget really is refreshed.
** b8
**
** 07-01-08 rri - RefreshWindows() uses detach_list() now.
**
** b9
**
** 07-01-21 rri - Changed IsDir() to use ExamineObjectTags() for the OS4-build.
**
** b11
**
** 07-02-25 rri - Modified the formula to calculate the default width's and position's
**                for the windows to better scale to different screen dimensions.
**                Thanks to Colin Ward for pointing out that there is problem!
**
** b12
**
** 08-08-29 rri - Modified sizes in GetGlobuff() by about doubling them, making them
**                a multiple of 16 KB with is about the biggest blocksize and making
**                them not exactly 128 KB or 64 KB in size.
**
**
*/


#include "DM.h"

UBYTE DisplayBuffer[256],
      *Globuff,
      sbuff[4100], /* 2.5RC6 rri */
      *Strap=NULL; /* 2.5.24 rri */

LONG Globuff_size;

struct Screen *MyScreen;


extern struct DirWindow *DirWin[],
                        *CDWin,
                        *CmdWin,
                        *DestWin;

extern struct MsgPort   *WinPort;

extern BOOL ActionArgsUnquoted[]; /* 2.6 jjt*/

extern UBYTE *ActionArgs[],
             *AutoCmdStr[], /* 2.5RC6 rri */
             DefStart[],   /* 2.5RC10 rri */
             *KeyCmdStr[], /* 2.5RC6 rri */
             ScreenTitle[],
             ReqStr[];

extern char DMname[]; /* 2.7 rri */

extern int SortType; /* 2.5.23 rri */

extern LONG  Bar_Height; /* 2.5b10 rri */

extern ULONG DWNum, /* 2.5RC10 rri */
             FLAGS, /* 2.5RC2 rri */
             Screen_Width,Screen_Height; /* 2.5b9 rri */

extern uint32 ProcessCount;  /* 2.6 jjt */

extern struct TagItem reqtags_Ok[];  /* 2.5b13 jjt */

extern APTR NamePool; /* 2.5RC6 rri */
extern APTR StringPool; /* 2.7 rri */

extern struct DirInfo DInfo; /* 2.7 rri */


void StrToUpper(UBYTE *str) /* 2.5b7 rri */
{
int i=0;

while(str[i])
 {
  str[i]=ToUpper(str[i]); /* 2.6 rri */
  i++;
 }
}


LONG GetActionArg(STRPTR keyword, UBYTE type, LONG def) {
  UBYTE *akw;
  LONG  idx=1,kwlen,val; /* 2.5b10 rri */

  /*  type = AATYPE_BOOL        - Returns <def> or index of keyword.
             AATYPE_NUM         - Returns <def> or <num>.
             AATYPE_STR         - Returns ptr to <def> or <str>.
             AATYPE_NEXTSTR     - First tests for "<keyword>=", like AATYPE_STR, otherwise
                                  behaves as AATYPE_TRUENEXTSTR.
             AATYPE_TRUENEXTSTR - Returns ptr to <def> or the next ActionArg after <keyword>).

      New in 2.5RC3:  AATYPE_NEXTSTR handles both "<keyword>=<string>" and "<keyword> <string>"
     conditions.
  */

  val = def;
  kwlen = (LONG) strlen(keyword); /* 2.5b10 ri */
  while ((akw = ActionArgs[idx++])) {
    if (Strnicmp(keyword, akw, kwlen) == 0) {
      if (type == AATYPE_BOOL) val = idx - 1;
      else {  /* 2.5RC3 jjt */
        akw += kwlen;
        if ((type != AATYPE_TRUENEXTSTR) && (*akw++ == '='))
         {
          if (akw) /* 2.5RC9 rri */
           {
            if(type == AATYPE_NUM) StrToLong(akw,&val);
            else val=(LONG) akw;
           }
         }
        else if (type >= AATYPE_NEXTSTR) {
          if ((akw = ActionArgs[idx])) val = (LONG) akw;
        }
      }
      break;
    }
  }

  return val;
}


BOOL IsDir(STRPTR name)
{
 BOOL dir=FALSE;

#ifdef __amigaos4__ /* 2.7b9 rri */
  struct ExamineData *dat;

  if(( dat = ExamineObjectTags(EX_StringName, name,
                               EX_DataFields, 0,
                               TAG_END)))
  {
   if ( EXD_IS_DIRECTORY(dat) )
   {
    dir = TRUE;
   }
   FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
  }
#else
 BPTR l;
 struct FileInfoBlock fi;

 if ((l = Lock(name, ACCESS_READ)))
 {
  if (Examine(l, &fi)) dir = (fi.fib_DirEntryType > 0);
  UnLock(l);
 }
#endif

  return dir;
}


UBYTE *SkipWhite(UBYTE *ptr)
{
while(*ptr==' '||*ptr==9) ptr++;
return(ptr);
}


BOOL AArg2Str(STRPTR keyword, STRPTR dest, ULONG length, BOOL upper, STRPTR def) /* 2.5b6 jjt */ /* 2.5RC9 rri */
{
DMstrncpy(dest,(UBYTE *) GetActionArg(keyword, AATYPE_NEXTSTR, (LONG) def), length); /* 2.5RC10 rri */
if (upper) StrToUpper(dest); /* 2.5b7 rri */
return (BOOL) (*dest != 0);
}


void display(const UBYTE format[],UBYTE *arg1)
{
sprintf(DisplayBuffer,format,arg1);
if(FLAGS&DMFLAG_QUIET) return; /* 2.5RC2 rri */
DMstrncpy(ScreenTitle,DisplayBuffer,255); /* 2.5RC10 rri */
SetTitles();
}


void QuoteCat(UBYTE *ptr,UBYTE *name)
{
int q=NeedQuote(name);

if(q) DMstrcat(ptr,"\""); /* 2.5RC9 rri */
DMstrcat(ptr,name); /* 2.5RC9 rri */
if(q) DMstrcat(ptr,"\""); /* 2.5RC9 rri */
}


int NeedQuote(UBYTE *ptr)
{
while(*ptr)
 {
/* if(*ptr=='\"') return(0);*/ /* 2.5RC9 rri */
 if(*ptr==' ') return(1);
  if(*ptr=='\\') return(0);
  ptr++;
 }
return(0);
}


UBYTE * FilterStar(UBYTE *pattern) /* 2.5.29 rri */
{
UBYTE *patternbuffer;
ULONG findex = 0, length;

length = ( strlen(pattern) * 2 ) + 10;

if(( patternbuffer=PoolAllocVec(NamePool, length )))
 {
  length -= 10;
  while(*pattern&&findex<length)
   {
    if (*pattern!='*')
     {
      patternbuffer[findex++] = *pattern++;
     }
    else
     {
      patternbuffer[findex++]='#';
      patternbuffer[findex++]='?';
      pattern++;
     }
   }
  patternbuffer[findex]=0;
 }
return (patternbuffer);
}


ULONG DMMatch(UBYTE *string,UBYTE *pattern) /* 2.5.29 rri */
{
UBYTE *tokenbuffer;
ULONG length,result=0;

length = ( strlen(pattern) * 2 ) + 10;

if((tokenbuffer=PoolAllocVec(NamePool, length )))
 {
  ParsePatternNoCase(pattern,tokenbuffer,length);
  result = MatchPatternNoCase(tokenbuffer,string);
  PoolFreeVec(tokenbuffer);
 }
return (result);
}


void RefreshWindows(void) /* 2.5b7 rri */
{
int i,x;
struct DirWindow *dw;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  if((dw=DirWin[i])) /* 2.5.23 gcc rri */
   {
    detach_list(dw); /* 2.7b8 rri */

    if(dw->Flags&DW_CMD)
    {
     dw->dwgadcollumn = NULL; /* no collum-info for cmd-windows */
    }
    else
    {
     PoolFreeVec(dw->dwgadcollumn);

     dw->dwgadcollumn = (struct ColumnInfo *) PoolAllocVec(StringPool,
                         sizeof(struct ColumnInfo) * (DInfo.num+1));

     for (x=0;x<DInfo.num;x++)
     {
      dw->dwgadcollumn[x].ci_Width = 100;
      dw->dwgadcollumn[x].ci_Title = DInfo.titles[x];
      dw->dwgadcollumn[x].ci_Flags = CIF_WEIGHTED|CIF_DRAGGABLE|CIF_SORTABLE;
     }
     dw->dwgadcollumn[x].ci_Width = -1;
    }

    SetGadgetAttrs(dw->dwgad[GID_List], dw->Window, NULL,LISTBROWSER_ColumnInfo, dw->dwgadcollumn, TAG_END,0);

    dis_files(dw);
    WinTitle(dw);
   }
 }
}


void StampProt(UBYTE *str,LONG prot) /* 2.5RC9 jjt */
{
int a;

sprintf(str,"HSPARWED");
prot ^= 15;

for(a=7;a>=0;a--)
 {
  if (!(prot&(1<<a)))
   {
    str[7-a]='-';
   }
 }
}


int GetGlobuff() // 2.5b7 rri
{
if(Globuff)
 {
  memset(Globuff,0,(size_t) Globuff_size); // 2.5b10 rri
  return(1);
 }
//Globuff_size=(1<<17)-4; // allocate 128K-4bytes - ATAPI-ZIP bug... 2.5b13 rri
Globuff_size=16384 * 15; // allocate 240 KB, safely a multiple of any blocksize 2.7b12 rri

if(!(Globuff=(UBYTE *)AllocMem(Globuff_size,MEMF_ANY | MEMF_CLEAR))) // 2.5.28 rri
 {
//  Globuff_size=(1<<16)-4; // second try with 64K-4bytes  2.5b13 rri
  Globuff_size=16384 * 7; // second try with 112 KB 2.7b12
  if(!(Globuff=(UBYTE *)AllocMem(Globuff_size,MEMF_ANY | MEMF_CLEAR))) // 2.5.28 rri
   {
    display(msgErrorNoMemory,0); // 2.5b13 rri
    return(0);
   }
 }
return(1);
}


void FreeGlobuff()
{
if(Globuff)
 {
  FreeMem(Globuff,Globuff_size);
  Globuff=0;
 }
}


void FindCmdWin(void) /* 2.5b7 rri */
{
int i;

i=0;

while(i<DMMAXWINDOWS) /* 2.5.23 rri */
 {
  if (DirWin[i])
   {
    if(DirWin[i]->Flags&DW_CMD)
     {
      CmdWin=DirWin[i];
     }
   }
  i++;
 }
}


int DOSParse(UBYTE *str,const UBYTE *hail,int i)
{
struct TagItem dostags[]={{DMREQ_FILEREQ, TRUE},{DMREQ_HELPNODE,0},{TAG_END,0}}; /* 2.5.26 rri */ /* 2.6 jjt */
UBYTE   *ptr=str,*ptr2;
int     q,s;

s=i; /* 2.5b10 */

dostags[1].ti_Data = (ULONG) (hail == msgReqDOSExec ? "Extern" : "REXX");

while(ActionArgs[i])
 {
  ptr2=ActionArgs[i];

  if (i!=s) /* 2.5b10 rri */
   {
    *ptr++=' ';
   }
/*   q=NeedQuote(ptr2); */
  q = ActionArgsUnquoted[i] ? 0 : NeedQuote(ptr2);  /* 2.6 jjt */
  if(q) *ptr++='"';

  while(*ptr2)
   {
    if(*ptr2=='\\')
     {
      if(q) *ptr++='"';
      ptr2++;
      *ptr++='\n';
/*       q=NeedQuote(ptr2); */
      q = ActionArgsUnquoted[i] ? 0 : NeedQuote(ptr2);  /* 2.6 jjt */
     }
    *ptr++ = *ptr2++;
   }
  if(q) *ptr++='"';
  *ptr=0;
  i++;
 }
if(i<2&&!DMReqTagList(hail, str, 512, dostags)) return(0); /* 2.5.26 rri */
return(1);
}


APTR PoolAllocVec(APTR mempool, ULONG size) {  /* 2.5b10 jjt */
  ULONG *mem;

  size += 8;
  if ((mem = AllocPooled(mempool, size))) { /* 2.5.31 rri */
    *mem++ = (ULONG) mempool;  /* Store mem-pool addr. (will be ptr - 8 bytes) */
    *mem++ = size;             /* Store string len.    (will be ptr - 4 bytes) */
  }

  return (APTR) mem;
}


void PoolFreeVec(APTR memptr) {  /* 2.5b10 jjt */
  ULONG *mem;

/*
   memptr - 8 bytes = actual start of mem block.
   *(memptr - 8 bytes) = mem-pool addr.
   *(memptr - 4 bytes) = mem length.
*/

if (memptr)
 {
  mem = (ULONG *) memptr;

  FreePooled((APTR) (*(mem - 2)), mem - 2, *(mem - 1)); /* 2.5.31 rri */
 }
}


STRPTR CloneStr(CONST_STRPTR str, APTR mempool) {  /* 2.5b10 jjt */
  STRPTR newstr=NULL;

  if ((str) && (*str)) {
    if ((newstr = PoolAllocVec(mempool, (ULONG) (strlen(str) + 1)))) strcpy(newstr, str);
  }
  return newstr;
}


void CloneBuffer(struct DirWindow *dw,UBYTE *str) /* 2.5RC6 rri */
{
uint32 length;
STRPTR newpath; /* 2.7b7 rri */

if(str)
 {
  length=strlen(str);
 }
else length=0;

//dw->dir_str.Buffer=PoolAllocVec(NamePool,length+101);
newpath = PoolAllocVec(NamePool,length+101);

if(str)
 {
//  strcpy(dw->dir_str.Buffer,str);
  strcpy(newpath,str);
 }
else
 {
//  dw->dir_str.Buffer[0]=0;
  newpath[0]=0;
 }

//dw->dir_str.MaxChars=length+100;

if(dw->Path!=0)
 {
  PoolFreeVec(dw->Path);
 }
//dw->Path=dw->dir_str.Buffer;
dw->Path=newpath;

SetGadgetAttrs(dw->dwgad[GID_String], dw->Window, NULL,
                       STRINGA_TextVal, dw->Path,
                       STRINGA_MaxChars, length+100,
                       TAG_END,0);

}


struct DirWindow *FindDMWin(struct Window *win)
{
struct DirWindow *olddw=CDWin,*dmw=NULL;
int i;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  if(DirWin[i])
    {
    dmw=DirWin[i];
    if(win==dmw->Window)
     {
      if(dmw->Flags&DW_CMD)
       {
        CmdWin=dmw;
        DWNum=i;
        if (dmw->dwgadmain != 0) // test!
         {
          ShowDirection(dmw,2);
         }
/* test!
        else
         {
          if(dmw->parent.GadgetText->IText[0] != 'C')
           {
            ShowDirection(dmw,2);
           }
         }
*/
        return(dmw);
       }
      break;
     }
   }
 }

if(dmw&&(dmw->Window->Flags&WFLG_WINDOWACTIVE))
 {
  DWNum=i;
  CDWin=dmw;
  if(CDWin!=olddw)
   {
    if(!(olddw->Flags&DW_SOURCE))
     {
      ShowDirection(DestWin,3);
      DestWin=olddw;
     }
    ShowDirection(DestWin,1);
    ShowDirection(CDWin,0);
   }
 }

return(dmw);
}


void SetTitles()
{
struct DirWindow *dw;
UBYTE *ptr=ScreenTitle;
int     i;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&(dw->Window->Flags&WFLG_WINDOWACTIVE))
   {
    SetWindowTitles(dw->Window,dw->Title,ptr);
    break;
   }
 }
}


void FreeUserData() /* 2.5RC10 rri */
{
struct Message *msg; /* 2.5RC10 rri */
ULONG i;
struct TagItem warnreqtags[]={{DMREQ_BUTTONS, 0},         /* 2.6 jjt */
                              {DMREQ_NOHELPBTN, TRUE},
                              {DMREQ_HELPNODE, (ULONG) "n0!="}, /* View() exits when nodes don't exist */
                              {TAG_END, 0}};

warnreqtags[0].ti_Data = (ULONG) msgGadOkay; /* 2.6 jjt */

CloseRead();  /* 2.5b7 jjt */

while(ProcessCount)  /* 2.6 jjt */
{
 DMReqTagList(msgErrorAsyncWindows, 0, 0, warnreqtags); /* 2.6 rri */
}

for(i=0;i<255;i++)
 {
  if(i<DMMAXWINDOWS&&DirWin[i]) /* 2.5.23 rri */
   {
    CloseDirWindow(i);
    DirWin[i]=0;
   }
 }

if (FindPort(DMname)) /* 2.7 rri */
 {
  while((msg=GetMsg(WinPort))) /* clear message-port */
   {
    ReplyMsg(msg);
   }
  // moved to DM2main() in DM.c ! 2.7 rri
  // RemPort(WinPort); // shut-down message-port!
 }

FreeStringArray(AutoCmdStr, 255); /* 2.7 jjt */
FreeStringArray(KeyCmdStr, 100);  /* 2.7 jjt */

CDWin=DestWin=CmdWin=0;

MyFreeMenus();

DoStdio("CLOSE");

if(!(FLAGS&DMFLAG_KEEPGLOBAL)) /* 2.5RC2 rri */
 {
  FreeGlobuff(); /* 2.5b7 rri */
 }

GetHostScreen(0);

if(MyScreen)
 {
  while (CheckScreen())
   {
    DMReqTagList(msgErrorVisitorWindows, 0, 0, warnreqtags);  /* 2.6 jjt */
   }
  CloseScreen(MyScreen);
  InitScreenDefaults();
  MyScreen=0;
 }

SortType=0; /* 2.5.23 rri */

FLAGS|=DMFLAG_RESET; /* 2.5RC2 rri */
}


int BootBatch(UBYTE *ptr)
{
BPTR lock;

/* 2.5.24 rri */

if(ptr&&*ptr!=0) /* 2.5RC4 rri */
 {
  /* BootBatch is only called from DM2main() so Strap must be NULL now */
  if(!(Strap=CloneStr(ptr,NamePool)))
   {
    return 0;
   }
 }
else
 {
  if(!(Strap=CloneStr("DiskMaster2.prefs",NamePool))) /* 2.6 rri */
   {
    return 0;
   }
 }

if((lock=Lock(Strap,ACCESS_READ))) /* 2.5.23 gcc rri */
 {
  UnLock(lock);
  GetCmdFile(0,Strap,0);
 }
else
 {
  sprintf(sbuff,"S:%s",Strap);
  PoolFreeVec(Strap);
  if(!(Strap=CloneStr(sbuff,NamePool)))
   {
    return 0;
   }
  if((lock=Lock(Strap,ACCESS_READ)))
   {
    UnLock(lock);
    GetCmdFile(0,Strap,0);
   }
  else
   {
    PoolFreeVec(Strap);
    if(!(Strap=CloneStr("S:DiskMaster2.prefs",NamePool))) /* 2.6 rri */
     {
      return 0;
     }
    if(ptr && *ptr=='"') /* 2.5.25 rri */
     {
      ActionCmd(254,ptr+1); /* 2.5RC10 rri */
     }
    else /* invoke internal startup */
     {
      uint32 cwidth, lwidth; /* 2.7b11 rri */

      /* 2.5RC10 rri */
      if (!GetGlobuff()) return(0);
      FLAGS|=DMFLAG_BATCH;
      ActionCmd(254,"NewS");

      /* 2.7b11 rri */
      cwidth = Screen_Width / 5; // 640=128 800=160 960=192 1024=204,8 1088=217,6 1152=230,4 1280=256 1440=288 1600=320
      if ( (cwidth & 0x01 ) && ((Screen_Width & 0x01) == 0) ) // if cwidth is odd and screen-width is even
      {
       cwidth++; // add one to cwidth -> 1088=218 -> 1088-218=870 -> 870:2=435 -> 435+435+218=1088
      }          // 2345=469 -> 938+938+469=2345   1236=247.2=248 -> 494+494+248=1236

      lwidth = (Screen_Width - cwidth) / 2; // 640=256 800=320 960=384 1024=410 1088=435 1152=461 1280=512 1440=576 1600=640

      sprintf(Globuff,"OpenW Path=sys: Left=0 Top=%ld Width=%ld Height=%ld\n"
                      "OpenW Path=ram: Left=%ld Top=%ld Width=%ld Height=%ld\n"
                      "OpenW CMD Left=%ld Top=%ld Width=%ld Height=%ld\n",
                      Bar_Height+1,lwidth,Screen_Height,
                      lwidth+cwidth,Bar_Height+1,lwidth,Screen_Height,
                      lwidth,Bar_Height+1,cwidth,Screen_Height);

      DMstrcat(Globuff,DefStart);
      ActionCmd(254,Globuff);
      FLAGS&=~DMFLAG_BATCH;
      DMLayoutMenus();
      About();
     }
   }
 }

if(DirWin[0])
 {
  FindCmdWin(); /* 2.5b7 rri */
  return 1;
 }
return 0; /* 2.5.23 rri */
}


ULONG Char2Nibble(ULONG c) {  /* 2.5b11 jjt */

  /* Returns 0 - 15, or 255 if <c> isn't a hex digit. */
/* just convert to 0-15... */ /* 2.5RC9 rri */

/*  if (isxdigit(c)) { */
    c |= 32;  /* Letters to lowercase; no effect on numbers. */
    c -= c < 'a' ? '0' : 87;
/*  } */

  return c;
}


void RefreshDevLists(void) {  /* 2.5b12 jjt */
  ULONG i;
  struct DirWindow *dw;

  Busy(1);
  for (i=0; i<DMMAXWINDOWS; i++) { /* 2.5.23 rri */
    if((dw=DirWin[i])) { /* 2.5.23 gcc rri */
      if (((dw->Flags & DW_CMD) == 0) && (dw->Path[0] == 0)) {
        FreeDirTable(dw);
        GetDevList(dw);
      }
    }
  }
  Busy(0);
}


int FindPattern(UBYTE *str)
{
while(*str)
 {
  if(*str=='*'||*str=='?'||*str=='#') return(1);
  str++;
 }
return(0);
}


void Separate(struct DirWindow *dw)
{
UBYTE *mark,*str=dw->Path;
ULONG len=strlen(str);

mark=str; /* 2.5b10 rri */
dw->Pattern[0]=0;

while(len)
 {
  if(str[len]==':')
   {
    mark=str+len+1;
    break;
   }
 if(str[len]=='/')
  {
   mark=str+len;
   *mark=0;
   mark++;
   break;
  }
  len--;
 }

if(mark) /* 2.5.29 rri */
 {
  UBYTE *patternbuffer;

  if(( patternbuffer = FilterStar(mark) ))
   {
    DMstrncpy(dw->Pattern,patternbuffer,31);
    PoolFreeVec(patternbuffer);
    *mark=0;
   }
 }
StrToUpper(dw->Pattern); /* 2.5b7 rri */
}


void FontToAttr(struct TextFont *font, struct TextAttr *attr) {  /* 2.5RC2 jjt */
  /*  Fills in a TextAttr with info from a TextFont.
      Does not check if the TextAttr passed to it is valid.
  */

  if (font) {
    attr->ta_Name  = GetTFName(font);
    attr->ta_YSize = font->tf_YSize;
    attr->ta_Style = font->tf_Style;
    attr->ta_Flags = font->tf_Flags;
  }
  else
  {
    attr->ta_Name  = 0;
    attr->ta_YSize = 0;
    attr->ta_Style = 0;
    attr->ta_Flags = 0;
  }
}


LONG CharPos(UBYTE c, STRPTR str) {  /* 2.5RC9 jjt */
  LONG i;

  /* Returns the position of <c> in <str>, or -1.  Case insensitive. */

  c = ToUpper(c); /* 2.6 rri */

  for (i=0; *str != 0; i++) {
    if (c == ToUpper(*str)) break; /* 2.6 rri */
    str++;
  }
  if (*str == 0) i = -1;

  return i;
}


void DMstrcat(UBYTE *dest,const UBYTE *source) /* 2.5RC9 rri */
{
while (*dest) dest++;
while ((*dest++ = *source++)); /* 2.5.23 gcc rri */
}


/* always 0-terminated! */
void DMstrncpy(UBYTE *dest, const UBYTE *source, ULONG size) /* 2.5RC10 rri */
{
if(!dest || !source) return;

if(!size)
 {
  *dest=0;
  return;
 }

while(size&&(*dest = *source))
 {
  dest++;
  source++;
  size--;
 }

if(!size&&*source)
 {
  dest--;
  *dest=0;
 }
}


void FreeStringArray(UBYTE *strarray[], uint32 arraylen)  /* 2.7 jjt */
{
  uint32 i;
  STRPTR ptr;

  /* --- Free all strings in <strarray>, and reset the array items to 0 --- */

  for(i=0; i < arraylen; i++)
  {
    if ((ptr = strarray[i]))
    {
      PoolFreeVec(ptr);
      strarray[i] = 0;
    }
  }
}

