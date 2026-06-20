/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
* |_o_o|\\ Copyright (c) 1989 The Software Distillery.                    *
* |. o.| ||          All Rights Reserved                                  *
* | .  | ||          Written by Doug Walker                               *
* | o  | ||          The Software Distillery                              *
* |  . |//           235 Trillingham Lane                                 *
* ======             Cary, NC 27513                                       *
*                    BBS:(919)-471-6436                                   *
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/* This file contains the routines that must be linked in to every pgm   */
/* that wants to use MemLib - MWInit, MWTerm, MWCheck, MWHold, MWPurge   */

#include "mempriv.h"
#include <exec/execbase.h>

struct MWGlobal mwg;

/* Autoinit routine.  This is called by the startup code before main(). */
/* The 240 is the priority of this init routine.  Don't mess with it.   */
int _STI_240_MWInit(void)
{
   MWInit(NULL, __MWFlags, __MWLogName);
   return 0;
}

static void MWClose(void);

/* Initialization routine - should be called once before any memory */
/* is allocated                                                     */

void MWInit(BPTR dbfh, LONG flags, char *dbnm)
{

   /* Close any existing log that we opened */
   if(mwg.flags & MWF_ACTIVE) MWClose();

   if(dbfh) mwg.dbfh = dbfh;
   else if(dbnm) mwg.dbnm = dbnm;  /* Deferred logname */
   else if(!(flags & MWF_NOLOG)) mwg.dbfh = Output();

   if(!(mwg.flags & MWF_ACTIVE))
   {
      mwg.lim[MWT_CHIP] = mwg.lim[MWT_FAST] = 0x7fffffff;

      mwg.task = FindTask(0L);
   }

   mwg.flags = flags|MWF_ACTIVE;
}

/* Termination routine.  Called by the cleanup code after exit(). */
/* The 240 is the priority of this cleanup routine; don't mess with it. */

void _STD_240_MWTerm(void)
{
   struct MWAlc *mwa;
   int msgdone = 0;

   if(!mwg.flags & MWF_ACTIVE)
      return;

   MWCheck();

   /* no need to trash the mem we may be about to free for good */
   mwg.flags |= MWF_NOFTRASH;
   mwg.flags &= ~MWF_CHECK;

   if(!(mwg.flags & MWF_NOFREE))
   {
      for(mwa=mwg.first; mwa; mwa=mwa->next)
      {
         if(!(mwa->flags & (MWI_MALLOC|MWI_VEC)))
         {
            if(!msgdone)
            {
               MWPrintf("%sMemWatch ERROR: The following "
                        "allocations were not freed:\n",MW_NEWLINE);
               msgdone = 1;
            }
            MWPrintAlc(mwa);
         }
      }
      while(mwg.first)
         MWFreeMem(mwg.first->memory, mwg.first->size, MWI_ANY, "MWTERM", 0);
   }
   MWPurge();  /* Really free all mem on the 'free' chain */

   MWClose();

   memset((char *)&mwg, 0, sizeof(struct MWGlobal));
}

/* For compatibility with previous versions */
void MWTerm(void)
{
   _STD_240_MWTerm();
}

#define V37 ((*(struct ExecBase **)4)->LibNode.lib_Version >= 36)

static void MWClose(void)
{
   char tmp[2];

   if(mwg.dbnm && mwg.dbfh)
   {
      if(!V37)  // If V37, they will be using /AUTO/CLOSE/WAIT
      {
         MWPrintf("Hit RETURN to continue: ");
         Read(mwg.dbfh, tmp, 1);
      }
      Close(mwg.dbfh);
   }
   mwg.dbfh = NULL;
}

void MWLimit(LONG chiplim, LONG fastlim)
{
   mwg.lim[MWT_CHIP] = chiplim;
   mwg.lim[MWT_FAST] = fastlim;
}

int MWCheckA(struct MWAlc *mwa)
{
   int header, trailer;
   char trash[2*MW_TRAILLEN+1];
   int i, j;
   char *mem;
   static const char hexchars[] = "0123456789ABCDEF";

   if(mwa->internal & MWI_REPORTED)
      return 0;

   if(header=memcmp((char *)&mwa->header, MWHEADSTR, MW_HEADLEN))
      MWPrintf("%sMemWatch ERROR: Header trashed\n",MW_NEWLINE);

   if(trailer=memcmp(mwa->memory+mwa->size, MWTRAILSTR, MW_TRAILLEN))
   {
      mem = mwa->memory + mwa->size;
      for(i=j=0; i<MW_TRAILLEN; i++)
      {
         trash[j++] = hexchars[(mem[i]&0xf0)>>4];
         trash[j++] = hexchars[mem[i]&0xf];
      }
      trash[j] = 0;
      MWPrintf("%sMemWatch ERROR: Trailer trashed, data 0x%s\n", MW_NEWLINE, trash);
   }

   if(header || trailer)
   {
      mwa->internal |= MWI_REPORTED;
      MWPrintAlc(mwa);
      return(1);
   }

   return(0);
}

/* Validity check routine - checks all known allocations for overwrites */
/* Called from every alloc and free routine, plus when specifically     */
/* invoked                                                              */

void MWCheck(void)
{
   struct MWAlc *mwa;
   char *tmpchar;
   int error, tmpint;

   error = 0;
   for(mwa=mwg.first; mwa; mwa=mwa->next)
   {
      if( (mwa->internal & MWI_REPMASK) == MWI_REPORTED) continue;

      error = MWCheckA(mwa);
   }

   for(mwa=mwg.freed; mwa; mwa=mwa->next)
   {
      if( (mwa->internal & MWI_REPMASK) == MWI_REPORTED) continue;

      for(tmpint=0, tmpchar=mwa->memory;
          tmpint<mwa->size;
          tmpint++, tmpchar++)
      {
         if(*tmpchar != MWFTRASH)
         {
            mwa->internal |= MWI_REPORTED;
            error = 1;
            MWPrintf("%sMemWatch ERROR: Freed memory modified\n",MW_NEWLINE);
            MWPrintAlc(mwa);
            break;
         }
      }
   }

   if(error) MWHold();
}

void MWHold(void)
{
   struct MWAlc *mwa;

   mwg.flags &= ~MWF_ERROR;

   /* We're attempting to go on, make all the sentinels correct */
   for(mwa=mwg.first; mwa; mwa=mwa->next)
   {
      mwa->internal &= ~MWI_REPMASK;
      memcpy(mwa->header, MWHEADSTR, MW_HEADLEN);
      memcpy((mwa->memory + mwa->size), MWTRAILSTR, MW_TRAILLEN);
   }

   for(mwa=mwg.freed; mwa; mwa=mwa->next)
   {
      mwa->internal &= ~MWI_REPMASK;
      memset(mwa->memory, MWFTRASH, mwa->size);
   }
}

/* MWPurge really frees all memory placed on the 'freed' chain by */
/* FreeMem() or free()                                            */

void MWPurge(void)
{
   struct MWAlc *cur, *next;

   for(cur=mwg.freed; cur; cur=next)
   {
      next = cur->next;
      FreeMem(cur, cur->size + sizeof(struct MWAlc));
   }
   mwg.freed = NULL;
}

void MWPrintf(char *ctl, ...)
{
   static char buffer[256];
   va_list args;

   va_start(args, ctl);

   /* Note: The weird string constant is actually CODE that will */
   /* be called by RawDoFmt.                                     */
   RawDoFmt(ctl, args, (void (*))"\x16\xc0\x4e\x75", buffer);

   va_end(args);

/* If you don't have Commodore's debug.lib, KPutStr will come up undefined. */
/* Edit mempriv.h and change the #define for USEDEBUGLIB to 0 in this case. */
#if USEDEBUGLIB
   if(mwg.flags & MWF_SERIAL) KPutStr(buffer);
   else
#endif
   {
      if(!mwg.dbfh && mwg.dbnm) mwg.dbfh = Open(mwg.dbnm, MODE_NEWFILE);
      if(mwg.dbfh) Write(mwg.dbfh, buffer, strlen(buffer));
   }
}

void *MWAllocMem(long size, long flags, long internal, char *file, long line)
{
   struct MWAlc *hd;
   char *tmpchar;
   int memtype;

   if(!(mwg.flags & MWF_ACTIVE)) return(NULL);

   /* Force warning for malloc'd memory not freed if requested */
   if(mwg.flags & MWF_MALLOCWRN) internal &= ~MWI_MALLOC;

   if(mwg.flags & MWF_CHECK) MWCheck();

   if(size <= 0)
   {
      MWPrintf("%sMemWatch ERROR: Bad %s() length %ld from line %ld file \"%s\"\n",
         MW_NEWLINE, ALCFAMILY(internal), size, line, file);
      return(NULL);
   }

   memtype = (flags & MEMF_CHIP ? MWT_CHIP : MWT_FAST);
   if(mwg.sum[memtype] + size > mwg.lim[memtype])
   {
      /* Over the limit, fail it */
      MWPrintf("MemWatch: %s memory allocation exceeds MWLimit amount\n",
         memtype == MWT_CHIP ? "CHIP" : "FAST");
      return(NULL);
   }

   while(!(tmpchar = (char *)AllocMem(sizeof(struct MWAlc)+size, flags)))
   {
      if(mwg.freed) MWPurge();
      else return(NULL);
   }

   hd = (struct MWAlc *)tmpchar;
   hd->size = size;
   hd->flags = flags;
   hd->internal = internal;
   hd->file = file;
   hd->line = line;
   hd->ffile = NULL;
   hd->fline = 0;
   memcpy(hd->header, MWHEADSTR, MW_HEADLEN);
   memcpy(hd->memory+size, MWTRAILSTR, MW_TRAILLEN);

   if(!(flags & MEMF_CLEAR) && !(mwg.flags & MWF_NOATRASH))
      memset(hd->memory, MWATRASH, size);   /* Trash the memory */

   hd->next = mwg.first;
   mwg.first = hd;

   if((mwg.sum[memtype] += size) > mwg.max[memtype])
      mwg.max[memtype] = mwg.sum[memtype];
   ++(mwg.num[memtype]);

   return((char *)hd->memory);
}

void MWFreeMem(void *mem, long size, long internal,
               char *file, long line)
{
   struct MWAlc *mwa, *prev;
   int memtype;
   int error = 0;

   if(!(mwg.flags & MWF_ACTIVE)) return;
   if(mwg.flags & MWF_CHECK) MWCheck();

   for(prev = NULL, mwa = mwg.first;
       mwa && mwa->memory != mem;
       prev = mwa, mwa = mwa->next);

   if(!mwa)
   {
      for(mwa=mwg.freed; mwa && mwa->memory != mem; mwa=mwa->next);
      if(mwa)
      {
         MWPrintf("%sMemWatch ERROR: Memory freed twice line %ld file \"%s\"\n", MW_NEWLINE,
            line, file);
         MWPrintAlc(mwa);
      }
      MWPrintf("%sMemWatch ERROR: %s() called on invalid memory\n"\
                  "addr 0x%08lx length %ld line %ld file \"%s\"\n", MW_NEWLINE,
            FREFAMILY(internal), mem, size, line, file);
      error = 1;
   }
   else if(!(internal & (MWI_MALLOC|MWI_VEC)) && mwa->size != size)
   {
      MWPrintf("%sMemWatch ERROR: Incorrect %s() length %ld line %ld file \"%s\"\n", MW_NEWLINE,
         FREFAMILY(internal), size, line, file);
      MWPrintAlc(mwa);
      error = 2;
   }
   else if(internal != MWI_ANY && (internal & mwa->internal) != internal)
   {
      MWPrintf("%sMemWatch ERROR: %s() mem freed with %s(), line %ld file \"%s\"\n", MW_NEWLINE,
         ALCFAMILY(mwa->internal), FREFAMILY(internal), line, file);
      MWPrintAlc(mwa);
   }
   else if(MWCheckA(mwa))
     error = 2;

   if(error)
   {
      MWHold();
      if(error == 1) return;
   }

   memtype = (mwa->flags & MEMF_CHIP ? MWT_CHIP : MWT_FAST);
   mwg.sum[memtype] -= mwa->size;
   --mwg.num[memtype];

   if(prev) prev->next = mwa->next;
   else     mwg.first = mwa->next;

   if(!(mwg.flags & MWF_NOFTRASH))
      memset(mwa->memory, MWFTRASH, mwa->size);  /* Trash it */

   if(mwg.flags & MWF_NOFKEEP)
     FreeMem((char *)mwa, mwa->size + sizeof(struct MWAlc));
   else
   {
      mwa->next = mwg.freed;
      mwg.freed = mwa;
      mwa->ffile = file;
      mwa->fline = line;
   }
}

void *MWrealloc(void *mem, long size, char *file, long line)
{
   void *new;
   struct MWAlc *mwa;

   if(!(new = MWAllocMem(size, 0, MWI_MALLOC, file, line)))
      return(NULL);

   if(mem)
   {
      for(mwa = mwg.first;
          mwa && mwa->memory != mem;
          mwa = mwa->next);

      if(mwa == NULL)
      {
         MWPrintf("%sMemWatch ERROR: bad memory passed to realloc\n",MW_NEWLINE);
         MWPrintf("%sPointer is 0x%08lx, called from line %ld file \"%s\"\n", MW_NEWLINE,
            line, file);
      }
      else if(!(mwa->internal & MWI_MALLOC))
      {
         MWPrintf("%sMemwatch ERROR: %s() memory passed to realloc()\n", MW_NEWLINE,
            ALCFAMILY(mwa->internal));
         MWPrintf("Passed from line %ld file \"%s\"\n", line, file);
         MWPrintAlc(mwa);
      }
      else if(mwa->size < size)
         size = mwa->size;

      memcpy(new, mem, size);

      if(mwa) MWFreeMem(mem, -1, MWI_MALLOC, file, line);
   }

   return(new);
}
