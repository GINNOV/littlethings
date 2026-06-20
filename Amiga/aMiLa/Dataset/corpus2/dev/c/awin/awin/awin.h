#ifndef _AWINAWIN_H
#define _AWINAWIN_H

/* awin.h

  defines, structures and prototypes for awin

  IMPORTANT: everything is subject to change!
  Do NOT rely on old object files!
  Always recompile files #including awin.h if awin.h
  has changed!

  All structure entries should be at longword aligned
  position for maximum speed and compatibility (68k<->ppc).

*/

#include <exec/exec.h>
#include <devices/timer.h>
#include <graphics/gfx.h>
#include <graphics/text.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <workbench/icon.h>
#include <workbench/workbench.h>
#include <graphics/gfxbase.h>
#include <intuition/intuitionbase.h>

typedef ULONG(*AWIDCMPHOOK_PTR)(struct IntuiMessage *);

typedef enum awports {
  AW_WRITEPORT=0,
  AW_DISPPORT,
  AW_NUMPORTS} awports;

typedef enum awdebugl {
  AWD_QUIET=0,
  AWD_VERBOSE,
  AWD_DEBUG} awdebugl;

typedef enum awidha {
  AWIDHA_NOP=0} awidha;

#define AW_VPRINT(a) if (display->debug) printf(a);
#define AW_VPRINT1(a,x) if (display->debug) printf(a,x);
#define AW_DPRINT(a) if (display->debug>=AWD_DEBUG) printf(a);
#define AW_DPRINT1(a,x) if (display->debug>=AWD_DEBUG) printf(a,x);

/* rrrrrggg gggbbbbb 565 -> rrrgggbb 332 */
#define awrgb16to332(x) ( (((x)>>8)&(7<<5)) | (((x)>>6)&(7<<2)) | (((x)>>3)&3) )

/* rrrrrggg gggbbbbb 565 -> 00000000rrrrr000gggggg00bbbbb000 0888 */
#define awrgb16to0888(x) ( (((x)&0xf800)<<8) | (((x)&0x7e0)<<5) | (((x)&0x1f)<<3) )


#if defined(AW_PPC)
#  define sub64p(a,b) \
     { ((ULONG *)(a))[0]=((ULONG *)(b))[0]-((ULONG *)(a))[0] \
         -(((ULONG *)(b))[1]<((ULONG *)(a))[1]?1:0); \
       ((ULONG *)(a))[1]=((ULONG *)(b))[1]-((ULONG *)(a))[1]; }

#  if defined(__SASC)

#    define ppcgettimerobject(a,b,c) \
       (PPCGetTimerObject((a),(b),(ULONG *)(c)))
#    define ppcsettimerobject(a,b,c) \
       (PPCSetTimerObject((a),(b),(ULONG *)(c)))
#    define ppcneg64p(a) \
       (PPCNeg64p((int *)(a)))
#    define ppcmuls64p(a,b) \
       (PPCMuls64p((int *)(a),(int *)(b)))
#    define ppcmulu64p(a,b) \
       (PPCMulu64p((int *)(a),(int *)(b)))
#    define ppcdivu64p(a,b) \
       (PPCDivu64p((int *)(a),(int *)(b)))

#  else
#    if defined(__GNUC__)

#      define ppcgettimerobject(a,b,c) \
         (PPCGetTimerObject((a),(b),(long long *)(c)))
#      define ppcsettimerobject(a,b,c) \
         (PPCSetTimerObject((a),(b),(long long *)(c)))
#      define ppcneg64p(a) \
         (*((long long *)(a))=PPCNeg64(*((long long *)(a))))
#      define ppcmuls64p(a,b) \
         (*((long long *)(a))=PPCMuls64(*((long long *)(a)),*((long long *)(b))))
#      define ppcmulu64p(a,b) \
         (*((long long *)(a))= \
         PPCMulu64(*((long long *)(a)),*((long long *)(b))))
#      define ppcdivu64p(a,b) \
         (*((long long *)(a))= \
         PPCDivu64(*((long long *)(a)),*((long long *)(b))))

#    else
#      error unknown compiler
#    endif
#  endif
#endif

/* struct awodargs flags */

#define AWODAF_INITWINDOW    0x00000001 /* initially open as window */
#define AWODAF_DONTUPDATEINA 0x00000002 /* don't update if inactive */
#define AWODAF_NODBUFFER     0x00000004 /* don't do double buffering */
#define AWODAF_FORCENATIVE   0x00000008 /* force native mode */
#define AWODAF_DIRECTDRAW    0x00000010 /* use directdraw with CGFX */
#define AWODAF_USEHAM        0x00000020 /* use ham for 16bit if applicable, if
                                           not defined uses 256col emulation */
#define AWODAF_WAITSWAP      0x00000040 /* wait dbuffer safetoswap, this limits
                                           fps to hz/2 */
#define AWODAF_USECGXVIDEO   0x00000080 /* use cgxvideo.library if possible */
#define AWODAF_ABSPOS        0x00000100 /* use absolute window positioning */
#define AWODAF_USEARGB16     0x00000200 /* use ARGB for depth 16 */


/* specifying AWODAF_FORCENATIVE clears AWODAF_DIRECTDRAW.
*/

/* this structure is used to handle awin settings,
   all public rw:
*/
struct awodargs {
  ULONG version;      /* 0 for now */

  ULONG flags;        /* initial flags, see defines above */

  ULONG modeid8;      /* explicit modeid to use for 8bit screen
                         mode, 0 means find best mode */

  ULONG modeid16;     /* explicit modeid to use for 16bit screen
                         mode, 0 means find best mode */

  ULONG width,height; /* initial display width and height
                         also always screen dimension */

  LONG x,y;           /* relative window displacement on pubscreen,
                         normally window is centered to
                         middle of visible part of a pubscreen.
                         use these offsets to move it relative
                         to that position. if AWODAF_ABSPOS is set
                         indicates absolute window left & top. */

  const char *title;  /* optional window title */

  const char *pubscreen;
                      /* optional pubscreen name to open window to,
                         NULL to open on default pubscreen */
  ULONG unused0;      /* this should be NULL for now */
};

/* returned by awreadargs,
   all private:
*/
struct awrdargs {
  struct Library *DOSBase;
  LONG *array;
  struct RDArgs *rda;  /* has two meanings really */
  ULONG wb;
};

/* used by awin awreadargs wb tooltypes wrapper
   if awreadargs is called from WB started app, rda
   points to struct awwbrdargs instead of struct RDArgs.
   all private:
*/
struct awwbrdargs {
  struct Library *IconBase;
  struct DiskObject *dobj;
  ULONG num;
  char *tlate;
  char **name;
  LONG *type;
};

/* returned by awcreatetimer
   all private:
*/
struct awtimer {
#if defined(AW_PPC)
  void *timerobject;
  ULONG tickspersec[2];
  ULONG start[2];
#else
  struct Library *timerbase;
  ULONG tickspersec;
  struct EClockVal start;
#endif
};

/* returned by awloadfile
*/
struct awfile {
  ULONG size;  /* public r */
  void *data;  /* public r */
  ULONG buflen;
  void *memory;
};

/* returned by awinitchunkystruct/awallocchunky
*/
struct awchunky {
  ULONG width,width_align,height; /* public r */
  ULONG depth;                    /* public r */
  UBYTE *framebuffer;             /* public rw */
  void *memory;
};

/* sucks a bit here, should have better system.. :) */
#define awscreensum(sc) (((ULONG)(sc))+((sc)->Width<<16)+(sc)->Height)

/* this struture is returned by awcreatedisplay,
   all private:
*/
struct awdisplay {
  struct ExecBase *SysBase;
  struct GfxBase *GfxBase;
  struct IntuitionBase *IntuitionBase;
  struct Library *UtilityBase;
  struct Library *TimerBase;
  struct Library *CyberGfxBase;
  struct Library *CGXVideoBase;
  struct Library *DOSBase;

  struct Screen *screen;
  struct Window *window;
  struct MsgPort *sbports[AW_NUMPORTS];
  struct ScreenBuffer *sbuf[2];
  struct BitMap *fblitptrbm,*tempbm;
  APTR pointerobject;
  void *memory;
  UBYTE *framebuffer;
  void *c2pplanes[2];
  UBYTE *remap332;
  AWIDCMPHOOK_PTR idcmphook;

  ULONG left,top;                       /* window position */
  ULONG width,width_align,
        pixperrow,scrwidth;             /* width */
  ULONG height;                         /* height */
  ULONG origw,origh;
  ULONG prevwidth,prevheight;           /* old window dimensions */
  ULONG widthaligner;
  ULONG modeid8,modeid16;
  LONG xdisp,ydisp;

  ULONG native,cgfx,truecolor,fblit,v40,
    stoprender,rendering,wlutpa,safetochange,safetowrite,
    curbuffer,slowwpa8,dbuffer,islinearmem,
    isrgb16,cgfx16bit,cgfx16bitf,gfxcard,debug,isham6,
    usehamf,doham;

  ULONG windowmode,dontupdateinactive,nodbuffer,waitswap,
    forcenative,directdraw,useham,usecgxvideo,abspos,
    useargb16;

  ULONG srcdepth,dstdepth;
  ULONG palentries;
  ULONG prevscreen;
  ULONG idcmpflags;

  ULONG vlwidth,vlheight;
  APTR vlhandle;

  struct BitMap c2pbitmap[2];      /* sizeof(struct BitMap) = 40 */
  struct RastPort temprp,renderrp; /* sizeof(struct RastPort) = 100 */

  ULONG palette[256];
  ULONG pal332[256];
  UBYTE remap[256]; /* <- be 4 byte aligned here! */
  UBYTE penal[256];

  char title[80];
  char pubscreen[MAXPUBSCREENNAME+1];
};

#define awalign(x,a) ((((ULONG)(x))+(a)-1)&-(a))


/* prototypes for public (well mostly;) functions */

ULONG awsetdebuglevel(struct awdisplay *display,UBYTE level);

struct awrdargs *awreadargs(struct awdisplay *display,
  struct awodargs *odargs,const char *template, LONG *array);
void awfreeargs(struct awrdargs *args);

ULONG awscreenmodereq(struct awdisplay *display,ULONG *modeid,
  ULONG depth,ULONG *w,ULONG *h,ULONG dodim);

struct awtimer *awcreatetimer(struct awdisplay *display);
void awrestarttimer(struct awtimer *timer);
ULONG awreadtimer(struct awtimer *timer);
ULONG awreadtimer_us(struct awtimer *timer);
void awdeletetimer(struct awtimer *timer);

ULONG awtoinnerw(struct awdisplay *display, ULONG width);
ULONG awtowindoww(struct awdisplay *display, ULONG width);
ULONG awtoinnerh(struct awdisplay *display, ULONG height);
ULONG awtowindowh(struct awdisplay *display, ULONG height);

AWIDCMPHOOK_PTR awsetidcmphook(struct awdisplay *display,
  AWIDCMPHOOK_PTR idcmphook);
ULONG awsetidcmpflags(struct awdisplay *display,
  ULONG idcmpflags);

struct BitMap *awallocbm(ULONG x,ULONG y,ULONG d,ULONG f,struct BitMap *b,
  ULONG fblit);

void awfreechunky(struct awchunky *chunky);
struct awchunky *awinitchunkystruct(struct awdisplay *display,
  ULONG width,ULONG height,ULONG depth);
struct awchunky *awallocchunky(struct awdisplay *display,ULONG width,
  ULONG height,ULONG depth);

void awclosedisplay(struct awdisplay *display);
void awdeletedisplay(struct awdisplay *display);
void awremap(struct awdisplay *display);
ULONG awsetpalette(struct awdisplay *display,ULONG *palette,ULONG n);
void *awiallocbitmap(struct awdisplay *display,struct BitMap *bm,
  ULONG width,ULONG height,ULONG depth,ULONG memtype);
ULONG awreopen(struct awdisplay *display);
struct awdisplay *awcreatedisplay(void);
ULONG awgetvisiblerect(struct awdisplay *display,
  struct Rectangle *rect);
ULONG awgetaspectratio(struct awdisplay *display,ULONG modeid,
  ULONG *xa,ULONG *ya);
ULONG awgetpropertyflags(struct awdisplay *display,ULONG modeid,
  ULONG *flags);
ULONG awgetmaxdepth(struct awdisplay *display,ULONG modeid,
  ULONG *maxdepth);
void awgetwindimension(struct awdisplay *display,
  ULONG *width,ULONG *height);

ULONG awsetflags(struct awdisplay *display,ULONG flags);

ULONG awopendisplay(struct awdisplay *display,
  struct awodargs *odargs);

ULONG awsetdisplaysize(struct awdisplay *display,
  ULONG width,ULONG height);

ULONG awhandleinput(struct awdisplay *display);


void awrenderchunky(struct awdisplay *display,struct awchunky *chunky);

void awrenderchunky_show(struct awdisplay *display,
  struct awchunky *chunky);

void awfreefile(struct awfile *file);
struct awfile *awloadfile(const char *name);

#endif /* _AWINAWIN_H */
