#include <exec/types.h>
#include <graphics/gfxbase.h>
#include <intuition/intuition.h>
#undef   NULL
#include <math.h>
#include <stdio.h>

/* NOTICE: If you are compiling this from 'HCE', remember to set the 'Use' */
/*         maths library gadget from the Linker-options Window. (VANSOFT)  */

/*
**    balls - a simulation of that kinetic thingy with three-d
**            smooth shaded  spheres with diffuse and specular
**            reflections. It'd be  nice if someone could  add
**            sound. A good demonstration  of  using  the  ffp
**            math subroutines.  I plan to add texture mapping
**            to the spheres in the future.
**
**
**    perry s. kivolowitz - ihnp4!ptsfa!well!perry
**
**    not to be distributed for commercial purposes. any
**    distribution must include this notice, please.
**
*/

void *OpenLibrary();
struct Screen *OpenScreen();
struct Window *OpenWindow();
struct IntuiMessage *GetMsg();
double sin(), cos(), fabs(), sqrt(), pow();

#ifdef   MY_DEBUG
FILE *dfp;
#endif

#define  RADIUS   20       /* radius of the balls ve are goink to draw */
#define  DEPTH    5L        /* number of pixel planes */
#define  NMAP     32       /* 2 to the DEPTH power   */
#define  AMBIENT  2        /* how much light on the dark side ofthe moon */
#define  NSTEPS   6        /* how many discreet frames in bouncers */

#define  SH       200      /* screen height */
#define  SW       320      /* screen width  */
#define  WH       (SH-10)  /* window height */
#define  WW       SW       /* window width  */
#define  MW       (WW / 2) /* middle of window */

#define  D        (2 * RADIUS)
#define  DL    (2L * RADIUS)

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
long MathBase;
long MathTransBase;

int is_cli = 0;

struct Window *w;                  /* window structure returned by exec */
struct Screen *s;                  /* screen structure returned by exec */
struct ColorMap *color_map;        /* pointer to c_map returned by exec */
short  displacements[D];           /* place for sphere's scanline dx's  */
short  surface[D];                 /* place for spehre's scanline dz's  */

struct bouncer {
 struct RastPort rp;
 struct BitMap   bm;
 long sx , sy;
} left[NSTEPS] , right[NSTEPS];

struct point {
 double x;
 double y;
 double z;
} light;

/*
** mask is a bit mask of things that I should close or deallocate
** when the program terminates for  any reason.  after opening or
** allocating some resource set the appropriate bit in mask.
*/

unsigned int mask = 0;

#define  INTUITION   0x00000001
#define  GRAPHICS    0x00000002
#define  SCREEN      0x00000004
#define  WINDOW      0x00000008
#define  COLORMAP    0x00000010
#define  MATH        0x00000020
#define  MATHTRANS   0x00000040

int rastcount = 0;      /* easy way to free rasters at termination */

chip struct NewScreen ns = {    /*****************/
 0 ,                     /* LeftEdge      */
 0 ,                     /* TopEdge       */
 SW ,                    /* Width         */
 SH ,                    /* Height        */
 DEPTH ,                 /* Depth         */
 0 ,                     /* DetailPen     */
 1 ,                     /* BlockPen      */
 0 ,                     /* ViewModes     */
 CUSTOMSCREEN ,          /* Type          */
 NULL ,                  /* *Font         */
 (UBYTE *)" spheres by p.s.kivolowitz" ,       /* *DefaultTitle */
 NULL ,                  /* *Gadgets      */
 NULL                    /* *CustomBitMap */
};                         /*****************/

struct NewWindow nw = {    /*****************/
 0 ,                     /* LeftEdge      */
 10 ,                    /* TopEdge       */
 WW ,                    /* Width         */
 WH ,                    /* Height        */
 -1 ,                    /* DetailPen     */
 -1 ,                    /* BlockPen      */
 IDCMP_CLOSEWINDOW,      /* IDCMP---Flags */
 WFLG_CLOSEGADGET        /*   F           */
 | WFLG_BACKDROP         /*     l         */
 | WFLG_BORDERLESS       /*       a       */
 | WFLG_NOCAREREFRESH    /*         g     */
 | WFLG_ACTIVATE ,       /*           s   */
 NULL ,                  /* *FirstGadget  */
 NULL ,                  /* *CheckMark    */
 (UBYTE *)"(still under development)" ,/* *Title        */
 NULL ,                  /* *Screen       */ /* to be filled in */
 NULL ,                  /* *BitMap       */
 0 ,                     /* MinWidth      */
 0 ,                     /* MinHeight     */
 0 ,                     /* MaxWidth      */
 0 ,                     /* MaxHeight     */
 CUSTOMSCREEN            /* Type          */
};                         /*****phew!!!*****/

double
degrad(degrees)
double degrees;
{
 double pi;

 pi = 335.0 / 113.0;   /* chinese approximation */
 pi *= degrees;
 return(pi/180.0);
}

main(argc , argv)
char *argv[];
{
 int i;
 struct IntuiMessage *message;
 if (argc) is_cli = 1;

#ifdef   MY_DEBUG
 if ((dfp = fopen("debug.file" , "w")) == NULL) {
    if (is_cli) printf("can't open debugging file\n");
    exit(1);
 }
 fprintf(dfp,"debugging information\n");
 fflush(dfp);
#endif

 if(!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",0L)))
 {
    if (is_cli) printf("no graphics library!!!\n");
    close_things();
    exit(1);
 }
 mask |= GRAPHICS;

 if(!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",
 0L)))
 {
    if (is_cli) printf("no intuition here!!\n");
    close_things();
    exit(1);
 }
 mask |= INTUITION;

 if ((MathBase = (long)OpenLibrary("mathffp.library" , 0L)) == NULL) {
    if (is_cli) printf("couldn't open mathffp library\n");
    close_things();
    exit(1);
 }
 mask |= MATH;

 if ((MathTransBase = (long)OpenLibrary("mathtrans.library" , 0L)) == NULL) {
    if (is_cli) printf("couldn't open mathtrans library\n");
    close_things();
    exit(1);
 }
 mask |= MATHTRANS;

 allocate_rasters();

 if ((s = (struct Screen *) OpenScreen(&ns)) == (struct Screen *) NULL) {
    if (is_cli) printf("could not open the screen!\n");
    close_things();
    exit(2);
 }
 mask |= SCREEN;
 nw.Screen = s;

 if((w = (struct Window *)OpenWindow(&nw)) == (struct Window *) NULL) {
    if (is_cli) printf("could not open the window!\n");
    close_things();
    exit(2);
 }
 mask |= WINDOW;

 init_color_map();

 light.x = 0.0;
 light.y = light.x + 150.0 - light.x;
 light.z = light.x + 25.0 - light.x;

 bres(RADIUS , displacements);

 /*
 ** make the three bottom balls
 */

 make_ball(w->RPort , MW - D , WH - RADIUS , -D , 0, 0);
 make_ball(w->RPort , MW     , WH - RADIUS ,  0 , 0, 0);
 make_ball(w->RPort , MW + D , WH - RADIUS ,  D , 0, 0);

 SetAPen(w->RPort,1);
 Move(w->RPort,10,25);
 Text(w->RPort,"PLEASE WAIT!",12);

 make_rotated_ball(&left[0] , -15 , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[0] , 15 , MW + 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&left[1] , -14 , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[1] , 14 , MW + 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&left[2] , -12 , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[2] , 12 , MW + 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&left[3] , -9  , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[3],  9  , MW + 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&left[4] , -5  , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[4],  5  , MW + 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&left[5] ,  0  , MW - 2 * D , 10 , WH - 10 - RADIUS);
 make_rotated_ball(&right[5],  0  , MW + 2 * D , 10 , WH - 10 - RADIUS);

 ClipBlit(&left[0].rp,0L,0L,w->RPort,left[0].sx,left[0].sy,DL,DL,0xC0L);
 ClipBlit(&right[NSTEPS-1].rp,0L,0L,w->RPort,right[NSTEPS-1].sx,
            right[NSTEPS-1].sy,DL,DL,0xC0L);

 SetAPen(w->RPort,1); /* Clear text. */
 Move(w->RPort,10,25);
 Text(w->RPort,"             ",13);

 message = (struct IntuiMessage *) GetMsg(w->UserPort);
 while (!message || (message->Class != IDCMP_CLOSEWINDOW)) {
    for (i = 1; i < NSTEPS; i++) {
       Delay(2L);
       WaitBOVP(&s->ViewPort);
       clear_rect(w->RPort,left[i-1].sx,left[i-1].sy,D,D);
       ClipBlit(&left[i].rp,0L,0L,w->RPort,left[i].sx,left[i].sy,
               DL,DL,0xC0L);
    }
    for (i = NSTEPS-2; i >= 0; i--) {
       WaitBOVP(&s->ViewPort);
       clear_rect(w->RPort,right[i+1].sx,right[i+1].sy,D,D);
       ClipBlit(&right[i].rp,0L,0L,w->RPort,right[i].sx,right[i].sy,
               DL,DL,0xC0L);
       Delay(2L);
    }
    Delay(1L);
    for (i = 1; i < NSTEPS; i++) {
       Delay(2L);
       WaitBOVP(&s->ViewPort);
       clear_rect(w->RPort,right[i-1].sx,right[i-1].sy,D,D);
       ClipBlit(&right[i].rp,0L,0L,w->RPort,right[i].sx,right[i].sy,
               DL,DL,0xC0L);
    }
    for (i = NSTEPS-2; i >= 0; i--) {
       WaitBOVP(&s->ViewPort);
       clear_rect(w->RPort,left[i+1].sx,left[i+1].sy,D,D);
       ClipBlit(&left[i].rp,0L,0L,w->RPort,left[i].sx,left[i].sy,
               DL,DL,0xC0L);
       Delay(2L);
    }
    Delay(1L);
    message = (struct IntuiMessage *) GetMsg(w->UserPort);
 }

#ifdef   MY_DEBUG
 fclose(dfp);
#endif

 close_things();
 exit(0);
}

clear_rect(rp , sx , sy , dx , dy)
struct RastPort *rp;
long sx,sy;
short dx,dy;
{
 ClipBlit(rp,sx,sy,rp,sx,sy,(long)dx,(long)dy,0x20L);
}

make_rotated_ball(b , degrees , cx , cy , length)
struct bouncer *b;
short degrees , cx , cy , length;
{
 int dx , dy;

 dx = length * sin(degrad(fabs((double)degrees)));
 dy = length * cos(degrad(fabs((double)degrees)));
 b->sx = cx + (degrees < 0 ? -dx : dx);
 b->sy = cy + dy;
 make_ball(&b->rp, RADIUS, RADIUS, (short)(b->sx-MW),
           (short)(WH-RADIUS-b->sy), 0);
 b->sx -= RADIUS;
 b->sy -= RADIUS;
}

close_things()
{
 if (rastcount) deallocate_rasters();
 if (mask & WINDOW)    CloseWindow(w);
 if (mask & SCREEN)    CloseScreen(s);
 if (mask & GRAPHICS)  CloseLibrary(GfxBase);
 OpenWorkBench();
 if (mask & INTUITION) CloseLibrary(IntuitionBase);
}

init_color_map()
{
 static short map_values[NMAP] = {
    /* format 0x0RGB */   /* ooooooooh ychhhhhh! fix this later! */
    /* 0  */  0x0430 ,
    /* 1  */  0x0FFF ,
    /* 2  */  0x0F01 ,
    /* 3  */  0x0F11 ,
    /* 4  */  0x0F12 ,
    /* 5  */  0x0F22 ,
    /* 6  */  0x0F23 ,
    /* 7  */  0x0F33 ,
    /* 8  */  0x0F34 ,
    /* 9  */  0x0F44 ,
    /* 10 */  0x0F45 ,
    /* 11 */  0x0F55 ,
    /* 12 */  0x0F56 ,
    /* 13 */  0x0F66 ,
    /* 14 */  0x0F67 ,
    /* 15 */  0x0F77 ,
    /* 16 */  0x0F78 ,
    /* 17 */  0x0F88 ,
    /* 18 */  0x0F89 ,
    /* 19 */  0x0F99 ,
    /* 20 */  0x0F9A ,
    /* 21 */  0x0FAA ,
    /* 22 */  0x0FAB ,
    /* 23 */  0x0FBB ,
    /* 24 */  0x0FBC ,
    /* 25 */  0x0FCC ,
    /* 26 */  0x0FCD ,
    /* 27 */  0x0FDD ,
    /* 28 */  0x0FDE ,
    /* 29 */  0x0FEE ,
    /* 30 */  0x0FEF ,
    /* 31 */  0x0FFF
};
 LoadRGB4(&s->ViewPort , map_values , (long)NMAP);
}

normalize(p)
struct point *p;
{
 double length;

 length = sqrt((p->x * p->x) + (p->y * p->y) + (p->z * p->z));
 p->x /= length;
 p->y /= length;
 p->z /= length;
}


make_ball(rp , basex , basey , cx , cy , cz)
struct RastPort *rp;
short basex, basey, cx, cy, cz;
{
 long I;
 int scanline;
 long x , y;
 struct point H , l;
 struct point pnt;
 double tmp , rad , d;


 rad = 1.0/RADIUS;

 basex -= RADIUS;
 basey -= RADIUS;
 l.x = light.x-(double)cx;  /* translate light source to */
 l.y = light.y-(double)cy;  /* make center of sphere the */
 l.z = light.z-(double)cz;  /* origin relative to light  */
 normalize(&l);

 for (scanline = 0; scanline < 2 * RADIUS; scanline++) {
    register short r;
    register short i;

    r = displacements[scanline];
    y = scanline + basey;
    pnt.y = (RADIUS - scanline) * rad;
    bres(r , surface);
    for (i = 0; i < 2 * r; i++) {
       pnt.x = (-r + i) * rad;
       pnt.z = surface[i] * rad;
       d = (pnt.z * l.z) + (pnt.y * l.y) + (pnt.x * l.x);
       I = AMBIENT;
       if (d > 0.0) {
          I += d * (NMAP - AMBIENT);
          H.x = l.x;
          H.y = l.y;
          H.z = l.z + 1.0;
          normalize(&H);
          /* reusing d */
          d = (H.x * pnt.x) + (H.y * pnt.y) + (H.z * pnt.z);
          d = pow(d, 12.0);
          if (d > 0.0)
     I += d * 12.0;
       }
       x = RADIUS - r + i + basex;
       if (I >= NMAP) I = NMAP - 1;
       SetAPen(rp , I);
       WritePixel(rp , x , y);
    }
 }
}

allocate_rasters()
{
 int i , j;
 void *AllocRaster();

 for (i = 0; i < NSTEPS; i++) {
    InitRastPort(&left[i].rp);
    InitRastPort(&right[i].rp);
    InitBitMap(&left[i].bm , DEPTH , DL , DL);
    InitBitMap(&right[i].bm , DEPTH , DL , DL);
    for (j = 0; j < DEPTH; j++) {
       left[i].bm.Planes[j] = AllocRaster(DL , DL);
       if (left[i].bm.Planes[j] == NULL) {
outer:      if (is_cli) printf("cannot allocate raster space\n");
          close_things();
          exit(1);
       }
       rastcount++;
       right[i].bm.Planes[j] = AllocRaster(DL , DL);
       if (right[i].bm.Planes[j] == NULL) goto outer;
       rastcount++;
    }
    left[i].rp.BitMap = &left[i].bm;
    right[i].rp.BitMap = &right[i].bm;
    SetRast(&left[i].rp , 0L);
    SetRast(&right[i].rp , 0L);
 }
}

deallocate_rasters()
{
 int i , j;

 for (i = 0; i < NSTEPS && rastcount >= 0; i++) {
    for (j = 0; j < DEPTH && rastcount >= 0; j++) {
       if (rastcount-- == 0) continue;
       FreeRaster(left[i].bm.Planes[j] , DL , DL);
       if (rastcount-- == 0) continue;
       FreeRaster(right[i].bm.Planes[j] , DL , DL);
    }
 }
}

/*
** b r e s . c
**
** perry s. kivolowitz - ihnp4!ptsfa!well!perry
**
** not to be distritbuted for commercial use. any distribution
** must included this notice, please.
**
** generate radial  displacements according to bresenham's circle
** algorithm. suitable for running twice, giving a fast spherical
** surface.
**
*/
 
bres(r , array)
register short *array;
register short r;
{
 register short x , y , d;
 
 x = 0;
 y = r;
 d = 3 - 2 * r;
 while (x < y) {
  *(array + r - y) = x;
  *(array + r - x) = y;
  *(array + r + y - 1) = x;
  *(array + r + x - 1) = y;
  if (d < 0) d += 4 * x + 6;
  else d += 4 * (x - y--) + 10;
  x++;
 }
 if (x == y) {
  *(array + r - y) = x;
  *(array + r + y - 1) = x;
 }
}


