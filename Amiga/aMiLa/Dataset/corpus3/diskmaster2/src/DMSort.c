/* DiskMaster II  Sorter Module
**
** Author: Richard "Dragon" Backhaus,Rudolph "Shadowolf" Riedel
** Date: 25.08.1997,07.09.1997
**
** 2.6
**
** 05-07-16 rri - Implemented new sortmode: sort by name-length -> L/L-
**              - Bugfix: sorting by extension could be trapped in an endless loop
**                        for empty directories.
**
** 05-07-17 rri - Changed all references to "2.5.33" into "2.6".
**              - Removed comments from header older than 2.5.29.
**
** 05-07-31 rri - Removed a warning with GCC from cmplenU()
**              - Removed two misplaced (uint32) casts for ToUpper().
**
** 05-11-12 rri - Bugfix: using 'Sort' with no window opened issued an enforcer-hit since 2.5b7.
**                        Thanks for reporting to Javier de las Rivas <javierdlr@jazzfree.com>!
**
** 2.7
**
** 06-11-11 rri - Updated ReSort() to remove dir-entries when they have an empty node-pointer.
**
** 06-12-01 rri - Redid the above change to free dir-entries only when they have ->sel > 1,
**                added freeing of the ListBrowser node.
**
** 06-12-04 rri - In ReSort(): removed debug-output, replaced a NewSize() call with
**                a call to dis_files() and removed a WinTitle() call.
**
** b2
**
** 06-12-10 rri - Modified ReSort() to not reset the display completely but rather re-arrange
**                the nodes in the list.
**
** b7
**
** 06-12-30 rri - Did some testing in ReSort() - ListBrowser has a bug that won't let it
**                expand collumns on LISTBROWESER_AutoFit unless the nodes are changed.
**
** 07-01-08 rri - ReSort() uses detach_list() / attach_list() now.
**
** b9
**
** 07-01-21 rri - Changed ReSort() for the OS4-build. At first it uses SetProcWindow() instead
**                of writing into process->pr_WindowPtr directly.
**                Changed ReSort() for the OS4-build to use ExamineObject() instead of
**                Lock()/Examine() for the periodic check if something changed.
**
*/

#include "DM.h"



extern struct DirWindow     *DirWin[],*CDWin;
extern struct FileInfoBlock Fib;
extern struct Process       *process;

extern LONG lockcount; /* 2.5.23 rri */

extern UBYTE *ActionArgs[];

extern APTR CommentPool, /* 2.5b10 rri */
            NamePool;    /* 2.5b10 rri */

extern ULONG FLAGS; /* 2.5RC2 rri */

typedef int (* SORTFUNC)(const void * , const void *); /* 2.5RC4 rri vbcc */


int SortType=0;

int cmpextU(struct DirList **val1,struct DirList **val2); /* 2.5b12 rri */
int cmpextD(struct DirList **val1,struct DirList **val2); /* 2.5b12 rri */
int CountDirs(struct DirList **dl,ULONG count); /* 2.5b12 rri */
int cmplenU(struct DirList **val1,struct DirList **val2); /* 2.6 rri */
int cmplenD(struct DirList **val1,struct DirList **val2); /* 2.6 rri */


int CountDirs(struct DirList **dl,ULONG count) /* 2.5b12 rri */
{
ULONG i; /* 2.5.23 gcc rri */
int dircount;

dircount=0;

for(i=0; i<=count-1; i++)
 {
  if(dl[i]->dir==1)
   {
    dircount++;
   }
  else
   {
    break;
   }
 }
return(dircount);
}

/*
Name:	DMSort Name + additional compare routines
*/

void DMSortN(struct DirList **dl,ULONG count,LONG direction) /* 2.5b10 rri */
{
if (direction == 0)
 {
  qsort(dl,(size_t) count,(size_t) sizeof(dl),(SORTFUNC)cmpnameU); /* 2.5RC4 rri vbcc */
 }
else if (direction == 1)
 {
  qsort(dl,(size_t) count,(size_t) sizeof(dl),(SORTFUNC)cmpnameD); /* 2.5RC4 rri vbcc */
 }
}


int cmpnameU(struct DirList **val1,struct DirList **val2) /* inserted 25.08.97 dGN! */
{
if(val1[0]->dir==val2[0]->dir)
/* if both files are either files or directories they should be compared */
 {
  return(Stricmp(val1[0]->name,val2[0]->name)); /* 2.5b7 rri */
 }
else if(val1[0]->dir>val2[0]->dir)
/* if only the first file is a dir, it moves ahead */
 {
 return(-10);
 }
/* if only the second file is a dir, it moves ahead */
return(10);
}


int cmpnameD(struct DirList **val1,struct DirList **val2)
{
int i;

i=cmpnameU(val1,val2);

if (i==1||i==(-1)) i=i*(-1);

return i;
}


/*
Name:	DMSort Size + additional compare routines
*/

void DMSortS(struct DirList **dl,ULONG count,LONG direction) /* 2.5b10 rri */
{
int	dircount,filecount;

qsort(dl,(size_t) count,(size_t) sizeof(dl),(SORTFUNC)cmpnameU); /* 2.5RC4 rri vbcc */

dircount=CountDirs(dl,count); /* 2.5b12 rri */
filecount=count-dircount; /* 2.5b12 rri */

if (filecount)
 {
 if (direction==2) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmpsizeU); /* 2.5RC4 rri vbcc */
 else if (direction == 3) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmpsizeD); /* 2.5RC4 rri vbcc */
 }

}


int cmpsizeU(struct DirList **val1,struct DirList **val2) /* inserted 25.08.97 dGN! */
{
return (val1[0]->size - val2[0]->size);
}


int cmpsizeD(struct DirList **val1,struct DirList **val2) /* inserted 25.08.97 dGN! */
{
return (val2[0]->size - val1[0]->size);
}


/*
Name:	DMSort date compare routines
*/

int cmpdateU(struct DirList **val1,struct DirList **val2)
{
if(val1[0]->dir==val2[0]->dir)
 {
 return(CompareDates((struct DateStamp *) &val2[0]->ds,(struct DateStamp *) &val1[0]->ds));
 }
else if(val1[0]->dir>val2[0]->dir)
 {
 return(-10);
 }
return(10); /* 2.5.23 gcc rri */
}


int cmpdateD(struct DirList **val1,struct DirList **val2) /* inserted 25.08.97 dGN! */
{
if(val1[0]->dir==val2[0]->dir)
 {
 return(CompareDates((struct DateStamp *) &val1[0]->ds,(struct DateStamp *) &val2[0]->ds));
 }
else if(val1[0]->dir>val2[0]->dir)
 {
 return(-1);
 }
return(1); /* 2.5.23 gcc rri */
}


/*
Name:	DMSort comment compare routines
*/

int cmpcmtU(struct DirList **val1,struct DirList **val2)
{
int i;

if(val1[0]->dir==val2[0]->dir)
 {
 if (!val1[0]->cmt&&!val2[0]->cmt) return(Stricmp(val1[0]->name,val2[0]->name)*10);
 if (!val1[0]->cmt) return(-1);
 else if (!val2[0]->cmt) return (1);
 else
  {
   i=Stricmp(val1[0]->cmt,val2[0]->cmt); /* 2.5b12 rri */
   if (i==0) return(Stricmp(val1[0]->name,val2[0]->name)*10);
   return i;
  }
 }
else if(val1[0]->dir>val2[0]->dir)
 {
 return(-10);
 }
return(10); /* 2.5.23 gcc rri */
}


int cmpcmtD(struct DirList **val1,struct DirList **val2) /* 2.5b12 rri */
{
int i;

i=cmpcmtU(val1, val2);

if (i==1||i==(-1)) i=i*(-1);

return i;
}


/*
Name:	DMSort Extension + additional compare routines
*/

void DMSortE(struct DirList **dl,ULONG count,LONG direction) /* 2.5b12 rri */
{
int	dircount,filecount;

if(count > 1) /* 2.6 rri */
 {
  qsort(dl,(size_t) count,(size_t) sizeof(dl),(SORTFUNC)cmpnameU); /* 2.5RC4 rri vbcc */

  dircount=CountDirs(dl,count);
  filecount=count-dircount;

  if (filecount)
   {
    if (direction==8) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmpextU); /* 2.5RC4 rri vbcc */
    else if (direction == 9) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmpextD); /* 2.5RC4 rri vbcc */
   }
 }

}


int cmpextU(struct DirList **val1,struct DirList **val2) /* 2.5b12 rri */
{
UBYTE *ptr1=val1[0]->name+strlen(val1[0]->name);
UBYTE *ptr2=val2[0]->name+strlen(val2[0]->name);
int i;

for(;ptr1>=val1[0]->name;ptr1--)
 {
  if(*ptr1=='.') break;
 }

for(;ptr2>=val2[0]->name;ptr2--)
 {
  if(*ptr2=='.') break;
 }

if(ptr1<val1[0]->name&&ptr2<val2[0]->name)
 {
  return(Stricmp(val1[0]->name,val2[0]->name));
 }

if(ptr1<val1[0]->name)
 {
  return -10;
 }
if(ptr2<val2[0]->name)
 {
  return 10;
 }

i=(Stricmp(ptr1,ptr2));
if (i==0) return(Stricmp(val1[0]->name,val2[0]->name));
return i*10;
}


int cmpextD(struct DirList **val1,struct DirList **val2) /* 2.5b12 rri */
{
int i;

i=cmpextU(val1,val2);

if (i>=10||i<=(-10)) i=i*(-1);

return i;
}


/*
Name:	DMSort Length + additional compare routines
*/

void DMSortL(struct DirList **dl,ULONG count,LONG direction) /* 2.6 rri */
{
int	dircount,filecount;

if(count > 1)
 {
  qsort(dl,(size_t) count,(size_t) sizeof(dl),(SORTFUNC)cmpnameU);

  dircount=CountDirs(dl,count);
  filecount=count-dircount;

  if (filecount)
   {
    if (direction==10) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmplenU);
    else if (direction == 11) qsort(&dl[dircount],(size_t) filecount,(size_t) sizeof(dl),(SORTFUNC)cmplenD);
   }
 }

}


int cmplenU(struct DirList **val1,struct DirList **val2) /* 2.6 rri */
{
uint32 lena = strlen(val1[0]->name);
uint32 lenb = strlen(val2[0]->name);

if(lena == lenb)
 {
  return(Stricmp(val1[0]->name,val2[0]->name));
 }

if(lena < lenb)
 {
  return -10;
 }

/* (lenb < lena) 2.6 rri */
return 10;
}


int cmplenD(struct DirList **val1,struct DirList **val2) /* 2.6 rri */
{
int i;

i=cmplenU(val1,val2);

if (i>=10 || i<=(-10)) i=i*(-1);

return i;
}



void Sort()
{
switch(ToUpper(ActionArgs[1][0])) /* 2.6 rri */
 {
  case 'N': SortType=0; break;
  case 'S': SortType=2; break;
  case 'D': SortType=4; break;
  case 'C': SortType=6; break;
  case 'E': SortType=8; break; /* 2.5b12 rri */
  case 'L': SortType=10; break; /* 2.6 rri */

  case 'F': SortType=20; break; /* 2.6 rri */
  case 'T': SortType=21; break; /* 2.6 rri */
  case 'G': GlobalSort(); break;
 }

if(ActionArgs[1][1]&&ActionArgs[1][1]=='-'&&SortType<19) /* 2.6 rri */
 {
  SortType++;
 }

if(ActionArgs[2]&&(ToUpper(ActionArgs[2][0])=='G')) /* 2.6 rri */
 {
  GlobalSort();
 }

else if(CDWin)
      {
       SetSortFlag(CDWin,SortType);
       ReSort();
       SortType=CDWin->Sorting; /* 2.5b7 rri */
      }
}


void GlobalSort(void)
{
struct DirWindow *dw;
int i,a;

a=0; /* 2.5b10 rri */

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&!dw->Flags)
   {
    SetSortFlag(dw,SortType);
    a=i;
   }
 }
ReSort();
if (DirWin[a]) /* 2.6 rri */
 {
  SortType=DirWin[a]->Sorting; /* 2.5b7 rri */
 }
}


void SetSortFlag(struct DirWindow *dw, int c)
{

if (c==21) /* 2.6 rri */
 {
  if (dw->Sorting!=20)
   {
    dw->Sorting=dw->Sorting+2;
    if (dw->Sorting>11)
     {
      dw->Sorting=dw->Sorting-12;
     }
   }
 }
else dw->Sorting=c;

if(dw->Path[0])
 {
  dw->Flags|=DWFLAG_RESORT;
 }
}


void DMSort(struct DirWindow *dw)
{
switch(dw->Sorting)
 {
  case 0:
  case 1: DMSortN(dw->DirList,(ULONG) dw->FileCount,dw->Sorting);
          break;
  case 2:
  case 3: DMSortS(dw->DirList,(ULONG) dw->FileCount,dw->Sorting); /* 2.5b10 rri */
          break;

  case 4: qsort(dw->DirList,(size_t) dw->FileCount,(size_t) sizeof(dw->DirList),(SORTFUNC)cmpdateD); /* 2.5RC4 rri vbcc */
          break;
  case 5: qsort(dw->DirList,(size_t) dw->FileCount,(size_t) sizeof(dw->DirList),(SORTFUNC)cmpdateU); /* 2.5RC4 rri vbcc */
          break;
  case 6: qsort(dw->DirList,(size_t) dw->FileCount,(size_t) sizeof(dw->DirList),(SORTFUNC)cmpcmtU); /* 2.5RC4 rri vbcc */
          break;
  case 7: qsort(dw->DirList,(size_t) dw->FileCount,(size_t) sizeof(dw->DirList),(SORTFUNC)cmpcmtD); /* 2.5RC4 rri vbcc */
          break;
  case 8:
  case 9: DMSortE(dw->DirList,(ULONG) dw->FileCount,dw->Sorting); /* 2.5b12 rri */
          break;
  case 10:
  case 11: DMSortL(dw->DirList,(ULONG) dw->FileCount,dw->Sorting); /* 2.6 rri */
           break;

  case 20: break; /* 2.6 rri */
 }
}


void ResortAll()
{
struct DirWindow	*dw;
int	i;

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];
  if(dw&&!dw->Flags&&dw->Path[0]) dw->Flags|=DWFLAG_RESORT;
 }
 ReSort();
}


void ReSort()
{
struct DirWindow *dw;
struct DirList **dl;
ULONG c,i,j; /* 2.5.23 gcc rri */

#ifdef __amigaos4__ /* 2.7b9 rri */
APTR save;
struct ExamineData *dat;
#else
APTR save=process->pr_WindowPtr;
sFIB *fib = &Fib;
BPTR lock; /* 2.5b10 rri */
#endif

#ifdef __amigaos4__ /* 2.7b9 rri */
save = SetProcWindow((APTR) -1L);
#else
process->pr_WindowPtr=(APTR)-1L;
#endif

if(FLAGS&DMFLAG_BATCH) /* 2.5RC2 rri */
 {
  return;
 }

for(i=0;i<DMMAXWINDOWS;i++) /* 2.5.23 rri */
 {
  dw=DirWin[i];

  if(!dw) continue;

  if(dw->Flags&DWFLAG_RESORT)
   {
    c=dw->FileCount;
    dl=dw->DirList;

    detach_list(dw); /* 2.7b8 rri */

    DMSortN(dl,c,0);

    for(j=0;j<c;j++)
     {
      if(dl[j] && dl[j]->sel>1)
       {
        if(dl[j]->cmt) /* 2.5b10 rri */
         {
          PoolFreeVec(dl[j]->cmt); /* 2.5b10 rri */
         }
        if(dl[j]->name) /* 2.5b10 rri */
         {
          PoolFreeVec(dl[j]->name); /* 2.5b10 rri */
         }
        /* 2.7 rri */
        Remove(dl[j]->node);
        FreeListBrowserNode(dl[j]->node);
        PoolFreeVec(dl[j]); /* 2.5RC10 rri */
        dl[j]=0;
        dw->FileCount--;
       }
     }

    DMSort(dw);
    DiskShadow(dw,&Fib);
    if(dw->DirLock)
     {
      UnLock(dw->DirLock);
      dw->DirLock=0;
     }

    /* 2.7 rri - re-arrange the nodes after re-sorting the list */
    NewList(&dw->dwgadlist);
    c=dw->FileCount;
    for (j=0;j < c;j++)
    {
     AddTail(&dw->dwgadlist,dl[j]->node);
    }

    attach_list(dw,TRUE); /* 2.7b8 rri */

    WinTitle(dw);
    dw->Flags&=~DWFLAG_RESORT;
   }

  else if(!(dw->Flags&DW_CMD)&&dw->Path[0]) /* if it`s a dir window with a valid path */
   {
#ifdef __amigaos4__ /* 2.7b9 rri */
    if(( dat = ExamineObjectTags(EX_StringName, dw->Path,
                                 EX_DataFields, EXF_DATE,
                                  TAG_END)))
     {
      if(CompareDates(&dw->PathDate,&dat->Date))
       {
        dw->Flags|=DWFLAG_RELOAD;
        lockcount++;
       }
      FreeDosObject(DOS_EXAMINEDATA,dat); /* Free data when done */
     }
#else
    if(!(lock=Lock(dw->Path,ACCESS_READ)))  /* if a lock to this path can`t be obtained */
     {

/* this portion of code was never ever executed before 2.5b7 anyways...
   2.5b9 rri */

/*
      CloneBuffer(dw,0); // 2.5RC6 rri
//      dw->Path[0]=0;  // show dev/vol/asn list
      InitDir(dw,0);
*/

     }
    else
     {
      if(Examine(lock,fib))
       {
        if(CompareDates(&dw->PathDate,&fib->fib_Date))
         {
          dw->Flags|=DWFLAG_RELOAD;
          lockcount++;
         }
/*
        else
         {
          ReSize(dw); // useless! 2.5RC7 rri
         }
*/
       }
      UnLock(lock);
     }
#endif
   }
 }
#ifdef __amigaos4__
SetProcWindow(save);
#else
process->pr_WindowPtr=(APTR)save;
#endif
}
