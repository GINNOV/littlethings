/* awindemo.c

  Simple example on how to use awin.

  Has three effects, dummy 16bit `pseudo'plasma,
  8bit rotatezoomer and tunnel.

  compiled with ppc-amigaos-gcc 2.7.2.1:

  rotzoom runs ~198fps in 64x48 dbuffer off pal screen on 603p@240/060,
  ~138fps 128x96, ~65fps 256x180 and ~45fps 320x240

  tunnel runs ~109fps (slow because of 128k table lookup),
  ~88fps 128x96, ~51fps 256x180 and ~38fps 320x240

  all effects are calculating 320x240 chunky framebuffer.

*/

#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <math.h>
#ifndef M_PI
#  define M_PI 3.14159265358979323846
#endif

#include "awin.h"

#define AWINDEMOVERSION "awindemo 1.0.13"

#define PLASMA_TIME 5000
#define PLASMA_WIDTH 320
#define PLASMA_HEIGHT 240
#define PLASMA_DEPTH 16

#define ROTZOOM_TIME 20000
#define ROTZOOM_WIDTH 320
#define ROTZOOM_HEIGHT 240
#define ROTZOOM_DEPTH 8

#define TUNNEL_TIME 20000
#define TUNNEL_WIDTH 320
#define TUNNEL_HEIGHT 240
#define TUNNEL_DEPTH 8

#define DEF_WIDTH 320
#define DEF_HEIGHT 240

#define SINTAB90 1024
#define SINTAB360 (SINTAB90*4)


unsigned long __stack=20480;

#if defined(AW_PPC)
void __chkabort(void);
void __chkabort(void){}
#else 
void __regargs __chkabort(void);
void __regargs __chkabort(void){}
#endif



/* this plasma isn't really plasma but simple routine to
   generate 16bit test chunky */

#define limr(x) (((x)<0)?0:(((x)>31)?31:(x)))
#define limg(x) (((x)<0)?0:(((x)>63)?63:(x)))
#define limb(x) (((x)<0)?0:(((x)>31)?31:(x)))
#define truncr(x) ((x)&31)
#define truncg(x) ((x)&63)
#define truncb(x) ((x)&31)
#define torgb565(r,g,b) ((r)<<11|(g)<<5|(b))

void plasma(struct awchunky *chunky,ULONG time) {

  ULONG x,y,
    *p=(ULONG *)chunky->framebuffer;
  ULONG r,g,b;

  r=time/64+1;
  g=time/32+3;
  b=-(time/16+5);

  for (y=0; y<chunky->height; y++) {

    r+=(((y+time/100)/13)&7)-3;
    g+=7-((y/11)&15);
    b+=((y/7)&31)-15;

    for (x=0; x<chunky->width_align; x+=8)

      *p++=
        torgb565(truncr(r),truncg(g),truncb(b))<<16|
        torgb565(truncr(r+1),truncg(g+1),truncb(b+1)),

      *p++=
        torgb565(truncr(r+2),truncg(g+2),truncb(b+2))<<16|
        torgb565(truncr(r+3),truncg(g+3),truncb(b+3)),

      *p++=
        torgb565(truncr(r+4),truncg(g+4),truncb(b+4))<<16|
        torgb565(truncr(r+5),truncg(g+5),truncb(b+5)),

      *p++=
        torgb565(truncr(r+6),truncg(g+6),truncb(b+6))<<16|
        torgb565(truncr(r+7),truncg(g+7),truncb(b+7)),

        r+=8,g+=8,b+=8;
  }
}


LONG *init_sintab(void) {
  LONG *sintab,i;

  sintab=malloc(sizeof(LONG)*(SINTAB360+SINTAB90));
  if (!sintab) {
    printf("no memory for sintab\n");
    return NULL;
  }
  for(i=0; i<(SINTAB360+SINTAB90); i++) {
    sintab[i]=sin(M_PI/180.0*i*360.0/SINTAB360)*32768;
  }
  return sintab;
}

/* this routine "taken" from QMap :) */

void rotzoom(struct awchunky *chunky,ULONG time,
  ULONG *alpha,LONG *sintab,UBYTE *pic) {

  ULONG x,y,tx,ty,tx2,ty2,
    *p=(ULONG *)chunky->framebuffer;
  LONG aktsin,aktcos;

  aktsin=2*sintab[*alpha&(SINTAB360-1)];
  aktcos=2*sintab[(*alpha&(SINTAB360-1))+SINTAB90];

  /* spend 10 seconds on SINTAB360 degrees */
  *alpha=time/(10000.0/SINTAB360);

  tx2=-100*sintab[(5*(*alpha)+23)&(SINTAB360-1)];
  ty2=-100*sintab[((7*(*alpha)+71)&(SINTAB360-1))+SINTAB90];
  for (y=0; y<chunky->height; y++) {
    tx=tx2;
    ty=ty2;
    for (x=0; x<chunky->width_align; x+=16)

      *p++=pic[((ty>>9)&(0x7f<<7))+((tx>>16)&0x7f)]<<24|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<16|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<8|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)],

      *p++=pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<24|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<16|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<8|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)],

      *p++=pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<24|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<16|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<8|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)],

      *p++=pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<24|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<16|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)]<<8|
           pic[(((ty+=aktcos)>>9)&(0x7f<<7))+(((tx+=aktsin)>>16)&0x7f)],

      ty+=aktcos, tx+=aktsin; /* !! */

    tx2+=aktcos;
    ty2-=aktsin;
    aktsin-=1<<8;
    aktcos+=1<<8;
  }
}


UWORD *init_tunnel(void) {
  UWORD *tunneltab;
  LONG x,y;
  ULONG xx,yy;
  UWORD *tab;

  tunneltab=malloc(TUNNEL_WIDTH*TUNNEL_HEIGHT*sizeof(UWORD));
  if (!tunneltab) {
    printf("no memory for tunneltab\n");
    return NULL;
  }

  /* again this stuff shamelesly ripped. */

  tab=tunneltab;

  for (y=TUNNEL_HEIGHT/2; y>-TUNNEL_HEIGHT/2; y--) {
    for (x=-TUNNEL_WIDTH/2; x<TUNNEL_WIDTH/2; x++) {
      if (x | y) {
        yy = (int) (6000 / sqrt((double)(x*x+y*y))) & 0xff;
        xx = (int) (atan2((double)y, (double)x) * (256/M_PI)) &0xff;
        *tab++ = yy<<8 | xx;
      } else {
        *tab++ = 0;
      }
    }
  }
  return tunneltab;
}

UBYTE *init_texture(struct awfile *pic) {
  UBYTE *texture=NULL;

  if (pic) {

    if (pic->size!=256*256) {
      printf("tunnel texture size not 256*256\n");
      awfreefile(pic);
      return NULL;
    }

    texture=malloc(256*256*2);
    if (!texture) {
      printf("no memory for texture\n");
      return NULL;
    }

    /* copy texture to mem twice */
    memcpy(texture+0*256*256,pic->data,256*256);
    memcpy(texture+1*256*256,pic->data,256*256);
    awfreefile(pic);
  }
  return texture;
}

void tunnel(struct awchunky *chunky,ULONG time,
  UWORD *position,UWORD *tunneltab,LONG *sintab,UBYTE *texture) {

  ULONG cnt=(chunky->width_align>>4)*chunky->height,
    index=0;
  ULONG *p=(ULONG *)chunky->framebuffer;
  UBYTE *t=&texture[*position];

  /* move along in texture */
  *position=
    ((time/4-sintab[(time/3+SINTAB90)&(SINTAB360-1)]/256)&0xff)<<8|
    ((time/32+sintab[(time/2)&(SINTAB360-1)]/128)&0xff);

  while (cnt--)
    *p++=t[tunneltab[index+0]]<<24 | t[tunneltab[index+1]]<<16 |
         t[tunneltab[index+2]]<<8  | t[tunneltab[index+3]],
    *p++=t[tunneltab[index+4]]<<24 | t[tunneltab[index+5]]<<16 |
         t[tunneltab[index+6]]<<8  | t[tunneltab[index+7]],
    *p++=t[tunneltab[index+8]]<<24 | t[tunneltab[index+9]]<<16 |
         t[tunneltab[index+10]]<<8 | t[tunneltab[index+11]],
    *p++=t[tunneltab[index+12]]<<24| t[tunneltab[index+13]]<<16 |
         t[tunneltab[index+14]]<<8 | t[tunneltab[index+15]],
    index+=16;
} 


void changepalette(struct awdisplay *display,
  struct awchunky *chunky,ULONG *palette,ULONG palentries) {

  ULONG x;
  ULONG *c;

  /* clear chunky and force it visible. this is to
     avoid nasty gfx glitch in screen mode. */

  x=(chunky->width_align>>4)*chunky->height;
  c=(ULONG *)chunky->framebuffer;
  while (x--) *c++=0,*c++=0,*c++=0,*c++=0;
  awrenderchunky_show(display,chunky);
    
  awsetpalette(display,palette,palentries);
}

ULONG myidcmp(struct IntuiMessage *msg) {

  switch (msg->Class) {
    case IDCMP_RAWKEY:
      printf("myidcmp: rawkey 0x%02x\n",msg->Code);
      break;
    case IDCMP_VANILLAKEY:
      printf("myidcmp: vanillakey %c (%d)\n",
        ((msg->Code>31)&&(msg->Code<127))?msg->Code:'.',msg->Code);
      break;
  }
  return AWIDHA_NOP;
}

#if defined(__SASC)
const char Version[] = "$VER: " AWINDEMOVERSION " " __AMIGADATE__ ;
#else
const char Version[] = "$VER: " AWINDEMOVERSION " (" __DATE__  ")";
#endif

int main(void) {

  struct awfile *bunnypic,*bunnypal,*glas2pal;
  struct awchunky *tunchunky,*rotchunky,*plasmachunky;
  struct awdisplay *display;
  struct awtimer *timer;
  struct awodargs odargs;
  struct awrdargs *rdargs;
  LONG array[4]={0};
  ULONG rottime,tuntime,plasmatime;
  ULONG ticks,inputticks=0,time,timebase;
  ULONG frames=0,took,fps100,rotpal=0,tunpal=0;
  ULONG alpha=0,quit=0;
  LONG *sintab;
  UBYTE *texture;
  UWORD *tunneltab,position=0;

  if ( (display=awcreatedisplay()) ) {

    awsetdebuglevel(display,AWD_VERBOSE);

    /* clear all & set default values */
    memset(&odargs,0,sizeof(odargs));
    odargs.flags=AWODAF_INITWINDOW | AWODAF_DIRECTDRAW;
    odargs.modeid8=0L;              /* find best modeid */
    odargs.modeid16=0L;             /* find best modeid */
    odargs.pubscreen="Workbench";   /* Workbench pubscreen */
    odargs.title="awin demo";
    odargs.width=DEF_WIDTH;      /* default dimensions same */
    odargs.height=DEF_HEIGHT;    /* as our "largest" effect's */
    odargs.x=0; odargs.y=0;

    rdargs=awreadargs(display,&odargs,
      "PLASMATIME/N,ROTTIME/N,TUNNELTIME/N,STARTTIME/N",array);

    if (rdargs) {

      printf(
        "   ESC Q quit\n"
        "   W     switch to window mode\n"
        "   S     switch to screen mode\n"
        "   TAB   toggle between window and screen mode\n"
        "   P     pause rendering (handy for screenshots;)\n"
        "   SPACE readjust window size/pos so that it has original w&h\n"
        "   M     change screen mode ModeID (also changes window size)\n\n");

      /* now we can modify odargs if we like, although
         overriding user given arguments is rude... :-) */


      printf("initializing...\n");

      bunnypic=awloadfile("bunny.raw");
      bunnypal=awloadfile("bunny.pal");
      tunneltab=init_tunnel();

      texture=init_texture(awloadfile("glas2.raw"));
      glas2pal=awloadfile("glas2.pal");

      sintab=init_sintab();

      if ( (!bunnypic) ||
           (!bunnypal) ||
           (!glas2pal) ||
           (!sintab) ||
           (!tunneltab) ||
           (!texture) ||
           (bunnypic->size!=128*128) ||
           (bunnypal->size!=1024) ||
           (glas2pal->size!=1024) ) {

        printf("something went wrong\n");

        awfreefile(glas2pal);
        awfreefile(bunnypal); awfreefile(bunnypic);
        awfreeargs(rdargs); awdeletedisplay(display);
        return 10;
      }

      /* call myidcmp for IDCMP_RAWKEY and IDCMP_VANILLAKEY */
      awsetidcmphook(display,myidcmp);
      awsetidcmpflags(display,IDCMP_RAWKEY|IDCMP_VANILLAKEY);

      if ( (timer=awcreatetimer(display)) ) {

        if ( (plasmachunky=awallocchunky(display,
          PLASMA_WIDTH,PLASMA_HEIGHT,PLASMA_DEPTH)) ) {

          if ( (rotchunky=awallocchunky(display,
            ROTZOOM_WIDTH,ROTZOOM_HEIGHT,ROTZOOM_DEPTH)) ) {

            if ( (tunchunky=awallocchunky(display,
              TUNNEL_WIDTH,TUNNEL_HEIGHT,TUNNEL_DEPTH)) ) {

              if (awopendisplay(display,&odargs)) {

                if (array[0]) plasmatime=1000 * *((ULONG *)array[0]);
                  else plasmatime=PLASMA_TIME;

                if (array[1]) rottime=1000 * *((ULONG *)array[1]);
                  else rottime=ROTZOOM_TIME;

                if (array[2]) tuntime=1000 * *((ULONG *)array[2]);
                  else tuntime=TUNNEL_TIME;

                if (array[3]) timebase=-1000 * *((ULONG *)array[3]);
                  else timebase=0;
                
                awrestarttimer(timer);

                while (!quit) {

                  ticks=awreadtimer(timer);
                  time=ticks-timebase;

                  /* handle input 5 times per second, this reduces overhead a
                     bit, but makes awin respond user input a bit sluggish */
                  if (ticks>inputticks) {
                    inputticks=ticks+200;  /* 1s/5=200ms */
                    quit=!awhandleinput(display);
                  }

                  if (time<plasmatime) {

                    plasma(plasmachunky,time);
                    awrenderchunky(display,plasmachunky);
                    frames++;

                  } else if (time<rottime+plasmatime) {

                    if (!rotpal) {
                      rotpal++;
                      changepalette(display,rotchunky,(ULONG *)bunnypal->data,256);
                      frames++;
                    }
                    rotzoom(rotchunky,time,&alpha,sintab,bunnypic->data);
                    awrenderchunky(display,rotchunky);
                    frames++;

                  } else if (time<tuntime+rottime+plasmatime) {

                    if (!tunpal) {
                      tunpal++;
                      changepalette(display,tunchunky,(ULONG *)glas2pal->data,256);
                      frames++;
                    }
                    tunnel(tunchunky,time,&position,tunneltab,sintab,texture);
                    awrenderchunky(display,tunchunky);
                    frames++;

                  } else {
                    /* restart */
                    rotpal=0; tunpal=0;
                    timebase+=time;
                  }
                }

                took=awreadtimer(timer);
                if (took<50) took=50;

                fps100=frames*1000/(took/100.0);

                printf("ran %lu ms (%lu seconds), %lu frames, %lu.%02lu average fps\n",
                  took,(took+500)/1000,frames,fps100/100,fps100%100);

                awclosedisplay(display);
              }
              awfreechunky(tunchunky);
            }
            awfreechunky(rotchunky);
          }
          awfreechunky(plasmachunky);
        }
        awdeletetimer(timer);
      }
      awfreefile(glas2pal);
      awfreefile(bunnypal);
      awfreefile(bunnypic);
      awfreeargs(rdargs);
    }
    awdeletedisplay(display);
  }
  return 0;
}
