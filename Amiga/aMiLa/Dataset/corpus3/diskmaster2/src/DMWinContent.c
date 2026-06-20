/* DiskMaster2 window content module - generates and converts the strings
**
** 2.5.29
**
** 04-04-04 rri - Bugfix: While renaming files or while setting file-comments it could happen
**                        that single chars were swallowed untill a dir was completly updated.
**                        Thanks for reporting to Glenn Edward <glenn_edw@email.com>!
**
** 2.5.30
**
** 04-08-06 rri - Bugfix: Files without comments were displayed with the wrong width for the comment field.
**
** 04-08-15 rri - Bugfix: Removed RefreshWindowFrame() as introduced with 2.5.26 again as it lead to an
**                        irritating flickering of the whole window.
**                        Thanks for reporting to Ivan Awfulitch <ivan@MNSi.Net>!
**
** 04-08-28 rri - Fixed the bugfix: Not sure why but the comment-fix introduced an enforcer-hit.
**                Thanks for reporting to Karsten Fischer <fisk@uni-paderborn.de>!
**
** 2.5.31
**
** 05-03-19 rri - Introduced calculation of numbers with 64 bit entities for OS4 version.
**              - Removed usage of dw->DiskFree,
**              - Added unit "T" hardcoded to baseconvert - just in case...
**
** 05-03-20 rri - Added display of MEMF_VIRTUAL in the main-title as %j/%i for OS4.
**
** 2.5.32
**
** 05-05-29 rri - Bugfix: the 68k version tried to printf("%lld"...) (64bit) and for some reason this
**                        crashed under OS4 instantly but worked just fine under Amithlon.
**
** 2.6
**
** 05-07-10 rri - Bugfix: When starting from the internal startup the default-name for the startup
**                        was killed.
**
** 05-07-17 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**
** 05-07-31 rri - Removed three misplaced (uint32) casts for ToUpper().
**              - Replaced hardcoded "G" and "T" with msgUnitGigB and msgUnitTerB.
**
** 05-08-03 rri - Bugfix: softlinked-files were displayed with a size of "0".
**
** 05-08-10 rri - Broken soft-links are displayed as files with a size of zero
**                and a comment that this is a broken link.
**
** 05-08-11 rri - Broken soft-links are really displayed as files now...
**              - Localised the broken-link comment.
**
** 05-08-19 rri - Modified "timeplus" option to use the new flag DMFLAG_TIMEPLUS.
**              - Bufix: volumes with InfoData.id_NumBlocks=0 caused a division-by-zero error.
**                       Found with a "toasted" DVD-RW...
**
** 05-08-21 rri - Added a minimal version of DoFileFormat() to ReSize() in order to calculate
**                the line-width of the windows before displaying anything.
**
** 05-08-23 rri - Fixed a misplaced "++" in the new code of ReSize()...
**
** 05-11-05 rri - InitDir() does not clear the windows' DW_CMD flag anymore.
**
** 05-11-26 rri - Bugfix: Due to a typo the OS4 version displayed negative values
**                        in the window-title for dirs with 2gig+ of files.
**                        Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**
** 2.7 rri
**
** 06-11-25 rri - Splitted Resize() in OS4 branch and pre-OS4 branch and modified the
**                OS4 branch for use with ListBrowser.gadget.
**
** 06-12-04 rri - Removed some debug-output.
**
** b2
**
** 06-12-10 rri - Removed some test-code from InitDir().
**              - Modified InitDir() to update the path-gadget.
**              - Removed some obsolete lines from GetNewPath().
**
** b4
**
** 06-12-16 rri - Removed some more obsolete code.
**              - InitDir() clears the path-gadget when loading the DEV/VOL/ASN list now.
**              - Re-integrated DoExAll() from the 2.5RC1 source.
**
** 06-12-17 rri - Implemented V52 DOS dir-scanning in DoExamineDir() and disbled
**                DoExAll() again in favour of it.
**              - Fix: made ReSize() aware of negative file-sizes for dirs from ExamineDir().
**
** b6
**
** 06-12-21 rri - Set the var for LBNA_Selected in ConvertBase() to uint32.
**
** b7
**
** 06-12-30 rri - Replaced a reference to dir_gad in GetDevList() by dwgad[GID_String].
**
** 07-01-02 rri - Added window-pointers to two SetGadgetAttrs() calls in InitDir().
**              - Changed DoFileFormat()'s options to Date instead of Day/Month/Year - like the listers.
**              - Fix: the total-amount of bytes in a dir was a low negative number in case there
**                were only dirs displayed.
**
** b8
**
** 07-01-05 rri - New function: examinedata2dlp() - Called from UpDateDlp()/DMDisk.c and DoExamineDir().
**
** b9
**
** 07-01-21 rri - Fixed typo, examindedata2dlp() -> examinedata2dlp()...
**              - The windows are set to busy now during directory-load.
**              - Modified DiskShadow() to use ExamineObject() for the OS4 build.
** b10
**
** 07-01-27 rri - Instead of counting the selected entries in ReSize() the ListBrowser.gadget
**                is queried for that information.
**              - Separated the 68k and OS4 versions of ConvertBase() to make them more readable.
**              - Removed the 32-bit code from the OS4-build of ReSize().
**              - Fix: dir-sizes were added to the byte-count of files - "TitleFormat" "%A".
**
** 07-01-28 rri - Removed DoExamineDir() and examinedata2dlp() from the 68k build.
**              - Fix: pattern-matching was not working with the new ExamineDir() based dir-scanner.
**
** 07-02-04 rri - Fix: reset by pressing enter in the string.gadget of the command-window
**                     did not work in 2.7b9
**                     Using original DiskShadow() again, new one can't work as long as InitDir()
**                     accesses the fileinfoblock which is supposed to be initialised by DiskShadow()...
**
** b11
**
** 07-02-10 rri - 68k: fixed ReSize() to work with ListBrowser.gadget.
**
** 07-02-25 rri - Command-window paths are now set to the command-file used
**                or in case non is used to "S:DiskMaster2.prefs".
**                Thanks to Colin Ward for reminding me to fix this!
**
** 07-02-26 rri - Bugfix: resolving links was not working, the ObtainDirContextTags() call
**                        in DoExamineDir() needed an additional "EX_DoCurrentDir, TRUE,"
**                        because exd->link return by ExamineDir() is relative not absolute.
**
**
*/

#include "DM.h"

#define LENGTH(x)  (*(UBYTE *)BADDR(x))
#define STRING(x)  (((char *)BADDR(x))+1)

extern UBYTE BarFormat[],
             DispFormat[],
             *DevHide_List[], /* 2.5b12 jjt */
             DMname[],
             *Globuff, /* 2.5b7 rri */
             sbuff[],
             ScreenTitle[],
             *Strap, /* 2.5.24 rri */
             TitleFormat[],
             Version[];

extern LONG digits, /* 2.5.23 rri */
            Globuff_size, /* 2.5b7 rri */
            LastI, /* 2.5.23 rri */
            lockcount, /* 2.5.23 rri */
#ifndef __amigaos4__ /* 2.7b7 rri */
            long_month, /* 2.5b13 rri */
#endif
            Notify; /* 2.5.23 rri */

extern ULONG DevHide_Count,  /* 2.5b12 jjt */
             FLAGS, /* 2.5RC2 rri */
             OldDir; /* 2.5.23 rri */

extern APTR CommentPool, /* 2.5b10 rri */
            NamePool, /* 2.5b10 rri */
            StringPool; /* 2.5RC10 rri */

extern struct DirList *DClickDir;

extern struct DirWindow *CmdWin,
                        *DestWin,
                        *DirWin[];

extern struct InfoData InfoData;

extern struct StringHistory PathHistory;  /* 2.5b10 jjt */


ULONG ShowDev=SHOWDEV_ALL; /* 2.5b12 jjt */

LONG  Base_Str_Len=99999, /* 2.5.23 rri */
      separator=0x2e, /* 2.5RC8 rri */
      sizes=1; /* 2.5RC8 rri */

#ifdef __amigaos4__ /* 2.7b10 rri */
int64 BTotal, LTotal;
UBYTE *AddConvStr(UBYTE *ptr,int64 freebl,int32 bytes); /* 2.5.23 gcc rri */
#else
int32 BTotal, LTotal;
uint32 gigaflag,Bgigaflag;
UBYTE *AddConvStr(UBYTE *ptr,ULONG freebl,ULONG bytes); /* 2.5.23 gcc rri */
#endif

UBYTE *AddPercentStr(UBYTE *ptr,ULONG part,ULONG whole); /* 2.5.26 rri */
int CacheLoad(struct DirWindow *dw);
void ExDone(struct DirWindow *dw);


#ifdef __amigaos4__ /* 2.7b10 rri */
void ConvertBase(struct BaseConvert *basecon)
{
const UBYTE *base; /* 2.5b13 rri */
UBYTE *ptr;
LONG cnt=0; /* 2.5.24 rri */

ptr=basecon->String;

if (!basecon->BlocksFree)
 {
  basecon->DiskFree=0;
  *ptr++='0'; /* 2.5b13 rri */
  *ptr=0; /* 2.5b13 rri */
  return;
 }

basecon->DiskFree = (int64) basecon->BlocksFree * basecon->BytesPerBlock;

while(basecon->DiskFree > Base_Str_Len) /* 2.5.24 rri */
 {
  basecon->DiskFree += 512;
  basecon->DiskFree = basecon->DiskFree >> 10;
  cnt++;
 }

switch(cnt)
 {
  case 0:  base = msgUnitBytes;
           break;
  case 1:  base = msgUnitKiloB;
           break;
  case 2:  base = msgUnitMegB;
           break;
  case 3:  base = msgUnitGigB; /* 2.6 rri */
           break;
  case 4:  base = msgUnitTerB; /* 2.6 rri */
           break;
  default: base = msgUnitBytes;
           break;
 }

sprintf(ptr,"%lld %s",basecon->DiskFree,base); /* 2.5.31 rri */
}
#else
void ConvertBase(struct BaseConvert *basecon)
{
const UBYTE *base; /* 2.5b13 rri */
UBYTE *ptr;
LONG cnt=0; /* 2.5.24 rri */

ptr=basecon->String;

if (!basecon->BlocksFree)
 {
  basecon->DiskFree=0;
  *ptr++='0'; /* 2.5b13 rri */
  *ptr=0; /* 2.5b13 rri */
  return;
 }

if(basecon->BlocksFree < (2147483647 / basecon->BytesPerBlock))
 {
  basecon->DiskFree = basecon->BlocksFree * basecon->BytesPerBlock;
 }
else
 {
  basecon->DiskFree += 512; /* 2.5RC10 rri */
  basecon->DiskFree = basecon->BlocksFree >> 10; /* 2.5RC9 rri */
  basecon->DiskFree = basecon->DiskFree * basecon->BytesPerBlock;
  cnt++; /* 2.5.24 rri */
 }

while(basecon->DiskFree > Base_Str_Len) /* 2.5.24 rri */
 {
  basecon->DiskFree += 512;
  basecon->DiskFree = basecon->DiskFree >> 10;
  cnt++;
 }

switch(cnt)
 {
  case 0:  base = msgUnitBytes;
           break;
  case 1:  base = msgUnitKiloB;
           break;
  case 2:  base = msgUnitMegB;
           break;
  case 3:  base = msgUnitGigB; /* 2.6 rri */
           break;
  case 4:  base = msgUnitTerB; /* 2.6 rri */
           break;
  default: base = msgUnitBytes;
           break;
 }

sprintf(ptr,"%ld %s",basecon->DiskFree,base);
}
#endif


#ifdef __amigaos4__ /* 2.7 rri */
void ReSize(struct DirWindow *dw)
{
struct DirList **dl=dw->DirList,
       *dlp=0;

int64 total=0,
      dirsize=0; /* 2.7b10 rri */
uint32 selectstate;
int32 i,sels=0;

/* bftotal -> Sum of File-Sizes without dirs */
/* total -> Sum of selected entries' sizes */

BTotal = 0; /* 2.7b10 rri */

GetAttr(LISTBROWSER_NumSelected,dw->dwgad[GID_List], &sels); /* 2.7b10 rri */
dw->Sels=sels;

for(i=0;i<dw->FileCount;i++)
 {
  dlp=dl[i];

  if(dlp->dir == 0) /* only count file's sizes */ /* 2.7b10 rri */
//  if (dlp->size > 0) /* 2.7b7 rri - necessary as with ExamineDir() dirs have a size of -1 ... */
  {
   BTotal += dlp->size; /* sum up sizes of all entries */
  }

  GetListBrowserNodeAttrs(dlp->node, LBNA_Selected, &selectstate, TAG_DONE, 0);

  if (selectstate != 0) /* calculate selected files/dirs only */
   {
    if(dlp->dir) /* separate dirs from files */
     {
      /* 2.7b10 rri - removed, was a workaround for a bug in some handler...
      if(dlp->size>536870912) // if a single dir is bigger than
       {                      // 2^29 * 512 = 256 GByte something is wrong...
        dlp->size=0;
       }
      */
      if (dlp->size > 0)   /* 2.7b10 rri */
      {                    /* the dlp->size var already holds the amount of */
       dirsize+=dlp->size; /* used blocks after 'Check' */
      }
      continue;
     }
     total += dlp->size;
   }
 }

 LTotal = total + (dirsize * dw->BytesPerBlock); /* 2.7b10 rri */
}

#else /* 68k version with 32bit arithmetics - 2.7b11 rri */
void ReSize(struct DirWindow *dw) /* 2.5b5 rri */
{
struct DirList **dl=dw->DirList,
       *dlp=0;
int32 i;
uint32 selectstate;

int32 total[100],bftotal[100]; /* 2.5b11 rri - max headroom now 200gig... */
uint32 sels=0,totaltest,bftest;
LONG x=0,y=0;

int32 dirsize=0;

/* bftotal -> Sum of File-Sizes without dirs */
/* total -> Sum of selected entries' sizes */

memset (total, 0, sizeof (total)); /* 2.7 rri */
memset (bftotal, 0, sizeof (bftotal)); /* 2.7 rri */

GetAttr(LISTBROWSER_NumSelected,dw->dwgad[GID_List], &sels);
dw->Sels=sels;

for(i=0;i<dw->FileCount;i++)
 {
  dlp=dl[i];

  GetListBrowserNodeAttrs(dlp->node, LBNA_Selected, &selectstate, TAG_DONE, 0);

  if (dlp->dir == 0)
   {
    bftest=bftotal[y]+dlp->size; /* 2gig boundary check */
    if (bftest>0x7fffffff) /* 2.5.23 gcc rri */
     {
      y++;
      if(y>99) /* 2.5b11 rri - better limit display to 200 gig than */
       {       /* crashing the machine... */
        y=99;
        bftotal[y]=0;
       }
      }
    bftotal[y]+=dlp->size;
   }

  if (selectstate != 0) /* calculate selected files/dirs only */
   {
    if(dlp->dir) /* separate dirs from files */
     {
      if(dlp->size>536870912) /* if a single dir is bigger than */
       {                      /* 2^29 * 512 = 256 GByte something is wrong... */
        dlp->size=0;          /* 2.5b11 rri */
       }                  /* the dlp->size var already holds the amount of */
      dirsize+=dlp->size; /* used blocks after 'Check' */
      continue;           /* 2^31 * 512 = 1 TByte max... */
     }
    totaltest=total[x]+dlp->size; /* 2gig boundary check */
    if (totaltest>0x7fffffff) /* 2.5.23 gcc rri */
     {
      x++;
      if(x>99) /* 2.5b11 rri */
       {
        x=99;
        total[x]=0;
       }
     }
    total[x]+=dlp->size;
   }
 }

 if(y>0) /* 2.5b5 rri */
  {
   BTotal=0;
   y=0;
   while (bftotal[y])
    {
     BTotal+=(bftotal[y]>>7); /* 2.5RC9 rri *//* 2.5b11 rri - 256 GByte max now */
     y++;
    }
   Bgigaflag=127; /* 2.5b13 rri */
  }
 else
  {
   BTotal=bftotal[0];
   Bgigaflag=0;
  }

 bftest = 100 * dw->BytesPerBlock; /* 2.5b10 rri */

 while(dirsize) /* 2.5b10 rri */
  {
   totaltest=total[x]+bftest; /* add the size of hundred blocks each loop */
   if (totaltest>0x7fffffff) /* 2.5.23 gcc rri */
    {
     x++;
    }
   if(dirsize>100)
    {
     total[x] += bftest;
     dirsize -= 100;
    }
   else
    {
     total[x] += dirsize * dw->BytesPerBlock;
     break;
    }
  }

 if(x>0)
  {
   LTotal=0;
   x=0;
   while (total[x])
    {
     LTotal+=(total[x]>>7); /* 2.5RC9 rri */
     x++;
    }
   gigaflag=127; /* 2.5b13 rri */
  }
 else
  {
   LTotal=total[0];
   gigaflag=0;
  }
}
#endif


UBYTE *AddPercentStr(UBYTE *ptr,ULONG part,ULONG whole) /* 2.5.26 rri */
{
ULONG var;

if(whole > 0) /* 2.6 rri */
 {
  if(part>0xffffff) /* we have to deal with bigger numbers */
   {
    whole = whole / 100;
    var = part + (part % whole);
   }
  else /* normal operation */
   {
    var = part * 100;
    var = var + (var % whole);
   }
  var = var / whole;
 }
else
 {
  var = 0;
 }

sprintf(ptr,"%ld%%",var);
ptr += strlen(ptr);
return(ptr);
}


#ifdef __amigaos4__ /* 2.7b10 rri */
UBYTE *AddConvStr(UBYTE *ptr,int64 freebl,int32 bytes)
#else
UBYTE *AddConvStr(UBYTE *ptr,ULONG freebl,ULONG bytes) /* 2.5.23 gcc rri */
#endif
{
struct BaseConvert winbase; /* 2.5b13 rri */

winbase.BytesPerBlock=bytes; /* 2.5b13 rri */

winbase.BlocksFree=freebl; /* 2.5.23 gcc rri */
ConvertBase(&winbase);
strcpy(ptr,winbase.String);
ptr+=strlen(winbase.String);
return(ptr);
}


void MainTitle()
{
UBYTE *ptr=ScreenTitle,*dptr=BarFormat;
ULONG c,chip,fast,any; /* 2.5.26 rri */

#ifdef __amigaos4__ /* 2.5.31 rri */
uint32 virtual;
#endif

struct DateTime DateTime;
UBYTE  Day[16],Time[16],Date[16];

DateStamp(&DateTime.dat_Stamp);

DateTime.dat_Format  = FORMAT_INT; /* yy-mmm-dd e.g. 00-Jul-13 */
DateTime.dat_Flags   = 0;
DateTime.dat_StrDay  = Day;
DateTime.dat_StrDate = Date;
DateTime.dat_StrTime = Time;

DateToStr(&DateTime);

Time[5]=0; /* cut-off seconds from time-string */

/* 2.5.26 rri */
#ifdef __amigaos4__ /* 2.5.31 rri */
virtual = AvailMem(MEMF_VIRTUAL);
#endif
chip = AvailMem(MEMF_CHIP);
fast = AvailMem(MEMF_FAST);
any = AvailMem(MEMF_ANY);

while((c = *dptr++)&&(ptr-ScreenTitle<200))
 {
  if(c!='%') *ptr++=c;
  else switch(c=ToUpper(*dptr++)) /* 2.6 rri */
   {
    case  0 : return;
    case 'A': strcpy(ptr,DMname);
              ptr+=strlen(DMname);
              break;

    /* 2.5.26 rri */
    case 'C': ptr=AddConvStr(ptr,chip,1);
              break;
    case 'B': ptr=AddPercentStr(ptr,chip,AvailMem(MEMF_CHIP|MEMF_TOTAL));
              break;
    case 'F': ptr=AddConvStr(ptr,fast,1);
              break;
    case 'E': ptr=AddPercentStr(ptr,fast,AvailMem(MEMF_FAST|MEMF_TOTAL));
              break;
    #ifdef __amigaos4__ /* 2.5.31 rri */
    case 'J': ptr=AddConvStr(ptr,virtual,1);
              break;
    case 'I': ptr=AddPercentStr(ptr,virtual,AvailMem(MEMF_VIRTUAL|MEMF_TOTAL));
              break;
    #endif
    case 'P': ptr=AddConvStr(ptr,any,1);
              break;
    case 'O': ptr=AddPercentStr(ptr,any,AvailMem(MEMF_ANY|MEMF_TOTAL));
              break;

    case 'T': strcpy(ptr,Time); ptr+=strlen(Time); break;

    /* 2.5b7 rri */
    case 'D': ptr[0]=Date[strlen(Date)-2]; /* 2.5b13 rri */
              ptr[1]=Date[strlen(Date)-1]; /* 2.5b13 rri */
              ptr+=2;
              break;
    case 'M': ptr[0]=Date[3];
              ptr[1]=Date[4];
              ptr[2]=Date[5];
              ptr+=3;
              if(Date[6]!='-') *ptr++=Date[6]; /* 2.5b13 rri */
              break;
    case 'Y': ptr[0]=Date[0];
              ptr[1]=Date[1];
              ptr+=2;
              break;
    /* 2.5b7 rri */
    case 'W': strcpy(ptr,Day);
              ptr+=strlen(Day);
              break;
    case 'V': c=0;
              while (Version[11+c])
               {
                *ptr++=Version[11+c++];
               }
              break;
    default : *ptr++=c;
   }
 }
*ptr=0;
}


void WinTitle(struct DirWindow *dw)
{
UBYTE *ptr,*dptr=TitleFormat;
ULONG c;
BPTR lock;
struct BaseConvert winbase;

MainTitle();
if(!dw) return; /* 2.5.24 rri */

ReSize(dw);

sbuff[0]=0; /* 2.5RC6 rri */
ptr=sbuff; /* use sbuff[] to build title-line - 2.5RC6 rri */

if((lock=Lock(dw->Path,ACCESS_READ))) /* 2.5.26 rri */
 {
  Info(lock,&InfoData);
 }

if(dw->FileCount && dw->DirList[0]->dir>1)
 {
 }

else while((c = *dptr++)&&(ptr-sbuff<100)) /* 2.5RC6 rri */
 {
  if(c!='%') *ptr++=c;
  else switch(c=ToUpper(*dptr++)) /* 2.6 rri */
   {
    case   0: return;
    case 'A': /* files` sizes  2.5b5 rri */
              #ifdef __amigaos4__
              ptr=AddConvStr(ptr,BTotal,1);  /* 2.7b10 rri */
              #else
              ptr=AddConvStr(ptr,BTotal,Bgigaflag+1);  /* 2.5b13 rri */
              #endif
              break;
    case 'B': /* selected files+dirs sizes */
              #ifdef __amigaos4__
              ptr=AddConvStr(ptr,LTotal,1);  /* 2.7b10 rri */
              #else
              ptr=AddConvStr(ptr,LTotal,gigaflag+1);  /* 2.5b13 rri */
              #endif
              break;
    case 'C': /* amount of files */
              ptr=AddConvStr(ptr,(ULONG) dw->FileCount,1);  /* 2.5b13 rri */
              if(dw->FileCount) /* remove " B" from converted string */
               {
                ptr-=2;
                *ptr=0;
                ptr[1]=0; /* 2.5RC7 rri */
               }
              break;
    case 'F': /* free space available */
              if(lock) /* 2.5.26 rri */
               {
                winbase.BlocksFree=InfoData.id_NumBlocks-InfoData.id_NumBlocksUsed;
                dw->BlocksFree=winbase.BlocksFree;
                winbase.BytesPerBlock=InfoData.id_BytesPerBlock;
                dw->BytesPerBlock=InfoData.id_BytesPerBlock; /* 2.5b5 rri */
                ConvertBase(&winbase);
                /* dw->DiskFree = winbase.DiskFree; */ /* 2.5.31 rri */
                strcpy(ptr,winbase.String);
                ptr+=strlen(winbase.String);
               }
              break;
    case 'I': /* number of selected files */
              ptr=AddConvStr(ptr,(ULONG) dw->Sels,1);  /* 2.5b13 rri */
              if(dw->Sels) /* remove " B" from converted string */
               {
                ptr-=2;
                *ptr=0;
                ptr[1]=0; /* 2.5RC7 rri */
               }
              break;
    case 'N': /* unique name for window-managers */ /* 2.5.26 rri */
              sprintf(ptr,"%s.%ld",DMname,dw->Number);
              ptr+=strlen(ptr);
              break;
    case 'O': /* occupied disk-space as percentage of available space */ /* 2.5.26 rri */
              if(lock)
               {
                ptr = AddPercentStr(ptr, InfoData.id_NumBlocksUsed, InfoData.id_NumBlocks);
               }
              break;
    case 'P': /* free disk-space as percentage of available space */ /* 2.5.26 rri */
              if(lock)
               {
                ptr = AddPercentStr(ptr, InfoData.id_NumBlocks-InfoData.id_NumBlocksUsed, InfoData.id_NumBlocks);
               }
              break;

    default : *ptr++=c;
   }
 }
*ptr=0; /* 2.5RC7 rri */

if(lock) /* 2.5.26 rri */
 {
  UnLock(lock);
 }

/* 2.5RC6 rri */
if(dw->Title != 0)
 {
  PoolFreeVec(dw->Title);
 }

dw->Title=CloneStr(sbuff, NamePool);

if(sbuff[0] == 0)
 {
  SetWindowTitles(dw->Window,0,ScreenTitle); /* 2.5.30 rri */
 }
else
 {
  SetWindowTitles(dw->Window,dw->Title,ScreenTitle);
 }
}

#ifndef __amigaos4__ /* 2.7b7 rri - this function is obsolete with Reaction-Windows */
void DoFileFormat(struct DirList *dlp,struct DirWindow *dw) /* 2.5RC7 rri */
{
UBYTE *ptr=sbuff,*dptr=DispFormat,*ptr2,*ptr3,
      digit[10]; /* 2.5RC7 rri */

int c;
struct BaseConvert winbase;
LONG ai, value; /* 2.5RC8 rri */

/* 2.5b7 rri */
struct DateTime DateTime;
UBYTE Time[16],Date[16];

DateTime.dat_Format    = FORMAT_DEF; /* 2.7b7 rri */
DateTime.dat_Flags     = 0;
DateTime.dat_StrDay    = NULL;
DateTime.dat_StrDate   = Date;
DateTime.dat_StrTime   = Time;

DateTime.dat_Stamp=dlp->ds;
DateToStr(&DateTime);

if(FLAGS & DMFLAG_TIMEPLUS) /* 2.6 rri */
 {
  sprintf(digit,":%02ld",dlp->ds.ds_Tick % 50);
  DMstrcat(Time,digit);
 }
else
 {
  Time[5]=0;
 }

/* 2.5b7 rri */

memset(ptr,' ',300); /* 2.5b10 rri */

/* 2.5RC10 rri */
if(dlp->dir==3) /* set display-format for cmd-windows fixed to 'N' */
 {
  digit[0]='N';
  digit[1]=0;
  dptr=digit;
 }

while(*dptr&&(ptr-sbuff<150))
 {
  switch(c=ToUpper(*dptr++)) /* 2.6 rri */
   {
    case 'N': if(dlp->name) /* 2.5RC8 rri */
               {
                ptr2=dlp->name;
                ptr3=ptr;
                if(ptr2) while(*ptr2) *ptr3++ = *ptr2++;
                ptr+=dw->ColsName;
                value = strlen(dlp->name); /* 2.5.29 rri */
                if(dw->ColsName < value) ptr+=value-dw->ColsName; /* 2.5.29 rri */
               }
              break;

    case 'C': /* if(dlp->dir==3) break; */ /* impossible - removed 2.5RC10 rri */
              if(dlp->dir==2)
               {
                ptr3=ptr+2;
                ptr2=0;
                if(dlp->attr==DLT_DEVICE) ptr2="(DEV)";
                else if(dlp->attr==DLT_VOLUME) ptr2="(VOL)";
                else if(dlp->attr==DLT_DIRECTORY) ptr2="(ASN)";
                dw->ColsCmt=7; /* 2.5RC7 rri */
               }
              else
               {
                ptr2=dlp->cmt;
                ptr3=ptr;
               }
              value = 0; /* 2.5.30 rri */
              if(ptr2)
               {
                while(*ptr2)
                 {
                  *ptr3++ = *ptr2++;
                  value++; /* 2.5.30 rri */
                 }
               }
              ptr+=dw->ColsCmt&0xFFF; /* 2.5RC7 rri */
              if((dw->ColsCmt&0xFFF) < value) ptr+=value-(dw->ColsCmt&0xFFF); /* 2.5.29 rri */
              break;

    case 'S': if(dlp->dir>1) break;
              value=winbase.BlocksFree=dlp->size;
              ai=(dw->ColsCmt>>12)-1;
              sprintf(digit,"%%%lds",ai+1);

              if(dlp->dir==1) /* 2.5RC8 rri */
               {
                if(dlp->size > 0) /* 2.7 rri */
                 {
                  winbase.BytesPerBlock=dw->BytesPerBlock; /* 2.5RC7 rri */
                  ConvertBase(&winbase);
                  sprintf(ptr,digit,winbase.String); /* 2.5RC7 rri */
                 }
               }
              else
               {
                if(sizes==2) /* 2.5RC8 rri */
                 {
                  winbase.BytesPerBlock=1;
                  ConvertBase(&winbase);
                  sprintf(ptr,digit,winbase.String);
                 }
                else /* sizes==1 / sizes==3 */ /* 2.5RC8 rri */
                 {
                  c=0;
                  for(;ai>=0;ai--)
                   {
                    if(sizes==3&&c==3)
                     {
                      ptr[ai]=separator; /* insert separator every three chars */
                      c=0;
                      continue;
                     }
                    ptr[ai]=(value % 10)+0x30; /* add current digit */
                    value=value/10;
                    if(value==0) break;
                    c++;
                   }
                 }
               }
              ptr+=(dw->ColsCmt>>12); /* 2.5RC8 rri */
              break;

    case 'T': if(dlp->dir<2)
               {
                ptr2=Time;
                ptr3=ptr;
                while(*ptr2) *ptr3++ = *ptr2++;
                ptr+=strlen(Time);
               }
              break;

    /* 2.7b7 rri - changed Day/Month/Year to Date - just like the listers */
    case 'D': if(dlp->dir<2)
               {
                ptr2=Date;
                ptr3=ptr;
                while(*ptr2) *ptr3++ = *ptr2++;
                ptr+=strlen(Date);
               }
              break;

    case 'A': if(dlp->dir<2)
               {
                StampProt(ptr,dlp->attr);
                ptr+=8;
                *ptr=' '; /* 2.5RC10 rri */
               }
              break;

    default : if(dlp->dir<2) *ptr++=c;
   }
 }
*ptr=' '; /* 2.5RC6 rri */
dw->Collums=(ptr-sbuff)+1; /* 2.5RC7 rri */
}
#endif

void QueryDosList(struct DirWindow *dw, struct DosList *doslist,int type) /* 2.5b12 rri */
{
struct DirList **dl,*dlp;
ULONG l,fl;

dl=dw->DirList;

l=LENGTH(doslist->dol_Name);

/* 2.5b12 jjt */
for (fl=0; fl < DevHide_Count; fl++)
 {
  /* --- Is this dev one the user wants to hide? --- */
  if (strlen(DevHide_List[fl]) == l)
   {
    if((Strnicmp(STRING(doslist->dol_Name),DevHide_List[fl],(LONG)l))==0) break;
   }
 }

if (fl == DevHide_Count)
 {
  if(!AllocDlp(dw)) return;
  dlp=dl[dw->FileCount++];
  dlp->dir=2;
  dlp->attr=type;
  if((dlp->name=PoolAllocVec(NamePool,(ULONG)(l+2))))
   {
    sprintf(dlp->name,"%s:",STRING(doslist->dol_Name)); /* 2.5.23 gcc rri */
   }
 }
}


void GetDevList(struct DirWindow *dw) /* 2.5b12 rri */
{
struct DosList *doslist;
struct DirList **dl;
ULONG x;

dl=dw->DirList;

if (ShowDev & SHOWDEV_DEV)
 {
  doslist = LockDosList(LDF_DEVICES|LDF_READ);
  while((doslist = NextDosEntry(doslist,LDF_DEVICES))) /* 2.5.23 gcc rri */
   {
    if(doslist->dol_Task)
     {
      QueryDosList(dw,doslist,DLT_DEVICE);
     }
   }
  UnLockDosList(LDF_DEVICES|LDF_READ);
  DMSortN(dl,dw->FileCount,0);
 }

x=dw->FileCount;

if (ShowDev & SHOWDEV_VOL)
 {
  doslist = LockDosList(LDF_VOLUMES|LDF_READ);
  while((doslist = NextDosEntry(doslist,LDF_VOLUMES))) /* 2.5.23 gcc rri */
   {
    QueryDosList(dw,doslist,DLT_VOLUME);
   }
  UnLockDosList(LDF_VOLUMES|LDF_READ);
  dl = &dw->DirList[x];
  DMSortN(dl,dw->FileCount-x,0);
 }

x=dw->FileCount;

if (ShowDev & SHOWDEV_ASN)
 {
  doslist = LockDosList(LDF_ASSIGNS|LDF_READ);
  while((doslist = NextDosEntry(doslist,LDF_ASSIGNS))) /* 2.5.23 gcc rri */
   {
    if(doslist->dol_Type==DLT_DIRECTORY)
     {
      QueryDosList(dw,doslist,DLT_DIRECTORY);
     }
   }
  UnLockDosList(LDF_ASSIGNS|LDF_READ);
  dl = &dw->DirList[x];
  DMSortN(dl,dw->FileCount-x,0);
 }

CloneBuffer(dw,0); /* 2.5RC6 rri */

NewSize(dw);
RefreshGadget(dw->dwgad[GID_String],dw->Window); /* 2.7b7 rri */
}


/* --------------------------- DIRECTORY LOAD --------------------------------- */

/*

test with a dir that has 18743 files on a FFS2 partition
with 8192 byte sized blocks:

using ExNext(): 9.1x seconds
using DoExAll(): 8.0x seconds

*/

/* 2.7b10 rri - implemented in DoExamineDir() directly instead
struct Hook ExamineDirHook;

#ifdef __amigaos4__
int32 SAVEDS ASM examinedir_hook(REG(a0, struct Hook *hook UNUSED),
                                 REG(a2, STRPTR match_string),
                                 REG(a1, struct ExamineData *examinedata))
{
// Printf("xx %s\n",match_string); // test!

 return (MatchPatternNoCase(match_string,examinedata->Name));
}
#endif
*/

#ifdef __amigaos4__
void examinedata2dlp(struct DirList *dlp,struct ExamineData *dat)
{
 dlp->name = CloneStr(dat->Name, NamePool);
 dlp->cmt = CloneStr(dat->Comment, CommentPool);
 dlp->size = dat->FileSize;
 dlp->attr = dat->Protection;
 dlp->ds = dat->Date;

 dlp->dir=0;

 if ( EXD_IS_DIRECTORY(dat) )
 {
  dlp->dir = 1;
 }

 if( EXD_IS_SOFTLINK(dat) )
 {
  struct ExamineData *linkedobj;

//Printf("%s is a link to %s!\n",dlp->name,dat->Link); // test!

  if(( linkedobj = ExamineObjectTags(EX_StringName, dat->Link, TAG_END) ))
  {
   if ( EXD_IS_DIRECTORY(linkedobj) ) /* linked entry is a dir */
   {
    dlp->dir = 1;
   }
   else /* linked object is a file, copy the correct file-size */ /* 2.7b11 rri */
   {
    dlp->size = linkedobj->FileSize;
   }
   FreeDosObject(DOS_EXAMINEDATA,linkedobj);
  }
 }
}
#endif


#ifdef __amigaos4__
void DoExamineDir(struct DirWindow *dw) /* 2.7 rri for use with DOS V52 */
{
APTR context;
UBYTE buffer[100];
STRPTR matchstring = NULL;
struct DirList *dlp;

if(dw->Pattern[0])
{
 strcpy(buffer,dw->Pattern);
 FilterStar(buffer);
 if (ParsePatternNoCase(buffer,sbuff,300)>=0)
 {
  matchstring = sbuff;
 }
}

context = ObtainDirContextTags(EX_FileLock, dw->DirLock,
                               EX_DoCurrentDir, TRUE, /* 2.7b11 rri */
                               // EX_DataFields,    ,
                               TAG_END);

if(context)
{
 struct ExamineData *dat;

 while((dat = ExamineDir(context))) /* until you run out of data.*/
 {
  if (matchstring != NULL && EXD_IS_FILE(dat)) /* 2.7b10 rri */ /* links are not handled... */
  {
   if (MatchPatternNoCase(matchstring,dat->Name) == 0)
   {
    continue;
   }
  }

  if(!AllocDlp(dw)) break;
  dlp=dw->DirList[dw->FileCount++];
  examinedata2dlp(dlp,dat); /* 2.7b9 rri */
 }

 if( ERROR_NO_MORE_ENTRIES != IoErr() )
 {
  PrintFault(IoErr(),NULL); /* failure - find out why */
 }
}
else
{
 PrintFault(IoErr(),NULL); /* failure - find out why */
}

ReleaseDirContext(context);   /* NULL safe */
ExDone(dw);
}
#endif

/*
void DoExAll(struct DirWindow *dw) // 2.7 rri - copied from 2.5RC1
{
struct ExAllControl *eac;
struct ExAllData *ead,*eadp;
struct DirList *dlp;
LONG more,res2;
ULONG n;
BPTR lock;
sFIB *info;
UBYTE buffer[100];

if((eac = AllocDosObject(DOS_EXALLCONTROL,NULL)) != NULL)
 {
  if (GetGlobuff())
   {
    ead=(struct ExAllData *)Globuff;
    eac->eac_MatchString=NULL;
    if(dw->Pattern[0])
     {
      strcpy(buffer,dw->Pattern);
      FilterStar(buffer);
      if (ParsePatternNoCase(buffer,sbuff,300)>=0)
       {
        eac->eac_MatchString=sbuff;
       }
     }
    eac->eac_LastKey = 0;
    eac->eac_MatchFunc=NULL;
    do
     {
      more = ExAll(dw->DirLock, ead, Globuff_size, ED_COMMENT, eac);
      res2 = IoErr();
      for (eadp=ead,n=eac->eac_Entries;n!=0;eadp=eadp->ed_Next,--n)
       {
        if(!AllocDlp(dw)) break;
        dlp=dw->DirList[dw->FileCount++];
        dlp->name = CloneStr(eadp->ed_Name, NamePool);
        dlp->size=eadp->ed_Size;
        dlp->attr=eadp->ed_Prot;
        dlp->ds.ds_Days=eadp->ed_Days;
        dlp->ds.ds_Minute=eadp->ed_Mins;
        dlp->ds.ds_Tick=eadp->ed_Ticks;

        dlp->dir=0;

        if(eadp->ed_Type==3)
         {
          if((lock=Lock(eadp->ed_Name,ACCESS_READ)))
           {
            if((info=AllocMem(sizeof(sFIB),MEMF_PUBLIC)))
             {
              if(Examine(lock,info))
               {
                if(info->fib_DirEntryType>0)
                 {
                  dlp->dir=1;
                 }
               }
              FreeMem(info,sizeof(info));
             }
            UnLock(lock);
           }
         }
        else if(eadp->ed_Type>=0) dlp->dir=1;

        dlp->cmt = CloneStr(eadp->ed_Comment, CommentPool);
       }
      if ((!more) && (res2 == ERROR_NO_MORE_ENTRIES))
       {
        continue; // ExAll failed normally with no entries
       }
     } while (more);
   }
  FreeDosObject(DOS_EXALLCONTROL,eac);
 }
Printf("DoExAll() done!\n"); // test!
ExDone(dw);
}
*/

void GetDirEntry(struct DirWindow *dw)
{
sFIB *fib=dw->Fib;

#ifndef __amigaos4__
struct DirList  *dlp;
int i;
#endif

if((dw->Flags&DWFLAG_RELOAD)&&!dw->DirLock)
 {
  InitDir(dw,0);
  return;
 }

if(!dw->DirLock||!fib) return;

#ifdef __amigaos4__
// DoExAll(dw);
 Busy(1); /* 2.7b9 rri */
 DoExamineDir(dw);
 Busy(0); /* 2.7b9 rri */
 return;
#else

i=ExNext(dw->DirLock,fib);

if(i&&dw->Pattern[0]&&fib->fib_DirEntryType<0) /* 2.5RC6 rri */
 {
  if(!DMMatch(fib->fib_FileName,dw->Pattern)) return;
 }

if(!i||!AllocDlp(dw))
 {
  ExDone(dw);
  return;
 }
dlp=dw->DirList[dw->FileCount++];

/* soft-link detection - 2.5.28 rri */
if(fib->fib_DirEntryType == ST_SOFTLINK)
 {
  BPTR lock;
  struct FileInfoBlock *info;

  strcpy(sbuff,dw->Path);
  AddPart(sbuff,fib->fib_FileName,4000);

  if((lock=Lock(sbuff,ACCESS_READ))) /* a link is resolved here */
   {
    if((info=AllocDosObject(DOS_FIB,TAG_DONE) ))
     {
      if(Examine(lock,info))
       {
        fib->fib_DirEntryType = info->fib_DirEntryType;
        fib->fib_Size = info->fib_Size; /* 2.6 rri */
       }
      FreeDosObject(DOS_FIB,info);
     }
    UnLock(lock);
   }
  else /* 2.6 rri */
   {
    /* the Lock() can only fail if the link is broken */

    fib->fib_DirEntryType = -1; /* mark as file, no matter what */
    fib->fib_Size = 0; /* entry is invalid, so display size as 0 */
    DMstrncpy(fib->fib_Comment,msgBrokenLink,79); /* mark entry as broken link */
   }

 }
Fib2Dlp(dlp,fib);
#endif
}


void InitDir(struct DirWindow *dw,int set)
{
BPTR lock; /* 2.5b13 rri */
uint32 *mem;

FreeDirTable(dw);

/*dw->Flags&=~0xF; // clears first four flags - in since 2.1c */
dw->Flags &= ~(/*DW_CMD|*/DWFLAG_RESORT|DWFLAG_ADD|DWFLAG_RELOAD); /* 2.6 rri */
//dw->Index=0; /* 2.7 rri */

if(!dw->Fib)
 {
  if(!(dw->Fib=AllocDosObject(DOS_FIB,TAG_DONE) )) /* 2.5.28 rri */
   {
    return;
   }
 }

Busy(1); /* 2.5b7 rri */

if(dw->Path[0])
 {
  while (dw->Path[strlen(dw->Path)-1] == '/') /* 2.5b9 rri */
   {
    dw->Path[strlen(dw->Path)-1]=0;
   }
  if (dw != CmdWin) StrHist_Add(&PathHistory, dw->Path); /* Cache path */  /* 2.5b10 jjt */

  if((lock=Lock(dw->Path,ACCESS_READ))) /* 2.5.23 gcc rri */
   {
    if(FLAGS&DMFLAG_EXPAND) /* 2.5RC2 rri */
     {
      NameFromLock(lock, sbuff, 4096); /* 2.5RC6 rri */
      CloneBuffer(dw,sbuff); /* 2.5RC6 rri */
     }
    UnLock(lock);

    if(!DiskShadow(dw,dw->Fib)) goto Q;

    /* 2.7 rri */
    mem = (uint32 *) dw->Path; /* allocated with PoolAllocVec()! */
    mem--;                     /* this is the size of the buffer */
    SetGadgetAttrs(dw->dwgad[GID_String], dw->Window, NULL, /* 2.7b7 rri */
                             STRINGA_TextVal, dw->Path,
                             STRINGA_MaxChars, *(mem)-2,
                             TAG_END,0);

//    RefreshGList(dw->dwgadmain, dw->Window, NULL, 1);

    dis_files(dw);
   }
 }

/* valid for cmd-windows */
if(set) /* 2.7b11 rri */
 {
  if(Strap)
  {
   CloneBuffer(dw,Strap); /* 2.7b11 rri */
  }
  goto Q;
 }

if(dw->DirLock&&Notify) /* 2.5b9 rri */
 {
  dw->DM2NotifyReq.nr_Name = dw->Path;
  if (StartNotify(&dw->DM2NotifyReq))
   {
    dw->DM2NotifyReq.nr_UserData=1; /* 2.5RC6 rri */
   }
 }

if(!dw->DirLock&&dw!=CmdWin) /* 2.5b9 rri */
 {
  SetGadgetAttrs(dw->dwgad[GID_String], dw->Window, NULL, /* 2.7b7 rri */
                             STRINGA_TextVal, NULL,
                             STRINGA_MaxChars, 100,
                             TAG_END,0);
//  RefreshGList(dw->dwgadmain, dw->Window, NULL, 1);
  GetDevList(dw);
 }
else if(dw->Fib->fib_DirEntryType<0&&dw==CmdWin)
      {
       GetCmdFile(dw,dw->Path,dw->Fib->fib_Size);
       Busy(0); /* 2.5b9 rri */
       return;
      }
else if(!CacheLoad(dw))
      {
       lockcount++;
       Busy(0); /* 2.5b7 rri */
       return;
      }

Q:

if(dw->DirLock)
 {
  UnLock(dw->DirLock);
  dw->DirLock=0;
 }

FreeDosObject(DOS_FIB,dw->Fib); /* 2.5.28 rri */
dw->Fib=0;
Busy(0); /* 2.5b7 rri */
}


int AllocDlp(struct DirWindow *dw)
{
struct DirList **dl=dw->DirList;
ULONG size; /* 2.5b10 rri */

if(dw->FileCount>=dw->MaxFile) /* no entry left in table */
 {
  /* allocate new dir-entries table with room for 500 entries more */

  size=dw->MaxFile<<2;
  if(!(dl=AllocMem(size+2000,MEMF_ANY | MEMF_CLEAR))) return(0); /* 2.5.28 rri */
  CopyMem(dw->DirList,dl,size); /* 2.5RC9 rri */
  FreeMem(dw->DirList,size);
  dw->DirList=dl;
  dw->MaxFile+=500;
 }

/* allocate new dir-entry */
if((dl[dw->FileCount]=(struct DirList *) PoolAllocVec(StringPool,sizeof(struct DirList)))) /* 2.5.23 gcc rri */
 {
  return 1;
 }
else return 0;
}

/* 2.7 rri obsolete! it's functionality is in dowindow() now!
int GetNewPath(struct DirWindow *dw)
{
UBYTE *ptr,*ptr2;

if(FLAGS&DMFLAG_DCLICK&&DClickDir)
 {
  if(DestWin && DestWin != dw && LastI >= 0 && DClickDir->sel)
   {
    DClickDir->sel=0;
// 2.7 rri dis_name(DestWin,LastI+DestWin->Index,(LONG) LastI);
   }
// 2.7 rri dw->h_prop.HorizPot=0;
// 2.7 rri dw->v_prop.VertPot=0;
  LastI = -1;
  dw->Index=0;
// 2.7 rri dw->Edge=0; // DefaultEdge; - 2.5RC3 rri this was never ever initialised!
  if(OldDir!=333&&DirWin[OldDir]&&DirWin[OldDir]->Path) strcpy(sbuff,DirWin[OldDir]->Path);
  else sbuff[0]=0;
  ptr=sbuff+strlen(sbuff)-1;
  ptr2=DClickDir->name;

  if (*ptr=='/')
   {
    *ptr=0;
    ptr--;
   }
  if(*ptr&&*(ptr2+strlen(ptr2)-1)!=':')
   {
    if(*ptr++!=':')
     {
      *ptr++='/';
      *ptr=0;
     }
   }
  else
   {
    ptr=sbuff;
   }

  strcpy(ptr,DClickDir->name);

  CloneBuffer(dw,sbuff);

  FLAGS&=~DMFLAG_DCLICK;
  DClickDir=0;
  InitDir(dw,0);
  return(1);
 }
return(0);
}
*/


#if 0 /* 2.7b10 rri can't work as long InitDir() accesses the fib... #ifdef __amigaos4__ */
int DiskShadow(struct DirWindow *dw,sFIB *fib UNUSED)
{
BPTR lock;

struct ExamineData *dat;

if(!dw->Path[0]) return(1);
if(!(lock=Lock(dw->Path,ACCESS_READ))) return(1);

Info(lock,&InfoData);

dw->BytesPerBlock=InfoData.id_BytesPerBlock;

dw->DirLock=lock;

if(( dat = ExamineObjectTags(EX_StringName, dw->Path,
                             EX_DataFields, EXF_DATE,
                             TAG_END)))
{
 dw->PathDate = dat->Date;
 FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
}

return(1);
}

#else
int DiskShadow(struct DirWindow *dw,sFIB *fib)
{
BPTR lock; /* 2.5b6 rri */

struct DateStamp *ds1,*ds2;

/* dw->DiskFree=0; */ /* 2.5.31 rri */
if(!dw->Path[0]) return(1);
if(!(lock=Lock(dw->Path,ACCESS_READ))) return(1);

Info(lock,&InfoData);

dw->BytesPerBlock=InfoData.id_BytesPerBlock; /* 2.5b5 rri */

dw->DirLock=lock;

if(!Examine(lock,fib)) return(0);

/* init struct DateStamp in struct DirWindow */

ds1 = &dw->PathDate;
ds2 = &fib->fib_Date;
ds1->ds_Days=ds2->ds_Days;
ds1->ds_Minute=ds2->ds_Minute;
ds1->ds_Tick=ds2->ds_Tick;

return(1);
}
#endif


int CacheLoad(struct DirWindow *dw)
{
struct DirWindow *dw2;
struct DirList **dl,**dl2,*dlp,*dlp2;
LONG i; /* 2.5.23 rri */

dw2=0; /* 2.5b10 rri */

/* look for a dir-window with the same path */
for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw2=DirWin[i];
  if(dw2&&dw!=dw2&&!strcmp(dw->Path,dw2->Path)) break;
 }

/* if there is no window with the same path leave the function */
if(i==DMMAXWINDOWS||!dw2||!dw2->FileCount) return(0); /* 2.5.23 rri */

ReSort();

if(dw2->DirLock||dw2->Flags&DWFLAG_RELOAD)
 {
  dw->Flags|=DWFLAG_RELOAD;
  return(0);
 }

dl2=dw2->DirList;

for(i=0;i<dw2->FileCount;i++)
 {
  dlp2=dl2[i];
  if(dw->Pattern[0])
   {
    if(dlp2->name&&!dlp2->dir) /* 2.5RC6 rri */
     {
      if(!DMMatch(dlp2->name,dw->Pattern)) continue;
     }
   }
  if(!AllocDlp(dw)) return(1);
  dl=dw->DirList;
  dlp=dl[dw->FileCount++];
  dlp->size=dlp2->size;
  dlp->attr=dlp2->attr;
  dlp->ds.ds_Days=dlp2->ds.ds_Days;
  dlp->ds.ds_Minute=dlp2->ds.ds_Minute;
  dlp->ds.ds_Tick=dlp2->ds.ds_Tick;
  dlp->dir=dlp2->dir;
  dlp->name = CloneStr(dlp2->name, NamePool); /* 2.5b10 rri */
  dlp->cmt = CloneStr(dlp2->cmt, CommentPool); /* 2.5b10 rri */
 }

DMSort(dw);
NewSize(dw);
return(1);
}


void ExDone(struct DirWindow *dw)
{
struct DirWindow *dw2;
LONG i; /* 2.5.23 rri */

UnLock(dw->DirLock);
dw->DirLock=0;
FreeDosObject(DOS_FIB,dw->Fib); /* 2.5.28 rri */
dw->Fib=0;
if(lockcount) lockcount--;
DMSort(dw);
NewSize(dw);
for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw2=DirWin[i];
  if(dw2&&(dw2->Flags&DWFLAG_RELOAD)&&!strcmp(dw->Path,dw2->Path))
   {
    dw2->Flags&=~DWFLAG_RELOAD;
   }
 }
}


void Fib2Dlp(struct DirList *dlp,sFIB *fib)
{
dlp->size=fib->fib_Size;
dlp->attr=fib->fib_Protection;
dlp->ds.ds_Days=fib->fib_Date.ds_Days;
dlp->ds.ds_Minute=fib->fib_Date.ds_Minute;
dlp->ds.ds_Tick=fib->fib_Date.ds_Tick;
dlp->name = CloneStr(fib->fib_FileName, NamePool); /* 2.5b10 rri */
dlp->cmt = CloneStr(fib->fib_Comment, CommentPool); /* 2.5b10 rri */
dlp->dir = (fib->fib_DirEntryType>=0) ? 1 : 0; /* 2.5.28 rri */
}


void FreeDirTable(struct DirWindow *dw)
{
struct DirList **dl=dw->DirList;
int i;

if(dw->DirLock)
 {
  UnLock(dw->DirLock);
  dw->DirLock=0;
  if(lockcount) lockcount--;
 }

for(i=0;i<dw->FileCount;i++)
 {
  if(dl[i]->cmt)
   {
    PoolFreeVec(dl[i]->cmt); /* 2.5b10 rri */
   }
  if(dl[i]->name)
   {
    PoolFreeVec(dl[i]->name); /* 2.5b10 rri */
   }
  PoolFreeVec(dl[i]); /* 2.5RC10 rri */
 }
dw->FileCount=0;

if(dw->DM2NotifyReq.nr_UserData) /* 2.5RC6 rri */
 {
  EndNotify(&dw->DM2NotifyReq);
  dw->DM2NotifyReq.nr_UserData=0; /* 2.5RC6 rri */
 }
}
