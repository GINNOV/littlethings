/* awin.c 1.0.13

todo:
 - test depth 16 directdraw with cv3d (modulo should be ok, but
   I'm not 100% sure)
 - implement window open/close hooks with possiblity to pass
   extra taglist to OpenWindowTags (for menus etc)
 - write 0x0 optimized versions of _awddscalech68k16,
   _awddremapscalech68k16, _awddscalech68k16_565,
   _awddscalech68k16_argb and awchunky2planarham6
 - add dithered 565->332 conversions (needed?)
 - add triplebuffering (needed?)
 - fixedsize flag (don't scale, don't allow window resize,
   or screenmodereq, width and height arguments ignored)
 - set pending quitflag in awrenderchunky if srcdepth change
   fails and check this flag in awhandleinput
 - add awismrFilterFunc_hookentry support for ppc version
 - argparser: if windowmode adjust width & height to
   1:1 aspect ratio (use awodargs default dimensions to get ar)
 - key to set current window size as default
 - implement jump to (next?) pubscreen

new features since last release:
 - implemented ARGB for depth 16, now window and non-directdraw
   screen mode have real 16bit output.
 - extensively tested on my brand new BVisionPPC,
   1280x1024 16bit wb on 21" monitor seriously kicks ass :-)

bugfixes since last release:
 v1.0.13
 - now uses DIPF_IS_HAM trick to get native default monitor
 - gfxcard and forcenative disables fblit check (speed issues)
 - forcenative + useham caused problems with CGFX/P96
 - *awiwbReadArgs /T didn't allow 1 for true and 0 for false
 - didn't set palette for 16bit screen
 - CGFX/P96 16bit directdraw was buggy due missing
   display->pixperrow/=2;
 - finally fixed awreadargs flag update
 v1.0.12
 - awallocbm should now change task ln_name ppc combatible way
 - awallocbm didn't check for pr_CLI -> fblit wasn't detected
   if awin was started from Workbench
 - awsetpalette didn't respect stoprender.
 - WriteLUTPixelArray used wrong palette with 16bit emu.
 - heart of 16bit->8bit system, awrgb16to332, was wrong, it
   lost all red bits :)
 - fixed rgb565->rgb332 remapscale 1:1
 - DIPF_IS_WB prevented selection of HAM modes.
 - finally found the nasty timer havoc from PPC code:
   PPCSub64 is fukken BUGGED! for example PPCSub64 thinks
   1c00011f79 - 1b40eede5c = 1bf12411d ... erm, maybe not!
   PPCSub64 doesn't handle lower long overflow condition
   correctly. how lame. replaced with own code.
 - really fixed PPC 'CyberGraphX 3+ PIXFMT_RGB16 not available' bug,
   it was because of unpatched (geninclude.pl)
   gg:ppc-amigaos/os-include/cybergraphx/cybergraphics.h
   struct CyberModeNode
 - fixed ppc timer wraparound bug
 v1.0.11
 - due stupid mistake you could not turn off dbuffering hmmph :)
 - fixed lockpubscreen fallback
 - found out that also SAS/C ppc fucks up os structure
   alignment. hmph
 - ppc had probs with INVALID_ID because it's ~0 and thus
   negative. fixed with #undef INVALID_ID #define INVALID_ID
   (0xffffffffUL). "<Piru_> Zuikkis, siellä o jotain häröä :)"
 - there was no 'display->native=1; display->cgfx=0;' code
   in awigetscreentype, and this caused problems with cgfx +
   native modes. Thanks to zuulkuul for reporting this problem :)
 - took ages to figure out that Libnix-PPC makes os structure
   alignment fuck up. damn it! :-( maybe libRILC then
 v1.0.10
 - added some fixed GG includes
 - improved awin.doc
 - added AW_SCALEDEBUG to help scale debugging
 - doesn't choke anymore if CloseScreen() fails, instead
   will DisplayBeep, Delay and retry until successful.
 - ouch, directdraw didn't wait safetowrite
 v1.0.9
 - fixed some ddazure2.ASM overflows
 - no more does awremap on window resize
 - improved awin.doc a bit
 - ddazure2.ASM/_awddremapscalech68k8 .samex trashed 12(a5)
   and 4(a5) with given a5. hillos to Asa who experienced some
   crashes because of this. :)
 v1.0.8
 - had (!display->truecolor) in awremap window mode, it
   broke wlutpa fallback code (it didn't alloc pens)
 v1.0.7
 - now you can choose only valid screenmodes with screenmodereq
 - implemented proper (I hope) modeid validation
 - added bunch of missing TAG_DONEs
 - preparing some stuff for 16bit support, also fixed argument
   parser accordingly
 - fixed lots of display->pixperrow=display->width; to
   display->pixperrow=display->width_align;
   now window resize should work again on wlutpa systems.
   (now YOU can shoot me for that mistake, thanks to Duken
   who apparently was the only one to resize the window... :)
 - made awsetpalette again NOT clear window on screen mode,
   I rely on coder doing palette changes correctly. now palette
   fades are possible (screen mode only tho)
 v1.0.6
 - oops, added __saveds to awismrFilterFunc_hookentry,
   it broke without when awindemo grew out of smalldata
 - hmpph. whoever convinced me that it doesn't make sense to
   use dbuffer with directdraw will be shot. I wish I wouldn't
   need to shoot myself.
 - added modulo support to awscalechunky
 v1.0.5
 - (bpr&0xf==0) -> ((bpr&0xf)==0) now directdraw works. Thanks
   to Duken who kindly recompiled bugfixed version.
 v1.0.4
 - there were no bugs. honest ;)
 v1.0.3
 - added fallback code here and there
 - general code cleanup
 v1.0.2
 - now checks DIPF_IS_DBUFFER before buffering
 - fixed to gracefully fall back to native mode if some unknown
   gfxsystem (CGFX V2 for example)
 - fixed CGFX doublebuffer to render correct bitmap
 - fixed awremap to check palentries and screen
 - fixed screenbuffer port cleanup

notes:
 - first CyberGraphX 4's were bugged I heard
 - c2p is used on native screen mode
 - c2p+blit is used on native window mode if fblit is running
   or there is no WCP/WPA8 patch installed
 - if there is no WCP/WPA8 patch or fblit running window
   mode flickers quite a lot, also interleaved screen reduces
   flicker
 - keys:
   ESC Q quit
   W     switch to window mode
   S     switch to screen mode
   TAB   toggle between window and screen mode
   P     pause rendering (handy for screenshots;)
   SPACE readjust window size/pos so that it has original w&h
   M     change screen mode ModeID (also changes window size)

suggestions:
 - always have correct 68040 (and 68060) libraries installed
 - always run SetPatch before running awin programs
 - on native systems use fblit and NewWPA8 for best performance
 - if CGXAGA seems utterly slow get NewWPA8 from aminet
   (however native AGA mode IS faster than CGXAGA)

legal mushmush:
 - see awin.doc/--introduction--

*/

/*
	;rrrrrggg gggbbbbb rrrrrggg gggbbbbb 565 565
	;to
	;rrrgggbb rrrgggbb 332 332

	moveq	#16,d7

	move.l	#~(1<<(2+16)),d5
	and.l	(a1)+,d5 ;1 rrrxxggg yyybb0zz rrrxxggg yyybbzzz
	move.l	(a1)+,d6 ;2 rrrxxggg yyybbzzz rrrxxggg yyybbzzz
	bra	.goxlop

.xlop	move.l	(a1)+,d5 ;1 rrrxxggg yyybb0zz rrrxxggg yyybbzzz
	move.l	(a1)+,d6 ;2 rrrxxggg yyybbzzz rrrxxggg yyybbzzz
	and.l	#~(1<<(2+16)),d5
	move.l	d4,(a0)+
.goxlop
	lsl.b	#3,d5	;1 rrrxxggg yyybb0zz rrrxxggg bbzzz000
	lsl.b	#3,d6	;2 rrrxxggg yyybbzzz rrrxxggg bbzzz000
	lsr.w	#5,d5	;1 rrrxxggg yyybb0zz 00000rrr xxgggbbz
	lsr.w	#5,d6	;2 rrrxxggg yyybbzzz 00000rrr xxgggbbz
	lsl.b	#2,d5	;1 rrrxxggg yyybb0zz 00000rrr gggbbz00
	lsl.b	#2,d6	;2 rrrxxggg yyybbzzz 00000rrr gggbbz00
	lsr.w	#3,d5	;1 rrrxxggg yyybb0zz 00000000 rrrgggbb
	lsr.w	#3,d6	;2 rrrxxggg yyybbzzz 00000000 rrrgggbb
	rol.l	d7,d5	;1 swap
	rol.l	d7,d6	;2 swap
	lsl.b	#3,d5	;1 00000000 rrrgggbb rrrxxggg bb0zz000
	lsl.b	#3,d6	;2 00000000 rrrgggbb rrrxxggg bbzzz000
	lsr.w	#5,d5	;1 00000000 rrrgggbb 00000rrr xxgggbb0
	lsr.w	#5,d6	;2 00000000 rrrgggbb 00000rrr xxgggbbz
	lsl.b	#2,d5	;1 00000000 rrrgggbb 00000rrr gggbb000
	lsl.b	#2,d6	;2 00000000 rrrgggbb 00000rrr gggbbz00
	lsl.w	#5,d5	;1 00000000 rrrgggbb rrrgggbb 00000000
	lsl.w	#5,d6	;2 00000000 rrrgggbb rrrgggbb z0000000
	lsl.l	#8,d5	;1 rrrgggbb rrrgggbb 00000000 00000000
	lsr.l	#8,d6	;2 00000000 00000000 rrrgggbb rrrgggbb
	move.l	d5,d4
	or.l	d6,d4	;  rrrgggbb rrrgggbb rrrgggbb rrrgggbb

	subq.w	#1,d3
	bne	.xlop


	moveq	#0,d5
	moveq	#0,d6
	moveq	#16,d7

.xlop	move.w	(a1),d5
	move.w	(2,a1),d6
	move.w	(a6,d5.l),d4	;  a-
	move.b	(a6,d6.l),d4	;  ab
	lsl.l	d7,d4		;ab--
	move.w	(4,a1),d5
	move.w	(6,a1),d6
	move.w	(a6,d5.l),d4	;abc-
	move.b	(a6,d6.l),d4	;abcd
	addq.l	#8,a1
	move.l	d4,(a0)+

	subq.w	#1,d3
	bne	.xlop
*/

/* just to be sure */
#if !defined(amigaos)
#  if !defined(__SASC)
#    error AmigaOS required.
#  endif
#endif

#define AW_DEBUG 1               /* disable this to get rid of extra debug messages */

#define AW_SCALEDEBUG 0          /* help debug (remap)scale routines */

#define AW_XPKSUPPORT 1          /* include xpkmaster.library support? */
#define AW_CGXVIDEOSUPPORT 1     /* include cgxvideo.library support? */

/* flags for 0x0 specific stuff */
#define AW_USEREMAPSCALE68K 1
#define AW_USEREMAPSCALE68K16 0  /* not implemented yet */
#define AW_USEC2P68K 1
#define AW_USEC2PHAM668K 0       /* not implemented yet */

/* if ppc compile make sure it doesn't have any 0x0 parts */
#if defined(AW_PPC)
#  undef AW_USEREMAPSCALE68K
#  undef AW_USEREMAPSCALE68K16
#  undef AW_USEC2P68K
#  undef AW_USEC2PHAM668K
#  define AW_USEREMAPSCALE68K 0
#  define AW_USEREMAPSCALE68K16 0
#  define AW_USEC2P68K 0
#  define AW_USEC2PHAM668K 0
#endif

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <strings.h>

#include <exec/exec.h>
#include <dos/dosextens.h>
#include <devices/timer.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <intuition/intuitionbase.h>
#include <intuition/classusr.h>
#include <intuition/pointerclass.h>
#include <libraries/asl.h>
#include <utility/hooks.h>
#include <cybergraphx/cybergraphics.h>
#if AW_CGXVIDEOSUPPORT
#  include <cybergraphx/cgxvideo.h>
#endif

#if defined(AW_PPC)
#  if defined(__SASC)

#    include <powerup/ppclib/interface.h>
#    include <powerup/ppclib/time.h>

#    include <proto/exec.h>
#    include <proto/timer.h>
#    include <proto/utility.h>
#    include <proto/intuition.h>
#    include <proto/graphics.h>
#    include <proto/dos.h>
#    include <proto/icon.h>
#    include <proto/asl.h>
#    include <powerup/gcclib/powerup_protos.h>
#    include <proto/cybergraphics.h>
#    if AW_CGXVIDEOSUPPORT
#      include <proto/cgxvideo.h>
#    endif
#    if AW_XPKSUPPORT
#      undef AW_XPKSUPPORT
#      define AW_XPKSUPPORT 0  /* not supportted for now */
#    endif
#  else

#    include <powerup/ppclib/interface.h>
#    include <powerup/ppclib/time.h>

#    include <powerup/ppcinline/exec.h>
#    include <powerup/ppcinline/timer.h>
#    include <powerup/ppcinline/utility.h>
#    include <powerup/ppcinline/intuition.h>
#    include <powerup/ppcinline/graphics.h>
#    include <powerup/ppcinline/dos.h>
#    include <powerup/ppcinline/icon.h>
#    include <powerup/ppcinline/asl.h>
#    include <powerup/gcclib/powerup_protos.h>
#    include <powerup/ppcinline/cybergraphics.h>
#    if AW_CGXVIDEOSUPPORT
#      include <powerup/ppcinline/cgxvideo.h>
#    endif
#    if AW_XPKSUPPORT
#      define NO_XPK_PROTOS
#      define NO_XPK_PRAGMAS
#      include <libraries/xpk.h>
#      include <powerup/ppcinline/xpkmaster.h>
#    endif
#  endif
#else
#  include <proto/exec.h>
#  include <proto/timer.h>
#  include <proto/utility.h>
#  include <proto/intuition.h>
#  include <proto/graphics.h>
#  include <proto/dos.h>
#  include <proto/icon.h>
#  include <proto/asl.h>
#  include <proto/cybergraphics.h>
#  if AW_CGXVIDEOSUPPORT
#    include <proto/cgxvideo.h>
#  endif
#  if AW_XPKSUPPORT
#    if defined(__SASC)
#      include <libraries/xpk.h>
#    else
#      define NO_XPK_PROTOS
#      define NO_XPK_PRAGMAS
#      include <libraries/xpk.h>
#      include <inline/xpkmaster.h>
#    endif
#  endif
#endif

#if AW_USEC2P68K
#  include "cpu5azure2.h"
#endif

/* gcc 68k only */
#if defined(__GNUC__) && !defined(AW_PPC)
#  include "gccstubs.h"
#endif

#if AW_USEREMAPSCALE68K || AW_USEREMAPSCALE68K16
#  include "ddazure2.h"
#endif

#include "awin.h"
#if defined(__SASC)
#  include <dos.h>
#else
#  ifndef WBenchMsg
extern struct WBStartup *_WBenchMsg;
#  endif
#endif

#define AW_MINWIDTH 64
#define AW_MAXWIDTH 1600
#define AW_MINHEIGHT 48
#define AW_MAXHEIGHT 1280
#define AW_WINRBARW 15
#define AW_PRECISION PRECISION_EXACT
#define AW_SANITY 64

#define AW_WWIDCMPFLAGS (IDCMP_RAWKEY|IDCMP_CLOSEWINDOW| \
  IDCMP_SIZEVERIFY|IDCMP_NEWSIZE|IDCMP_INACTIVEWINDOW| \
  IDCMP_ACTIVEWINDOW)

#define AW_SWIDCMPFLAGS (IDCMP_RAWKEY| \
  IDCMP_INACTIVEWINDOW|IDCMP_ACTIVEWINDOW)

#if defined(AW_PPC) && defined(INVALID_ID)
#  undef INVALID_ID
#  define INVALID_ID (0xffffffffUL)
#endif

#if !defined(AW_DEBUG)
#  define AW_DEBUG 0
#endif
#if !defined(AW_SCALEDEBUG)
#  define AW_SCALEDEBUG 0
#endif
#if !defined(AW_USEREMAPSCALE68K)
#  define AW_USEREMAPSCALE68K 0
#endif
#if !defined(AW_USEREMAPSCALE68K16)
#  define AW_USEREMAPSCALE68K16 0
#endif
#if !defined(AW_USEC2P68K)
#  define AW_USEC2P68K 0
#endif
#if !defined(AW_USEC2PHAM668K)
#  define AW_USEC2PHAM668K 0
#endif

/* --- code begins here --- */

ULONG awsetdebuglevel(struct awdisplay *display,UBYTE level) {
  ULONG oldlevel=0;
  if (display) {
    oldlevel=(ULONG)display->debug;
    display->debug=level;
  }
  AW_DPRINT("awin: AWD_DEBUG on\n");
  if ( (oldlevel>=AWD_DEBUG) &&
       (level<AWD_DEBUG) ) {
    printf("awin: AWD_DEBUG off\n");
  }
  return oldlevel;
}

void awivalidatemodeid(struct awdisplay *display,
  ULONG *modeid,ULONG width,ULONG height,ULONG depth) {

  ULONG handled=0,flags,maxdepth,mid;
  struct GfxBase *GfxBase;
  struct Library *CyberGfxBase;

  /*if (!*modeid) return;*/

  if (display) {
    GfxBase=display->GfxBase;

    if (*modeid==INVALID_ID) {
      AW_VPRINT("awin: INVALID_ID, falling back to default\n");
      *modeid=0;
    } else if (ModeNotAvailable(*modeid)) {
      AW_VPRINT("awin: modeid not available, falling back to default\n");
      *modeid=0;
    } else {
      if ( (display->CyberGfxBase) && (display->cgfx) ) {
        CyberGfxBase=display->CyberGfxBase;
        if (IsCyberModeID(*modeid)) {
          if (depth==16) {
            if (GetCyberIDAttr(CYBRIDATTR_PIXFMT,*modeid)
              !=PIXFMT_RGB16) {
              AW_VPRINT("awin: modeid not PIXFMT_RGB16, falling back to default\n");
              *modeid=0;
            }
          }
          if (depth==8) {
            if (GetCyberIDAttr(CYBRIDATTR_PIXFMT,*modeid)
              !=PIXFMT_LUT8) {
              AW_VPRINT("awin: modeid not PIXFMT_LUT8, falling back to default\n");
              *modeid=0;
            }
          }
          handled=1;
        }
      }
      if (!handled) {

        flags=0;
        awgetpropertyflags(display,*modeid,&flags);

        if ( (display->usehamf) &&
             (depth==16) /*&&
             (flags&DIPF_IS_HAM)*/ ) {

          /* make 2:1 mode for ham6 */
          mid=BestModeID(
            BIDTAG_SourceID,*modeid,
            BIDTAG_DIPFMustHave,
              (flags&(SPECIAL_FLAGS|DIPF_IS_LACE))|
              (display->nodbuffer?0:DIPF_IS_DBUFFER)|
              DIPF_IS_HAM,
            BIDTAG_NominalWidth,width<=640?width*2:1280,
            BIDTAG_NominalHeight,height,
            BIDTAG_Depth,6,
            TAG_DONE);

#if AW_DEBUG
          printf("ham6 modeid: 0x%lx\n",mid);
#endif

          if (mid!=INVALID_ID) *modeid=mid;
        }

        flags=0;
        awgetpropertyflags(display,*modeid,&flags);
        flags&=SPECIAL_FLAGS;

        if (flags) {
          if ( !((display->usehamf) &&
                 (depth==16) &&
                 (flags==DIPF_IS_HAM)) ) {
            AW_VPRINT("awin: modeid has bad attributes, falling back to default\n");
            *modeid=0;
            handled=1;
          }
        }
      }
      if (!handled) {
        maxdepth=0;
        awgetmaxdepth(display,*modeid,&maxdepth);
        if (maxdepth<8) {
          AW_VPRINT("awin: modeid can't handle 8 bits, falling back to default\n");
          *modeid=0;
          handled=1;
        }
      }
      if (!handled) {
        if (BestModeID(
          BIDTAG_SourceID,*modeid,
          BIDTAG_DIPFMustHave,
            (display->nodbuffer?0:DIPF_IS_DBUFFER)|
            ((depth==16)&&display->usehamf?
              DIPF_IS_HAM:0),
          TAG_DONE)==INVALID_ID) {

          AW_VPRINT("awin: modeid doesn't have requested attributes, falling back to default\n");
          *modeid=0;
        }
      }
    }
  }  
}

void awivalidatedim(struct awdisplay *display,
  ULONG *w,ULONG *h) {

  if (display) {
    if (*w<AW_MINWIDTH) *w=AW_MINWIDTH;
    else if (*w>AW_MAXWIDTH) *w=AW_MAXWIDTH;
    if (*h<AW_MINHEIGHT) *h=AW_MINHEIGHT;
    else if (*h>AW_MAXHEIGHT) *h=AW_MAXHEIGHT;
  }
}

void awiwbFreeArgs(struct awwbrdargs *rdargs) {

  struct ExecBase *SysBase=(*((struct ExecBase **)4));
  struct Library *IconBase;
  struct awwbrdargs* wbrdargs;

  if (rdargs) {
    wbrdargs=(struct awwbrdargs*)rdargs;
    IconBase=wbrdargs->IconBase;

    if (wbrdargs->type) free(wbrdargs->type);
    if (wbrdargs->name) free(wbrdargs->name);
    if (wbrdargs->dobj) FreeDiskObject(wbrdargs->dobj);
    if (wbrdargs->IconBase) CloseLibrary(wbrdargs->IconBase);
    free(wbrdargs);
  }
}

char *awiFindToolType(struct awwbrdargs* wbrdargs,
  char **toolTypeArray,char *typename) {

  struct Library *IconBase=wbrdargs->IconBase;
  ULONG tt=0;
  char *s,*d,c,*ret;
  char tmp[128];

  while ((s=toolTypeArray[tt++])) {
    d=tmp; ret=NULL;
    while ( (!ret) && (d<tmp+127) ) {
      c=*s++;
      switch (c) {
        case '=': c=0; ret=s; break;
        case 0: ret=s-1; break;
      }
      *d++=c;
    }
    *d=0; /* in case d=tmp+127 ... */
    if (MatchToolValue(typename,tmp)) {
      return ret;
    }
  }
  return NULL;
}

struct RDArgs *awiwbReadArgs(struct awdisplay *display,
  const char *template,LONG *array,struct RDArgs *nullargs) {

  struct ExecBase *SysBase=(*((struct ExecBase **)4));
  struct Library *DOSBase=display->DOSBase;
  struct Library *IconBase;
  struct awwbrdargs *wbrdargs;
  ULONG len,type;
  char *s,*d,c,fullpath[256];

  wbrdargs=malloc(sizeof(struct awwbrdargs));
  if (wbrdargs) {
    memset(wbrdargs,0,sizeof(struct awwbrdargs));

    wbrdargs->IconBase=OpenLibrary(ICONNAME,39);
    if (wbrdargs->IconBase) {

      IconBase=wbrdargs->IconBase;

      NameFromLock(_WBenchMsg->sm_ArgList[0].wa_Lock,fullpath,255);
      AddPart(fullpath,_WBenchMsg->sm_ArgList[0].wa_Name,255);
      fullpath[255]=0;

      wbrdargs->dobj=GetDiskObject(fullpath);
      if (wbrdargs->dobj) {

        len=strlen(template);
        wbrdargs->tlate=malloc(len+1);
        if (wbrdargs->tlate) {
          s=(char *)template; d=wbrdargs->tlate;
          if (*s) wbrdargs->num=1;
          do {
            c=*s++;
            if (c==',') wbrdargs->num++;
            *d++=c;
          } while (c);

	  if (wbrdargs->num) {

            wbrdargs->type=malloc(sizeof(ULONG)*wbrdargs->num);
            wbrdargs->name=malloc(sizeof(char *)*wbrdargs->num);
            if ( (wbrdargs->name) && (wbrdargs->type) ) {

              s=wbrdargs->tlate;
              d=s; len=0; type=0;
              do {
                c=*s++;
                switch (c) {
                  case '=':
                    *(s-1)='|';
                    break;
                  case '/':
                    *(s-1)=0;
                    c=*s++;
                    switch (c) {
                      case 'S':
                      case 's': type|=1; type&=~6; break;
                      case 'N':
                      case 'n': type|=2; type&=~5; break;
                      case 'T':
                      case 't': type|=4; type&=~3; break;
                      case 'A':
                      case 'a': type|=8; break;
                      case 'K':
                      case 'k': break;
                      default:
                        AW_VPRINT1("awin: /%c not supported in wbargs!\n",c);
                        awiwbFreeArgs(wbrdargs);
                        SetIoErr(ERROR_BAD_TEMPLATE); return NULL;
                        break;
                    }
                    break;
                  case 0:
                  case ',':
                    wbrdargs->name[len]=d; d=s;
                    wbrdargs->type[len]=type; type=0;
                    *(s-1)=0;
                    len++;
                    break;
                }
              } while (c);

              for (len=0; len<wbrdargs->num; len++) {
                s=awiFindToolType(wbrdargs,wbrdargs->dobj->do_ToolTypes,
                  wbrdargs->name[len]);
                if (s) {
                  wbrdargs->type[len]&=~8; /* /A */

                  switch (wbrdargs->type[len]) {
                    case 0: /* string */
                      array[len]=(LONG)s;
                      break;
                    case 1: /* /S */
                      if (!*s) {
                        array[len]=1;
                      } else {
                        awiwbFreeArgs(wbrdargs);
                        SetIoErr(ERROR_TOO_MANY_ARGS); return NULL;
                      }
                      break;
                    case 2: /* /N */
                      if (*s) {
                        ((ULONG *)wbrdargs->name)[len]=strtol(s,&d,10);
                        if (*d) {
                          awiwbFreeArgs(wbrdargs);
                          SetIoErr(ERROR_BAD_NUMBER); return NULL;
                        }
                        array[len]=(LONG)&(((ULONG *)wbrdargs->name)[len]);
                      } else {
                        awiwbFreeArgs(wbrdargs);
                        SetIoErr(ERROR_KEY_NEEDS_ARG); return NULL;
                      }
                      break;
                    case 4: /* /T */
                      if (MatchToolValue("yes|on|1",s)) {
                        array[len]=1;
                      } else if (MatchToolValue("no|off|0",s)) {
                        array[len]=0;
                      } else {
                        awiwbFreeArgs(wbrdargs);
                        SetIoErr(ERROR_KEY_NEEDS_ARG); return NULL;
                      }
                      break;
                  }
                }
              }
              for (len=0; len<wbrdargs->num; len++) {
                if (wbrdargs->type[len]&8) {
                  awiwbFreeArgs(wbrdargs);
                  SetIoErr(ERROR_REQUIRED_ARG_MISSING); return NULL;
                }
              }

              /* success, template, array set */
              return (struct RDArgs *)wbrdargs;
            } else {
              awiwbFreeArgs(wbrdargs);
              SetIoErr(ERROR_NO_FREE_STORE); return NULL;
            }
          } else {

            /* success, no template, array not set */
            return (struct RDArgs *)wbrdargs;
          }
        } else {
          awiwbFreeArgs(wbrdargs);
          SetIoErr(ERROR_NO_FREE_STORE); return NULL;
        }
      } else {
        awiwbFreeArgs(wbrdargs);
        /* SetIoErr() by GetDiskObject */
        return NULL;
      }
    } else {
      awiwbFreeArgs(wbrdargs);
      SetIoErr(ERROR_INVALID_RESIDENT_LIBRARY); return NULL;
    }
  }
  SetIoErr(ERROR_NO_FREE_STORE); return NULL;
}

struct awrdargs *awreadargs(struct awdisplay *display,
  struct awodargs *odargs,const char *template, LONG *array) {

  struct awrdargs *args;

  typedef enum awmyargs {
    AW_AWINDOW=0,
    AW_ASCREEN,
    AW_AMODEID8,
    AW_AMODEID16,
    AW_AREQMODE8,
    AW_AREQMODE16,
    AW_APUBSCREEN,
    AW_AWIDTH,
    AW_AHEIGHT,
    AW_AUINA,
    AW_ADBUFFER,
    AW_AWAITSWAP,
    AW_ANATIVE,
    AW_AHAM,
    AW_ADIRECTDRAW,
    AW_ACGXV,
    AW_AUSEARGB16,
    AW_ANUM
  } awmyargs;

  const char *itemplate=
    "WINDOW/S,"
    "SCREEN/S,"
    "SCREENMODE8=MODEID8=MODEID/K,"
    "SCREENMODE16=MODEID16/K,"
    "REQUESTMODE8=REQMODE8=MODEREQ8/S,"
    "REQUESTMODE16=REQMODE16=MODEREQ16/S,"
    "PUBSCREEN=PUB/K,"
    "WIDTH=WID=W/N/K,"
    "HEIGHT=HEI=H/N/K,"
    "UPDATEINACTIVE=UINA/T,"
    "DOUBLEBUFFER=DBUFFER/T,"
    "WAITSWAP/T,"
    "FORCENATIVE=NATIVE/T,"
    "USEHAM=HAM/T,"
    "DIRECTDRAW/T,"
    "USECGXVIDEO=CGXV/T,"
    "USEARGB16/T,";  /* last ',' is handled */

  const char *tpt;
  char *temp=NULL,ioebuf[80];
  ULONG x,nargs=0,oldflags,olddepth;
  struct Library *DOSBase=display->DOSBase;

  args=malloc(sizeof(struct awrdargs));
  if (args) {
    memset(args,0,sizeof(struct awrdargs));
    args->DOSBase=DOSBase;

    if ( (template) && (*template) && (array) ) {

      for (tpt=template,nargs=1+AW_ANUM; *tpt; tpt++)
        if (*tpt==',') nargs++;

#if AW_DEBUG
/*
      printf(": total %lu arguments\n",nargs);
*/
#endif

      args->array=malloc(sizeof(LONG)*nargs);
      if (args->array) {
        /* clear our argarray... */
        memset(args->array,0,sizeof(LONG)*AW_ANUM);
        /* and copy user argarray after em */
        memcpy(&args->array[AW_ANUM],array,
          sizeof(LONG)*(nargs-AW_ANUM));

        temp=malloc(strlen(itemplate)+strlen(template)+1);

      } else {
        awfreeargs(args); args=NULL;
      }
    } else {
      args->array=malloc(sizeof(LONG)*AW_ANUM);
      if (args->array) {
        /* clear our argarray... */
        memset(args->array,0,sizeof(LONG)*AW_ANUM);

        temp=malloc(strlen(itemplate)+1);

      } else {
        awfreeargs(args); args=NULL;
      }
    }

    if (args) {
      if (temp) {

        /* fill our argarray toggles (/T) from odargs */

        args->array[AW_AUINA]=odargs->flags&AWODAF_DONTUPDATEINA?0:1;
        args->array[AW_ADBUFFER]=odargs->flags&AWODAF_NODBUFFER?0:1;
        args->array[AW_ANATIVE]=odargs->flags&AWODAF_FORCENATIVE?1:0;
        args->array[AW_AHAM]=odargs->flags&AWODAF_USEHAM?1:0;
        args->array[AW_ADIRECTDRAW]=odargs->flags&AWODAF_DIRECTDRAW?1:0;
        args->array[AW_AWAITSWAP]=odargs->flags&AWODAF_WAITSWAP?1:0;
        args->array[AW_ACGXV]=odargs->flags&AWODAF_USECGXVIDEO?1:0;
        args->array[AW_AUSEARGB16]=odargs->flags&AWODAF_USEARGB16?1:0;


        /* create full template */
        strcpy(temp,itemplate);
        if (nargs) {
          strcat(temp,template);
        } else {
          /* handle last ',' */
          temp[strlen(temp)-1]=0;
        }

#if AW_DEBUG
/*
        printf(": full template: \"%s\"\n",temp);
*/
#endif

        if (_WBenchMsg) {
          args->rda=awiwbReadArgs(display,temp,args->array,NULL);
          args->wb=1;
        } else {
          args->rda=ReadArgs(temp,args->array,NULL);
        }

        free(temp);

        if (args->rda) {

          if (nargs) {
            /* copy user argarray back... */
            memcpy(array,&args->array[AW_ANUM],
              sizeof(LONG)*(nargs-AW_ANUM));
          }

          /* handle our arguments */

          /* check mutually exclusive args */

          if ( (args->array[AW_AWINDOW] && args->array[AW_ASCREEN]) ||
               (args->array[AW_APUBSCREEN] && args->array[AW_ASCREEN]) ||
               (args->array[AW_ANATIVE] && args->array[AW_ADIRECTDRAW]) ) {
            if (args->array[AW_ANATIVE]) {
              /* NATIVE overrides DIRECTDRAW */
              args->array[AW_ADIRECTDRAW]=0;
            } else {
              /* WINDOW or PUBSCREEN overrides SCREEN */
              args->array[AW_ASCREEN]=0;
            }
            AW_VPRINT("awin: mutually exclusive arguments removed\n");
          }

          /* set odargs fields... */

          odargs->flags|=args->array[AW_AWINDOW]?AWODAF_INITWINDOW:0;
          odargs->flags&=args->array[AW_ASCREEN]?(~AWODAF_INITWINDOW):(~0);

          if (args->array[AW_AMODEID8]) {
            x=0;
            if (sscanf((char *)args->array[AW_AMODEID8],"0x%lx",&x)==1)
              odargs->modeid8=x;
            else if (sscanf((char *)args->array[AW_AMODEID8],"0X%lx",&x)==1)
              odargs->modeid8=x;
            else if (sscanf((char *)args->array[AW_AMODEID8],"$%lx",&x)==1)
              odargs->modeid8=x;
            else if (sscanf((char *)args->array[AW_AMODEID8],"%lu",&x)==1)
              odargs->modeid8=x;
            else AW_VPRINT("awin: bad modeid number\n");
          }

          if (args->array[AW_AMODEID16]) {
            x=0;
            if (sscanf((char *)args->array[AW_AMODEID16],"0x%lx",&x)==1)
              odargs->modeid16=x;
            else if (sscanf((char *)args->array[AW_AMODEID16],"0X%lx",&x)==1)
              odargs->modeid16=x;
            else if (sscanf((char *)args->array[AW_AMODEID16],"$%lx",&x)==1)
              odargs->modeid16=x;
            else if (sscanf((char *)args->array[AW_AMODEID16],"%lu",&x)==1)
              odargs->modeid16=x;
            else AW_VPRINT("awin: bad modeid number\n");
          }

          if (args->array[AW_APUBSCREEN]) {
            temp=malloc(
              strlen((char *)args->array[AW_APUBSCREEN])+1);
            if (temp) {
              /* will keep this memory until program is quit */
              strcpy(temp,(char *)args->array[AW_APUBSCREEN]);
              odargs->pubscreen=temp;
            }
          }

          if (args->array[AW_AWIDTH])
            odargs->width=*((ULONG *)args->array[AW_AWIDTH]);

          if (args->array[AW_AHEIGHT])
            odargs->height=*((ULONG *)args->array[AW_AHEIGHT]);

          /* update flags */

          odargs->flags=( odargs->flags&~(
            AWODAF_DONTUPDATEINA|
            AWODAF_NODBUFFER|
            AWODAF_FORCENATIVE|
            AWODAF_USEHAM|
            AWODAF_DIRECTDRAW|
            AWODAF_WAITSWAP|
            AWODAF_USECGXVIDEO) ) /* !! */

            | (
            (args->array[AW_AUINA]?       0:AWODAF_DONTUPDATEINA)|
            (args->array[AW_ADBUFFER]?    0:AWODAF_NODBUFFER)|
            (args->array[AW_ANATIVE]?     AWODAF_FORCENATIVE:0)|
            (args->array[AW_AHAM]?        AWODAF_USEHAM:0)|
            (args->array[AW_ADIRECTDRAW]? AWODAF_DIRECTDRAW:0)|
            (args->array[AW_AWAITSWAP]?   AWODAF_WAITSWAP:0)|
            (args->array[AW_ACGXV]?       AWODAF_USECGXVIDEO:0)|
            (args->array[AW_AUSEARGB16]?  AWODAF_USEARGB16:0)); /* !! */

          /* and if AREQMODEn put up an screenmodereq */

          oldflags=awsetflags(display,odargs->flags);
          olddepth=display->srcdepth;
          if (args->array[AW_AREQMODE8]) {
            display->srcdepth=8;
            (void)awscreenmodereq(
              display,
              &odargs->modeid8,8,
              &odargs->width,
              &odargs->height,
              1);
          }
          if (args->array[AW_AREQMODE16]) {
            display->srcdepth=16;
            (void)awscreenmodereq(
              display,
              &odargs->modeid16,16,
              &odargs->width,
              &odargs->height,
              1);
          }
          display->srcdepth=olddepth;
          awsetflags(display,oldflags);

          free(args->array); args->array=NULL;

          /* return ok */
          return args;

        } else {
          if (display->debug>=AWD_VERBOSE) {
            if (Fault(IoErr(),"",ioebuf,80))
              printf("awin%s\n",ioebuf);
          }
          awfreeargs(args);
        }

      } else {
        awfreeargs(args);
      }
    }

  }
  return NULL;
}

void awfreeargs(struct awrdargs *args) {
  struct Library *DOSBase=args->DOSBase;

  if (args) {
    if (args->rda) {
      if (args->wb) awiwbFreeArgs((struct awwbrdargs *)args->rda);
      else FreeArgs(args->rda);
    }
    if (args->array) free(args->array);

    free(args);
  }
}

#if defined(AW_PPC)
#  define AW_ISMRHOOKF 0
#else
#  define AW_ISMRHOOKF 1
#endif

#if AW_ISMRHOOKF
#  ifdef __SASC
ULONG __asm __saveds awismrFilterFunc_hookentry(
  register __a0 struct Hook *hook,
  register __a1 ULONG modeid,
  register __a2 struct ScreenModeRequester *srm);
#  else
#    ifdef __GNUC__
ULONG __saveds awismrFilterFunc_hookentry(
  struct Hook *hook __asm("a0"),
  ULONG modeid __asm("a1"),
  struct ScreenModeRequester *srm __asm("a2"));
#    else
#      error awismrFilterFunc_hookentry prototype
#    endif
#  endif

#  ifdef __SASC
ULONG __asm __saveds awismrFilterFunc_hookentry(
  register __a0 struct Hook *hook,
  register __a1 ULONG modeid,
  register __a2 struct ScreenModeRequester *srm) {
#  else
#    ifdef __GNUC__
ULONG __saveds awismrFilterFunc_hookentry(
  struct Hook *hook __asm("a0"),
  ULONG modeid __asm("a1"),
  struct ScreenModeRequester *srm __asm("a2")) {
#    else
#      error awismrFilterFunc_hookentry function
#    endif
#  endif
  struct awdisplay *display=(struct awdisplay *)(srm->sm_UserData);
  ULONG xa,ya;
  float rat;
  struct Library *CyberGfxBase;

  if (display) {
    if (awgetaspectratio(display,modeid,&xa,&ya)) {
      rat=((float)xa)/ya;

      /* don't allow weird aspect ratios */
      if ( (rat<.666) || (rat>1.50) ) {
        return 0L;
      }
    }
    if ( (display->CyberGfxBase) && (display->cgfx) ) {
      CyberGfxBase=display->CyberGfxBase;
      if (IsCyberModeID(modeid)) {
        switch (GetCyberIDAttr(CYBRIDATTR_PIXFMT,modeid)) {
          case PIXFMT_LUT8:   /* only allow LUT8 and RGB16 */
          case PIXFMT_RGB16:
            break;
          default: return 0L;
        }
      }
    }
  }
  return 1L;
}
#endif /* AW_ISMRHOOKF */

ULONG awscreenmodereq(struct awdisplay *display,ULONG *modeid,
  ULONG depth,ULONG *w,ULONG *h,ULONG dodim) {

  struct ExecBase *SysBase;
  struct IntuitionBase *IntuitionBase;
  struct Library *AslBase;
  struct ScreenModeRequester *smr;
  struct Hook hook;
  /*struct Process *thisproc=FindTask(NULL);*/
  ULONG ret=0,propertyflags=0;

  if (display) {
    SysBase=display->SysBase;
    IntuitionBase=display->IntuitionBase;

    AslBase=OpenLibrary("asl.library",38L);
    if (AslBase) {

#if AW_ISMRHOOKF
      /* Initialize the hook for awismrFilterFunc_hookentry() */
      hook.h_Entry   =(unsigned long (* )())awismrFilterFunc_hookentry;
      hook.h_SubEntry=0;   /* this program does not use this */
      hook.h_Data    =0;   /* this program does not use this */
#endif

      /* should test usehamf && depth==16 ? */
      if (display->doham) {
        propertyflags|=DIPF_IS_HAM;
      }

      smr=(struct ScreenModeRequester *)
        AllocAslRequestTags(ASL_ScreenModeRequest,
          /*ASLSM_Window,(ULONG)thisproc->pr_WindowPtr,*/
          ASLSM_SleepWindow,1,

          *modeid?ASLSM_InitialDisplayID:TAG_IGNORE,*modeid,
          *w?ASLSM_InitialDisplayWidth:TAG_IGNORE,*w,
          *h?ASLSM_InitialDisplayHeight:TAG_IGNORE,*h,

          /*dodim?ASLSM_InitialOverscanType:TAG_IGNORE,OSCAN_TEXT,*/

          ASLSM_PropertyMask,
            DIPF_IS_DUALPF|DIPF_IS_PF2PRI|DIPF_IS_HAM|
            DIPF_IS_EXTRAHALFBRITE|
            propertyflags,

          ASLSM_PropertyFlags,
            propertyflags,

          dodim?ASLSM_DoWidth:TAG_IGNORE,1,
          dodim?ASLSM_DoHeight:TAG_IGNORE,1,
          /*dodim?ASLSM_DoOverscanType:TAG_IGNORE,1,*/

          ASLSM_MinWidth,AW_MINWIDTH,
          ASLSM_MinHeight,AW_MINHEIGHT,
          ASLSM_MaxWidth,AW_MAXWIDTH,
          ASLSM_MaxHeight,AW_MAXHEIGHT,

          ASLSM_InitialDisplayDepth,depth,
          ASLSM_MinDepth,6,
          ASLSM_MaxDepth,depth,

          AW_ISMRHOOKF?ASLSM_FilterFunc:TAG_IGNORE,(ULONG)&hook,
          ASLSM_UserData,(ULONG)display,

          TAG_DONE);

      if (smr) {

        /* Pop up the requester */
        if (AslRequest(smr, NULL)) {

          ret=1;
          *modeid=smr->sm_DisplayID;
          *w=smr->sm_DisplayWidth;
          *h=smr->sm_DisplayHeight;

          awivalidatedim(display,w,h);
          awivalidatemodeid(display,modeid,*w,*h,depth);
#if 0
          printf("display mode id: 0x%lx\n"
            "width: %ld\nheight: %ld\n"
            "depth: %ld\noscan: %ld\n"
            "bitmapwidth: %ld\nbitmapheight: %ld\n",
            smr->sm_DisplayID,
            smr->sm_DisplayWidth,
            smr->sm_DisplayHeight,
            smr->sm_DisplayDepth,
            smr->sm_OverscanType,
            smr->sm_BitMapWidth,
            smr->sm_BitMapHeight);
#endif
        }

        FreeAslRequest(smr);
      } else {
        AW_VPRINT("awin: AllocAslRequestTags failed\n");
      }

      CloseLibrary(AslBase);
    } else {
      /* asl.library not found, beep as error */
      DisplayBeep(display->screen);
    }
  }
  return ret;
}

/* timer API */

struct awtimer *awcreatetimer(struct awdisplay *display) {
#if defined(AW_PPC)
  struct awtimer *timer;
  struct TagItem tags[2];

  if (display) {
    timer=malloc(sizeof(struct awtimer));
    if (timer) {
      memset(timer,0,sizeof(struct awtimer));

      tags[0].ti_Tag=PPCTIMERTAG_CPU; tags[0].ti_Data=1;
      tags[1].ti_Tag=TAG_DONE;
      timer->timerobject=PPCCreateTimerObject(tags);
      if (timer->timerobject) {

        ppcgettimerobject(timer->timerobject,
          PPCTIMERTAG_TICKSPERSEC,timer->tickspersec);
        ppcgettimerobject(timer->timerobject,
          PPCTIMERTAG_CURRENTTICKS,timer->start);

        return timer;
      }
      awdeletetimer(timer);
    }
  }
  return NULL;
}
#else
  struct awtimer *timer;
  struct Library *TimerBase;

  if (display) {
    TimerBase=display->TimerBase;

    timer=malloc(sizeof(struct awtimer));
    if (timer) {
      memset(timer,0,sizeof(struct awtimer));

      timer->timerbase=display->TimerBase;
      timer->tickspersec=ReadEClock(&timer->start);
      return timer;
    }
  }
  return NULL;
}
#endif

void awrestarttimer(struct awtimer *timer) {
#if defined(AW_PPC)
  if (timer) {
    ppcgettimerobject(timer->timerobject,PPCTIMERTAG_CURRENTTICKS,timer->start);
  }
}
#else
  struct Library *TimerBase;

  if (timer) {
    TimerBase=timer->timerbase;
    ReadEClock(&timer->start);
  }
}
#endif

/* return milliseconds elapsed since awcreatetimer/awrestarttimer */
ULONG awreadtimer(struct awtimer *timer) {
#if defined(AW_PPC)

  /* this routine wraps in 4*1024*1024*1024/1000=4294964 seconds */


  ULONG start[2],current[2];

  if (timer) {
    start[0]=timer->start[0]; start[1]=timer->start[1];
    ppcgettimerobject(timer->timerobject,PPCTIMERTAG_CURRENTTICKS,current);

    /* PPCSub64:

    1c 00011f79 - 1b 40eede5c = 1 bf12411d ???
    doesn't handle overflow of lower long correctly!

    printf("%lx %08lx - %lx %08lx = ",
      current[0],current[1],start[0],start[1]);
    start[0]=current[0]-start[0]-(current[1]<start[1]?1:0);
    start[1]=current[1]-start[1];
    printf("%lx %08lx\n",start[0],start[1]);
    */

    sub64p(start,current);

    current[0]=0; current[1]=1000;
    ppcmulu64p(start,current);
    ppcdivu64p(start,timer->tickspersec);
    /* start[0] should be 0 */
    return start[1];
  }
  return 0L;
}
#else
  struct Library *TimerBase;
  struct EClockVal current;

  if (timer) {
    TimerBase=timer->timerbase;
    ReadEClock(&current);
    SubTime((struct timeval *)&current,(struct timeval *)&timer->start);
    return (ULONG)(1000.0*current.ev_lo/((double)timer->tickspersec));
  }
  return 0L;
}
#endif

/* return microseconds elapsed since awcreatetimer/awrestarttimer */
ULONG awreadtimer_us(struct awtimer *timer) {
#if defined(AW_PPC)

  /* this routine wraps in 4*1024*1024*1024/1000000=4292 seconds */

  ULONG start[2],current[2];

  if (timer) {
    start[0]=timer->start[0]; start[1]=timer->start[1];
    ppcgettimerobject(timer->timerobject,PPCTIMERTAG_CURRENTTICKS,current);
    sub64p(start,current);
    current[0]=0; current[1]=1000000;
    ppcmulu64p(start,current);
    ppcdivu64p(start,timer->tickspersec);
    /* start[0] should be 0 */
    return start[1];
  }
  return 0L;
}
#else
  struct Library *TimerBase;
  struct EClockVal current;

  if (timer) {
    TimerBase=timer->timerbase;
    ReadEClock(&current);
    SubTime((struct timeval *)&current,(struct timeval *)&timer->start);
    return 10UL*current.ev_lo/((timer->tickspersec+50000UL)/100000UL);
  }
  return 0L;
}
#endif

void awdeletetimer(struct awtimer *timer) {
  if (timer) {
#if defined(AW_PPC)
    if (timer->timerobject) PPCDeleteTimerObject(timer->timerobject);
#endif

    free(timer);
  }
}


ULONG awtoinnerw(struct awdisplay *display, ULONG width) {
  if (display->window)
    return width - display->window->BorderLeft - display->window->BorderRight;
  else if (display->screen)
    return width - display->screen->WBorLeft - display->screen->WBorRight
      - AW_WINRBARW;
  else return width;
}
ULONG awtowindoww(struct awdisplay *display, ULONG width) {
  if (display->window)
    return width + display->window->BorderLeft + display->window->BorderRight;
  if (display->screen)
    return width + display->screen->WBorLeft + display->screen->WBorRight
      + AW_WINRBARW;
  else return width;
}
ULONG awtoinnerh(struct awdisplay *display, ULONG height) {
  if (display->window)
    return height - display->window->BorderTop - display->window->BorderBottom;
  if (display->screen)
    return height - display->screen->WBorTop - display->screen->WBorBottom
      - display->screen->Font->ta_YSize - 1;
  else return height;
}
ULONG awtowindowh(struct awdisplay *display, ULONG height) {
  if (display->window)
    return height + display->window->BorderTop + display->window->BorderBottom;
  if (display->screen)
    return height + display->screen->WBorTop + display->screen->WBorBottom
      + display->screen->Font->ta_YSize + 1;
  else return height;
}

AWIDCMPHOOK_PTR awsetidcmphook(struct awdisplay *display,
  AWIDCMPHOOK_PTR idcmphook) {

  AWIDCMPHOOK_PTR oldhook;
  oldhook=display->idcmphook;
  display->idcmphook=idcmphook;
  return oldhook;
}

ULONG awsetidcmpflags(struct awdisplay *display,
  ULONG idcmpflags) {

  struct IntuitionBase *IntuitionBase=display->IntuitionBase;
  ULONG oldflags,flagmask;

  if (display->window) {
    if (display->windowmode) flagmask=AW_WWIDCMPFLAGS;
      else flagmask=AW_SWIDCMPFLAGS;

    if ( (display->window->IDCMPFlags)!=
         (flagmask|idcmpflags) ) {
      ModifyIDCMP(display->window,flagmask|idcmpflags);
    }
  }

  oldflags=display->idcmpflags;
  display->idcmpflags=idcmpflags;
  return oldflags;
}

struct BitMap *awallocbm(ULONG x,ULONG y,ULONG d,ULONG f,struct BitMap *b,
  ULONG fblit) {

  struct Library *GfxBase;
  struct Library *DOSBase;
  struct Process *proc;
  struct BitMap *bm=NULL;
  char *oname=NULL,opn[256];
  struct ExecBase *SysBase=(*((struct ExecBase **)4));

#if defined(AW_PPC)
  struct Caos kaaos;

  /* -*- odump by Harry "Piru" Sintonen */
  static const ULONG awsetlnnameinner[]={
    0x20894e75};
  /* -*- */
#endif

  GfxBase=OpenLibrary(GRAPHICSNAME,39);
  if (GfxBase) {

    if (fblit) {
      DOSBase=OpenLibrary("dos.library",39);
      proc=(struct Process *)FindTask(NULL);
      Forbid();
      if ( (DOSBase) && (proc->pr_Task.tc_Node.ln_Type==NT_PROCESS) &&
           (proc->pr_CLI) ) {
        GetProgramName(opn,255);
        SetProgramName("FBLITPLANES");
      } else {
        oname=proc->pr_Task.tc_Node.ln_Name;

#if defined(AW_PPC)
        kaaos.a0=(ULONG)&proc->pr_Task.tc_Node.ln_Name;
        kaaos.a1=(ULONG)"FBLITPLANES";
        kaaos.caos_Un.Function=(APTR)awsetlnnameinner;
        kaaos.M68kCacheMode=IF_CACHEFLUSHALL;
        kaaos.PPCCacheMode=IF_CACHEFLUSHALL;
        PPCCallM68k(&kaaos);
#else
        proc->pr_Task.tc_Node.ln_Name="FBLITPLANES";
#endif

      }

      bm=AllocBitMap(x,y,d,f,b);
      
      if ( (DOSBase) && (proc->pr_Task.tc_Node.ln_Type==NT_PROCESS) &&
           (proc->pr_CLI) ) {
        SetProgramName(opn);
      } else {

#if defined(AW_PPC)
        kaaos.a0=(ULONG)&proc->pr_Task.tc_Node.ln_Name;
        kaaos.a1=(ULONG)oname;
        kaaos.caos_Un.Function=(APTR)awsetlnnameinner;
        kaaos.M68kCacheMode=IF_CACHEFLUSHALL;
        kaaos.PPCCacheMode=IF_CACHEFLUSHALL;
        PPCCallM68k(&kaaos);
#else
        proc->pr_Task.tc_Node.ln_Name=oname;
#endif

      }
      Permit();
      CloseLibrary(DOSBase);
    } else {

      bm=AllocBitMap(x,y,d,f,b);
    }

    CloseLibrary(GfxBase);
  }
  return bm;
}

void awinitc2p(struct awdisplay *display) {

  /* c2p specific init */

#if AW_USEC2P68K

  awinitchunky2planar(
    display->framebuffer,
    display->scrwidth,
    display->height,
    display->dstdepth);
#endif
}

void awdoc2p(struct awdisplay *display) {

  /* c2p specific stuff */

#if AW_USEC2P68K

  awchunky2planar(display->c2pbitmap[display->curbuffer].Planes[0]);

#else

/* based on c2p from QMap
*/

#define m3 0x33333333
#define m5 0x55555555
#define mf1 0x00ff00ff
#define mf2 0x0f0f0f0f

  unsigned long planesize32=display->scrwidth*display->height/32;
  unsigned long *ch=(unsigned long *)display->framebuffer;
  unsigned long *pl=(unsigned long *)display->c2pbitmap[display->curbuffer].Planes[0];
  unsigned long a,b,c,d,e,f,g,h;
  unsigned long a1,b1,c1,d1,e1,f1,g1,h1;
  unsigned long t,i=planesize32;

  while (i--) {
    a=*ch++; b=*ch++; c=*ch++; d=*ch++;
    e=*ch++; f=*ch++; g=*ch++; h=*ch++;

    /*
    a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0 a
    e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0 b
    i7i6i5i4i3i2i1i0 j7j6j5j4j3j2j1j0 k7k6k5k4k3k2k1k0 l7l6l5l4l3l2l1l0 c
    m7m6m5m4m3m2m1m0 n7n6n5n4n3n2n1n0 o7o6o5o4o3o2o1o0 p7p6p5p4p3p2p1p0 d

    q7q6q5q4q3q2q1q0 r7r6r5r4r3r2r1r0 s7s6s5s4s3s2s1s0 t7t6t5t4t3t2t1t0 e
    u7u6u5u4u3u2u1u0 v7v6v5v4v3v2v1v0 w7w6w5w4w3w2w1w0 x7x6x5x4x3x2x1x0 f
    y7y6y5y4y3y2y1y0 z7z6z5z4z3z2z1z0 A7A6A5A4A3A2A1A0 B7B6B5B4B3B2B1B0 g
    C7C6C5C4C3C2C1C0 D7D6D5D4D3D2D1D0 E7E6E5E4E3E2E1E0 F7F6F5F4F3F2F1F0 h

    ->

    a7b7c7d7e7f7g7h7 i7j7k7l7m7n7o7p7 q7r7s7t7u7v7w7x7 y7z7A7B7C7D7E7F7
    a6b6c6d6e6f6g6h6 i6j6k6l6m6n6o6p6 q6r6s6t6u6v6w6x6 y6z6A6B6C6D6E6F6
    a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5 q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
    a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4 q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4

    a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 q3r3s3t3u3v3w3x3 y3z3A3B3C3D3E3F3
    a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2 q2r2s2t2u2v2w2x2 y2z2A2B2C2D2E2F2
    a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 q1r1s1t1u1v1w1x1 y1z1A1B1C1D1E1F1
    a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0 q0r0s0t0u0v0w0x0 y0z0A0B0C0D0E0F0

    */

    a1=(a&~mf1)|((c&~mf1)>>8); /* a7a6a5a4a3a2a1a0 i7i6i5i4i3i2i1i0 c7c6c5c4c3c2c1c0 k7k6k5k4k3k2k1k0 */
    b1=(b&~mf1)|((d&~mf1)>>8); /* e7e6e5e4e3e2e1e0 m7m6m5m4m3m2m1m0 g7g6g5g4g3g2g1g0 o7o6o5o4o3o2o1o0 */
    c1=(e&~mf1)|((g&~mf1)>>8); /* q7q6q5q4q3q2q1q0 y7y6y5y4y3y2y1y0 s7s6s5s4s3s2s1s0 A7A6A5A4A3A2A1A0 */
    d1=(f&~mf1)|((h&~mf1)>>8); /* u7u6u5u4u3u2u1u0 C7C6C5C4C3C2C1C0 w7w6w5w4w3w2w1w0 E7E6E5E4E3E2E1E0 */

    e1=(a&mf1)<<8|(c&mf1); /* b7b6b5b4b3b2b1b0 j7j6j5j4j3j2j1j0 d7d6d5d4d3d2d1d0 l7l6l5l4l3l2l1l0 */
    f1=(b&mf1)<<8|(d&mf1); /* f7f6f5f4f3f2f1f0 n7n6n5n4n3n2n1n0 h7h6h5h4h3h2h1h0 p7p6p5p4p3p2p1p0 */
    g1=(e&mf1)<<8|(g&mf1); /* r7r6r5r4r3r2r1r0 z7z6z5z4z3z2z1z0 t7t6t5t4t3t2t1t0 B7B6B5B4B3B2B1B0 */
    h1=(f&mf1)<<8|(h&mf1); /* v7v6v5v4v3v2v1v0 D7D6D5D4D3D2D1D0 x7x6x5x4x3x2x1x0 F7F6F5F4F3F2F1F0 */
    
    a=(a1&mf2)<<4|(b1&mf2); /* a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0 */
    c=(c1&mf2)<<4|(d1&mf2); /* q3q2q1q0u3u2u1u0 y3y2y1y0C3C2C1C0 s3s2s1s0w3w2w1w0 A3A2A1A0E3E2E1E0 */
    e=(e1&mf2)<<4|(f1&mf2); /* b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0 */
    g=(g1&mf2)<<4|(h1&mf2); /* r3r2r1r0v3v2v1v0 z3z2z1z0D3D2D1D0 t3t2t1t0x3x2x1x0 B3B2B1B0F3F2F1F0 */

    b=(a1&~mf2)|((b1&~mf2)>>4); /* a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4 */
    d=(c1&~mf2)|((d1&~mf2)>>4); /* q7q6q5q4u7u6u5u4 y7y6y5y4C7C6C5C4 s7s6s5s4w7w6w5w4 A7A6A5A4E7E6E5E4 */
    f=(e1&~mf2)|((f1&~mf2)>>4); /* b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4 */
    h=(g1&~mf2)|((h1&~mf2)>>4); /* r7r6r5r4v7v6v5v4 z7z6z5z4D7D6D5D4 t7t6t5t4x7x6x5x4 B7B6B5B4F7F6F5F4 */

    f1=e&m3; /*     b1b0    f1f0     j1j0    n1n0     d1d0    h1h0     l1l0    p1p0 */
    f1=((f1<<2)|(f1<<16))&0xffff0000;
    t=g&m3;  /*     r1r0    v1v0     z1z0    D1D0     t1t0    x1x0     B1B0    F1F0 */
    f1|=((t<<2)|(t<<16))>>16;

    b1=a&m3; /*     a1a0    e1e0     i1i0    m1m0     c1c0    g1g0     k1k0    o1o0 */
    b1=((b1<<2)|(b1<<16))&0xffff0000;
    t=c&m3;  /*     q1q0    u1u0     y1y0    C1C0     s1s0    w1w0     A1A0    E1E0 */
    b1|=((t<<2)|(t<<16))>>16;

    pl[planesize32*0]= (f1&m5)  | ((b1&m5)<<1);
    pl[planesize32*1]= (b1&~m5) | ((f1&~m5)>>1);

    e1=e&~m3;
    e1=(e1|(e1<<14))&0xffff0000;
    t=g&~m3;
    e1|=(t|(t<<14))>>16;
    a1=a&~m3;
    a1=(a1|(a1<<14))&0xffff0000;
    t=c&~m3;
    a1|=(t|(t<<14))>>16;

    pl[planesize32*2]= (e1&m5)  | ((a1&m5)<<1);
    pl[planesize32*3]= (a1&~m5) | ((e1&~m5)>>1);

    h1=f&m3;
    h1=((h1<<2)|(h1<<16))&0xffff0000;
    t=h&m3;
    h1|=((t<<2)|(t<<16))>>16;

    d1=b&m3;
    d1=((d1<<2)|(d1<<16))&0xffff0000;
    t=d&m3;
    d1|=((t<<2)|(t<<16))>>16;

    pl[planesize32*4]= (h1&m5)  | ((d1&m5)<<1);
    pl[planesize32*5]= (d1&~m5) | ((h1&~m5)>>1);

    g1=f&~m3;
    g1=(g1|(g1<<14))&0xffff0000;
    t=h&~m3;
    g1|=(t|(t<<14))>>16;

    c1=b&~m3;
    c1=(c1|(c1<<14))&0xffff0000;
    t=d&~m3;
    c1|=(t|(t<<14))>>16;

    pl[planesize32*6]= (g1&m5)  | ((c1&m5)<<1);
    pl[planesize32*7]= (c1&~m5) | ((g1&~m5)>>1);

    pl++;
  }
#endif
}


/* written by Harry "Piru" Sintonen, and you can see it:)
*/

void awinitc2pham6(struct awdisplay *display) {

  /* c2p specific init */

  ULONG *p4,*p5,cnt,b,max;

  if ( (!display->windowmode) && (display->isham6) ) {

    max=display->dbuffer?2:1;

    for (b=0; b<max; b++) {
      p4=(ULONG *)display->c2pbitmap[b].Planes[4];
      p5=(ULONG *)display->c2pbitmap[b].Planes[5];
      cnt=display->scrwidth*display->height/32;  /* w*h/8/4 */
      while (cnt--) *p4++=0x33333333, *p5++=0x44444444;
    }
  }


#if AW_USEC2PHAM668K

  awinitchunky2planarham6(
    display->framebuffer,
    display->scrwidth,
    display->height,
    display->dstdepth);

#else
#endif
}

void awdoc2pham6(struct awdisplay *display) {

  /* c2p specific stuff */

#if AW_USEC2PHAM668K

  awchunky2planarham6(display->c2pbitmap[display->curbuffer].Planes[0]);

#else

  unsigned long planesize32=display->scrwidth*display->height/32; /* w*h/8/4 */
  unsigned long *ch=(unsigned long *)display->framebuffer;
  unsigned long *pl=(unsigned long *)display->c2pbitmap[display->curbuffer].Planes[0];
  unsigned long a,b,c,d,a1,b1,c1,d1;
  unsigned long i=planesize32;

  while (i--) {
    a=*ch++; b=*ch++; c=*ch++; d=*ch++;

    /* rrrrrggg gggbbbbb RRRRRGGG GGGBBBBB -> ggggrrrr bbbbbbbb GGGGRRRR BBBBBBBB */
    a=(a&0x07800780)<<5 | (a&0xf000f000)>>4 | (a&0x001e001e)<<3 | (a&0x001e001e)>>1;
    b=(b&0x07800780)<<5 | (b&0xf000f000)>>4 | (b&0x001e001e)<<3 | (b&0x001e001e)>>1;
    c=(c&0x07800780)<<5 | (c&0xf000f000)>>4 | (c&0x001e001e)<<3 | (c&0x001e001e)>>1;
    d=(d&0x07800780)<<5 | (d&0xf000f000)>>4 | (d&0x001e001e)<<3 | (d&0x001e001e)>>1;

    /*
    You guys with more experience with c2ps probably know better ways to do
    this. Feel free to improve it. :)

    a3a2a1a0 b3b2b1b0 c3c2c1c0 d3d2d1d0 e3e2e1e0 f3f2f1f0 g3g2g1g0 h3h2h1h0 a
    i3i2i1i0 j3j2j1j0 k3k2k1k0 l3l2l1l0 m3m2m1m0 n3n2n1n0 o3o2o1o0 p3p2p1p0 b
    q3q2q1q0 r3r2r1r0 s3s2s1s0 t3t2t1t0 u3u2u1u0 v3v2v1v0 w3w2w1w0 x3x2x1x0 c
    y3y2y1y0 z3z2z1z0 A3A2A1A0 B3B2B1B0 C3C2C1C0 D3D2D1D0 E3E2E1E0 F3F2F1F0 d

    1        9        17       25       2        10       18       26
    3        11       19       27       4        12       20       28
    5        13       21       29       6        14       22       30
    7        15       23       31       8        16       24       32


                      -----------                         -----------
    1        9        17       25       2        10       18       26
    -----------                         -----------
    3        11       19       27       4        12       20       28
                      ===========                         ===========
    5        13       21       29       6        14       22       30
    ===========                         ===========
    7        15       23       31       8        16       24       32

    ->

    1        9        3        11       2        10       4        12
    17       25       19       27       18       26       20       28
    5        13       7        15       6        14       8        16
    21       29       23       31       22       30       24       32


             --1               --2      --1               --2
    1        9        3        11       2        10       4        12

    17       25       19       27       18       26       20       28

    5        13       7        15       6        14       8        16

    21       29       23       31       22       30       24       32

    ->

    1        2        3        4        9        10       11       12
    17       18       19       20       25       26       27       28
    5        6        7        8        13       14       15       16
    21       22       23       24       29       30       31       32


                                        -----------------------------
    1        2        3        4        9        10       11       12
                                        .............................
    17       18       19       20       25       26       27       28
    -----------------------------
    5        6        7        8        13       14       15       16
    .............................
    21       22       23       24       29       30       31       32

    ->

    1        2        3        4        5        6        7        8 
    17       18       19       20       21       22       23       24
    9        10       11       12       13       14       15       16
    25       26       27       28       29       30       31       32

    (a&0x11111111)<<3|(c&0x11111111)<<2|(b&0x11111111)<<1|(d&0x11111111);
    (a&0x22222222)<<2|(c&0x22222222)<<1|(b&0x22222222)   |(d&0x22222222)>>1;
    (a&0x44444444)<<1|(c&0x44444444)   |(b&0x44444444)>>1|(d&0x44444444)>>2;
    (a&0x88888888)   |(c&0x88888888)>>1|(b&0x88888888)>>2|(d&0x88888888)>>3;

    ->

    a3b3c3d3 e3f3g3h3 i3j3k3l3 m3n3o3p3  q3r3s3t3 u3v3w3x3 y3z3A3B3 C3D3E3F3
    a2b2c2d2 e2f2g2h2 i2j2k2l2 m2n2o2p2  q2r2s2t2 u2v2w2x2 y2z2A2B2 C2D2E2F2
    a1b1c1d1 e1f1g1h1 i1j1k1l1 m1n1o1p1  q1r1s1t1 u1v1w1x1 y1z1A1B1 C1D1E1F1
    a0b0c0d0 e0f0g0h0 i0j0k0l0 m0n0o0p0  q0r0s0t0 u0v0w0x0 y0z0A0B0 C0D0E0F0

    */

    a1 = (a & 0xff00ff00) | ((b & 0xff00ff00)>>8);
    c1 = (c & 0xff00ff00) | ((d & 0xff00ff00)>>8);
    b1 = (b & 0x00ff00ff) | ((a & 0x00ff00ff)<<8);
    d1 = (d & 0x00ff00ff) | ((c & 0x00ff00ff)<<8);

    a = (a1 & 0xf0f00f0f) | ((a1 & 0x0f0f0000)>>12) | ((a1 & 0xf0f0)<<12);
    b = (b1 & 0xf0f00f0f) | ((b1 & 0x0f0f0000)>>12) | ((b1 & 0xf0f0)<<12);
    c = (c1 & 0xf0f00f0f) | ((c1 & 0x0f0f0000)>>12) | ((c1 & 0xf0f0)<<12);
    d = (d1 & 0xf0f00f0f) | ((d1 & 0x0f0f0000)>>12) | ((d1 & 0xf0f0)<<12);

    a1 = (a & 0xffff0000) | (c >> 16);
    b1 = (b & 0xffff0000) | (d >> 16);
    c1 = (a << 16) | (c & 0xffff);
    d1 = (b << 16) | (d & 0xffff);

    pl[planesize32*0]=
      (a1&0x11111111)<<3 | (c1&0x11111111)<<2 |
      (b1&0x11111111)<<1 | (d1&0x11111111);
    pl[planesize32*1]=
      (a1&0x22222222)<<2 | (c1&0x22222222)<<1 |
      (b1&0x22222222)    | (d1&0x22222222)>>1;
    pl[planesize32*2]=
      (a1&0x44444444)<<1 | (c1&0x44444444) |
      (b1&0x44444444)>>1 | (d1&0x44444444)>>2;
    pl[planesize32*3]=
      (a1&0x88888888)    | (c1&0x88888888)>>1 |
      (b1&0x88888888)>>2 | (d1&0x88888888)>>3;

    pl++;
  }
#endif
}

void awfreechunky(struct awchunky *chunky) {
  if (chunky) {
    if (chunky->memory) free(chunky->memory);
    free(chunky);
  }
}

struct awchunky *awinitchunkystruct(struct awdisplay *display,
  ULONG width,ULONG height,ULONG depth) {
  struct awchunky *chunky;

  chunky=malloc(sizeof(struct awchunky));
  if (chunky) {
    memset(chunky,0,sizeof(struct awchunky));

    chunky->width_align=awalign(width,32);
    chunky->width=width;
    chunky->height=height;
    chunky->depth=depth;
  }
  return chunky;
}

struct awchunky *awallocchunky(struct awdisplay *display,ULONG width,
  ULONG height,ULONG depth) {

  ULONG size;
  struct awchunky *chunky;

  if ( (!width) || (!height) || (!depth) ) return NULL;
  if ( (depth!=8) && (depth!=16) ) return NULL;

  chunky=awinitchunkystruct(display,width,height,depth);
  if (chunky) {

    size=(depth>>3)*
      chunky->width_align*chunky->height+63+AW_SANITY;

    chunky->memory=malloc(size);
     if (chunky->memory) {
      memset(chunky->memory,0,size);
      chunky->framebuffer=(UBYTE *)awalign(chunky->memory,32);
    } else {
      awfreechunky(chunky); chunky=NULL;
    }
  }
  return chunky;
}

void awfreepens(struct awdisplay *display) {

#if defined(AW_PPC)
  struct Caos kaaos;

  /* -*- odump by Harry "Piru" Sintonen */
  static const ULONG awfreepensinner[]={
    0x48e73f3e,0x26482849,0x2e3c0000,0x01004a14,
    0x670a7000,0x204a1013,0x4eaefc4c,0x421c421b,
    0x538766ea,0x4cdf7cfc,0x4e754e71};
  /* -*- */

  if (display) {

    kaaos.a0=(ULONG)display->remap;
    kaaos.a1=(ULONG)display->penal;
    kaaos.a2=(ULONG)display->screen->ViewPort.ColorMap;
    kaaos.a6=(ULONG)display->GfxBase;
    kaaos.caos_Un.Function=(APTR)awfreepensinner;
    kaaos.M68kCacheMode=IF_CACHEFLUSHALL;
    kaaos.PPCCacheMode=IF_CACHEFLUSHALL;
    PPCCallM68k(&kaaos);
  }

#else

  struct GfxBase *GfxBase;
  LONG x;

  if (display) {

    GfxBase=display->GfxBase;
    for (x=0; x<256; x++) {
      if (display->penal[x]) {
        ReleasePen(display->screen->ViewPort.ColorMap,
          (ULONG)display->remap[x]);
        display->penal[x]=0;
      }
      display->remap[x]=0;
    }
  }
#endif
}

void awicleardisplay(struct awdisplay *display) {
  struct GfxBase *GfxBase;

  if ( (display) && (display->window) ) {
    GfxBase=display->GfxBase;
    EraseRect(display->window->RPort,display->window->BorderLeft,
      display->window->BorderTop,display->window->BorderLeft+
      awtoinnerw(display,display->window->Width)-1,display->window->
      BorderTop+awtoinnerh(display,display->window->Height)-1);
  }
}

void awclosedisplay(struct awdisplay *display) {
  struct ExecBase *SysBase;
  struct GfxBase *GfxBase;
  struct IntuitionBase *IntuitionBase;
  struct Library *DOSBase;
#if AW_CGXVIDEOSUPPORT
  struct Library *CGXVideoBase;
#endif

  if (display) {
    SysBase=display->SysBase;
    GfxBase=display->GfxBase;
    IntuitionBase=display->IntuitionBase;
    DOSBase=display->DOSBase;

    awicleardisplay(display);
    if (display->native) WaitBlit();

    if (display->windowmode) {

#if AW_CGXVIDEOSUPPORT
      if (display->vlhandle) {
        CGXVideoBase=display->CGXVideoBase;
        DetachVLayer(display->vlhandle);
        DeleteVLayerHandle(display->vlhandle);
        display->vlhandle=NULL;
        display->vlwidth=0; display->vlheight=0;
      }
#endif

      awfreepens(display);

      if (display->c2pplanes[0]) {
        FreeVec(display->c2pplanes[0]); display->c2pplanes[0]=NULL;
      }
      if (display->memory) {
        free(display->memory); display->memory=NULL;
      }
      if (display->tempbm) {
        FreeBitMap(display->tempbm); display->tempbm=NULL;
      }

      if (display->window) {
        display->left=display->window->LeftEdge;
        display->top=display->window->TopEdge;
        display->prevwidth=awtoinnerw(display,display->window->Width);
        display->prevheight=awtoinnerh(display,display->window->Height);
        CloseWindow(display->window); display->window=NULL;
      }

      if (display->screen) {
        display->prevscreen=awscreensum(display->screen);
        UnlockPubScreen(NULL,display->screen); display->screen=NULL;
      }

    } else {

      if (display->memory) {
        free(display->memory); display->memory=NULL;
      }
      if (display->tempbm) {
        FreeBitMap(display->tempbm); display->tempbm=NULL;
      }

      if (display->window) {
        CloseWindow(display->window); display->window=NULL;
      }

      if (display->pointerobject) {
        DisposeObject(display->pointerobject);
        display->pointerobject=NULL;
      }

      if ( (display->sbuf[0]) &&
           (display->sbuf[1]) &&
           (display->sbports[AW_WRITEPORT]) &&
           (display->sbports[AW_DISPPORT]) ) {

        if ( (!display->safetochange) ||
             (!display->safetowrite) ) {

          /* wait some time for (possible) pending messages to arrive.
             This hacky thing is here to "fix" some CGFX stuff.
          */
          WaitTOF(); WaitTOF();

          /* cleanup pending messages */
          while (GetMsg(display->sbports[AW_WRITEPORT]));

          if (display->waitswap) {
            /* cleanup pending messages */
            while (GetMsg(display->sbports[AW_DISPPORT]));
          }
        }
      }

      if (display->screen) {
        if (display->native) WaitBlit();

        if (display->sbuf[1]) {
          FreeScreenBuffer(display->screen,display->sbuf[1]);
          display->sbuf[1]=NULL;
        }

        if (display->sbuf[0]) {
          FreeScreenBuffer(display->screen,display->sbuf[0]);
          display->sbuf[0]=NULL;
        }
      }

      if (display->sbports[AW_WRITEPORT]) {
        DeleteMsgPort(display->sbports[AW_WRITEPORT]);
        display->sbports[AW_WRITEPORT]=NULL;
      }

      if (display->sbports[AW_DISPPORT]) {
        if (display->waitswap) {
          DeleteMsgPort(display->sbports[AW_DISPPORT]);
        }
        display->sbports[AW_DISPPORT]=NULL;
      }

      if (display->screen) {
        while (!CloseScreen(display->screen)) {
          DisplayBeep(display->screen);
          Delay(25);
        }
        display->screen=NULL;
      }

      if (display->c2pplanes[1]) {
        FreeVec(display->c2pplanes[1]); display->c2pplanes[1]=NULL;
      }

      if (display->c2pplanes[0]) {
        FreeVec(display->c2pplanes[0]); display->c2pplanes[0]=NULL;
      }

    }

    if (display->fblitptrbm) {
      FreeBitMap(display->fblitptrbm); display->fblitptrbm=NULL;
    }
  }
}

void awdeletedisplay(struct awdisplay *display) {
  struct ExecBase *SysBase;

  if (display) {
    SysBase=display->SysBase;

    awclosedisplay(display);

    if (display->DOSBase) CloseLibrary(display->DOSBase);
    if (display->remap332) free(display->remap332);
    if (display->UtilityBase) CloseLibrary(display->UtilityBase);
#if AW_CGXVIDEOSUPPORT
    if (display->CGXVideoBase) CloseLibrary(display->CGXVideoBase);
#endif
    if (display->CyberGfxBase) CloseLibrary(display->CyberGfxBase);
    /* display->TimerBase do nothing */
    if (display->IntuitionBase) CloseLibrary((struct Library *)
      display->IntuitionBase);
    if (display->GfxBase) CloseLibrary((struct Library *)
      display->GfxBase);

    free(display);
  }
}

/*
inline UBYTE awrgb16to332(UWORD x) {
  return ((x>>8)&(7<<5)) | ((x>>6)&(7<<2)) | ((x>>3)&3);
}
*/

void awremap(struct awdisplay *display) {
  struct GfxBase *GfxBase;
  ULONG table[256*3+2],x,max,r,g,b,f,*pal;

#if defined(AW_PPC)
  struct Caos kaaos;

  /* -*- odump by Harry "Piru" Sintonen */
  static const ULONG awremapinner[]={
    0x48e73f3e,0x2e002848,0x2a4942a7,0x42a74879,
    0x84000001,0x2f014879,0x84000000,0x4eaeff1c,
    0x7c004a12,0x670a7000,0x204b1015,0x4eaefc4c,
    0x421a528d,0x530666ea,0x45eaff00,0x4bedff00,
    0x78ff204b,0x4cdc000e,0x224f4eae,0xfcb82200,
    0x5281660a,0x222cfff8,0x4eaefc10,0x600414fc,
    0x00011ac0,0x538766da,0x4fef0014,0x4cdf7cfc,
    0x4e754e71,0x00000000,0x00000000,0x00000000,
    0};
  /* -*- */
#else
  LONG p;
#endif

  pal=(display->srcdepth==16)?display->pal332:display->palette;
  max=(display->srcdepth==16)?256:display->palentries;

  if ( (display->window) && (max) ) {

    GfxBase=display->GfxBase;

    if ( (!display->windowmode) && (display->isham6) ) {
      max=16;
      table[0]=max<<16;
      for (x=0; x<max; x++) {
        g=x<<4|x;
        table[x*3+1]=0;
        f=(g&0xf)<<4|(g&0xf);
        table[x*3+2]=(g<<24)|(f<<16)|(f<<8)|f;
        table[x*3+3]=0;
      }
      table[max*3+1]=0;

    } else {

      table[0]=max<<16;
      for (x=0; x<max; x++) {

        r=(pal[x]>>16)&0xff;
        g=(pal[x]>>8)&0xff;
        b=pal[x]&0xff;

        f=(r&0xf)<<4|(r&0xf);
        table[x*3+1]=(r<<24)|(f<<16)|(f<<8)|f;

        f=(g&0xf)<<4|(g&0xf);
        table[x*3+2]=(g<<24)|(f<<16)|(f<<8)|f;

        f=(b&0xf)<<4|(b&0xf);
        table[x*3+3]=(b<<24)|(f<<16)|(f<<8)|f;
      }
      table[max*3+1]=0;
    }

    if (display->windowmode) {

      if ( !(display->truecolor && display->wlutpa) ) {

        awicleardisplay(display);

        /* (re)build remap table */

#if defined(AW_PPC)
        kaaos.a0=(ULONG)&table[1];
        kaaos.a1=(ULONG)display->remap;
        kaaos.a2=(ULONG)display->penal;
        kaaos.a3=(ULONG)display->screen->ViewPort.ColorMap;
        kaaos.a6=(ULONG)display->GfxBase;
        kaaos.d0=(ULONG)max;
        kaaos.d1=(ULONG)AW_PRECISION;
        kaaos.caos_Un.Function=(APTR)awremapinner;
        kaaos.M68kCacheMode=IF_CACHEFLUSHALL;
        kaaos.PPCCacheMode=IF_CACHEFLUSHALL;
        PPCCallM68k(&kaaos);
#else
        if (display->native) WaitBlit();

        for (x=0; x<256; x++) {
          if (display->penal[x]) {
            ReleasePen(display->screen->ViewPort.ColorMap,
              (ULONG)display->remap[x]);
            display->penal[x]=0;
          }
          display->remap[x]=0;
        }

        for (x=0; x<max; x++) {

          p=ObtainBestPen(
            display->screen->ViewPort.ColorMap,
            table[x*3+1],
            table[x*3+2],
            table[x*3+3],
            OBP_Precision,AW_PRECISION,
            OBP_FailIfBad,0,
            TAG_DONE);

          if (p!=-1) {
            display->penal[x]=1;
          } else {
            p=FindColor(
              display->screen->ViewPort.ColorMap,
              table[x*3+1],
              table[x*3+2],
              table[x*3+3],
              -1L);
          }

          display->remap[x]=(UBYTE)p;
        }
#endif

        for (x=0; x<65536; x+=4) {
          display->remap332[x+0]=display->remap[awrgb16to332(x+0)];
          display->remap332[x+1]=display->remap[awrgb16to332(x+1)];
          display->remap332[x+2]=display->remap[awrgb16to332(x+2)];
          display->remap332[x+3]=display->remap[awrgb16to332(x+3)];
        }

      }
    
    } else {

      LoadRGB32(&display->screen->ViewPort,table);

    }
  }
}

ULONG awsetpalette(struct awdisplay *display,ULONG *palette,ULONG n) {

  if ( (n<1) || (n>256) ) return 0;
  display->palentries=n;
  memcpy(display->palette,palette,sizeof(ULONG)*n);

  if (!display->stoprender) {
    /* really do it */
    awremap(display);
  }

  return 1;
}

void *awiallocbitmap(struct awdisplay *display,struct BitMap *bm,
  ULONG width,ULONG height,ULONG depth,ULONG memtype) {

  ULONG size,p,w;
  UBYTE *mem;
  struct ExecBase *SysBase=display->SysBase;
  struct GfxBase *GfxBase=display->GfxBase;

  if ( (depth>=1) && (depth<=8) ) {

    w=awalign(width,32);

    size=(w>>4)*2*height;

    mem=AllocVec(size*depth+63+AW_SANITY,memtype);
    if (mem) {
      InitBitMap(bm,depth,w,height);
      for (p=0; p<depth; p++) {
        bm->Planes[p]=(void *)(awalign(mem,32)+p*size);
      }
      return mem;
    }
  }
  return NULL;
}

ULONG awreopen(struct awdisplay *display) {
  ULONG mul,size,ret=1;
  struct ExecBase *SysBase;
  struct GfxBase *GfxBase;

  if (display) {
    SysBase=display->SysBase;
    GfxBase=display->GfxBase;
    if (display->native) WaitBlit();

    if (display->windowmode) {

      if (display->c2pplanes[0]) FreeVec(display->c2pplanes[0]);
      if (display->memory) free(display->memory);

      display->width=awtoinnerw(display,display->window->Width);
      display->height=awtoinnerh(display,display->window->Height);
      display->width_align=awalign(display->width,display->widthaligner);
      display->pixperrow=display->width_align;
      display->scrwidth=display->width_align;
    }
    if (display->tempbm) FreeBitMap(display->tempbm);

    display->tempbm=awallocbm(
      display->width_align,1,display->dstdepth,
      0L,display->window->RPort->BitMap,0);

    if (display->tempbm) {
      memcpy(&display->temprp,display->windowmode?
        display->window->RPort:&display->screen->RastPort,
        sizeof(struct RastPort));
      display->temprp.Layer=NULL;
      display->temprp.BitMap=display->tempbm;

      /* set up buffering renderrp */
      if (!display->windowmode) {
        memcpy(&display->renderrp,&display->screen->RastPort,
          sizeof(struct RastPort));
      }

      if (display->useargb16 && display->cgfx &&
          display->truecolor) {
        /* ARGB = 4 bytes per pixel */
        mul=4;
      } else {
        /* chunky depth >>3 bytes per pixel
            8 = 1
           16 = 2 */
        mul=display->srcdepth>>3;
      }

      size=mul*
        display->width_align*display->height+AW_SANITY+63;

      display->memory=malloc(size);
      if (display->memory) {
        memset(display->memory,0,size);
        display->framebuffer=(UBYTE *)awalign(display->memory,32);

        if (display->native) {

          if (display->windowmode) {

            display->c2pplanes[0]=awiallocbitmap(
              display,&display->c2pbitmap[0],
              display->width_align,display->height,8,
              display->fblit?MEMF_PUBLIC:MEMF_CHIP);

            if (display->c2pplanes[0]) {

              display->curbuffer=0;  /* for window c2p */
              awinitc2p(display);

            } else {
              AW_VPRINT("awin: could not allocate c2pbitmap[0] chip memory\n");
              awclosedisplay(display); return 0L;
            }

          } else {

            if (display->isham6) {
              awinitc2pham6(display);
            } else {
              awinitc2p(display);
            }

          }

        }

        /*printf("reopen succeeded\n");
        */

#if AW_DEBUG
        printf("width: %ld (%ld/%ld) height: %ld c2pbitmap planes: 0x%08lx\n"
               "native: %ld fblit: %ld slowwpa: %ld cgfx: %ld srcdepth: %ld dstdepth: %ld\n"
               "truecolor: %ld wlutpa: %ld waitswap: %ld directdraw: %ld\n",
        display->width,display->width_align,display->widthaligner,display->height,
        (ULONG)display->c2pbitmap[0].Planes[0],display->native,
        display->fblit,display->slowwpa8,display->cgfx,
        display->srcdepth,display->dstdepth,display->truecolor,
        display->wlutpa,display->waitswap,display->directdraw);
#endif

      } else {
        AW_VPRINT1("awin: could not allocate %ld bytes for framebuffer\n",size);
        awclosedisplay(display); ret=0;
      }
    } else {
      AW_VPRINT("awin: could not alloc temp bitmap\n");
      awclosedisplay(display); ret=0;
    }
  }
  return ret;
}

ULONG awibest16cmodeid(struct awdisplay *display,
  ULONG width,ULONG height) {

  struct Library *CyberGfxBase;
  struct CyberModeNode *cmodelist,*cmoden;
  ULONG serror=0x7fffffff,error,targetarea,
    camodeid=INVALID_ID,sw=0x7fffffff,sh=0x7fffffff,
    smodeid=INVALID_ID;

  struct TagItem acml_tags[3];

  if ( (display) && (display->CyberGfxBase) ) {
    CyberGfxBase=display->CyberGfxBase;

    targetarea=width*height;

    acml_tags[0].ti_Tag=CYBRMREQ_MinDepth; acml_tags[0].ti_Data=16;
    acml_tags[1].ti_Tag=CYBRMREQ_MaxDepth; acml_tags[1].ti_Data=16;
    acml_tags[2].ti_Tag=TAG_DONE;
    cmodelist=(struct CyberModeNode *)AllocCModeListTagList(acml_tags);

    if (cmodelist) {
      cmoden=cmodelist;
      while ( (cmoden=(struct CyberModeNode *)cmoden->Node.ln_Succ)
        ->Node.ln_Succ ) {
        if ( (GetCyberIDAttr(CYBRIDATTR_PIXFMT,cmoden->DisplayID)
              ==PIXFMT_RGB16) && (cmoden->Depth==16) ) {

          if ( (cmoden->Width<width) &&
               (cmoden->Height<height) ) {
            if ( (cmoden->Width<=sw) &&
                 (cmoden->Height<=sh) ) {

              smodeid=cmoden->DisplayID;
              sw=cmoden->Width;
              sh=cmoden->Height;
            }
          }
          error=cmoden->Width*cmoden->Height;
          error=(error>targetarea)?(error-targetarea):(targetarea-error);
          if (error<serror) {
            camodeid=cmoden->DisplayID;
            serror=error;
          }
        }
      }
      FreeCModeList((struct List *)cmodelist);

      if (smodeid!=INVALID_ID) return smodeid;
      if (camodeid!=INVALID_ID) return camodeid;
    }
  }
  return INVALID_ID;
}


struct awdisplay *awcreatedisplay(void) {
  struct awdisplay *display;
  struct MsgPort *port;
  struct timerequest *treq;
  struct ExecBase *SysBase=(*((struct ExecBase **)4));
  struct Library *CyberGfxBase;
  struct Library *cgxsystemBase;
  ULONG wpa8func,rombase,x;
  struct SignalSemaphore *setpatchsema;
  struct TagItem bcmid_tags[3];

  if (SysBase->LibNode.lib_Version<39) {
    printf("awin: requires at least AmigaOS 3.0\n");
    return NULL;
  }

  Forbid();
  setpatchsema=FindSemaphore("« SetPatch »");
  Permit();

  if (!setpatchsema) {
    printf("awin: SetPatch not run\n");
    return NULL;
  }

  display=malloc(sizeof(struct awdisplay));
  if (display) {
    memset(display,0,sizeof(struct awdisplay));
    display->SysBase=SysBase;

    display->GfxBase=(struct GfxBase *)
      OpenLibrary(GRAPHICSNAME,39L);
    if (display->GfxBase) {
  
      display->IntuitionBase=(struct IntuitionBase *)
        OpenLibrary("intuition.library",39L);
      if (display->IntuitionBase) {
    
        display->v40 = display->GfxBase->LibNode.lib_Version>=40 ? 1 : 0;
        /* debug
        display->v40=0;
        */

        /* if not akiko hardware... */
        if ( !((display->v40) && (display->GfxBase->ChunkyToPlanarPtr)) ) {

          rombase=((ULONG)SysBase->LibNode.lib_Node.ln_Name)&0xffff0000;
          wpa8func=*((ULONG *)((ULONG)display->GfxBase-0x312+2));

          if ( ((wpa8func>rombase) &&
               (wpa8func<(rombase+0x80000))) ||
               (wpa8func<=SysBase->MaxLocMem) ) {
            /* WPA8 is in ROM or chip memory */
            display->slowwpa8=1;
          } else {
            /* WPA8 is in fastram, check for SetPatch WPA8 */
            if ( (*((ULONG *)(wpa8func+0))==0x48E73F38) &&
                 (*((ULONG *)(wpa8func+4))==0x944048C2) &&
                 (*((ULONG *)(wpa8func+8))==0x52822802) ) {
              /* SetPatch WPA */
              display->slowwpa8=1;
            }
          }
        }

        port=CreateMsgPort();
        if (port) {
          treq=(struct timerequest *)CreateIORequest(port,
            sizeof(struct timerequest));
          if (treq) {
            if (!OpenDevice(TIMERNAME,UNIT_MICROHZ,
               (struct IORequest *)treq,0L)) {
              display->TimerBase=(struct Library *)treq->tr_node.io_Device;
              CloseDevice((struct IORequest *)treq);
            }
            DeleteIORequest((struct IORequest *)treq);
          }
          DeleteMsgPort(port);
        }
        if (display->TimerBase) {

          display->CyberGfxBase=OpenLibrary(CYBERGFXNAME,41);

          if (display->CyberGfxBase) {
            CyberGfxBase=display->CyberGfxBase;
            cgxsystemBase=OpenLibrary("cgxsystem.library",41);
            if (cgxsystemBase) {
              if ( (cgxsystemBase->lib_Version!=41) ||
                   (cgxsystemBase->lib_Revision>=20) ) {

                display->wlutpa=1;

              } else {

                /* too old cgxsystem.library for WLUTPA */
                printf("awin: too old cgxsystem.library for WriteLUTPixelArray(), falling\n"
                  "back to WritePixelArray(). Please update to minimum\n"
                  "ftp://ftp.phase5.de/pub/phase5/cgx3/cgxv41_r70a.lha and\n"
                  "ftp://ftp.phase5.de/pub/phase5/cgx3/cgxsyslib4121.lha\n");
              }
              CloseLibrary(cgxsystemBase);
            }

            bcmid_tags[0].ti_Tag  = CYBRBIDTG_NominalWidth;
            bcmid_tags[0].ti_Data = 320;
            bcmid_tags[1].ti_Tag  = CYBRBIDTG_NominalHeight;
            bcmid_tags[1].ti_Data = 240;
            bcmid_tags[2].ti_Tag  = TAG_DONE;
            display->gfxcard=BestCModeIDTagList(bcmid_tags);
            if (display->gfxcard!=INVALID_ID) display->gfxcard=1;
            else display->gfxcard=0;

            display->cgfx16bit=
              (awibest16cmodeid(display,320,240)!=INVALID_ID)?1:0;

#if AW_DEBUG
            printf("CGFX3+/P96 gfxcard %savailable\n"
                   "CGFX3+/P96 PIXFMT_RGB16 %savailable\n",
              display->gfxcard?"":"not ",
              display->cgfx16bit?"":"not ");
#endif

#if AW_CGXVIDEOSUPPORT
            display->CGXVideoBase=OpenLibrary("cgxvideo.library",41);
#if AW_DEBUG
            printf("CGXVideoBase: %lx\n",(ULONG)display->CGXVideoBase);
#endif
#endif

          }

          display->UtilityBase=OpenLibrary("utility.library",39);
          if (display->UtilityBase) {

            display->srcdepth=8;

            /* build rgb332 palette */
            for (x=0; x<256; x++) {
              display->pal332[x]=(x&0xe0)<<16|(x&0x1c)<<11|(x&3)<<6;
            }

            display->remap332=malloc(65536);
            if (display->remap332) {

              display->DOSBase=OpenLibrary("dos.library",39);
              if (display->DOSBase) {

                /* ... */

              } else {
                printf("awin: could not open dos.library v39\n");
                awdeletedisplay(display); display=NULL;
              }
            } else {
              printf("awin: could not allocate 64k memory\n");
              awdeletedisplay(display); display=NULL;
            }
          } else {
            printf("awin: could not open utility.library v39\n");
            awdeletedisplay(display); display=NULL;
          }

        } else {
          printf("awin: could not open timer.device\n");
          awdeletedisplay(display); display=NULL;
        }
      } else {
        printf("awin: could not open intuition.library v39\n");
        awdeletedisplay(display); display=NULL;
      }
    } else {
      printf("awin: could not open graphics.library v39\n");
      awdeletedisplay(display); display=NULL;
    }
  }

  return display;
}

ULONG awgetvisiblerect(struct awdisplay *display,
  struct Rectangle *rect) {

  struct GfxBase *GfxBase;
  struct IntuitionBase *IntuitionBase;
  ULONG modeid;

  if ( (display) && (display->screen) ) {
    GfxBase=display->GfxBase;
    IntuitionBase=display->IntuitionBase;

    modeid=GetVPModeID(&display->screen->ViewPort);
    if (modeid!=INVALID_ID) {
      if (QueryOverscan(modeid,rect,OSCAN_TEXT)) {
        rect->MinX+=display->screen->LeftEdge;
        rect->MinY+=display->screen->TopEdge;
        rect->MaxX-=display->screen->LeftEdge;
        rect->MaxY-=display->screen->TopEdge;
/*
        printf("visiblerect: %ld,%ld - %ld,%ld\n",
          rect->MinX,rect->MinY,rect->MaxX,rect->MaxY);
*/
        return 1L;
      }
    }
  }
  return 0L;
}

ULONG awgetaspectratio(struct awdisplay *display,ULONG modeid,
  ULONG *xa,ULONG *ya) {

  struct GfxBase *GfxBase;
  struct DisplayInfo dinfo;

  if (modeid!=INVALID_ID) {
    GfxBase=display->GfxBase;

    if (GetDisplayInfoData(NULL,(UBYTE *)&dinfo,
      sizeof(struct DisplayInfo),DTAG_DISP,modeid)>0) {

      *xa=dinfo.Resolution.x; *ya=dinfo.Resolution.y;
      return 1L;
    }
  }
  return 0L;
}

ULONG awgetpropertyflags(struct awdisplay *display,ULONG modeid,
  ULONG *flags) {

  struct GfxBase *GfxBase;
  struct DisplayInfo dinfo;

  if (modeid!=INVALID_ID) {
    GfxBase=display->GfxBase;

    if (GetDisplayInfoData(NULL,(UBYTE *)&dinfo,
      sizeof(struct DisplayInfo),DTAG_DISP,modeid)>0) {

      *flags=dinfo.PropertyFlags;
      return 1L;
    }
  }
  return 0L;
}

ULONG awgetmaxdepth(struct awdisplay *display,ULONG modeid,
  ULONG *maxdepth) {

  struct GfxBase *GfxBase;
  struct DimensionInfo dinfo;

  if (modeid!=INVALID_ID) {
    GfxBase=display->GfxBase;

    if (GetDisplayInfoData(NULL,(UBYTE *)&dinfo,
      sizeof(struct DimensionInfo),DTAG_DIMS,modeid)>0) {

      *maxdepth=dinfo.MaxDepth;
      return 1L;
    }
  }
  return 0L;
}

void awgetwindimension(struct awdisplay *display,
  ULONG *width,ULONG *height) {

  struct GfxBase *GfxBase;
  ULONG xa,ya;
  float rat;

  if ( (display) && (display->screen) ) {
    GfxBase=display->GfxBase;

    *width=display->origw;
    *height=display->origh;

    /* make window (close to) square */

    xa=22; ya=22;
    awgetaspectratio(display,GetVPModeID(&display->screen->ViewPort),
      &xa,&ya);
    rat=((double)xa)/ya;

    if (rat<.166) {
      /* 8:1 */
      *width *= 2; *height /= 4;
    } else if (rat<.333) {
      /* 4:1 */
      *width *= 2; *height /= 2;
    } else if (rat<.666) {
      /* 2:1 */
      *height /= 2;
    } else if (rat>6.00) {
      /* 1:8 */
      *width /= 4; *height *= 2;
    } else if (rat>3.00) {
      /* 1:4 */
      *width /= 2; *height *= 2;
    } else if (rat>1.50) {
      /* 1:2 */
      *width /= 2;
    }

  }
}

void awigetscreentype(struct awdisplay *display) {

  struct GfxBase *GfxBase;
  struct Library *CyberGfxBase;

  if ( (display) && (display->screen) ) {

    GfxBase=display->GfxBase;

    display->dstdepth=GetBitMapAttr(display->screen->RastPort.BitMap,
      BMA_DEPTH);
    display->native=GetBitMapAttr(display->screen->RastPort.BitMap,
      BMA_FLAGS)&BMF_STANDARD?1:0;

    if ( (!display->forcenative) && (display->CyberGfxBase) ) {
      CyberGfxBase=display->CyberGfxBase;

      if (GetCyberMapAttr(display->screen->RastPort.BitMap,
        CYBRMATTR_ISCYBERGFX)) {

        display->native=0; display->cgfx=1;
        display->dstdepth=GetCyberMapAttr(display->screen->RastPort.BitMap,
          CYBRMATTR_DEPTH);
        if (display->dstdepth==0xffffffff) display->dstdepth=0;

        display->islinearmem=
          GetCyberMapAttr(
            display->screen->RastPort.BitMap,
            CYBRMATTR_ISLINEARMEM);

        display->isrgb16=
          (GetCyberMapAttr(
            display->screen->RastPort.BitMap,
            CYBRMATTR_PIXFMT)==PIXFMT_RGB16)?1:0;
      } else {
        /* is native mode */
        display->native=1; display->cgfx=0;
      }
    }

    if (display->dstdepth) {
      if (display->cgfx) {
        display->truecolor=display->dstdepth>8?1:0;
      }
    } else {
      display->cgfx=0; display->native=0;
    }
  }
}

ULONG awiopendisplay(struct awdisplay *display) {

  struct ExecBase *SysBase;
  struct GfxBase *GfxBase;
  struct IntuitionBase *IntuitionBase;
  struct Library *CyberGfxBase;
  ULONG ret=1,modeid=INVALID_ID,newmodeid,errorcode,
    cgfxmodeid=0,flags,*modeidpt;
  ULONG natwidthaligner,natscrwidth;
  struct Rectangle rect;
  struct TagItem bcmid_tags[4];

  if (display) {
    SysBase=display->SysBase;
    GfxBase=display->GfxBase;
    IntuitionBase=display->IntuitionBase;

    display->fblitptrbm=awallocbm(16,1,2,BMF_CLEAR,NULL,1);
    if (display->fblitptrbm) {
      if (display->gfxcard && display->forcenative ) {
        /* if we have a gfxcard and forcenative is set
           do NOT think cgfx is fblit */
        display->fblit=0;
      } else {
        display->fblit=TypeOfMem(display->fblitptrbm->Planes[0])&MEMF_CHIP?0:1;
      }

      if ( (display->fblit) || (display->slowwpa8) ) {
        /* c2p needs min 32 */
        display->widthaligner=32;
      } else {
        /* WPA8 needs exactly 16 */
        /* WCP can take about anything */
        display->widthaligner=display->v40?32:16;
      }

      if (display->windowmode) {

#if defined(__GNUC__) && defined(AW_PPC)
        display->screen=LockPubScreen(
          *display->pubscreen?
          (ULONG)display->pubscreen:NULL);
#else
        display->screen=LockPubScreen(
          *display->pubscreen?
          display->pubscreen:NULL);
#endif

        /* fallback to default pubscreen if named not found */
        if ( (*display->pubscreen) && (!display->screen) ) {
          display->screen=LockPubScreen(NULL);
        }

        if (display->screen) {

          /* if we have the same screen then open on old pos */
          if (awscreensum(display->screen)==display->prevscreen) {

            display->width=display->prevwidth;
            display->height=display->prevheight;
            display->width_align=awalign(display->width,display->widthaligner);
            display->pixperrow=display->width_align;
            display->scrwidth=display->width_align;

            /* display->left and display->top are ok already */

          } else {

            awgetwindimension(display,&display->width,&display->height);
            display->width_align=awalign(display->width,display->widthaligner);
            display->pixperrow=display->width_align;
            display->scrwidth=display->width_align;

            if (display->abspos) {

              /* absolute position given */
              display->left=display->xdisp;
              display->top=display->ydisp;

            } else {

              /* center the window */
              rect.MinX=0; rect.MinY=0;
              rect.MaxX=display->screen->Width;
              rect.MaxY=display->screen->Height;
              awgetvisiblerect(display,&rect);

              display->left=(rect.MaxX-rect.MinX-
                awtowindoww(display,display->width))/2+display->xdisp;
              display->top=(rect.MaxY-rect.MinY-
                awtowindowh(display,display->height))/2+display->ydisp;
            }
          }

          display->window=OpenWindowTags(0L,
            WA_CustomScreen,(ULONG)display->screen,
            WA_Left,display->left,
            WA_Top,display->top,
            WA_InnerWidth,display->width,
            WA_InnerHeight,display->height,
            WA_AutoAdjust,1,
            WA_MinWidth,awtowindoww(display,AW_MINWIDTH),
            WA_MaxWidth,awtowindoww(display,AW_MAXWIDTH),
            WA_MinHeight,awtowindowh(display,AW_MINHEIGHT),
            WA_MaxHeight,awtowindowh(display,AW_MAXHEIGHT),
            *display->title?WA_Title:TAG_IGNORE,(ULONG)display->title,
            WA_Flags,WFLG_ACTIVATE|WFLG_CLOSEGADGET|WFLG_DRAGBAR|
              WFLG_DEPTHGADGET|WFLG_SIZEGADGET|WFLG_RMBTRAP|
              WFLG_NOCAREREFRESH|WFLG_SIZEBRIGHT,
            WA_IDCMP,AW_WWIDCMPFLAGS|display->idcmpflags,
            TAG_DONE);

          if (!display->window) {
            AW_VPRINT("awin: could not open window\n");
            awclosedisplay(display); ret=0;
          }

        } else {
          AW_VPRINT("awin: could not lock pubscreen\n");
          awclosedisplay(display); ret=0;
        }

      } else {

        /* screen mode */

        if ( (display->srcdepth==16) && (display->usehamf) ) {
          display->doham=1;
        } else {
          display->doham=0;
        }

        display->width=display->origw;
        display->height=display->origh;

        /* NATIVE: width is multiple of 64 (AGA) or 32 (OCS/ECS) */
        natwidthaligner=16<<
          display->GfxBase->bwshifts[display->GfxBase->MemType];
        if (natwidthaligner<32) natwidthaligner=32;
        natscrwidth=awalign(display->width,natwidthaligner);
        if (display->doham) natscrwidth*=2;

        modeidpt=(display->srcdepth==16)?&display->modeid16:&display->modeid8;

/*        if ( (!display->modeid16) &&*/
        if ( (!*modeidpt) &&
             (!display->forcenative) &&
             (display->CyberGfxBase) ) {
          CyberGfxBase=display->CyberGfxBase;

          bcmid_tags[0].ti_Tag  = CYBRBIDTG_NominalWidth;
          bcmid_tags[0].ti_Data = awalign(display->width,32);
          bcmid_tags[1].ti_Tag  = CYBRBIDTG_NominalHeight;
          bcmid_tags[1].ti_Data = display->height;
          bcmid_tags[2].ti_Tag  = CYBRBIDTG_Depth;
          bcmid_tags[2].ti_Data = display->cgfx16bitf?display->srcdepth:8;
          bcmid_tags[3].ti_Tag  = TAG_DONE;
          modeid=BestCModeIDTagList(bcmid_tags);
        }

        if ( (*modeidpt) && (*modeidpt!=INVALID_ID) ) {
          modeid=*modeidpt;
        } else {

          if (modeid==INVALID_ID) {

            /* get native default monitor for widht/height
               (asking HAM will filter out foreign monitors) */
            modeid=BestModeID(
              BIDTAG_DIPFMustHave,
                (display->nodbuffer?0:DIPF_IS_DBUFFER)|
                DIPF_IS_HAM,
              BIDTAG_NominalWidth,natscrwidth,
              BIDTAG_NominalHeight,display->height,
              BIDTAG_Depth,1,
              TAG_DONE);
            if (modeid==INVALID_ID) modeid=0;
            else modeid&=MONITOR_ID_MASK,

            modeid=BestModeID(
              BIDTAG_MonitorID,modeid,
              BIDTAG_DIPFMustHave,
                (display->nodbuffer?0:DIPF_IS_DBUFFER)|
                (display->doham?DIPF_IS_HAM:0),
              BIDTAG_NominalWidth,natscrwidth,
              BIDTAG_NominalHeight,display->height,
              BIDTAG_Depth,display->doham?6:8,
              TAG_DONE);
          }
        }

        if (modeid!=INVALID_ID) {

          if ( (!display->forcenative) && (display->CyberGfxBase) ) {
            CyberGfxBase=display->CyberGfxBase;
            if (IsCyberModeID(modeid)) {
              cgfxmodeid=1;

              if ( (display->srcdepth==16) &&
                   (display->cgfx16bitf) ) {

                if (GetCyberIDAttr(
                     CYBRIDATTR_PIXFMT,modeid)!=PIXFMT_RGB16) {

                  newmodeid=awibest16cmodeid(
                    display,
                    awalign(display->width,32),
                    display->height);
                  if (newmodeid!=INVALID_ID) {
                    modeid=newmodeid;
                  }
                }
              }
            }
          }

#if AW_DEBUG
          printf("cgfxmodeid: %ld modeid: 0x%lx (%lu)\n",
            cgfxmodeid,modeid,modeid);
#endif

          if (cgfxmodeid) {

            /* CGFX: width is multiple of 32 */
            display->widthaligner=32;

            display->width_align=awalign(display->width,display->widthaligner);
            display->scrwidth=display->width_align;

            display->screen=OpenScreenTags(NULL,
              SA_Width,display->scrwidth,
              SA_Height,display->height,
              SA_Depth,display->cgfx16bitf?display->srcdepth:8,
              *display->title?SA_Title:TAG_IGNORE,(ULONG)display->title,
              SA_ShowTitle,0,
              SA_Quiet,1,
              SA_Type,CUSTOMSCREEN,
              SA_DisplayID,modeid,
              SA_ErrorCode,(ULONG)&errorcode,
              TAG_DONE);
          } else {

            flags=0L;
            awgetpropertyflags(display,modeid,&flags);

            display->widthaligner=natwidthaligner;
            display->width_align=awalign(display->width,display->widthaligner);

            if ( (flags&DIPF_IS_HAM) &&
                 display->doham) {
              display->scrwidth=display->width_align*2;
            } else {
              display->scrwidth=display->width_align;
            }

            display->c2pplanes[0]=
              awiallocbitmap(
                display,
                &display->c2pbitmap[0],
                display->scrwidth,
                display->height,
                (flags&DIPF_IS_HAM)&&display->doham?6:8,
                MEMF_CHIP|MEMF_CLEAR);

            if (!display->c2pplanes[0]) {
              AW_VPRINT("awin: could not allocate bitmap[0] chip memory\n");
              awclosedisplay(display); return 0L;
            }

            display->screen=OpenScreenTags(NULL,
              SA_Width,display->scrwidth,
              SA_Height,display->height,
              SA_Depth,(flags&DIPF_IS_HAM)&&display->doham?6:8,
              SA_BitMap,(ULONG)&display->c2pbitmap[0],
              *display->title?SA_Title:TAG_IGNORE,(ULONG)display->title,
              SA_ShowTitle,0,
              SA_Quiet,1,
              SA_Type,CUSTOMSCREEN,
              SA_DisplayID,modeid,
              SA_AutoScroll,1,
              SA_ErrorCode,(ULONG)&errorcode,
              display->IntuitionBase->LibNode.lib_Version>=40 ?
                SA_MinimizeISG:TAG_IGNORE,1,
              TAG_DONE);
          }

          if (display->screen) {

            display->pixperrow=display->width_align;

            flags=0L;
            awgetpropertyflags(display,
              GetVPModeID(&display->screen->ViewPort),&flags);

            if (!display->nodbuffer) {
              display->dbuffer=flags&DIPF_IS_DBUFFER?1:0;
            }

#if AW_DEBUG
            printf("dbuffer: %ld\n",
              display->dbuffer);
#endif

            if (display->dbuffer) {

              if (!cgfxmodeid) {

                display->c2pplanes[1]=
                  awiallocbitmap(
                    display,
                    &display->c2pbitmap[1],
                    display->scrwidth,
                    display->height,
                    (flags&DIPF_IS_HAM)&&display->doham?6:8,
                    MEMF_CHIP);

                if (!display->c2pplanes[1]) {
                  AW_VPRINT("awin: could not allocate bitmap[1] chip memory\n");
                  awclosedisplay(display); return 0L;
                }

              }

              display->sbports[AW_DISPPORT]=CreateMsgPort();
              if (display->waitswap) {
                display->sbports[AW_WRITEPORT]=CreateMsgPort();
              } else {
                display->sbports[AW_WRITEPORT]=
                  display->sbports[AW_DISPPORT];
              }

              if ( (display->sbports[AW_DISPPORT]) &&
                   (display->sbports[AW_WRITEPORT]) ) {

#if defined(__GNUC__) && defined(AW_PPC)
                display->sbuf[0]=AllocScreenBuffer(
                  display->screen,cgfxmodeid?NULL:(ULONG)&display->c2pbitmap[0],
                  cgfxmodeid?SB_SCREEN_BITMAP:0L);
                display->sbuf[1]=AllocScreenBuffer(
                  display->screen,cgfxmodeid?NULL:(ULONG)&display->c2pbitmap[1],
                  0L);
#else
                display->sbuf[0]=AllocScreenBuffer(
                  display->screen,cgfxmodeid?NULL:&display->c2pbitmap[0],
                  cgfxmodeid?SB_SCREEN_BITMAP:0L);
                display->sbuf[1]=AllocScreenBuffer(
                  display->screen,cgfxmodeid?NULL:&display->c2pbitmap[1],
                  0L);
#endif

                if ( (display->sbuf[0]) && (display->sbuf[1]) ) {

                  display->sbuf[0]->sb_DBufInfo->
                    dbi_SafeMessage.mn_ReplyPort=display->sbports[AW_WRITEPORT];
                  display->sbuf[1]->sb_DBufInfo->
                    dbi_SafeMessage.mn_ReplyPort=display->sbports[AW_WRITEPORT];

                  if (display->waitswap) {
                    display->sbuf[0]->sb_DBufInfo->
                      dbi_DispMessage.mn_ReplyPort=display->sbports[AW_DISPPORT];
                    display->sbuf[1]->sb_DBufInfo->
                      dbi_DispMessage.mn_ReplyPort=display->sbports[AW_DISPPORT];
                  }

                  display->safetochange=1;
                  display->safetowrite=1;
                  display->curbuffer=1;

                } else {
                  AW_VPRINT("awin: could not allocate dbuffer screenbuffers\n");
                  awclosedisplay(display); ret=0;
                }

              } else {
                AW_VPRINT("awin: could not allocate dbuffer msgports\n");
                awclosedisplay(display); ret=0;
              }
            } else {

              display->curbuffer=0;  /* for c2p */

            }

            if (ret) {
              display->pointerobject=NewObject(
                NULL,POINTERCLASS,
                POINTERA_BitMap,(ULONG)display->fblitptrbm,
                POINTERA_WordWidth,1,
                TAG_DONE);

              display->window=OpenWindowTags(0L,
                WA_CustomScreen,(ULONG)display->screen,
                display->pointerobject?WA_Pointer:TAG_IGNORE,
                  (ULONG)display->pointerobject,
                WA_Left,0,
                WA_Top,0,
                WA_Width,display->screen->Width,
                WA_Height,display->screen->Height,
                WA_Flags,WFLG_ACTIVATE|WFLG_RMBTRAP|WFLG_NOCAREREFRESH|
                  WFLG_BACKDROP|WFLG_BORDERLESS,
                WA_IDCMP,AW_SWIDCMPFLAGS|display->idcmpflags,
                TAG_DONE);

              if (!display->window) {
                AW_VPRINT("awin: could not open window\n");
                awclosedisplay(display); ret=0;
              }
            }
          } else {
            if (display->debug>=AWD_VERBOSE) {
              printf("awin: OpenScreenTagList failed: ");
              switch (errorcode) {
                case OSERR_NOMONITOR:
                  puts("monitor for display mode not available");
                  break;
                case OSERR_NOCHIPS:
                  puts("you need newer custom chips for display mode");
                  break;
                case OSERR_NOMEM:
                  puts("couldn't get normal memory");
                  break;
                case OSERR_NOCHIPMEM:
                  puts("couldn't get chip memory");
                  break;
                case OSERR_PUBNOTUNIQUE:
                  puts("public screen name already used");
                  break;
                case OSERR_UNKNOWNMODE:
                  puts("don't recognize display mode requested");
                  break;
                case OSERR_TOODEEP:
                  puts("screen too deep to be displayed on this hw");
                  break;
                case OSERR_ATTACHFAIL:
                  puts("illegal attachment of screens was requested");
                  break;
              }
            }
            awclosedisplay(display); ret=0;
          }

        } else {
          if (display->debug>=AWD_VERBOSE) {
            printf("awin: could not find modeid for %ldx%ldx%ld.\n",
              display->scrwidth,display->height,
              display->cgfx16bitf?display->srcdepth:8);
          }
          awclosedisplay(display); ret=0;
        }
      }

      if (ret) {
        /* (screen &) window open etc */

        awigetscreentype(display);

        if (display->dstdepth) {

          /* debug
          display->native=0; display->cgfx=1;
          display->truecolor=1;
          */

          if ( (!display->native) && (!display->cgfx) ) {
            if (!display->windowmode) {
              AW_VPRINT("awin: neither native nor gfxcard screen\n"
                "falling back to native mode\n");
            }
            display->native=1;
          }

          if (!display->windowmode) {

            display->isham6=0;
            if (display->doham) {
              if ( (flags&DIPF_IS_HAM) && (display->dstdepth==6) ) {
                display->isham6=1;
              } else {
                AW_VPRINT("awin: bad ham6 screen\n");
#if AW_DEBUG
                printf("flags&DIPF_IS_HAM: %ld display->dstdepth: %ld\n",
                  flags&DIPF_IS_HAM,display->dstdepth);
#endif
                awclosedisplay(display); return 0;
              }
            }

            if ( (display->screen->Width!=display->scrwidth) ||
                 (display->screen->Height!=display->height) ) {
              AW_VPRINT("awin: screen dimensions don't match!\n");
              awclosedisplay(display); return 0L;
            }
            if ( (!display->isham6) &&
                 (display->srcdepth==8) &&
                 (display->dstdepth!=display->srcdepth) ) {
              AW_VPRINT("awin: screen depth doesn't match!\n");
              awclosedisplay(display); return 0L;
            }
          }

#if AW_DEBUG
/*
          printf("isham6: %lu\n",display->isham6);
*/
#endif

          awremap(display);

          if (awreopen(display)) {
            if ( (display->windowmode) &&
                 (display->screen) &&
                 (awscreensum(display->screen)!=
                 display->prevscreen) ) {

              ScreenToFront(display->screen);
            }

            /* ... */

          } else ret=0;

        } else {
          AW_VPRINT("awin: fucked up screen depth\n");
          awclosedisplay(display); ret=0;
        }
      }

    } else {
      AW_VPRINT("awin: could not allocate fblit bitmap\n");
      awclosedisplay(display); ret=0;
    }
  }
  return ret;
}

ULONG awsetdisplaysize(struct awdisplay *display,
  ULONG width,ULONG height) {

  ULONG ret=0;

  if (display) {
    if (display->screen) {
      awclosedisplay(display);

      display->origw=width;
      display->origh=height;
      display->prevscreen=0;

      ret=awiopendisplay(display);
      if (!ret) {
        /* try the other mode (fallback) */
        display->windowmode ^= 1;
        ret=awiopendisplay(display);
        if (!ret) display->windowmode ^= 1;
      }
    } else {
      display->origw=width;
      display->origh=height;
      display->prevscreen=0;
    }
  }
  return ret;
}

ULONG awsetflags(struct awdisplay *display,ULONG flags) {
  ULONG ret=0;
  if (display) {

    /* build oldflags */
    if (display->windowmode) ret|=AWODAF_INITWINDOW;
    if (display->dontupdateinactive) ret|=AWODAF_DONTUPDATEINA;
    if (display->nodbuffer) ret|=AWODAF_NODBUFFER;
    if (display->forcenative) ret|=AWODAF_FORCENATIVE;
    if (display->directdraw) ret|=AWODAF_DIRECTDRAW;
    if (display->useham) ret|=AWODAF_USEHAM;
    if (display->waitswap) ret|=AWODAF_WAITSWAP;
    if (display->usecgxvideo) ret|=AWODAF_USECGXVIDEO;
    if (display->useargb16) ret|=AWODAF_USEARGB16;
    if (display->abspos) ret|=AWODAF_ABSPOS;


    /* force flags sensible */
    if (flags&AWODAF_FORCENATIVE) flags&=~AWODAF_DIRECTDRAW;

    /* set flags in struct display */
    display->windowmode=
      flags&AWODAF_INITWINDOW?1:0;

    display->dontupdateinactive=
      flags&AWODAF_DONTUPDATEINA?1:0;

    display->nodbuffer=
      flags&AWODAF_NODBUFFER?1:0;

    display->forcenative=
      flags&AWODAF_FORCENATIVE?1:0;

    display->directdraw=
      flags&AWODAF_DIRECTDRAW?1:0;

    display->useham=
      flags&AWODAF_USEHAM?1:0;

    display->waitswap=
      flags&AWODAF_WAITSWAP?1:0;

    display->usecgxvideo=
      flags&AWODAF_USECGXVIDEO?1:0;

    display->useargb16=
      flags&AWODAF_USEARGB16?1:0;

    display->abspos=
      flags&AWODAF_ABSPOS?1:0;

    if (display->gfxcard && (!display->forcenative)) {
      display->usehamf=0;
    } else {
      display->usehamf=display->useham;
    }

    if (display->forcenative) {
      display->cgfx16bitf=0;
    } else {
      display->cgfx16bitf=display->cgfx16bit;
    }

  }
  return ret;
}

ULONG awopendisplay(struct awdisplay *display,
  struct awodargs *odargs) {

  ULONG ret=1;

  if ( (display) && (!display->window) ) {

    (void)awsetflags(display,odargs->flags);

    awivalidatedim(display,&odargs->width,&odargs->height);
    awivalidatemodeid(display,&odargs->modeid8,
      odargs->width,odargs->height,8);
    awivalidatemodeid(display,&odargs->modeid16,
      odargs->width,odargs->height,16);

    if (odargs->modeid8) {
      display->modeid8=odargs->modeid8;
    }
    if (odargs->modeid16) {
      display->modeid16=odargs->modeid16;
    }

    if (odargs->title) {
      strncpy(display->title,odargs->title,79);
      display->title[79]=0;
    } else *display->title=0;

    if (odargs->pubscreen) {
      strncpy(display->pubscreen,odargs->pubscreen,MAXPUBSCREENNAME);
      display->pubscreen[MAXPUBSCREENNAME]=0;
    } else *display->pubscreen=0;

    display->origw=odargs->width;
    display->origh=odargs->height;

    if (display->windowmode) {
      display->xdisp=odargs->x;
      display->ydisp=odargs->y;
    }

#if 0
    ret=awiopendisplay(display);
    if (!ret) {
      /* try the other mode (fallback) */
      display->windowmode ^= 1;
      ret=awiopendisplay(display);
      if (!ret) display->windowmode ^= 1;
    }
#endif

  }
  return ret;
}

ULONG awhandleinput(struct awdisplay *display) {
  ULONG ret=1,action,origw,origh;
  LONG quit=0,doreopen=0,space=0,w=0,s=0,tab=0,p=0,m=0;
  LONG xdif,ydif;
  struct ExecBase *SysBase=display->SysBase;
  struct GfxBase *GfxBase=display->GfxBase;
  struct IntuitionBase *IntuitionBase=display->IntuitionBase;
  struct IntuiMessage *msg,mcopy;

  /* indicate quit if there is no window */
  if ( (!display) || (!display->window) ) return 0;

  while ( (msg=(struct IntuiMessage *)
    GetMsg(display->window->UserPort)) ) {
    if (msg->Class==IDCMP_SIZEVERIFY) {
      display->stoprender=1;
      /* make sure buffers are flushed */
      while (display->rendering);
      if (display->native) WaitBlit();
    }
    memcpy(&mcopy,msg,sizeof(struct IntuiMessage));
    ReplyMsg((struct Message *)msg);

    if ( (display->idcmphook) &&
         (mcopy.Class & display->idcmpflags) ) {

      action=display->idcmphook(&mcopy);

      if (action!=AWIDHA_NOP) {
        AW_DPRINT("awin: display->idcmphook action not implemented yet\n");
      }
    }

    switch (mcopy.Class) {
      case IDCMP_CLOSEWINDOW:
        quit=1;
        break;
      case IDCMP_NEWSIZE:
        doreopen=1;
        break;
      case IDCMP_RAWKEY:
        switch (mcopy.Code) {
          case 0x45:
          case 0x10:
            /* Q / ESC */
            quit=1;
            break;
          case 0x40:
            /* space */
            space=1;
            break;
          case 0x11:
            /* W */
            w=1;
            break;
          case 0x21:
            /* S */
            s=1;
            break;
          case 0x42:
            /* TAB */
            tab=1;
            break;
          case 0x19:
            /* P */
            p=1;
            break;
          case 0x37:
            /* M */
            m=1;
            break;
        }
        /*
        printf("rawkey: %ld ",mcopy.Code);
        printf("qualifier: 0x%lx\n",mcopy.Qualifier);
        */
        break;

      case IDCMP_VANILLAKEY:
        switch (mcopy.Code) {
          case 'q':
          case 'Q':
          case  27: quit=1; break;
          case ' ': space=1; break;
          case 'w':
          case 'W': w=1; break;
          case 's':
          case 'S': s=1; break;
          case   9: tab=1; break;
          case 'p':
          case 'P': p=1; break;
          case 'm':
          case 'M': m=1; break;
        }
        break;

      case IDCMP_INACTIVEWINDOW:
        if (display->dontupdateinactive) {
          display->stoprender=1;
        }
        break;
      case IDCMP_ACTIVEWINDOW:
        if (display->dontupdateinactive) {
          display->stoprender=0;
        }
        break;

    }
  }

  if (quit) {

    /* quit */

    ret=0;

  } else if (doreopen) {

    /* handle window resize */

    if (awreopen(display)) {
      display->stoprender=0;
    } else ret=0;

  } else if (space) {

    if (display->windowmode) {

      awgetwindimension(display,&origw,&origh);
      xdif=display->width-origw; ydif=display->height-origh;

      if ( xdif || ydif ) {

        display->stoprender=1;   /* kindof hack, relies on IDCMP_NEWSIZE */

        if (display->abspos) {

          /* readjust window size */

          ChangeWindowBox(display->window,
            display->window->LeftEdge,display->window->TopEdge,
            awtowindoww(display,origw),awtowindowh(display,origh));
        } else {

          /* readjust window size/position */

          ChangeWindowBox(display->window,
            display->window->LeftEdge+xdif/2,display->window->TopEdge+ydif/2,
            awtowindoww(display,origw),awtowindowh(display,origh));
        }
      }
    }

  } else if (w) {

   /* goto window mode, if not already */

   if (!display->windowmode) {
     awclosedisplay(display);
     display->windowmode=1;
     ret=awiopendisplay(display);
     if (!ret) {
       /* retry screen mode */
       display->windowmode=0;
       ret=awiopendisplay(display);
       if (!ret) display->windowmode ^= 1;
     }
     display->stoprender=0;
   }

  } else if (s) {

    /* goto screen mode, if not already */

    if (display->windowmode) {
      awclosedisplay(display);
      display->windowmode=0;
      ret=awiopendisplay(display);
      if (!ret) {
        /* retry window mode */
        display->windowmode=1;
        ret=awiopendisplay(display);
        if (!ret) display->windowmode ^= 1;
      }
      display->stoprender=0;
    }

  } else if (tab) {

    /* toggle mode */

    awclosedisplay(display);
    display->windowmode ^= 1;
    ret=awiopendisplay(display);
    if (!ret) {
      /* retry the original mode */
      display->windowmode ^= 1;
      ret=awiopendisplay(display);
      if (!ret) display->windowmode ^= 1;
    }
    display->stoprender=0;

  } else if (p) {

    /* toggle pause... */

    display->stoprender ^= 1;

  } else if (m) {

    /* screenmode req... */

    awclosedisplay(display);

    if (awscreenmodereq(
      display,
      (display->srcdepth==16)?&display->modeid16:&display->modeid8,
      display->srcdepth,
      &display->width,
      &display->height,
      1)) {

      display->origw=display->width;
      display->origh=display->height;
      display->prevscreen=0;
    }

    ret=awiopendisplay(display);
    if (!ret) {
      /* try the other mode (fallback) */
      display->windowmode ^= 1;
      ret=awiopendisplay(display);
      if (!ret) display->windowmode ^= 1;
    }

    display->stoprender=0;

  }

  return ret;
}

/* LUT8 -> LUT8 scale and remap routines */

/* LUT8 scale chunky buffer, 24.8 precision
*/

void awscalechunky8(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddscalech68k8(
    chunky->framebuffer,
    display->framebuffer,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align,
    display->pixperrow);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,*t,*d,modulo;

#if AW_SCALEDEBUG
  display->height--;
#endif

  modulo=display->pixperrow-display->width_align;

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00), x=0;
        x<display->width_align; x+=16)

        *d++=chunky->framebuffer[xpo>>8]<<24|
          chunky->framebuffer[(xpo+=xadd)>>8]<<16|
          chunky->framebuffer[(xpo+=xadd)>>8]<<8|
          chunky->framebuffer[(xpo+=xadd)>>8],

        *d++=chunky->framebuffer[(xpo+=xadd)>>8]<<24|
          chunky->framebuffer[(xpo+=xadd)>>8]<<16|
          chunky->framebuffer[(xpo+=xadd)>>8]<<8|
          chunky->framebuffer[(xpo+=xadd)>>8],

        *d++=chunky->framebuffer[(xpo+=xadd)>>8]<<24|
          chunky->framebuffer[(xpo+=xadd)>>8]<<16|
          chunky->framebuffer[(xpo+=xadd)>>8]<<8|
          chunky->framebuffer[(xpo+=xadd)>>8],

        *d++=chunky->framebuffer[(xpo+=xadd)>>8]<<24|
          chunky->framebuffer[(xpo+=xadd)>>8]<<16|
          chunky->framebuffer[(xpo+=xadd)>>8]<<8|
          chunky->framebuffer[(xpo+=xadd)>>8],

        xpo+=xadd; /* !! */
  } else {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (t=(ULONG *)(chunky->framebuffer+chunky->width_align*(ypo>>8)),
           x=0; x<display->width_align; x+=16)
        *d++=*t++, *d++=*t++, *d++=*t++, *d++=*t++; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#endif


/* LUT8 scale + remap chunky buffer, 24.8 precision
*/

void awremapscalechunky8(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddremapscalech68k8(
    chunky->framebuffer,
    display->framebuffer,
    display->remap,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,*d;
  UBYTE *s;

#if AW_SCALEDEBUG
  display->height--;
#endif

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00),x=0;
        x<display->width_align; x+=16)

        *d++=display->remap[chunky->framebuffer[xpo>>8]]<<24|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap[chunky->framebuffer[(xpo+=xadd)>>8]],

        xpo+=xadd; /* !! */

  } else {
    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      ypo+=yadd, y++)
      for (x=0, s=chunky->framebuffer+chunky->width_align*(ypo>>8);
        x<display->width_align; x+=16)

        *d++=display->remap[s[0]]<<24 | display->remap[s[1]]<<16 |
          display->remap[s[2]]<<8 | display->remap[s[3]],

        *d++=display->remap[s[4]]<<24 | display->remap[s[5]]<<16 |
          display->remap[s[6]]<<8 | display->remap[s[7]],

        *d++=display->remap[s[8]]<<24 | display->remap[s[9]]<<16 |
          display->remap[s[10]]<<8 | display->remap[s[11]],

        *d++=display->remap[s[12]]<<24 | display->remap[s[13]]<<16 |
          display->remap[s[14]]<<8 | display->remap[s[15]],

        s+=16; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#endif


/* RGB16 -> LUT8 scale and remap routines */


/* RGB565 scale chunky buffer, 24.8 precision
   output LUT8
*/

void awscalechunky16(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K16

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddscalech68k16(
    chunky->framebuffer,
    display->framebuffer,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align,
    display->pixperrow);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,modulo,*d;
  UWORD *framebuffer=(UWORD *)chunky->framebuffer;

#if AW_SCALEDEBUG
  display->height--;
#endif

  modulo=display->pixperrow-display->width_align;

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00), x=0;
        x<display->width_align; x+=16)

        /* can't use (xpo+=xadd) because awrgb16to332 is a macro */

        *d++=awrgb16to332(framebuffer[(xpo+xadd*0)>>8])<<24|
          awrgb16to332(framebuffer[(xpo+xadd*1)>>8])<<16|
          awrgb16to332(framebuffer[(xpo+xadd*2)>>8])<<8|
          awrgb16to332(framebuffer[(xpo+xadd*3)>>8]),

        *d++=awrgb16to332(framebuffer[(xpo+xadd*4)>>8])<<24|
          awrgb16to332(framebuffer[(xpo+xadd*5)>>8])<<16|
          awrgb16to332(framebuffer[(xpo+xadd*6)>>8])<<8|
          awrgb16to332(framebuffer[(xpo+xadd*7)>>8]),

        *d++=awrgb16to332(framebuffer[(xpo+xadd*8)>>8])<<24|
          awrgb16to332(framebuffer[(xpo+xadd*9)>>8])<<16|
          awrgb16to332(framebuffer[(xpo+xadd*10)>>8])<<8|
          awrgb16to332(framebuffer[(xpo+xadd*11)>>8]),

        *d++=awrgb16to332(framebuffer[(xpo+xadd*12)>>8])<<24|
          awrgb16to332(framebuffer[(xpo+xadd*13)>>8])<<16|
          awrgb16to332(framebuffer[(xpo+xadd*14)>>8])<<8|
          awrgb16to332(framebuffer[(xpo+xadd*15)>>8]),

          xpo+=xadd*16; /* !! */
  } else {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (framebuffer=(UWORD *)(chunky->framebuffer+
        (chunky->width_align<<1)*(ypo>>8)),
        x=0; x<display->width_align; x+=16)

        *d++=awrgb16to332(framebuffer[0])<<24|
          awrgb16to332(framebuffer[1])<<16|
          awrgb16to332(framebuffer[2])<<8|
          awrgb16to332(framebuffer[3]),

        *d++=awrgb16to332(framebuffer[4])<<24|
          awrgb16to332(framebuffer[5])<<16|
          awrgb16to332(framebuffer[6])<<8|
          awrgb16to332(framebuffer[7]),

        *d++=awrgb16to332(framebuffer[8])<<24|
          awrgb16to332(framebuffer[9])<<16|
          awrgb16to332(framebuffer[10])<<8|
          awrgb16to332(framebuffer[11]),

        *d++=awrgb16to332(framebuffer[12])<<24|
          awrgb16to332(framebuffer[13])<<16|
          awrgb16to332(framebuffer[14])<<8|
          awrgb16to332(framebuffer[15]),

        framebuffer+=16; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#endif


/* RGB565 scale + remap chunky buffer, 24.8 precision
   output LUT8
*/

void awremapscalechunky16(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K16

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddremapscalech68k16(
    chunky->framebuffer,
    display->framebuffer,
    display->remap,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,*d;
  UWORD *s,*framebuffer=(UWORD *)chunky->framebuffer;

#if AW_SCALEDEBUG
  display->height--;
#endif

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00),x=0;
        x<display->width_align; x+=16)

        *d++=display->remap332[framebuffer[xpo>>8]]<<24|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap332[framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap332[framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap332[framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap332[framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap332[framebuffer[(xpo+=xadd)>>8]],

        *d++=display->remap332[framebuffer[(xpo+=xadd)>>8]]<<24|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<16|
          display->remap332[framebuffer[(xpo+=xadd)>>8]]<<8|
          display->remap332[framebuffer[(xpo+=xadd)>>8]],

        xpo+=xadd; /* !! */

  } else {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      ypo+=yadd, y++)
      for (x=0, s=(UWORD *)(chunky->framebuffer+
        (chunky->width_align<<1)*(ypo>>8));
        x<display->width_align; x+=16)

        *d++=display->remap332[s[0]]<<24 | display->remap332[s[1]]<<16 |
          display->remap332[s[2]]<<8 | display->remap332[s[3]],

        *d++=display->remap332[s[4]]<<24 | display->remap332[s[5]]<<16 |
          display->remap332[s[6]]<<8 | display->remap332[s[7]],

        *d++=display->remap332[s[8]]<<24 | display->remap332[s[9]]<<16 |
          display->remap332[s[10]]<<8 | display->remap332[s[11]],

        *d++=display->remap332[s[12]]<<24 | display->remap332[s[13]]<<16 |
          display->remap332[s[14]]<<8 | display->remap332[s[15]],

        s+=16; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif

}

#endif

/* RGB565 scale chunky buffer, 24.8 precision
   output RGB565
*/

void awscalechunky16_565(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K16

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddscalech68k16_565(
    chunky->framebuffer,
    display->framebuffer,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align,
    display->pixperrow);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,*t,modulo,*d;
  UWORD *framebuffer=(UWORD *)chunky->framebuffer;

#if AW_SCALEDEBUG
  display->height--;
#endif

  modulo=(display->pixperrow-display->width_align)*2;

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00), x=0;
        x<display->width_align; x+=16)

        *d++=framebuffer[xpo>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],
        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],

        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],
        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],

        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],
        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],

        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],
        *d++=framebuffer[(xpo+=xadd)>>8]<<16|
          framebuffer[(xpo+=xadd)>>8],

        xpo+=xadd; /* !! */
  } else {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (t=(ULONG *)(chunky->framebuffer+
        chunky->width_align*2*(ypo>>8)),
        x=0; x<display->width_align; x+=16)

        *d++=*t++, *d++=*t++, *d++=*t++, *d++=*t++,
        *d++=*t++, *d++=*t++, *d++=*t++, *d++=*t++; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#endif


/* RGB565 scale chunky buffer, 24.8 precision
   output ARGB
*/

void awscalechunky16_argb(struct awdisplay *display,
  struct awchunky *chunky) {

#if AW_USEREMAPSCALE68K16

#if AW_SCALEDEBUG
  display->height--;
#endif

  awddscalech68k16_argb(
    chunky->framebuffer,
    display->framebuffer,
    chunky->width,
    chunky->height,
    display->width,
    display->height,
    display->width_align,
    display->pixperrow);

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#else

  ULONG x,y,xpo,ypo,xadd,yadd,modulo,*d;
  UWORD *framebuffer=(UWORD *)chunky->framebuffer;

#if AW_SCALEDEBUG
  display->height--;
#endif

  modulo=(display->pixperrow-display->width_align)*2;

  xadd=(chunky->width<<8)/display->width;
  yadd=(chunky->height<<8)/display->height;

  if (xadd!=256) {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (xpo=chunky->width_align*(ypo&0xffffff00), x=0;
        x<display->width_align; x+=16)

        *d++=awrgb16to0888(framebuffer[(xpo+xadd*0)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*1)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*2)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*3)>>8]),

        *d++=awrgb16to0888(framebuffer[(xpo+xadd*4)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*5)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*6)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*7)>>8]),

        *d++=awrgb16to0888(framebuffer[(xpo+xadd*8)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*9)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*10)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*11)>>8]),

        *d++=awrgb16to0888(framebuffer[(xpo+xadd*12)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*13)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*14)>>8]),
        *d++=awrgb16to0888(framebuffer[(xpo+xadd*15)>>8]),

        xpo+=xadd*16; /* !! */
  } else {

    for (ypo=0, d=(ULONG *)display->framebuffer, y=0; y<display->height;
      d=(ULONG *)((ULONG)d+modulo), ypo+=yadd, y++)
      for (framebuffer=(UWORD *)(chunky->framebuffer+
        chunky->width_align*2*(ypo>>8)),
        x=0; x<display->width_align; x+=16)

        *d++=awrgb16to0888(framebuffer[0]),
        *d++=awrgb16to0888(framebuffer[1]),
        *d++=awrgb16to0888(framebuffer[2]),
        *d++=awrgb16to0888(framebuffer[3]),

        *d++=awrgb16to0888(framebuffer[4]),
        *d++=awrgb16to0888(framebuffer[5]),
        *d++=awrgb16to0888(framebuffer[6]),
        *d++=awrgb16to0888(framebuffer[7]),

        *d++=awrgb16to0888(framebuffer[8]),
        *d++=awrgb16to0888(framebuffer[9]),
        *d++=awrgb16to0888(framebuffer[10]),
        *d++=awrgb16to0888(framebuffer[11]),

        *d++=awrgb16to0888(framebuffer[12]),
        *d++=awrgb16to0888(framebuffer[13]),
        *d++=awrgb16to0888(framebuffer[14]),
        *d++=awrgb16to0888(framebuffer[15]),

        framebuffer+=16; /* !! */
  }

#if AW_SCALEDEBUG
  display->height++;
#endif
}

#endif



void awiwaitsafetowrite(struct awdisplay *display) {
#if defined(AW_PPC)
  struct Caos kaaos;

  /* -*- odump by Harry "Piru" Sintonen */
  static const ULONG awsafewaitinner[]={
    0x48e72020,0x24002448,0x204a4eae,0xfe8c4a80,
    0x66082002,0x4eaefec2,0x60ee4cdf,0x04044e75,
    0};
  /* -*- */
#else
  struct ExecBase *SysBase=display->SysBase;
#endif

  if (display->dbuffer) {
    if (!display->safetowrite) {
#if defined(AW_PPC)
      kaaos.d0=1L<<(display->sbports[AW_WRITEPORT]->mp_SigBit);
      kaaos.a0=(ULONG)display->sbports[AW_WRITEPORT];
      kaaos.a6=(ULONG)display->SysBase;
      kaaos.caos_Un.Function=(APTR)awsafewaitinner;
      kaaos.M68kCacheMode=IF_CACHEFLUSHNO;
      kaaos.PPCCacheMode=IF_CACHEFLUSHNO;
      PPCCallM68k(&kaaos);
#else
      while (!GetMsg(display->sbports[AW_WRITEPORT]))
        Wait(1L<<(display->sbports[AW_WRITEPORT]->mp_SigBit));
#endif
      display->safetowrite=1;
    }
  }
}


void awidirectdraw8(struct awdisplay *display,
  struct awchunky *chunky) {

  struct Library *CyberGfxBase=display->CyberGfxBase;
  APTR handle;
  ULONG width,height,pixfmt,bpp;
  /* save original variables */
  ULONG orig_pixperrow=display->pixperrow;
  UBYTE *orig_framebuffer=display->framebuffer;

  struct TagItem lbm_tags[7];

  lbm_tags[0].ti_Tag=LBMI_WIDTH;      lbm_tags[0].ti_Data=(ULONG)&width;
  lbm_tags[1].ti_Tag=LBMI_HEIGHT;     lbm_tags[1].ti_Data=(ULONG)&height;
  lbm_tags[2].ti_Tag=LBMI_PIXFMT,     lbm_tags[2].ti_Data=(ULONG)&pixfmt;
  lbm_tags[3].ti_Tag=LBMI_BYTESPERPIX;lbm_tags[3].ti_Data=(ULONG)&bpp;
  lbm_tags[4].ti_Tag=LBMI_BYTESPERROW;lbm_tags[4].ti_Data=(ULONG)&display->pixperrow;
  lbm_tags[5].ti_Tag=LBMI_BASEADDRESS;lbm_tags[5].ti_Data=(ULONG)&display->framebuffer;
  lbm_tags[6].ti_Tag=TAG_DONE;

  handle=LockBitMapTagList(
    display->renderrp.BitMap,
    lbm_tags);

  if (handle) {
    if ( (pixfmt==PIXFMT_LUT8) && (bpp==1) &&
         (width==display->scrwidth) &&
         (height==display->height) ) {

      /* scale chunky directly to gfxcard framebuffer */
      awscalechunky8(display,chunky);
    }

    UnLockBitMap(handle);
  }
  /* restore original variables */
  display->framebuffer=orig_framebuffer;
  display->pixperrow=orig_pixperrow;
}


void awidirectdraw16(struct awdisplay *display,
  struct awchunky *chunky) {

  struct Library *CyberGfxBase=display->CyberGfxBase;
  APTR handle;
  ULONG width,height,pixfmt,bpp;
  /* save original variables */
  ULONG orig_pixperrow=display->pixperrow;
  UBYTE *orig_framebuffer=display->framebuffer;

  struct TagItem lbm_tags[7];

  lbm_tags[0].ti_Tag=LBMI_WIDTH;      lbm_tags[0].ti_Data=(ULONG)&width;
  lbm_tags[1].ti_Tag=LBMI_HEIGHT;     lbm_tags[1].ti_Data=(ULONG)&height;
  lbm_tags[2].ti_Tag=LBMI_PIXFMT,     lbm_tags[2].ti_Data=(ULONG)&pixfmt;
  lbm_tags[3].ti_Tag=LBMI_BYTESPERPIX;lbm_tags[3].ti_Data=(ULONG)&bpp;
  lbm_tags[4].ti_Tag=LBMI_BYTESPERROW;lbm_tags[4].ti_Data=(ULONG)&display->pixperrow;
  lbm_tags[5].ti_Tag=LBMI_BASEADDRESS;lbm_tags[5].ti_Data=(ULONG)&display->framebuffer;
  lbm_tags[6].ti_Tag=TAG_DONE;

  handle=LockBitMapTagList(
    display->renderrp.BitMap,
    lbm_tags);

  if (handle) {
    if ( (pixfmt==PIXFMT_RGB16) && (bpp==2) &&
         (width==display->scrwidth) &&
         (height==display->height) ) {

      display->pixperrow/=2;

      /* scale chunky directly to gfxcard framebuffer */
      awscalechunky16_565(display,chunky);
    }

    UnLockBitMap(handle);
  }
  /* restore original variables */
  display->framebuffer=orig_framebuffer;
  display->pixperrow=orig_pixperrow;
}


#if AW_CGXVIDEOSUPPORT

/* render rgb565 chunky to cgxvideo.library vlayer rgb565 pc */

void awwritevlayer(struct awdisplay *display,
  struct awchunky *chunky) {

  struct Library *CGXVideoBase=display->CGXVideoBase;
  UWORD *d,*s;
  ULONG x,y,*e,*t;

  if (LockVLayer(display->vlhandle)) {

    d=(UWORD *)GetVLayerAttr(display->vlhandle,VOA_BaseAddress);

    if (display->vlwidth & 15) {

      /* ab -> ba */

      for (y=0; y<display->vlheight; y++)
        for (x=0, s=(UWORD *)chunky->framebuffer+chunky->width_align*y*2;
          x<display->vlwidth; x++)

          *d++=(s[0]<<8)|(s[0]>>8), s++;

    } else {

      /* abcd -> badc */

      t=(ULONG *)d;

      for (y=0; y<display->vlheight; y++)
        for (x=0, e=(ULONG *)chunky->framebuffer+chunky->width_align*y*2;
          x<display->vlwidth; x+=16)

          *t++=(e[0]&0xff00ff00)>>8 | (e[0]&0x00ff00ff)<<8,
          *t++=(e[1]&0xff00ff00)>>8 | (e[1]&0x00ff00ff)<<8,
          *t++=(e[2]&0xff00ff00)>>8 | (e[2]&0x00ff00ff)<<8,
          *t++=(e[3]&0xff00ff00)>>8 | (e[3]&0x00ff00ff)<<8, e+=4; /* !! */
    }

    UnLockVLayer(display->vlhandle);
  }
}
#endif

void awirenderchunky(struct awdisplay *display,
  struct awchunky *chunky) {

  struct GfxBase *GfxBase=display->GfxBase;
  struct IntuitionBase *IntuitionBase=display->IntuitionBase;
  struct Library *CyberGfxBase;
#if defined(__GNUC__) && !defined(AW_PPC)
  struct writepixelarrayargs wpa;
  struct writelutpixelarrayargs wluta;
#endif
  ULONG orig_pixperrow,orig_width;

#if defined(AW_PPC)
  struct Caos kaaos;

  /* -*- odump by Harry "Piru" Sintonen */
  static const ULONG awsafewaitinner[]={
    0x48e72020,0x24002448,0x204a4eae,0xfe8c4a80,
    0x66082002,0x4eaefec2,0x60ee4cdf,0x04044e75,
    0};
  /* -*- */
#else
  struct ExecBase *SysBase=display->SysBase;
#endif

#if AW_SCALEDEBUG
  display->framebuffer[display->width_align*(display->height-1)]=127;
  display->framebuffer[display->width_align*(display->height-1)+2]=127;
  display->framebuffer[display->width_align*display->height-3]=127;
  display->framebuffer[display->width_align*display->height-1]=127;
#endif

  if (display->windowmode) {

#if AW_CGXVIDEOSUPPORT
    if (display->vlhandle) {

      /* render to vlayer,
         basically this is just copymem with every byte swapped.
         we know that chunky depth is 16, too. */

      awwritevlayer(display,chunky);

    } else {
#endif

    if (display->cgfx) {
      CyberGfxBase=display->CyberGfxBase;

      if (display->truecolor) {

        if (display->useargb16 && (display->srcdepth==16) ) {
          /* we have hi/true colour CGFX/P96 screen for output,
             USEARGB16 flag set and depth 16 source
             so scale to ARGB and then WPA */

          awscalechunky16_argb(display,chunky);

#if !defined(__GNUC__) || defined(AW_PPC)
          WritePixelArray(
            display->framebuffer,0,0,
            display->width_align*4,
            display->window->RPort,
            display->window->BorderLeft,
            display->window->BorderTop,
            awtoinnerw(display,display->window->Width),
            awtoinnerh(display,display->window->Height),
            RECTFMT_ARGB);
#else
          wpa.srcrect=display->framebuffer;
          wpa.srcx=0; wpa.srcy=0;
          wpa.srcmod=display->width_align*4;
          wpa.rastport=display->window->RPort;
          wpa.dstx=display->window->BorderLeft;
          wpa.dsty=display->window->BorderTop;
          wpa.sizex=awtoinnerw(display,display->window->Width);
          wpa.sizey=awtoinnerh(display,display->window->Height);
          wpa.srcf=RECTFMT_ARGB;
          wpa.base=CyberGfxBase;
          writepixelarray(&wpa);
#endif

        } else {

          if (display->wlutpa) {
            /* we have >8 depth cybergraphx so first scale chunky */
            if (display->srcdepth==16)
              awscalechunky16(display,chunky);
            else awscalechunky8(display,chunky);

            /* then WriteLUTPixelArray */

#if !defined(__GNUC__) || defined(AW_PPC)
            WriteLUTPixelArray(
              display->framebuffer,
              0,0,
              display->width_align,
              display->window->RPort,
              (ULONG *)((display->srcdepth==16)?display->pal332:
                display->palette),
              display->window->BorderLeft,
              display->window->BorderTop,
              awtoinnerw(display,display->window->Width),
              awtoinnerh(display,display->window->Height),
              CTABFMT_XRGB8);
#else
            wluta.srcrect=display->framebuffer;
            wluta.srcx=0; wluta.srcy=0;
            wluta.srcmod=display->width_align;
            wluta.rastport=display->window->RPort;
            wluta.ctable=(display->srcdepth==16)?display->pal332:display->palette;
            wluta.dstx=display->window->BorderLeft;
            wluta.dsty=display->window->BorderTop;
            wluta.sizex=awtoinnerw(display,display->window->Width);
            wluta.sizey=awtoinnerh(display,display->window->Height);
            wluta.ctabf=CTABFMT_XRGB8;
            wluta.base=CyberGfxBase;
            writelutpixelarray(&wluta);
#endif

          } else {

            /* we have truecolor cybergraphx and no WLUTPA
               so remap & scale self and WPA */

            /* remap & scale chunky to display */
            if (display->srcdepth==16)
              awremapscalechunky16(display,chunky);
            else awremapscalechunky8(display,chunky);

#if !defined(__GNUC__) || defined(AW_PPC)
            WritePixelArray(
              display->framebuffer,0,0,
              display->width_align,
              display->window->RPort,
              display->window->BorderLeft,
              display->window->BorderTop,
              awtoinnerw(display,display->window->Width),
              awtoinnerh(display,display->window->Height),
              RECTFMT_LUT8);
#else
            wpa.srcrect=display->framebuffer;
            wpa.srcx=0; wpa.srcy=0;
            wpa.srcmod=display->width_align;
            wpa.rastport=display->window->RPort;
            wpa.dstx=display->window->BorderLeft;
            wpa.dsty=display->window->BorderTop;
            wpa.sizex=awtoinnerw(display,display->window->Width);
            wpa.sizey=awtoinnerh(display,display->window->Height);
            wpa.srcf=RECTFMT_LUT8;
            wpa.base=CyberGfxBase;
            writepixelarray(&wpa);
#endif
          }
        }

      } else {

        /* we have <=8 depth cybergraphx so scale self and WPA */

        /* remap & scale chunky to display */
        if (display->srcdepth==16)
          awremapscalechunky16(display,chunky);
        else awremapscalechunky8(display,chunky);

#if !defined(__GNUC__) || defined(AW_PPC)
        WritePixelArray(
          display->framebuffer,0,0,
          display->width_align,
          display->window->RPort,
          display->window->BorderLeft,
          display->window->BorderTop,
          awtoinnerw(display,display->window->Width),
          awtoinnerh(display,display->window->Height),
          RECTFMT_LUT8);
#else
        wpa.srcrect=display->framebuffer;
        wpa.srcx=0; wpa.srcy=0;
        wpa.srcmod=display->width_align;
        wpa.rastport=display->window->RPort;
        wpa.dstx=display->window->BorderLeft;
        wpa.dsty=display->window->BorderTop;
        wpa.sizex=awtoinnerw(display,display->window->Width);
        wpa.sizey=awtoinnerh(display,display->window->Height);
        wpa.srcf=RECTFMT_LUT8;
        wpa.base=CyberGfxBase;
        writepixelarray(&wpa);
#endif

      }
    } else {

      if ( (display->native) &&
           ((display->fblit) || (display->slowwpa8)) ) {

        /* native system with fblit or slow WCP/WPA8 */

        /* remap & scale chunky to display */
        if (display->srcdepth==16)
          awremapscalechunky16(display,chunky);
        else awremapscalechunky8(display,chunky);


        /* do c2p */
        awdoc2p(display);

        /* and then blit resulting planes to rastport */
        BltBitMapRastPort(
          &display->c2pbitmap[0],0,0,
          display->window->RPort,
          display->window->BorderLeft,
          display->window->BorderTop,
          awtoinnerw(display,display->window->Width),
          awtoinnerh(display,display->window->Height),
          0xc0);

      } else {

        /* general system */

        /* remap & scale chunky to display */
        if (display->srcdepth==16)
          awremapscalechunky16(display,chunky);
        else awremapscalechunky8(display,chunky);

        /* bang it with WCP or WPA8 */
        if (display->v40) {
          WriteChunkyPixels(
            display->window->RPort,
            display->window->BorderLeft,
            display->window->BorderTop,
            display->window->BorderLeft+
              awtoinnerw(display,display->window->Width)-1,
            display->window->BorderTop+
              awtoinnerh(display,display->window->Height)-1,
            display->framebuffer,
            display->width_align);
        } else {
          WritePixelArray8(
            display->window->RPort,
            display->window->BorderLeft,
            display->window->BorderTop,
            display->window->BorderLeft+
              awtoinnerw(display,display->window->Width)-1,
            display->window->BorderTop+
              awtoinnerh(display,display->window->Height)-1,
            display->framebuffer,
            &display->temprp);
        }
      }
    }

#if AW_CGXVIDEOSUPPORT
    }
#endif

  } else {

    /* screen mode */

    if (display->dbuffer) {
      /* set renderrp BitMap according to curbuffer */
      display->renderrp.BitMap=
        display->sbuf[display->curbuffer]->sb_BitMap;
    } else {
      /* no dbuffer, set to standard bitmap */
      display->renderrp.BitMap=
        display->screen->RastPort.BitMap;
    }

    if (display->cgfx) {
      CyberGfxBase=display->CyberGfxBase;

      if ( ((display->directdraw) && (display->islinearmem)) &&
           ((display->srcdepth==8) ||
            ((display->srcdepth==16) && (display->isrgb16))) ) {

        /* DirectDraw: scalechunky directly to CGFX bitmap */

        /* wait until it is safe to render */
        awiwaitsafetowrite(display);

        if (display->srcdepth==16)
          awidirectdraw16(display,chunky);
        else awidirectdraw8(display,chunky);

      } else {

        if (display->truecolor && display->useargb16 &&
            (display->srcdepth==16) ) {
          /* we have hi/true colour CGFX/P96 screen for output,
             USEARGB16 flag set and depth 16 source
             so scale to ARGB and then WPA */

          awscalechunky16_argb(display,chunky);

#if !defined(__GNUC__) || defined(AW_PPC)
          WritePixelArray(
            display->framebuffer,0,0,
            display->width_align*4,
            &display->renderrp,
            0,0,
            display->width,
            display->height,
            RECTFMT_ARGB);
#else
          wpa.srcrect=display->framebuffer;
          wpa.srcx=0; wpa.srcy=0;
          wpa.srcmod=display->width_align*4;
          wpa.rastport=&display->renderrp;
          wpa.dstx=0; wpa.dsty=0;
          wpa.sizex=display->width;
          wpa.sizey=display->height;
          wpa.srcf=RECTFMT_ARGB;
          wpa.base=CyberGfxBase;
          writepixelarray(&wpa);
#endif

        } else {
        /* we have cybergraphx so scale self and WPA */

        /* scale chunky to display */
        if (display->srcdepth==16)
          awscalechunky16(display,chunky);
        else awscalechunky8(display,chunky);

#if !defined(__GNUC__) || defined(AW_PPC)
        /* wait until it is safe to render */
        awiwaitsafetowrite(display);

        WritePixelArray(
          display->framebuffer,
          0,0,
          display->width_align,
          &display->renderrp,
          0,0,
          display->width,
          display->height,
          RECTFMT_LUT8);
#else
        wpa.srcrect=display->framebuffer;
        wpa.srcx=0; wpa.srcy=0;
        wpa.srcmod=display->width_align;
        wpa.rastport=&display->renderrp;
        wpa.dstx=0; wpa.dsty=0;
        wpa.sizex=display->width;
        wpa.sizey=display->height;
        wpa.srcf=RECTFMT_LUT8;
        wpa.base=CyberGfxBase;
        /* wait until it is safe to render */
        awiwaitsafetowrite(display);
        writepixelarray(&wpa);
#endif

      }
      }
    } else {
      if (display->native) {

        /* native system */

        /* force to render whole width because c2p converts
           whole buffer anyways (and has no modulo, ok this
           could be "fixed" but who cares.. really;) */

        orig_width=display->width;
        orig_pixperrow=display->pixperrow;

        display->width=display->width_align;
        display->pixperrow=display->width;

        /* scale chunky to display */
        if (display->srcdepth==16) {
          if (display->isham6) {

            display->width/=2;
            display->width_align/=2;
            display->pixperrow/=2;
            awscalechunky16_565(display,chunky);
            display->pixperrow*=2;
            display->width_align*=2;
            display->width*=2;

          } else awscalechunky16(display,chunky);
        } else awscalechunky8(display,chunky);

        display->pixperrow=orig_pixperrow;
        display->width=orig_width;

        /* wait until it is safe to render */
        awiwaitsafetowrite(display);

        /* do c2p */
        if ( (display->srcdepth==16) && (display->isham6) ) {
          awdoc2pham6(display);
        } else awdoc2p(display);

      } else {

        /* general system */

        /* scale chunky to display */
        if (display->srcdepth==16)
          awscalechunky16(display,chunky);
        else awscalechunky8(display,chunky);

        /* wait until it is safe to render */
        awiwaitsafetowrite(display);

        /* bang it with WCP or WPA8 */
        if (display->v40) {
          WriteChunkyPixels(
            &display->renderrp,
            0,0,
            display->width-1,
            display->height-1,
            display->framebuffer,
            display->width_align);
        } else {
          WritePixelArray8(
            &display->renderrp,
            0,0,
            display->width-1,
            display->height-1,
            display->framebuffer,
            &display->temprp);
        }
      }
    }

    if (display->dbuffer) {
      if (display->waitswap) {
        /* wait until it is safe to swap */
        if (!display->safetochange) {

#if defined(AW_PPC)
          kaaos.d0=1L<<(display->sbports[AW_DISPPORT]->mp_SigBit);
          kaaos.a0=(ULONG)display->sbports[AW_DISPPORT];
          kaaos.a6=(ULONG)display->SysBase;
          kaaos.caos_Un.Function=(APTR)awsafewaitinner;
          kaaos.M68kCacheMode=IF_CACHEFLUSHNO;
          kaaos.PPCCacheMode=IF_CACHEFLUSHNO;
          PPCCallM68k(&kaaos);
#else
          while (!GetMsg(display->sbports[AW_DISPPORT]))
            Wait(1L<<(display->sbports[AW_DISPPORT]->mp_SigBit));
#endif
          display->safetochange=1;

        }
      }
      /*if (display->native) WaitBlit();*/
      if (ChangeScreenBuffer(display->screen,
        display->sbuf[display->curbuffer])) {

        display->safetochange=0;
        display->safetowrite=0;
        display->curbuffer ^= 1;  /* toggle buffer */
      }
    }
  }
}

void awrenderchunky(struct awdisplay *display,
  struct awchunky *chunky) {

  ULONG ret=1,odepth=display->srcdepth,openscr=0;

#if AW_CGXVIDEOSUPPORT
  struct Library *CGXVideoBase;
  struct TagItem cvlh_tags[4];
#endif

  if (!display->stoprender) {
    display->rendering=1;

    /* this handles initial open */
    if (display->window==NULL) {
      display->srcdepth=chunky->depth;

      ret=awiopendisplay(display);
      if (!ret) {
        /* try the other mode (fallback) */
        display->windowmode ^= 1;
        ret=awiopendisplay(display);
        if (!ret) display->windowmode ^= 1;
      }
    }

    if (display->srcdepth!=chunky->depth) {
      if (!display->windowmode) {
        if ( ( (display->modeid8!=display->modeid16) ||
               (display->usehamf) ) ||
             (display->cgfx16bitf) ) {
          /* screen mode, close screen */
          awclosedisplay(display);
          openscr=1;
        } else {
          awicleardisplay(display);
        }
      }

      /* change depth */
      display->srcdepth=chunky->depth;

      /* ... */

      if ( (display->windowmode) || (!openscr) ) {
        /* reload palette */
        awremap(display);
        /* and update the display */
        awreopen(display);
      } else {
        ret=awiopendisplay(display);
        if (!ret) {
          /* try the original depth */
          display->srcdepth=odepth;
          ret=awiopendisplay(display);
          /* if still failed try opening with new depth
             on next round */
          if (!ret) display->srcdepth=chunky->depth;
        }
      }
    }

#if AW_CGXVIDEOSUPPORT

    /* handle vlayer */

    if ( (ret) && (display->usecgxvideo) &&
         (display->CGXVideoBase) &&
         (display->windowmode) &&
         (display->srcdepth==16) &&
          ((odepth!=chunky->depth) ||  /* if srcdepth *changed* */
           (display->vlwidth!=chunky->width) ||
           (display->vlheight!=chunky->height)) ) {

      CGXVideoBase=display->CGXVideoBase;

      if (display->vlhandle) {
        DetachVLayer(display->vlhandle);
        DeleteVLayerHandle(display->vlhandle);
        display->vlhandle=NULL;
      }

      cvlh_tags[0].ti_Tag=VOA_SrcWidth;  cvlh_tags[0].ti_Data=chunky->width;
      cvlh_tags[1].ti_Tag=VOA_SrcHeight; cvlh_tags[1].ti_Data=chunky->height;
      cvlh_tags[2].ti_Tag=VOA_SrcType;   cvlh_tags[2].ti_Data=SRCFMT_RGB16PC;
      cvlh_tags[3].ti_Tag=TAG_DONE;

      display->vlhandle=CreateVLayerHandleTagList(
        display->screen,cvlh_tags);

      if (display->vlhandle) {

        cvlh_tags[0].ti_Tag=TAG_DONE;

        if (AttachVLayerTagList(
          display->vlhandle,
          display->window,
          cvlh_tags)) {

          /* attached successfully */

          display->vlwidth=chunky->width;
          display->vlheight=chunky->height;

        } else {
          DeleteVLayerHandle(display->vlhandle);
          display->vlhandle=NULL;
        }
      }
    }
#endif

    awirenderchunky(display,chunky);

    display->rendering=0;
  }
}

void awrenderchunky_show(struct awdisplay *display,
  struct awchunky *chunky) {

  awrenderchunky(display,chunky);

  /* if in screen mode render chunky twice forcing it
     visible */
  if (!display->windowmode) {
    awrenderchunky(display,chunky);
  }
}

void awfreefile(struct awfile *file) {

  struct ExecBase *SysBase=(*((struct ExecBase **)4));

  if (file) {
    if (file->memory) {
      if (file->buflen) {
        /* xpk allocated buffer... */
        FreeMem(file->memory,file->buflen);
      } else {
        /* our allocated buffer */
        free(file->memory);
      }
    }
    free(file);
  }
}

#if AW_XPKSUPPORT

ULONG awixpkload(struct awfile *file,const char *name) {

  struct ExecBase *SysBase=(*((struct ExecBase **)4));
  struct Library *XpkBase;
  ULONG ret=0,size,buflen;
  void *memory;
  char error[XPKERRMSGSIZE+1];
  struct TagItem up_tags[8];

  XpkBase=OpenLibrary("xpkmaster.library",0L);
  if (XpkBase) {

    up_tags[0].ti_Tag = XPK_InName;       up_tags[0].ti_Data = (ULONG)name;
    up_tags[1].ti_Tag = XPK_GetError;     up_tags[1].ti_Data = (ULONG)error;
    up_tags[2].ti_Tag = XPK_GetOutLen;    up_tags[2].ti_Data = (ULONG)&size;
    up_tags[3].ti_Tag = XPK_GetOutBuf;    up_tags[3].ti_Data = (ULONG)&memory;
    up_tags[4].ti_Tag = XPK_GetOutBufLen; up_tags[4].ti_Data = (ULONG)&buflen,
    up_tags[5].ti_Tag = XPK_OutMemType;   up_tags[5].ti_Data = MEMF_PUBLIC;
    up_tags[6].ti_Tag = XPK_PassThru;     up_tags[6].ti_Data = 1;
    up_tags[7].ti_Tag = TAG_DONE;

    if (!XpkUnpack(up_tags)) {

      file->memory=malloc(size+63+AW_SANITY);
      if (file->memory) {
        file->size=size;
        file->data=(void *)awalign(file->memory,32);
        memcpy(file->data,memory,size);
        FreeMem(memory,buflen);
      } else {
        file->size=size;
        file->memory=memory;
        file->buflen=buflen;
      }
      ret=1;

    } else {
      file->memory=NULL; file->buflen=0;
      printf("awin xpk: %s\n",error);
    }

    CloseLibrary(XpkBase);
  } else {
    printf("awin: could not open xpkmaster.library\n");
  }
  return ret;
}
#endif

struct awfile *awloadfile(const char *name) {
  struct awfile *file;
  FILE *fp;
#if AW_XPKSUPPORT
  ULONG id;
#endif

  fp=fopen(name,"r");
  if (fp) {
    if (fseek(fp,0L,SEEK_END)!=-1L) {
      file=malloc(sizeof(struct awfile));
      if (file) {
        memset(file,0,sizeof(struct awfile));
        file->size=ftell(fp);
        if (file->size>0) {

#if AW_XPKSUPPORT
          if (file->size>12) {
            rewind(fp);
            if (fread(&id,1,4,fp)==4) {
              if (id==('X'<<24|'P'<<16|'K'<<8|'F')) {
                if (awixpkload(file,name)) {
                  fclose(fp);
                  return file;
                }
              }
            }
          }
#endif
          file->memory=malloc(file->size+63+AW_SANITY);
          if (file->memory) {
            file->data=(void *)awalign(file->memory,32);
            rewind(fp);
            if (fread(file->data,1,file->size,fp)==file->size) {
              fclose(fp);
              return file;
            }
          }
        }
        awfreefile(file);
      }
    }
    fclose(fp);
  } else {
    printf("awin: could not open %s\n",name);
  }
  return NULL;
}
