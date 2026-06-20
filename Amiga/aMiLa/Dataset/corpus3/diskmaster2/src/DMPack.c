/* DiskMaster II  Packing Module  Pack/Autounpack
**
** 2.5.31
**
** 04-10-12 rri - XFDMasterBase is of type struct Library for OS4.
**
** 04-10-31 rri - Changed two LibOpen() calls to the new format.
**
** 05-03-21 rri - Replaced 2 "#ifdef __PPC__" with "#ifdef __amigaos4__".
**
** 2.6
**
** 05-07-24 rri - Changed header of AutoUnpack() to match prototype in DM.h
**              - Removed comments from header older than 2.5.29.
**
*/

#include "DM.h"


/* --- Macros --- */
#define BOUNDS(x, lo, hi) (x)<(lo) ? lo : ((x)>(hi) ? (hi) : (x))


/* --- Global Vars  ---*/
extern UBYTE *ActionArgs[], dcPath[];
extern APTR StringPool; /* 2.5.23 rri */

struct Library       *XpkBase;

#ifdef __amigaos4__ /* 2.5.31 rri */
struct Library *xfdMasterBase;
#else
struct xfdMasterBase *xfdMasterBase;
#endif


#ifdef __amigaos4__ /* 2.5.31 rri */
struct XpkIFace        *IXpk = NULL;
struct xfdMasterIFace  *IxfdMaster = NULL;
#endif


/* --- Program --- */

void DMPack(UBYTE *name, sFIB *fib, int comp)
{
BPTR   fh;
UBYTE  *dest, /* 2.5.28 rri */
       *old=NULL,  /* 2.5.23 rri */
       *defpk, *fn, resultstr[80];
LONG   keep, samename, pkmode, err=0, oldsize, newsize=0;
ULONG  sl;
struct XFile *xf;

#ifdef __amigaos4__ /* 2.5.31 rri */
if(LibOpen("xpkmaster", &XpkBase, 4, (uint32) &IXpk)) /* 2.5.31 rri */
#else
if(LibOpen("xpkmaster", &XpkBase, 4))
#endif
 {
  fn = FilePart(name);

  if(IsDir(dcPath)) /* 2.5.23 rri */
   {
    sl=strlen(dcPath)+strlen(fn)+20;
    if((dest=PoolAllocVec(StringPool,sl)))
     {
      strcpy(dest,dcPath);
      AddPart(dest,fn,sl);
     }
   }
  else /* 2.5.23 rri */
   {
    if((dest=PoolAllocVec(StringPool,(ULONG) strlen(dcPath)+20)))
     {
      strcpy(dest,dcPath);
     }
   }
  if(dest) /* 2.5.23 rri */
   {
    sl = strlen(dest) - 4;
    if ((Stricmp(dest + sl, ".xpk") == 0) ||
        (Stricmp(dest + sl, ".dmp") == 0)) *(dest + sl) = 0; /* Strip ".xpk" or ".dmp". */
    else
     {
      sl++;
      if (Stricmp(dest + sl, ".pp") == 0) *(dest + sl) = 0;  /* Strip ".pp". */
     }

    if (comp && GetActionArg("SUFFIX", AATYPE_BOOL, 0)) DMstrcat(dest, ".xpk"); /* Add ".xpk" suffix. */ /*2.5RC9 rri */

    if ((xf = AutoUnpack(name)))
     {
      keep = GetActionArg("KEEPORIG", AATYPE_BOOL, 0);
      samename = Stricmp(name, dest) == 0;
      if (samename && keep)
       {
        if((old=PoolAllocVec(StringPool,(ULONG) strlen(name)+6))) /* 2.5.23 rri */
         {
          sprintf(old, "%s.old", name);
          if (!Rename(name, old)) goto xit;
         }
       }
      if (comp)
       {
        /* --- Pack --- */
        defpk = FindSemaphore("« XpkMasterPrefs »") ? "USER" : "NUKE";
        pkmode = GetActionArg("MODE", AATYPE_NUM, 100);
        pkmode = BOUNDS(pkmode, 0, 100),

        err = XpkPackTags(XPK_InBuf,      (LONG) xf->data, /* 2.5.23 gcc rri */
                          XPK_InLen,      xf->len,
                          XPK_OutName,    (LONG) dest,     /* 2.5.23 gcc rri */
                          XPK_GetOutLen,  (LONG) &newsize, /* 2.5.23 gcc rri */
                          XPK_PackMethod, GetActionArg("METHOD", AATYPE_STR, (LONG) defpk),
                          XPK_PackMode,   pkmode,
                          TAG_DONE);
       }
      else
       {
        /* --- Unpack --- */
        if ((fh = Open(dest, MODE_NEWFILE)))
         {
          newsize = xf->len;
          err = Write(fh, xf->data, xf->len) == 0;
          Close(fh);
         }
       }

      if (err == 0)
       {
        /* --- Clone original's protection bits & comment --- */
        SetProtection(dest, fib->fib_Protection);
        SetComment(dest, fib->fib_Comment);

        if (!keep && !samename)
         {
          /* --- Delete original file --- */
          SetProtection(name, 0);  /* Make file deletable... */
          DeleteFile(name);        /* ...What file?          */
         }
        oldsize = fib->fib_Size;
        sprintf(resultstr, "%s %s (%ld -> %ld  %ld%%%%)",
                             fn, comp ? msgStatCompressed : msgStatDecompressed,
                             oldsize, newsize, (oldsize - newsize) * 100 / oldsize);  /* 2.5b13 jjt */
       }
      else
       {
xit:    sprintf(resultstr, comp ? msgErrorCompress : msgErrorDecompress, fn);  /* 2.5b13 jjt */
       }
      FreeXFile(xf);
      display(resultstr, 0);
     }
    else display(msgErrorFileOpen, fn);  /* 2.5b13 jjt */
    if(old) PoolFreeVec(old); /* 2.5.23 rri */
    PoolFreeVec(dest); /* 2.5.23 rri */
   }
 }
else display(msgErrorFileOpen, "XPKMaster Library.");  /* 2.5b13 jjt */
}


struct XFile * AutoUnpack(UBYTE * name) { /* 2.6 rri */
  BPTR                 fh;
  UBYTE                *buf=NULL;
  LONG                 ok=FALSE;
  ULONG                buflen=0, rlen=0, cnt; /* 2.5.23 rri */
  struct XFile         *xf=NULL;
  struct xfdBufferInfo *xbi;

#ifdef __amigaos4__ /* 2.5.31 rri */
  LibOpen("xfdmaster", (struct Library **) &xfdMasterBase, 37, (uint32) &IxfdMaster); /* 2.5.31 rri */
#else
  LibOpen("xfdmaster", (struct Library **) &xfdMasterBase, 37); /* 2.5RC6 rri */
#endif

  if ((fh = Open(name, MODE_OLDFILE))) {
    /* --- Load file --- */
    Seek(fh, 0, OFFSET_END);
    if ((buflen = Seek(fh, 0, OFFSET_BEGINNING))) {
      if ((buf = AllocMem(buflen, MEMF_ANY | MEMF_CLEAR))) { /* 2.5.28 rri */
        if ((rlen = Read(fh, buf, buflen)) > 0) ok = TRUE;
      }
    }
    Close(fh);

    if (ok)
     {
      if ((xf = NewXFile()))
       {
        ok = FALSE;
        xbi = xf->xinfo;
        if (xfdMasterBase && xbi)
         {
          xbi->xfdbi_SourceBuffer = buf;
          xbi->xfdbi_SourceBufLen = buflen;
          xbi->xfdbi_TargetBufMemType = MEMF_ANY | MEMF_CLEAR; /* 2.5.28 rri */
          xbi->xfdbi_Flags = XFDFF_RECOGEXTERN;

          if (xfdRecogBuffer(xbi))
           {
            ok = xfdDecrunchBuffer(xbi);
           }
         }
        if (ok)
         {
          /* Use decrunched buffer. */
          FreeMem(buf, buflen);
          xf->data = xbi->xfdbi_TargetBuffer;
          xf->len = xbi->xfdbi_TargetBufSaveLen;
          xf->buflen = xbi->xfdbi_TargetBufLen;
         }
        else
         {
          /* Use raw buffer. */
          xf->data = buf;
          xf->len = rlen;
          xf->buflen = buflen;
         }

        /* --- Test if data is binary --- */
        buf = xf->data;
        for(cnt=0;(cnt<rlen&&cnt<512);cnt++) /* 2.5.23 rri */
         {
          if (buf[cnt] == 0)
           {
            xf->dataisbin = TRUE;
            break;
           }
         }
       }
     }
  }
if ((xf == NULL) && buf) FreeMem(buf, buflen);
return xf;
}


struct XFile * NewXFile(void)
{
struct XFile *xf;

if(( xf = AllocVec(sizeof (*xf),MEMF_ANY | MEMF_CLEAR) ))
 {
  if (xfdMasterBase) xf->xinfo = xfdAllocObject(XFDOBJ_BUFFERINFO);
 }
return xf;
}


void FreeXFile(struct XFile *xf)
{
if (xf)
 {
  if (xf->data && xf->buflen) FreeMem(xf->data, xf->buflen);
  if (xf->xinfo) xfdFreeObject(xf->xinfo);
  FreeVec(xf);
 }
}
