/* DiskMaster II Text Reader
**
** 2.5.29
**
** 04-04-02 rri - Replaced five "#ifdef __PPC__" with "#ifdef __amigaos4__".
**              - Bugfix: When displaying more than 512k lines with 'Read' the scroll-bar was "disabled".
**              - Bugfix: With special combinations of window-height and lines to display the initial
**                        setup of the scroll-bar was disfunctional.
**                        Thanks for reporting to Michel Bagmeijer <303dmx@hetnet.nl>!
**
** 2.5.31
**
** 04-10-31 rri - Changed one LibOpen() call to the new format.
**              - Fixed a warning in fd_reqsearchpat() by setting the var "c" to UBYTE.
**
** 04-12-22 rri - Removed LibDeletePool() and LibCreatePool() -> DM2 goes V39+!
**
** 05-03-26 rri - Replaced "FuckingTopaz" with "Screen_TAttr".
**
** 2.6
**
** 05-07-31 rri - Replaced one (STRPTR) cast with a (UBYTE *) to get rid of a
**                warning with the OS4 SDK 51.10.
**              - Removed comments from header older than 2.5.29.
**              - Added an (UBYTE) cast to one ToUpper() call.
**
** 05-08-01 rri - Corrected defaults for "WINY" and "WINH".
**              - Added support for OS4 mouse-wheel events.
**
** 05-08-07 rri - Introduced var wheel_multiply.
**              - Finalised support for OS4 mouse-wheel events.
**
** 05-10-01 jjt - Added "TABSIZE" option.
**
** 05-11-07 jjt - DMRead() - Replaced the CreatNewProc() call with CreateNewProcTags().
**                Removed the g_reqproctags.
**              - Removed some old commented-out lines.
**              - hndl_idcmp() - Help key opens the "Read" node of DM.guide.
**
** 05-11-08 jjt - Added a DMREQ_HELPNODE tag to g_readreqtags.
**
** 2.7
**
** 06-07-06 rri - Bugfix: Files with trailing PC line-feeds ($0D $0A) caused
**                a visit from the GrimReaper under OS4 because memory was
**                read from address "buffer-2".
**                Thanks for reporting to Javier de las Rivas <javierdlr@euskalnet.net>!
**
** b7
**
** 06-12-26 rri - Switched to DMFONTS_READER in fd_openwin().
**
** b9
**
** 07-01-17 rri - Removed the old-C-style init of g_readsearchpat[], should be well without it.
**
**
*/

#include "DM.h"



/* ---- Constants --- */
#define SHIFT (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT)

/* 2.5b10 jjt (01-01-27) */
#define LDA_MAX 500

#define GID_VSCROLL 1

#define VSSET_TOT 1
#define VSSET_VIS 2
#define VSSET_TOP 4

#define FINDOFFSET_NONE 0
#define FINDOFFSET_LINE 1
#define FINDOFFSET_PAGE 2

#define TITLE_STD     1
#define TITLE_NOMATCH 2

#define ID_FTXT 0x46545854
#define ID_CHRS 0x43485253

/* 2.5b7 jjt */
#define RDCMD_SHOW 1
#define RDCMD_EXIT 2



/*  --- Structure Definitions --- */
struct styledata {
  /* size = 1 (possibly 4) */
  unsigned style:     4;
  unsigned highlight: 1;
  unsigned srchupper: 1;
  unsigned matchany:  1;
};

struct linedata {
  /* size = 12 */
  UBYTE   *dptr;
  ULONG    trueline;  /* 2.5b10 jjt (01-01-29) */
  UWORD    rawlen;
  UBYTE    outlen;
  BOOL     parseme;
};

struct linedataarray {
  /* size =  */
  struct linedataarray *link;
  struct linedata       lines[LDA_MAX];
};

struct filedisplay; /* 2.5.23 gcc rri */

struct linelist {
  /* size = 76 */
  ULONG    total;
  ULONG    topline;
  ULONG    loffset;
  ULONG    maxstrw;
  ULONG    maxtop;
  ULONG    maxoff;
  ULONG    scrollstep;
  LONG   (*makefunc) (struct filedisplay *fd, ULONG line);
  ULONG   *searched;
  ULONG    bookmark[10];
};

struct filedisplay {
  /* size =  */
  struct filedisplay   *next;    /* 2.5b7 jjt */
  struct filedisplay   *prev;    /* 2.5b7 jjt */
  LONG                  linked;  /* 2.5b7 jjt */

  APTR                  mempool; /* 2.5b10 jjt */

  STRPTR                fullname;
  STRPTR                name;

  struct XFile         *xf;
  UBYTE                *data;
  UBYTE                *stopptr; /* 2.5b10 jjt (01-02-02) */
  ULONG                 datalen;

  struct linedataarray *asclda;
  ULONG                 truecount; /* 2.5b10 jjt (01-01-29) */
  struct linelist       asclist;
  struct linelist       hexlist;
  struct linelist      *crntlist;
  LONG                  hexmode;

  ULONG                 hvisible;
  ULONG                 vvisible;
  ULONG                 charw;
  ULONG                 charh;

  struct Screen        *scrn;  /* 2.5b7 jjt */
  struct Window        *win;
  UBYTE                 wintitle[114];
  struct DrawInfo      *drwinfo;
  struct Gadget        *vscroller;

  struct TextFont      *font;

  ULONG                 tpen;
  ULONG                 wx0;
  ULONG                 wy0;
  ULONG                 wx1;
  ULONG                 wy1;
  ULONG                 ty0;

  UBYTE                 srchraw[81];
  UBYTE                 srchstr[81];
  ULONG                 srchlen;
  LONG                  lastmatch;

  UBYTE                *outptr;
  ULONG                 outlen;
  UBYTE                 outbuf[256];
  struct styledata      outstyle[256];
  UBYTE                 stylelen[256];

  ULONG                 clipstartln;
  ULONG                 clipendln;
  ULONG                 clipcrntln;
  ULONG                 clipstartch;
  ULONG                 clipendch;
  ULONG                 clipcrntch;
  LONG                  clipboxmode;

  LONG                  pausedm;  /* 2.5b7 jjt */
  UBYTE                 tabsize;  /* 2.6 jjt */
};



/* --- Function Prototypes --- */
void                   hndl_read(void);
struct filedisplay   * fd_new(STRPTR fname);
void                   fd_end(struct filedisplay *fd);
LONG                   fd_asciiscan(struct filedisplay *fd);
LONG                   fd_openwin(struct filedisplay *fd);
void                   fd_setvisible(struct filedisplay *fd);
void                   fd_settitle(struct filedisplay *fd, ULONG type);
void                   hndl_idcmp(void);
void                   fd_swaplists(struct filedisplay *fd);
void                   fd_filldisplay(struct filedisplay *fd);
void                   fd_setcursor(struct filedisplay *fd, ULONG aty);
void                   fd_printline(struct filedisplay *fd, ULONG line);
void                   fd_cleartoedge(struct filedisplay *fd);
void                   fd_vscroll(struct filedisplay *fd, LONG up);
LONG                   fd_settopline(struct filedisplay *fd, LONG line, LONG scrollupd);
void                   fd_setvscroller(struct filedisplay *fd, ULONG setme);
LONG                   fd_setoffset(struct filedisplay * fd, LONG offset);
LONG                   fd_makehexline(struct filedisplay *fd, ULONG line);
LONG                   fd_makeascline(struct filedisplay *fd, ULONG line);
LONG                   fd_searchline(struct filedisplay *fd, ULONG line);
LONG                   fd_reqsearchpat(struct filedisplay *fd, UBYTE *pattern);
LONG                   fd_findnext(struct filedisplay *fd, LONG prev, ULONG offset);
void                   fd_copy2cb(struct filedisplay *fd);
void                   fd_hibox(struct filedisplay *fd);

struct linedataarray * lda_new(APTR mempool);
struct linedata      * lda_getldx(struct linedataarray *lda, ULONG line);



/* --- Macros --- */
#define BOUNDS(x, lo, hi) (x)<(lo) ? lo : ((x)>(hi) ? (hi) : (x))



/* --- Global Vars  --- */
extern ULONG                FLAGS; /* 2.5RC2 rri */
extern STRPTR               DiskMaster2Guide;  /* 2.6 jjt */
extern struct Screen        *Screen;
extern struct Process       *process;
extern struct StringHistory ReadHistory;
extern struct TextAttr      Default_TAttr;  /* 2.7 rri */
extern struct TextFont      *DMFonts[];    /* 2.5RC2 jjt */
extern uint32 wheel_multiply; /* 2.6 rri */

UBYTE              g_readsearchpat[81]; // test! 2.7b9 rri ={0};
LONG               g_error, g_readsigbit= -1, g_acksigbit= -1;  /* 2.5b7 jjt */
ULONG              g_selfile, g_winflags,
                   g_readcount=0, g_readcmd, /* 2.5b7 jjt */
                   g_readsig, g_acksig,  /* 2.5b7 jjt */
                   g_idcmpflags = IDCMP_CLOSEWINDOW | IDCMP_NEWSIZE |
                                  IDCMP_VANILLAKEY | IDCMP_RAWKEY |
                                  #ifdef __amigaos4__
                                  IDCMP_EXTENDEDMOUSE| /* 2.6 rri */
                                  #endif
                                  IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS | IDCMP_IDCMPUPDATE;  /* 2.5b7 jjt */
const ULONG        g_CommonWinFlags = WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_SMART_REFRESH |
                                      WFLG_ACTIVATE | WFLG_NEWLOOKMENUS,  /* 2.5b10 jjt */
                   g_ReaderWinFlags = WFLG_SIZEGADGET | WFLG_SIZEBRIGHT | WFLG_CLOSEGADGET |
                                      WFLG_NOCAREREFRESH | WFLG_RMBTRAP;   /* 2.5b10 jjt */
APTR               g_readdata;  /* 2.5b7 jjt */
struct Library     *IFFParseBase;

#ifdef __amigaos4__ /* 2.5.26 rri */
struct IFFParseIFace   *IIFFParse = NULL;
#endif

struct Task        *g_readtask=0; /* 2.5b7 jjt */
struct MsgPort     *g_readport;   /* 2.5b7 jjt */
struct filedisplay *g_fdlist=0;   /* 2.5b7 jjt */
struct TagItem     g_readreqtags[]={{DMREQ_SCREEN,  0},            /* 2.5.23 gcc rri */
                                    {DMREQ_HISTORY,(ULONG) &ReadHistory}, /* 2.5.23 gcc rri */
                                    {DMREQ_TITLE,(ULONG) "DMRead"}, /* 2.5.23 gcc rri */
                                    {DMREQ_HELPNODE, (ULONG) "Read"},  /* 2.6 jjt */
                                    {TAG_END,0}};  /* 2.5b10 jjt */ /* 2.5.23 gcc rri */


/* --- Program --- */
void DMRead(UBYTE *file) {   /* 2.5b7 jjt */
  struct filedisplay *fd;

  if (g_acksigbit == -1) {
    g_error = TRUE;

    if ((g_acksigbit = AllocSignal(-1)) != -1) {
      g_acksig = 1 << g_acksigbit;
      if (CreateNewProcTags(NP_Entry,(ULONG) hndl_read,
                            NP_StackSize, 8192,
                            NP_Name,(ULONG) "DMRead",
                            TAG_END))  /* 2.6 jjt */
      {
        Wait(g_acksig);
      }
    }

    if (g_error) {
      display(msgErrorReadInit, 0);  /* 2.5b13 jjt */
      CloseRead();
      goto xit;
    }
  }

  if ((fd = fd_new(file))) {
    g_readcmd = RDCMD_SHOW;
    g_readdata = fd;
    Signal(g_readtask, g_readsig);
    Wait(g_acksig);
    if (fd->pausedm) Wait(g_acksig);  /* Wait until current reader is closed. */
  }

  xit:
  Busy(0);
}


void CloseRead() {  /* 2.5b7 jjt */
  *g_readsearchpat = 0;

  if (g_readtask) {
    if (g_readsigbit != -1) {
      g_readcmd = RDCMD_EXIT;
      Signal(g_readtask, g_readsig);
      Wait(g_acksig);
    }
    g_readtask = 0;
  }
  FreeSignal(g_acksigbit);
  g_acksigbit = -1;
}

/* 2.5b7 jjt */
SAVEDS void hndl_read(void) /* 2.5.23 rri */
{
LONG               done=FALSE;
ULONG              portsig, sigs;
struct filedisplay *fd;

  /* --- Set up --- */
  g_error = TRUE;

  g_readsigbit = AllocSignal(-1);
// test!
  if (g_readsigbit != -1)
//  if ((g_readsigbit = AllocSignal(-1)) != -1)
  {
    g_readsig = 1 << g_readsigbit;
    if ((g_readport = CreateMsgPort())) g_error = FALSE;
  }

  if (!g_error) {
    g_readtask = FindTask(NULL);  /* 2.5b7 jjt */
    portsig = 1 << g_readport->mp_SigBit;
    Signal((struct Task *) process, g_acksig);

  /* --- Main loop --- */
    do {
      sigs = Wait(g_readsig | portsig);
      if (sigs & g_readsig) {
        /* Reader signal*/
        switch (g_readcmd) {
          case RDCMD_SHOW:
            if ((fd = g_readdata)) {
              if (g_fdlist) {
                fd->next = g_fdlist;
                g_fdlist->prev = fd;
              }
              g_fdlist = fd;
              fd->linked = TRUE;

              fd->win->UserPort = g_readport;
              ModifyIDCMP(fd->win, g_idcmpflags);
            }
            break;

          case RDCMD_EXIT:
            while (g_fdlist) fd_end(g_fdlist);
            done = TRUE;
            break;
        }

        g_readcmd = 0;
        if (!done) Signal((struct Task *) process, g_acksig);
      }

      if (sigs & portsig) {
        /* IDCMP signal */
        hndl_idcmp();
      }

    } while (!done);
  }

  /* --- Finished --- */
  if (g_readport) DeleteMsgPort(g_readport);
  FreeSignal(g_readsigbit);
  g_readsigbit = -1;
  Signal((struct Task *) process, g_acksig);
}


struct filedisplay * fd_new(STRPTR fname)
{
APTR               pool;
LONG               error=TRUE, i;
struct filedisplay *fd=NULL;

/* 2.5.31 rri */
if ((pool = CreatePool(MEMF_ANY | MEMF_CLEAR, 8500, 8000))) /* 2.5.28 rri */
 {
  if ((fd = PoolAllocVec(pool, sizeof (struct filedisplay))))
   {
    fd->mempool = pool;

    i = GetActionArg("TABSIZE", AATYPE_NUM, 8);  /* 2.6 jjt */
    fd->tabsize = BOUNDS(i, 1, 20);  /* 2.6 jjt */

    if ((fd->fullname = CloneStr(fname, pool)))
     {
      fd->name = (STRPTR) FilePart(fd->fullname);
      fd->xf = AutoUnpack(fd->fullname);

      if (fd->xf)
       {
        fd->data = fd->xf->data;
        fd->datalen = fd->xf->len;
        fd->stopptr = fd->data + fd->datalen;  /* 2.5b10 jjt (01-02-02) */
        fd->hexmode = GetActionArg("HEX", AATYPE_BOOL, fd->xf->dataisbin);
        fd->crntlist = fd->hexmode ? &fd->hexlist : &fd->asclist;

        fd->hexlist.total = (fd->datalen / 16) + (fd->datalen & 0x0F ? 1 : 0);
        fd->hexlist.topline = 0;
        fd->hexlist.maxstrw = 63;
        fd->hexlist.scrollstep = fd->hexlist.total / 0x10000 + 1;
        fd->hexlist.makefunc = fd_makehexline;

        for (i=0; i < 10; i++)
         {
          /* --- Init bookmarks --- */
          fd->hexlist.bookmark[i] = 0xFFFFF830; /* fd_hndlidcmp() will treat -2000 as "no change". */
          fd->asclist.bookmark[i] = 0xFFFFF830;
         }

        if ((fd->asclda = lda_new(pool)))
         {
          if (fd_asciiscan(fd))
           {
            fd->asclist.topline = 0;
            fd->asclist.scrollstep = fd->asclist.total / 0x10000 + 1;
            fd->asclist.makefunc = fd_makeascline;

            if ((fd->hexlist.searched = PoolAllocVec(pool, (fd->hexlist.total / 32 + 1) * 4)))
             {
              if ((fd->asclist.searched = PoolAllocVec(pool, (fd->asclist.total / 32 + 1) * 4)))
               {
                if (GetActionArg("SEARCH", AATYPE_BOOL, 0))
                 {
                  display(msgStatSearching, fd->name);  /* 2.5b13 jjt */
                  i = GetActionArg("SEARCH", AATYPE_STR, 0);
                  i = fd_reqsearchpat(fd, i ? (UBYTE *) i : g_readsearchpat);  /* 2.6 rri */
                  strcpy(g_readsearchpat, fd->srchraw);
                  if ((i == 0) && (*g_readsearchpat == 0)) /* 2.5.26 jjt */
                   {
                    /* --- Search req. was cancelled. --- */
                    FLAGS |= DMFLAG_ABORT;
                    goto xit;
                   }
                  if (i == -2000) goto xit;
                  fd->crntlist->topline = i;
                  fd->pausedm = TRUE;  /* 2.5b7 jjt */
                 }
                else fd->pausedm = GetActionArg("WAIT", AATYPE_BOOL, 0);  /* 2.5.26 jjt */

                if (fd_openwin(fd))
                 {
                  Busy(1);
                  fd_filldisplay(fd);
                  error = FALSE;  /* 2.5b7 jjt */
                 }
               } /* if ((fd->asclist... */
             } /* if ((fd->hexlist... */
           } /* if (fd_asciiscan(fd)) */
         } /* if ((fd->asclda... */
       } /* if (fd->xf) */
     } /* if ((fd->fullname... */
   } /*if ((fd = PoolAllocVec(... */
 else /* 2.5.28 rri */
  {
   /* 2.5.31 rri */
   DeletePool(pool);
  }
 } /* if ((pool = LibCreatePool( */

if (error)
 {
  display(msgErrorReadView, FilePart(fname));  /* 2.5b13 jjt */
  xit:
  fd_end(fd);
  fd = NULL;
 }
return fd;
}


void fd_end(struct filedisplay *fd) {
  if (fd) {
    if (fd->linked) {  /* 2.5b7 jjt */
      if (fd->prev) fd->prev->next = fd->next;
      else g_fdlist = fd->next;

      if (fd->next) fd->next->prev = fd->prev;
    }

    if (fd->drwinfo) FreeScreenDrawInfo(fd->scrn, fd->drwinfo);
    if (fd->win) {
      if (fd->vscroller) {
        RemoveGList(fd->win, fd->vscroller, -1);
        DisposeObject(fd->vscroller);
      }

      CloseSharedWindow(fd->win);  /* 2.5b7 jjt */
    }
    if (fd->font) CloseFont(fd->font);

    FreeXFile(fd->xf);

    if (fd->pausedm) Signal((struct Task *) process, g_acksig);  /* 2.5b7 jjt */

    /* 2.5.31 rri */
    DeletePool(fd->mempool);  /* 2.5rc4 rri */
  }
}


LONG fd_asciiscan(struct filedisplay *fd) {
  UBYTE                *bptr, *lstart, maxcols, *spcbrk=0;
  LONG                 done=FALSE, lineend=FALSE, special=FALSE, inctrue=TRUE;
  ULONG                c, len=0, charcount=0, lcount=LDA_MAX, maxsw=0, ltotal=0, trueline=0;
  struct linedata      *ldptr;
  struct linedataarray *lda, *lastlda;

  bptr = fd->data;
  lstart = bptr;
  ldptr = fd->asclda->lines;
  lastlda = fd->asclda;

  c = GetActionArg("WRAP", AATYPE_NUM, 254);
  maxcols = BOUNDS(c, 20, 254);

  do {

    c = *bptr++;

    if ( c == 0x0A )
     {
      lineend = TRUE;
     }

    if ( c == 0x0D )
     {
      if( (fd->data < (bptr-1) ) && (*(bptr - 2) != 0x0a) ) /* 2.7 rri */
      {
       if ( *bptr != 0x0A )
       {
        lineend = TRUE;
       }
      }
     }

    else
    {
     if (((c & 0x7F) < 32))
     {  /* 2.5b9 jjt */
      special = TRUE;
      spcbrk = bptr;
      if (fd->xf->dataisbin == FALSE)
      {  /* 2.5b9 jjt */
       if (c == 0x09)
       {                     /* TAB */
        charcount += fd->tabsize;  /* 2.6 jjt */
        charcount -= (charcount % fd->tabsize);  /* 2.6 jjt */
       }
       else if ((c == 27) && (*bptr == '['))
       {   /* ANSI */
        bptr++;
        len++;
        while (1)
        {
         c = *bptr++;
         len++;
         if ((c == 'm') || (c == 0) || (bptr >= fd->stopptr)) break;
        }
       }
      }
     }
     else
     {
      if (c == ' ') spcbrk = bptr;
      charcount++;
     }
    }

    if (charcount > maxcols) {
      if (spcbrk) {
        bptr = spcbrk;
        len = (spcbrk - lstart - 1);
      }
      else bptr--;  /* 2.5b10 jjt */
      charcount = min(maxcols, len);
      lineend = TRUE;
      inctrue = FALSE;  /* 2.5b10 jjt (01-01-29) */
    }

    if (bptr >= fd->stopptr) {
      lineend = TRUE;
      done = TRUE;
    }

    len++;

    if (lineend) {
      lcount--; /* 2.5.23 rri */
      ldptr->dptr = lstart;
      ldptr->rawlen = len;
      ldptr->outlen = charcount;
      ldptr->parseme = special;
      ldptr->trueline = trueline;

      maxsw = max(maxsw, charcount);
      ltotal++;

      if (inctrue) trueline += 1;  /* 2.5b10 jjt (01-01-29) */
      else inctrue = TRUE;         /* 2.5b10 jjt (01-01-29) */

      lineend = FALSE;
      lstart = bptr;
      len = 0;
      charcount = 0;
      special = FALSE;
      spcbrk = 0;

      if (lcount) ldptr++; /* 2.5.23 rri */
      else {
        if ((lda = lda_new(fd->mempool)) == NULL) return FALSE;
        /* link_linedataarray(fd->asclda, lda); */
        lastlda->link = lda; /* 2.5b10 jjt (01-01-30) */
        lastlda = lda;       /* 2.5b10 jjt (01-01-30) */
        lcount = LDA_MAX;
        ldptr = lda->lines;
      }
    }
  } while (!done);

  fd->asclist.maxstrw = maxsw;
  fd->asclist.total = ltotal;

  fd->truecount = trueline; /* 2.5b10 jjt (01-01-29) */

  return TRUE;
}


LONG fd_openwin(struct filedisplay *fd) {
  LONG          ok=TRUE, unlockscr=TRUE,
                x, y, w, h, mw, mh, z[4], tbdr, pscr, fsize;
  STRPTR        sptr;
  struct Screen   *scrn=NULL;  /* 2.5b7 jjt */

  pscr = GetActionArg("PUBSCR", AATYPE_STR, 0);
  if (pscr) scrn = LockPubScreen((STRPTR) pscr);  /* 2.5b7 jjt */
  if (scrn == NULL) {
    scrn = Screen;
    unlockscr = FALSE;
  }

  fd->scrn = scrn;  /* 2.5b7 jjt */
  fd->drwinfo = GetScreenDrawInfo(scrn);
  fd->tpen = GetActionArg("TPEN", AATYPE_NUM, (LONG) fd->drwinfo->dri_Pens[TEXTPEN]);  /* 2.5b13 jjt */

  /* 2.5RC2 jjt */
  sptr = (STRPTR) GetActionArg("FONT", AATYPE_STR, (LONG) GetTFName(DMFonts[DMFONTS_READER]));
  fsize = GetActionArg("FSIZE", AATYPE_NUM, (LONG) DMFonts[DMFONTS_READER]->tf_YSize);
  if (DMOpenFont(DMFONTS_READER, sptr, fsize)) { /* 2.7 rri */
    fd->font = DMFonts[DMFONTS_READER]; /* 2.7 rri */
    //DMFonts[DMFONTS_TMPFIXED] = NULL; /* 2.7 rri */
  }
  else fd->font = OpenFont(&Default_TAttr); /* 2.7 rri */

  fd->charw = fd->font->tf_XSize;
  fd->charh = fd->font->tf_YSize + 1;

  tbdr = scrn->WBorTop + fd->drwinfo->dri_Font->tf_YSize + 1;  /* 2.5b9 jjt */
  mh = tbdr + scrn->WBorBottom + max(fd->charh + 2, 36);
  mw = 73 + fd->charw;

  x = GetActionArg("WINX", AATYPE_NUM, 10);
  y = GetActionArg("WINY", AATYPE_NUM, (LONG) scrn->BarHeight + 1); /* 2.6 rri */
  w = GetActionArg("WINW", AATYPE_NUM, (LONG) scrn->Width);
  w = max(w, mw);
  h = GetActionArg("WINH", AATYPE_NUM, (LONG) scrn->Height - y); /* 2.6 rri */
  h = max(h, mh);
  z[0] = x;
  z[1] = y;
  z[2] = w;
  z[3] = mh;

  fd->vscroller = NewObject(NULL, "propgclass", GA_ID, GID_VSCROLL,
                                                GA_RelRight, -13,
                                                GA_Top, tbdr + 2,
                                                GA_Width, 10,
                                                GA_RelHeight, -(tbdr + 14),
                                                GA_RightBorder, TRUE,
                                                PGA_Total, 0xffff, /* 2.5.29 rri */
                                                PGA_Visible, 0xffff, /* 2.5.29 rri */
                                                PGA_Freedom, FREEVERT,
                                                PGA_NewLook, TRUE,
                                                PGA_Borderless, TRUE,
                                                ICA_TARGET, ICTARGET_IDCMP,
                                                TAG_END, 0);

  fd->win = OpenWindowTags(NULL, WA_Left,      x,
                                 WA_Top,       y,
                                 WA_Width,     w,
                                 WA_Height,    h,
                                 WA_MinWidth,  mw,
                                 WA_MinHeight, mh,
                                 WA_MaxWidth,  0xFFFF,
                                 WA_MaxHeight, 0xFFFF,
                                 WA_Zoom,      z,
                                 WA_IDCMP,         NULL, /* 2.5b7 jjt */
                                 WA_Flags,         g_CommonWinFlags | g_ReaderWinFlags,  /* 2.5b10 jjt */
                                 WA_PubScreen,     scrn,
                                 WA_PubScreenFallBack, TRUE,
                                 WA_AutoAdjust,    TRUE,
                                 WA_ScreenTitle,   fd->fullname,
                                 WA_Gadgets,       fd->vscroller, /* 2.5b9 jjt */
                                 TAG_DONE);
  if (fd->win) {
    fd->win->UserData = (BYTE *) fd;  /* 2.5b7 jjt */

    g_winflags = fd->win->Flags;
    SetFont(fd->win->RPort, fd->font);

    fd->wx0 = fd->win->BorderLeft + 1;
    fd->wy0 = tbdr + 1;  /* 2.5b9 jjt */
    fd->ty0 = fd->wy0 + fd->font->tf_Baseline;

    fd_setvisible(fd);

    fd_settitle(fd, TITLE_STD);

    fd_setvscroller(fd, VSSET_TOT | VSSET_VIS | VSSET_TOP);

    if (unlockscr) ScreenToFront(scrn);
  }
  else ok = FALSE;  /* 2.5b7 jjt */

  if (unlockscr) UnlockPubScreen(NULL, scrn);

  return ok;  /* 2.5b7 jjt */
}


void fd_setvisible(struct filedisplay *fd){
  ULONG  w, h;

  w = fd->win->Width  - fd->win->BorderLeft - fd->win->BorderRight - 2;
  h = fd->win->Height - fd->win->BorderTop - fd->win->BorderBottom - 2;

  fd->hvisible = w / fd->charw;
  fd->vvisible = h / fd->charh;

  fd->wx1 = w + 4;
  fd->wy1 = fd->wy0 + fd->vvisible * fd->charh - 1;

  fd->hexlist.maxtop = fd->hexlist.total > fd->vvisible ? fd->hexlist.total - fd->vvisible : 0;
  fd->hexlist.maxoff = fd->hexlist.maxstrw > fd->hvisible ? fd->hexlist.maxstrw - fd->hvisible : 0;
  fd->asclist.maxtop = fd->asclist.total > fd->vvisible ? fd->asclist.total - fd->vvisible : 0;
  fd->asclist.maxoff = fd->asclist.maxstrw > fd->hvisible ? fd->asclist.maxstrw - fd->hvisible : 0;

  fd_settopline(fd, fd->crntlist->topline, FALSE);
  fd_setvscroller(fd, VSSET_VIS | VSSET_TOP);
  fd_setoffset(fd, fd->crntlist->loffset);
}


void fd_settitle(struct filedisplay *fd, ULONG type) {
  const UBYTE  *titlptr;  /* 2.5b13 jjt */
  UBYTE  shortname[35];
  ULONG  trueline, truetotal;
  struct linelist *ll;
  struct linedata *ld;

  if (type == TITLE_STD) {
    ll = fd->crntlist;

    strcpy(shortname + 31, "...");     /* 2.5b10 jjt */
    CopyMem(fd->name,shortname,31); /* 2.5RC9 rri */

    /* 2.5b10 jjt (01-02-01) */
    if (fd->hexmode) {
      trueline = ll->topline;
      truetotal = ll->total;
    }
    else {
      ld = lda_getldx(fd->asclda, ll->topline);
      trueline = ld->trueline + 1;
      truetotal = fd->truecount;
    }

    sprintf(fd->wintitle, "%s   L: %lu-%lu/%lu (%lu/%lu)  C: %lu-%lu/%lu", shortname,
                                                                           ll->topline + 1, min(ll->topline + fd->vvisible, ll->total), ll->total,
                                                                           trueline, truetotal,
                                                                           ll->loffset + 1, ll->loffset + fd->hvisible, ll->maxstrw);
    titlptr = fd->wintitle;
  }
  else titlptr = fd->srchlen ? msgStatNoMatch : msgStatNoPattern;  /* 2.5b13 jjt */

  SetWindowTitles(fd->win, titlptr, (UBYTE *) -1);
}


void hndl_idcmp(void) {
  APTR                 iaddr;
  LONG                 done, settitl=FALSE, scrollupd=TRUE, clear=FALSE, forceredraw=FALSE,
                       offset, newoff, newtop = -2000;
  ULONG                titltype = TITLE_STD,
                       mx, my, /* 2.5.23 gcc rri */
                       code, qual, cx, cl, class, tmp1;
  struct IntuiMessage  *msg;
  struct filedisplay   *fd, *tmpfd=0;   /* 2.5b7 jjt */
  struct linelist      *ll;
  struct Window        *win;  /* 2.5b7 jjt */
  struct linedata      *ld;

  while ((msg = (struct IntuiMessage *) GetMsg(g_readport))) {
    class = msg->Class;
    code = msg->Code;
    qual = msg->Qualifier;
    iaddr = msg->IAddress;
    mx = msg->MouseX;
    my = msg->MouseY;
    win = msg->IDCMPWindow;  /* 2.5b7 jjt */
    ReplyMsg((struct Message *) msg);

    if (win == NULL) return;  /* 2.5b7 jjt */

    done = FALSE;
    fd = (struct filedisplay *) win->UserData;  /* 2.5b7 jjt */
    ll = fd->crntlist;
    offset = ll->loffset;
    newoff = offset;

    switch (class) {
      case IDCMP_MOUSEBUTTONS: /* 2.5b6 rri */
        if (code == SELECTDOWN) {
          if ((mx > fd->wx0) && (mx <= fd->wx1) && (my >= fd->wy0) && (my < fd->wy1)) {
            fd->clipboxmode = (qual & SHIFT) != 0;
            my = min(my, fd->wy1);
            fd->clipstartln = min((my - fd->wy0) / fd->charh, ll->total - ll->topline);
            fd->clipstartch = (mx - fd->wx0) / fd->charw;
            fd->clipendln = fd->clipstartln;
            fd->clipendch = fd->clipstartch;
            fd->clipcrntln = fd->clipstartln;
            fd->clipcrntch = fd->clipstartch;
            win->Flags |= WFLG_REPORTMOUSE;  /* Start paying attention to rodent. */
          }
        }
        else if ((code == SELECTUP) && (win->Flags & WFLG_REPORTMOUSE)) {
          win->Flags = g_winflags;  /* Shut up, mouse. */
          if ((fd->clipstartln != fd->clipendln) || (fd->clipstartch != fd->clipendch)) {
            fd_copy2cb(fd);
            fd->clipcrntln = fd->clipstartln;
            fd->clipcrntch = fd->clipstartch;
            fd_hibox(fd);  /* Erase existing box. */
          }
        }
        else if (code == MENUDOWN) done = TRUE;
        break;

#ifdef __amigaos4__ /* 2.6 rri */
      case IDCMP_EXTENDEDMOUSE:
        if (code & IMSGCODE_INTUIWHEELDATA)
         {
          struct IntuiWheelData *iwd;

          iwd = (struct IntuiWheelData *)msg->IAddress;

          /* Vertical wheel scroll */
           newtop = ll->topline + iwd->WheelY * wheel_multiply;

          /* Horizontal wheel scroll */
           newoff = ll->loffset + iwd->WheelX * wheel_multiply;
         }
        break;
#endif

      case IDCMP_MOUSEMOVE:
        if (win->Flags & WFLG_REPORTMOUSE) {
          mx = BOUNDS(mx, fd->wx0, fd->wx1);
          my = BOUNDS(my, fd->wy0, fd->wy1);
          cl = min((my - fd->wy0) / fd->charh, ll->total - ll->topline);
          cx = (mx - fd->wx0 + 1) / fd->charw;  /* 2.5RC2 jjt */
          if ((cl != fd->clipendln) || (cx != fd->clipendch)) {
            if (fd->clipboxmode) fd_hibox(fd);  /* Erase box. */
            else {  /* 2.5b10 (01-02-22) */
              fd->clipcrntln = fd->clipendln;
              fd->clipcrntch = fd->clipendch;
            }
            fd->clipendln = cl;
            fd->clipendch = cx;
            fd_hibox(fd);  /* Draw box. */
          }
        }
        break;

      case IDCMP_CLOSEWINDOW:
        done = TRUE;
        break;

      case IDCMP_NEWSIZE:
        fd_setvisible(fd);
        forceredraw = TRUE;
        clear = TRUE;
        break;

      case IDCMP_VANILLAKEY:
        switch(code) {
          case 'h':               /* Hex/ASCII mode */
          case 'm':               /* Hex/ASCII mode */
            fd_swaplists(fd);
            forceredraw = TRUE;
            clear = TRUE;
            break;

          case 3:                 /* Quit (Ctrl-C) */
          case 27:                /* Quit (Esc)    */
            if(fd->pausedm) FLAGS|=DMFLAG_ABORT; /* 2.5.26 rri */
          case 'q':               /* Quit          */
          case '0':               /* Quit (NK 0)   */
            if ((code == '0') && ((qual & IEQUALIFIER_NUMERICPAD) == 0)) break;
            done = TRUE;
            break;

          case 'S':                         /* Search from top       */
            fd_settopline(fd, 0, TRUE);
          case 's':                         /* Search                */
            newtop = fd_reqsearchpat(fd, NULL);
            goto matchtest;
          case 'n':                         /* Find next             */
          case 'c':                         /* Find next             */
          case 'p':                         /* Find prev             */
          case 'N':                         /* Find next (page mode) */
          case 'C':                         /* Find next (page mode) */
          case 'P':                         /* Find prev (page mode) */
            newtop = fd_findnext(fd, (LONG) ((code | 0x20) == 'p'), (LONG) (code & 0x20 ? FINDOFFSET_LINE : FINDOFFSET_PAGE));
matchtest:  if (newtop == -2000) {
              if (*g_readsearchpat && fd->pausedm) done = TRUE;  /* 2.5b7 jjt */
              titltype = TITLE_NOMATCH;
            }
            forceredraw = TRUE;
            break;

          case 'g':               /* Goto line (ignore wrapping)  */
          case 'G':               /* Goto line (respect wrapping) */
            fd->outbuf[0] = 0;
            g_readreqtags[0].ti_Data = (ULONG) fd->scrn;
            /* 2.5b10 jjt (01-02-01) */
            if (DMReqTagList(msgReqGotoLine, fd->outbuf, 15, g_readreqtags)) {  /* 2.5b13 jjt */
              StrToLong(fd->outbuf,&newtop); /* 2.5RC9 rri */
              newtop--; /* 2.5RC9 rri */
              if ((fd->hexmode == FALSE) && (fd->truecount != ll->total) && (code == 'g')) {
                my = BOUNDS(newtop,(LONG) 0, (LONG) fd->truecount - 1); /* 2.5.23 gcc rri */
                for (newtop=0; newtop < (LONG) ll->total; newtop++) { /* 2.5.23 gcc rri */
                  ld = lda_getldx(fd->asclda, newtop);
                  if (ld->trueline == my) break;
                }
              }
            }
            break;

          case '8':
            if (qual & IEQUALIFIER_NUMERICPAD) goto up;     /* Scroll up    */
            break;
          case '2':
            if (qual & IEQUALIFIER_NUMERICPAD) goto down;   /* Scroll down  */
            break;
          case '4':
            if (qual & IEQUALIFIER_NUMERICPAD) goto left;   /* Scroll left  */
            break;
          case '6':
            if (qual & IEQUALIFIER_NUMERICPAD) goto right;  /* Scroll right */
            break;

          case '1':
            if ((qual & IEQUALIFIER_NUMERICPAD) == 0) break;
          case 'b':
pageend:    newtop = 0x7FFFFFFF;                      /* Page end. */
            break;
          case '3':
            if ((qual & IEQUALIFIER_NUMERICPAD) == 0) break;
          case 32: /* Space */
pagedn:     newtop = ll->topline + fd->vvisible - 1;  /* Page down */
            break;
          case '7':
            if ((qual & IEQUALIFIER_NUMERICPAD) == 0) break;
          case 't':
pagetop:    newtop = 0;                               /* Page top  */
            break;
          case '9':
            if ((qual & IEQUALIFIER_NUMERICPAD) == 0) break;
          case 8: /* BS */
pageup:     newtop = ll->topline - fd->vvisible + 1;  /* Page up   */
            break;

          case '*':  /* Unfreeze DM  2.5b7 jjt */
            if (fd->pausedm) {
              fd->pausedm = FALSE;
              Signal((struct Task *) process, g_acksig);
            }
            break;

          case 9:  /* Tab - Cycle windows  2.5b7 jjt */
            if (fd->prev) tmpfd = fd->prev;
            else {
              tmpfd = g_fdlist;
              while (tmpfd->next) tmpfd = tmpfd->next;
            }

cycle:      if (tmpfd && (tmpfd != fd)) {
              WindowToFront(tmpfd->win);
              ActivateWindow(tmpfd->win);
            }
            break;

/* Test
          case 'T':
            for (tmp1=0; tmp1 < 100; tmp1++) fd_vscroll(fd, FALSE);
            break;
*/

/*
          default:
            sprintf(fd->outbuf, "Code = %lx", (APTR) code);
            DMReq(fd->outbuf, 0, 0, 0, DMREQ_TITLE, "Keypress!",
                                       DMREQ_BUTTONS, "Okay",
                                       TAG_END);
            break;
*/
        }
        break;  /* End of VANILLAKEY */

      case IDCMP_RAWKEY:
        if ((code > 0x4F) && (code < 0x5A)) {                  /* Test F1 - F10 */
          tmp1 = code - 0x50;                                  /* Get idx       */
          if (qual & SHIFT) ll->bookmark[tmp1] = ll->topline;  /* Set mark      */
          else newtop = ll->bookmark[tmp1];                    /* Go to mark (uninitialized value is -2000) */
        }
        else {
          switch (code) {                                      /* Test other RAWKEYS */
            case 0x42:  /* Shift-Tab - Reverse cycle windows  2.5b7 jjt */
              if (qual & SHIFT) tmpfd = fd->next ? fd->next : g_fdlist;
              goto cycle;

            case CURSORUP:
up:           if (qual & SHIFT) goto pageup;                     /* Page up  */
              else if (qual & IEQUALIFIER_CONTROL) goto pagetop; /* Page top */
              else fd_vscroll(fd, TRUE);                         /* Line up  */
              break;

            case CURSORDOWN:
down:         if (qual & SHIFT) goto pagedn;                      /* Page down */
              else if (qual & IEQUALIFIER_CONTROL) goto pageend;  /* Page end  */
              else fd_vscroll(fd, FALSE);                         /* Line down */
              break;

            case CURSORRIGHT:
right:        if (qual & SHIFT) newoff = ll->loffset + fd->hvisible - 1;  /* Page right      */
              else if (qual & IEQUALIFIER_CONTROL) newoff = 255;          /* Page full-right */
              else newoff++;                                              /* Char right      */
              break;

            case CURSORLEFT:
left:         if (qual & SHIFT) newoff = ll->loffset - fd->hvisible + 1;  /* Page left      */
              else if (qual & IEQUALIFIER_CONTROL) newoff = 0;            /* Page full-left */
              else newoff--;                                              /* Char left      */
              break;

            case 0x5F:  /* 2.6 jjt */
              ViewAsync(DiskMaster2Guide, "Read");  /* Help */
              break;
          }
        }
        break;  /* End of RAWKEY */

    case IDCMP_IDCMPUPDATE:
      if (GetTagData(GA_ID, 0, iaddr) == GID_VSCROLL)  {
        GetAttr(PGA_Top, fd->vscroller, (ULONG *) &newtop);
        newtop *= ll->scrollstep;
        scrollupd = FALSE;
      }
      /* break; */
    }  /* End of switch(class). */

    if (done) fd_end(fd);   /* 2.5b7 jjt */
    else {
      if (newtop != -2000) settitl = fd_settopline(fd, newtop, scrollupd);
      if (newoff != offset) settitl = fd_setoffset(fd, newoff);

      if (settitl || forceredraw) {
        fd_settitle(fd, titltype);
        fd_filldisplay(fd);
        if (clear) {
          Move(win->RPort, 0, fd->win->RPort->cp_y - (LONG) fd->win->RPort->TxBaseline);
          fd_cleartoedge(fd);
        }
      }
    }
  }    /* End of while(msg).    */
}


void fd_swaplists(struct filedisplay *fd) {
  UBYTE                *addr;
  ULONG               /* i, l=0,*/ newtop;
  struct linedata      *ld;

  if (fd->hexmode) {
    /* 2.5b10 jjt (01-02-01) */
    addr = fd->data + (fd->hexlist.topline * 16);
    for (newtop=0; newtop < fd->asclist.total; newtop++) {
      ld = lda_getldx(fd->asclda, newtop);
      if (addr <= ld->dptr) break;
    }
    fd->hexmode = FALSE;
  }
  else {
    /* 2.5b10 jjt (01-02-01) */
    ld = lda_getldx(fd->asclda, fd->asclist.topline);
    newtop = (ULONG) (ld->dptr - fd->data) / 16;
    fd->hexmode = TRUE;
  }

  fd->crntlist = fd->hexmode ? &fd->hexlist : &fd->asclist;
  fd_settopline(fd, newtop, FALSE);
  fd_setvscroller(fd, VSSET_TOT | VSSET_VIS | VSSET_TOP);
}


void fd_filldisplay(struct filedisplay *fd) {
  ULONG            i, maxl, line;
  struct linelist  *ll;

  ll = fd->crntlist;
  maxl = min(ll->total, fd->vvisible);

  /* --- Print lines ---*/
  line = ll->topline;
  fd_setcursor(fd, 0);
  for (i = 0; i < maxl; i++) {
    fd_printline(fd, line++);
  }
}


void fd_setcursor(struct filedisplay *fd, ULONG aty) {
  ULONG y;

  y = (aty * fd->charh) + fd->ty0;
  Move(fd->win->RPort, fd->wx0, y);
}


void fd_printline(struct filedisplay *fd, ULONG line) {
  UBYTE            *strptr, *slenptr;
  LONG             mlx, style, sl;
  ULONG            offset, x, y, x1, y1, col0, l=0;
  struct RastPort  *rp;
  struct styledata *styleptr;

  rp = fd->win->RPort;

  x = rp->cp_x;
  y = rp->cp_y;
  col0 = x;

  mlx = fd->hvisible;
  offset = fd->crntlist->loffset;

  (*fd->crntlist->makefunc) (fd, line);

  if (offset < fd->outlen) {
    strptr = fd->outptr + offset;
    styleptr = fd->outstyle;
    slenptr = fd->stylelen;

    do {
      /* --- Find style at current offset --- */
      style = styleptr++->style;
      sl = *slenptr++;
      l += sl;
    } while (l < offset);
    sl = l - offset;

    SetDrMd(rp, JAM2);
    SetAPen(rp, (ULONG) fd->tpen);

    l = offset + 1;
    while (mlx >= 0) {
      /* --- Print text --- */
      SetSoftStyle(rp, style, FSF_BOLD | FSF_ITALIC | FSF_UNDERLINED);
      Text(rp, strptr, min(mlx, sl));

      strptr += sl;
      l += sl;
      mlx -= sl;
      if (l >= fd->outlen) break;

      style = styleptr++->style;
      sl = *slenptr++;
    }
  }

  y1 = y - rp->TxBaseline;
  if (mlx > 0) {
    /* --- Clear to EOL --- */
    x = rp->cp_x;
    x1 = fd->win->Width - fd->win->BorderRight - 1;
    EraseRect(rp, x, y1, x1, y1 + rp->TxHeight);
  }


  if (offset < fd->outlen) {
    /* ---Highlight --- */
    SetDrMd(rp, COMPLEMENT);
    SetWrMsk(rp, 2);
    x = col0;
    mlx = min (fd->hvisible, fd->outlen - offset);

    styleptr = fd->outstyle + offset;
    while (mlx--) {
      if (styleptr++->highlight) {
        RectFill(rp, x, y1, x + fd->charw - 1, y1 + rp->TxHeight - 1);
      }
      x += fd->charw;
    }
    SetWrMsk(rp, 0xFF);
  }

  Move(rp, col0, y + fd->charh);  /* LF */
}


void fd_cleartoedge(struct filedisplay *fd) {
  ULONG           x, y, x1, y1;
  struct RastPort *rp;

  rp = fd->win->RPort;
  x1 = fd->win->Width - fd->win->BorderRight - 1;
  y1 = fd->win->Height - fd->win->BorderBottom - 1;

  /* --- Clear to bottom --- */
  x = fd->wx0;
  y = rp->cp_y;
  if (y < y1) EraseRect(rp, x, y, x1, y1);

  /* --- Clear to edge --- */
  x = fd->wx0 + (fd->hvisible * fd->charw);
  y = fd->wy0;
  if (x < x1) EraseRect(rp, x, y, x1, y1);
}


void fd_vscroll(struct filedisplay *fd, LONG up) {
  LONG            th;
  ULONG           ok, x, y, x1, y1, line, top;
  struct linelist *ll;
  struct RastPort *rp;

  ll = fd->crntlist;
  top = ll->topline;

  ok = up ? top != 0 : top != ll->maxtop;
  if (ok) {
    rp = fd->win->RPort;

    th = fd->charh;
    x = fd->wx0;
    y = fd->wy0;
    x1 = x + (fd->hvisible * rp->TxWidth);
    y1 = y + (fd->vvisible * th) - 1;
    if (up) th = -th;

    ScrollRaster(rp, 0, th, x, y, x1, y1);

    if (up) {
      y = 0;
      top--;
      line = top;
    }
    else {
      y = fd->vvisible - 1;
      top++;
      line = top + y;
    }
    fd_settopline(fd, top, TRUE);

    fd_setcursor(fd, y);
    fd_printline(fd, line);

    fd_settitle(fd, TITLE_STD);
  }
}


LONG fd_settopline(struct filedisplay *fd, LONG line, LONG scrollupd) {
  LONG ok, newtop;

  newtop = BOUNDS(line, 0, (LONG) fd->crntlist->maxtop); /* 2.5.23 gcc rri */
  ok = newtop != (LONG) fd->crntlist->topline; /* 2.5.23 gcc rri */
  if (ok) {
    fd->crntlist->topline = newtop;
    if (scrollupd) fd_setvscroller(fd, VSSET_TOP);
  }

  return ok;
}


LONG fd_setoffset(struct filedisplay *fd, LONG offset) {
  LONG ok, newoff;

  newoff = BOUNDS(offset, 0, (LONG) fd->crntlist->maxoff); /* 2.5.23 gcc rri */
  ok = newoff != (LONG) fd->crntlist->loffset; /* 2.5.23 gcc rri */
  if (ok) fd->crntlist->loffset = newoff;

  return ok;
}


void fd_setvscroller(struct filedisplay *fd, ULONG setme) {
  ULONG sstep, total, vis, top;

  sstep = fd->crntlist->scrollstep;
  total = fd->crntlist->total / sstep;
  vis = fd->vvisible / sstep - sstep + 1;
  top = fd->crntlist->topline / sstep;

  if(vis > 0xffff) vis = 1; /* for big files vis could become "negative" - 2.5.29 rri */

  SetGadgetAttrs(fd->vscroller, fd->win, NULL, setme & VSSET_TOT ? PGA_Total : TAG_IGNORE, total,
                                               setme & VSSET_VIS ? PGA_Visible : TAG_IGNORE, vis,
                                               setme & VSSET_TOP ? PGA_Top : TAG_IGNORE, top,
                                               TAG_END);
}


LONG fd_makehexline(struct filedisplay *fd, ULONG line) {
  UBYTE *bptr, *hptr, *aptr, ascnums[16];
  LONG  srchmatch=FALSE, chi, clo;
  ULONG c, i, addr;

  hptr = fd->outbuf;
  fd->outstyle[0].style = FS_NORMAL;
  fd->stylelen[0] = 63;
  c = '0';
  for (i = 0; i < 64; i++) {
    if (i == 10) c = 'A';
    if (i < 16) ascnums[i] = c++;

    *(hptr + i) = 32;
    fd->outstyle[i].highlight = 0;
  }
  *(hptr+63) = 0;

  fd->outlen = 63;
  fd->outptr = fd->outbuf;

  addr = line * 16;
  sprintf(hptr, "%08lX:", addr);
  *(hptr+9) = ' ';

  bptr = fd->data + addr;
  hptr += 10;
  aptr = fd->outbuf + 47;

  for (i = 1; (i < 17) && (bptr < fd->stopptr); i++) {
    c = *bptr++;

    chi = c >> 4;
    clo = c & 0x0F;
    *hptr++ = ascnums[chi];
    *hptr++ = ascnums[clo];

    *aptr++ = (c & 0x7F) < 32 ? '.' : c;  /* 2.5b9 jjt */

    if ((i & 3) == 0) hptr++;      /* Skip a space (4 bytes written). */
  }

  if (fd->srchlen) srchmatch = fd_searchline(fd, line);
  return srchmatch;
}


LONG fd_makeascline(struct filedisplay *fd, ULONG line) {
  UBYTE             *bptr, *sptr, *slenptr, *cptr, *stopptr;
  LONG              srchmatch=FALSE;
  ULONG             c, style, oldstyle=FS_NORMAL,
                    spcs, charcount=0, oldstylestart=0, l;
  struct linedata   *ld;
  struct styledata  *styleptr;

  ld = lda_getldx(fd->asclda, line);  /* 2.5b10 jjt (01-02-01) */

  styleptr = fd->outstyle;
  slenptr = fd->stylelen;
  styleptr++->style = FS_NORMAL;

  if (ld->parseme) {
    bptr = ld->dptr;
    stopptr = bptr + ld->rawlen;

    sptr = fd->outbuf;
    fd->outptr = fd->outbuf;

    do {
      c = *bptr++;

      if (((c & 0x7F) < 32)) {  /* 2.5b9 jjt */
        if (fd->xf->dataisbin == FALSE) {  /* 2.5b9 jjt */
          if (c == 0x09) {                         /* --- Expand TABs --- */
            spcs = charcount + fd->tabsize;  /* 2.6 jjt */
            spcs -= (spcs % fd->tabsize);  /* 2.6 jjt */
            for (; charcount < spcs; charcount++) *sptr++ = ' ';
          }

          else if ((c == 27) && (*bptr == '[')) {  /* --- ANSI :-P --- */
            bptr++;
            cptr = bptr;
            style = oldstyle;

            while (bptr < stopptr) {
              c = *bptr++;
              if ((c == 0) || (c == 0x0A)) {
                style = oldstyle;
                break;
              }
              if ((c == ';') || (c == 'm')) {
                if ((bptr - cptr) == 2) {
                  switch(*cptr) {
                    case '0':
                      style = FS_NORMAL;
                      break;
                    case '1':
                      style |= FSF_BOLD;
                      break;
                    case '3':
                      style |= FSF_ITALIC;
                      break;
                    case '4':
                      style |= FSF_UNDERLINED;
                      break;
                  }
                }
                cptr = bptr;
                if (c == 'm') break;
              }
            }

            l = charcount - oldstylestart;
            if ((style != oldstyle) && l) {
              *slenptr++ = l;                /* Length of last style. */
              styleptr++->style = style;     /* New style. */
              oldstylestart = charcount;
              oldstyle = style;
            }
          }
        }
      }
      else {
        *sptr++ = c;
        charcount++;
      }
    } while (bptr < stopptr);

    *sptr = 0;
    *slenptr = charcount - oldstylestart;

    fd->outlen = charcount;
  }

  else {
    fd->outptr = ld->dptr;
    fd->outlen = ld->outlen;
    *slenptr = ld->outlen;
  }

  for (l = 0; l < fd->outlen; l++) fd->outstyle[l].highlight = 0;

  if (fd->srchlen) srchmatch = fd_searchline(fd, line);
  return srchmatch;
}


LONG fd_searchline(struct filedisplay *fd, ULONG line) {
  UBYTE *pptr, *sptr;
  LONG  hex, success=FALSE,
        c, i, stop, hli, hls;
  ULONG pl, match=0, slidx, skipbit, hbit;

  hex = fd->hexmode;

  pptr = fd->srchstr;
  pl = fd->srchlen;
  i = 0;

  slidx = line / 32;
  skipbit = 0x80000000 >> (line % 32);

  if ((fd->crntlist->searched[slidx] & skipbit) == 0) {
    if (hex) {
      hbit = line * 16;
      sptr = fd->data + hbit;
      stop = min((ULONG) (fd->stopptr - sptr), pl + 16); /* 2.5.23 gcc rri */

      i -= min(pl-1, hbit);
    }
    else {
      sptr = fd->outptr;
      stop = fd->outlen;
    }

    for (; i < stop; i++) {
      c = *(sptr + i);
      if (fd->outstyle[match].srchupper) c = ToUpper((UBYTE) c); /* 2.6 rri */
      if ((c == *(pptr + match)) || fd->outstyle[match].matchany) {
        match += 1;
        if (match == pl) {
          /* --- Set highlight bits. --- */
          c = i - pl + 1;
          if (hex) {
            c = max(0, c);
            hls = min(i, 15) + 1;
            for (; c < hls; c++) {
              hli = (c * 2) + (c / 4) + 10;
              fd->outstyle[47 + c].highlight = 1;
              fd->outstyle[hli].highlight = 1;
              fd->outstyle[hli + 1].highlight = 1;
            }
          }
          else for (; c < i + 1; c++) fd->outstyle[c].highlight = 1;

          match = 0;
          success = TRUE;
          fd->lastmatch = line;
        }
      }
      else if (match) {
        i -= match;
        match = 0;
      }
    }
    if (success == FALSE) fd->crntlist->searched[slidx] |= skipbit;
  }

  return success;
}


LONG fd_reqsearchpat(struct filedisplay *fd, UBYTE *pattern) {
  UBYTE            buf[81], *bptr, *pptr;
  UBYTE            c; /* 2.5.31 rri */
  LONG             upperon=TRUE, loop;
  ULONG            qc=0, l, pl=0, offset=FINDOFFSET_LINE, i, chi, clo;
  struct styledata *uptr;

  if (pattern && *pattern) strcpy(buf, pattern);  /* 2.5b7 jjt */
  else {
    *buf = 0;  /* 2.5b10 jjt */
    g_readreqtags[0].ti_Data = (ULONG) (fd->scrn ? fd->scrn : Screen);  /* 2.5b10 jjt */
    if (DMReqTagList(msgReqSearchPat, buf, 80, g_readreqtags) == 0) return (LONG) fd->crntlist->topline;  /* 2.5b13 jjt */
  }
  bptr = buf;

  if (strcmp(fd->srchraw, bptr)) {  /* New pattern entered; parse it. */
    offset = FINDOFFSET_NONE;
    fd->lastmatch = 0;

    pptr = fd->srchstr;
    uptr = fd->outstyle;
    l = strlen(bptr);
    if (l) {
        while ((c = *bptr++)) {
        uptr->matchany = FALSE;
        if (c == 0x5C) {           /* "\" - Don't interpret next char as special. */
          if (*bptr) c = *bptr++;
        }
        else if (c == '$') {       /* Hex. */
          /* 2.5b10 jjt (01-02-03) */
          loop = TRUE;
          while (loop) {
/*
            chi = *bptr++;
            if (isxdigit(chi)) {
              clo = *bptr++;
              if (isxdigit(clo) == 0) {
                clo = chi;
                chi = 0;
                loop = FALSE;
              }
              chi = chi > '9' ? (chi & 0x5F) - '7' : chi - '0';
              clo = clo > '9' ? (clo & 0x5F) - '7' : clo - '0';
*/
            if ((chi = Char2Nibble((ULONG) *bptr++)) < 16) {    /* 2.5b11 jjt*/
              if ((clo = Char2Nibble((ULONG) *bptr++)) > 15) {
                clo = chi;
                chi = 0;
                loop = FALSE;
              }

              *(pptr++) = chi * 16 + clo;
              uptr++->srchupper = FALSE;
              pl++;
            }
            else loop = FALSE;
          }
          bptr--;
          continue;
        }
        else if (c == '~') {       /* Case-sensitivity toggle. */
          upperon ^= TRUE;
          continue;
        }
        else if (c == '?') {       /* Match any. */
          uptr->matchany = TRUE;
          qc++;  /* Count "?"s. */
        }

        *(pptr++) = upperon ? ToUpper(c) : c;
        uptr++->srchupper = upperon;
        pl++;
      }

      if (qc == l) {         /* If pattern is all "?"s then shorten it to one. */
        fd->srchstr[1] = 0;
        pl = 1;
      }
    }
    *pptr = 0;

    strcpy(fd->srchraw, buf);
    fd->srchlen = pl;

    /* --- Clear searched arrays --- */
    for (i=0; i < (fd->hexlist.total / 32 + 1); i++) fd->hexlist.searched[i] = 0L;
    for (i=0; i < (fd->asclist.total / 32 + 1); i++) fd->asclist.searched[i] = 0L;
  }

  return fd_findnext(fd, FALSE, offset);
}


LONG fd_findnext(struct filedisplay *fd, LONG prev, ULONG offset) {
  LONG  match=FALSE,
        (*makefunc) (struct filedisplay *fdx, ULONG line), /* 2.5.23 gcc rri */
        dir, line, offstep;
  ULONG *srched, skipbit;

  offstep = offset ? (offset == FINDOFFSET_LINE ? 1 : fd->vvisible) : 0;
  if (prev) offstep = -offstep;
  line = fd->crntlist->topline + offstep;
  dir = prev ? -1 : 1;

  if (!prev && (fd->crntlist->topline == fd->crntlist->maxtop) &&
      (fd->lastmatch > (LONG) fd->crntlist->topline)) line = fd->lastmatch + 1; /* 2.5.23 gcc rri */

  srched = fd->crntlist->searched + (line / 32);
  skipbit = 0x80000000 >> (line % 32);

  makefunc = fd->crntlist->makefunc;
  while ((line > -1) && ((ULONG) line < fd->crntlist->total)) { /* 2.5.23 gcc rri */
    if ((*srched & skipbit) == 0) {
      match = (*makefunc) (fd, line);
      if (match) break;
    }
    line += dir;
    if (prev) {
      skipbit <<= 1;
      if (skipbit == 0) {
        srched--;
        skipbit = 1L;
      }
    }
    else {
      skipbit >>= 1;
      if (skipbit == 0) {
        srched++;
        skipbit = 0x80000000;
      }
    }
  }

  return match ? line : -2000;
}


void fd_copy2cb(struct filedisplay *fd) {
  LONG  append=FALSE, (*makefunc) (struct filedisplay *fdx, ULONG line); /* 2.5.23 gcc rri */
  ULONG srchlen, so, csc, cec, csl, cel, len;
  struct IFFHandle *iffhndl=0;

#ifdef __amigaos4__ /* 2.5.26 rri */
  if (LibOpen("iffparse", &IFFParseBase, 36, (uint32) &IIFFParse)) iffhndl = AllocIFF(); /* 2.5.31 rri */
#else
  if (LibOpen("iffparse", &IFFParseBase, 36)) iffhndl = AllocIFF();  /* 2.5RC6 rri */
#endif
  if (iffhndl) {
    srchlen = fd->srchlen;
    fd->srchlen = 0;  /* Turn searching off. */
    makefunc = fd->crntlist->makefunc;

    csl = fd->clipstartln + fd->crntlist->topline;
    csc = fd->clipstartch + fd->crntlist->loffset;
    cel = fd->clipendln + fd->crntlist->topline;
    cec = fd->clipendch + fd->crntlist->loffset;

    len = (csl == cel) || fd->clipboxmode;
    if (((csl > cel) && (len == 0)) || (len && (csc > cec))) {
      so = csc;
      csc = cec;
      cec = so;
    }
      if (csl > cel) {
      so = csl;
      csl = cel;
      cel = so;
    }

    if ((iffhndl->iff_Stream = (ULONG) OpenClipboard(0))) {
      InitIFFasClip(iffhndl);
      if (OpenIFF(iffhndl, IFFF_WRITE) == 0) {
        if (PushChunk(iffhndl, ID_FTXT, ID_FORM, IFFSIZE_UNKNOWN) == 0) {
          if (PushChunk(iffhndl, ID_FTXT, ID_CHRS, IFFSIZE_UNKNOWN) == 0) {
            so = csc;
            for (; csl <= cel; csl++) {
              (*makefunc)(fd, csl);
              if (so > fd->outlen) so = fd->outlen;
              len = (fd->clipboxmode || (csl == cel)) ? min(fd->outlen, cec) : fd->outlen;
              if (append) WriteChunkBytes(iffhndl, "\n", 1);
              if (WriteChunkBytes(iffhndl, fd->outptr + so, len - so) < 0) break;
              append = TRUE;
              so = fd->clipboxmode ? csc : 0;
            }
            PopChunk(iffhndl);
          }
          PopChunk(iffhndl);
        }
        CloseIFF(iffhndl);
      }
      CloseClipboard((struct ClipboardHandle *) iffhndl->iff_Stream);
    }
    FreeIFF(iffhndl);  /* 2.5b7 jjt */
    fd->srchlen = srchlen;
  }
}


void fd_hibox(struct filedisplay *fd) {
  ULONG            csc, cec, ch, csl, cel, sx, sy, ex, ey, t, smpl;
  struct RastPort *rp;

  rp = fd->win->RPort;
  csl = fd->clipcrntln;
  csc = fd->clipcrntch;
  cel = fd->clipendln;
  cec = fd->clipendch;
  ch = fd->charh;

  smpl = (csl == cel) || fd->clipboxmode;

  if (((csl > cel) && (smpl == 0)) || (smpl && (csc > cec))) {
    t = csc;
    csc = cec;
    cec = t;
  }
  if (csl > cel) {
    t = csl;
    csl = cel;
    cel = t;
  }

  sx = csc * fd->charw + fd->wx0;
  sy = csl * ch + fd->wy0 - 1;
  ex = cec * fd->charw + fd->wx0;
  ey = cel * ch + fd->wy0 - 1;
  ch--;
  SetWrMsk(rp, 1);
  SetDrMd(rp, COMPLEMENT);

  if (smpl) RectFill(rp, sx, sy, ex - 1, ey + ch);
  else {
    RectFill(rp, sx, sy, fd->wx1, sy + ch);
    RectFill(rp, fd->wx0, ey, ex - 1, ey + ch);
    if ((cel - csl) > 1) RectFill(rp, fd->wx0, sy + ch + 1, fd->wx1, ey - 1);
  }

  SetWrMsk(rp, 0xFF);
}



struct linedataarray * lda_new(APTR mempool) {
  /* 2.5b10 jjt (01-01-27) */
  return PoolAllocVec(mempool, sizeof (struct linedataarray));
}


struct linedata * lda_getldx(struct linedataarray *lda, ULONG line) {  /* 2.5b10 jjt (01-02-01) */
  for (; line >= LDA_MAX; line -= LDA_MAX) lda = lda->link;
  return &lda->lines[line];
}

