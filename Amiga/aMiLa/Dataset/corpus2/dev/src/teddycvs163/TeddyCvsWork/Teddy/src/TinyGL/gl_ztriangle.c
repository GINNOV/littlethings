#include <stdlib.h>
#include "TinyGL/gl_zbuffer.h"

#define ZCMP(z,zpix) ((z) >= (zpix))

void ZB_fillTriangleFlat( ZBuffer *zb, ZBufferPoint *p0,ZBufferPoint *p1, ZBufferPoint *p2 ){
	int color;

#define INTERP_Z

#define DRAW_INIT()                      \
{                                        \
  color=RGB_TO_PIXEL(p2->r,p2->g,p2->b); \
}
  
#define PUT_PIXEL(_a)              \
{                                  \
    zz=z >> ZB_POINT_Z_FRAC_BITS;  \
    if (ZCMP(zz,pz[_a])) {         \
      pp[_a]=color;                \
      pz[_a]=zz;                   \
    }                              \
    z+=dzdx;                       \
}

#define DRAW_LINE()				\
{						\
  register unsigned short *pz;  \
  register PIXEL *pp;           \
  register unsigned int z,zz;   \
  register int n;               \
  n=(x2 >> 16) - x1;            \
  pp=pp1+x1;                    \
  pz=pz1+x1;                    \
  z=z1;                         \
  while (n>=3) {                \
    PUT_PIXEL(0);               \
    PUT_PIXEL(1);               \
    PUT_PIXEL(2);               \
    PUT_PIXEL(3);               \
    pz+=4;                      \
    pp+=4;                      \
    n-=4;                       \
  }                             \
  while (n>=0) {                \
    PUT_PIXEL(0);               \
    pz+=1;                      \
    pp+=1;                      \
    n-=1;                       \
  }                             \
}
  
#include "TinyGL/gl_ztriangle.h"

#undef PUT_PIXEL
}

/*
 * Smooth filled triangle.
 * The code below is very tricky :)
 */

void ZB_fillTriangleSmooth( ZBuffer *zb, ZBufferPoint *p0, ZBufferPoint *p1, ZBufferPoint *p2 ){
	int _drgbdx;

#define INTERP_Z
#define INTERP_RGB

#define SAR_RND_TO_ZERO(v,n) (v / (1<<n))

#define DRAW_INIT() 				\
{						\
  _drgbdx=(SAR_RND_TO_ZERO(drdx,6) << 22) & 0xFFC00000;		\
  _drgbdx|=SAR_RND_TO_ZERO(dgdx,5) & 0x000007FF;		\
  _drgbdx|=(SAR_RND_TO_ZERO(dbdx,7) << 12) & 0x001FF000; 	\
}


#define PUT_PIXEL(_a)				\
{						\
    zz=z >> ZB_POINT_Z_FRAC_BITS;		\
    if (ZCMP(zz,pz[_a])) {				\
      tmp=rgb & 0xF81F07E0;			\
      pp[_a]=tmp | (tmp >> 16);			\
      pz[_a]=zz;				\
    }						\
    z+=dzdx;					\
    rgb=(rgb+drgbdx) & ( ~ 0x00200800);		\
}


#define DRAW_LINE()							   \
{									   \
  register unsigned short *pp,*pz;					   \
  register unsigned int tmp,z,zz,rgb,drgbdx;				   \
  register int n;							   \
  n=(x2 >> 16) - x1;							   \
  pp=pp1+x1;								   \
  pz=pz1+x1;								   \
  z=z1;									   \
  rgb=(r1 << 16) & 0xFFC00000;						   \
  rgb|=(g1 >> 5) & 0x000007FF;						   \
  rgb|=(b1 << 5) & 0x001FF000;						   \
  drgbdx=_drgbdx;							   \
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
    pp+=4;								   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    pp+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "TinyGL/gl_ztriangle.h"

#undef PUT_PIXEL
}

void ZB_setTexture(ZBuffer *zb,unsigned short *texture)
{
  zb->current_texture=texture;
}

void ZB_fillTriangleMapping(ZBuffer *zb,
			    ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned short *texture;

#define INTERP_Z
#define INTERP_ST

#define DRAW_INIT()				\
{						\
  texture=zb->current_texture;			\
}

#define PUT_PIXEL(_a)				\
{						\
   zz=z >> ZB_POINT_Z_FRAC_BITS;		\
     if (ZCMP(zz,pz[_a])) {				\
       pp[_a]=texture[((t & 0x3FC00000) | s) >> 14];	\
       pz[_a]=zz;				\
    }						\
    z+=dzdx;					\
    s+=dsdx;					\
    t+=dtdx;					\
}

#define DRAW_LINE()				\
{						\
  register unsigned short *pp,*pz;		\
  register unsigned int s,t,z,zz;		\
  register int n;		\
  n=(x2>>16)-x1;                             \
  pp=pp1+x1;					\
  pz=pz1+x1;					\
  z=z1;						\
  s=s1;                                         \
  t=t1;						\
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
    pp+=4;								   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    pp+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "TinyGL/gl_ztriangle.h"

#undef PUT_PIXEL
}
/*
 * Texture mapping with perspective correction.
 * We use the gradient method to make less divisions.
 * TODO: pipeline the division
 */
#if 1

void ZB_fillTriangleMappingPerspective(ZBuffer *zb,
                            ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned short *texture;
  float fdzdx,fndzdx,ndszdx,ndtzdx;

#define INTERP_Z
#define INTERP_STZ

#define NB_INTERP 8

#define DRAW_INIT()				\
{						\
  texture=zb->current_texture;\
  fdzdx=(float)dzdx;\
  fndzdx=NB_INTERP * fdzdx;\
  ndszdx=NB_INTERP * dszdx;\
  ndtzdx=NB_INTERP * dtzdx;\
}


#define PUT_PIXEL(_a)                                           \
{                                                               \
   zz=z >> ZB_POINT_Z_FRAC_BITS;                                \
   if (ZCMP(zz,pz[_a])) {                                       \
       pp[_a]=*(signed short *)((char *)texture+                \
               (((t & 0x3FC00000) | (s & 0x003FC000)) >> 13));  \
       pz[_a]=zz;   \
   }                \
    z+=dzdx;        \
    s+=dsdx;        \
    t+=dtdx;        \
}

#define DRAW_LINE()				\
{						\
  register unsigned short *pp,*pz;		\
  register unsigned int s,t,z,zz;	\
  register int n,dsdx,dtdx;		\
  float sz,tz,fz,zinv; \
  n   =(x2>>16)-x1;                             \
  fz  =(float)z1;\
  zinv=1/fz;\
  pp  =pp1+x1;					\
  pz  =pz1+x1;					\
  z   =z1;						\
  sz  =sz1;\
  tz  =tz1;\
  while (n>=(NB_INTERP-1)) {						   \
    {\
      float ss,tt;\
      ss  =(sz * zinv);\
      tt  =(tz * zinv);\
      s   =(int) ss;\
      t   =(int) tt;\
      dsdx= (int)( (dszdx - ss*fdzdx)*zinv );\
      dtdx= (int)( (dtzdx - tt*fdzdx)*zinv );\
      fz  +=fndzdx;\
      zinv=1/ fz;\
    }\
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    PUT_PIXEL(4);							   \
    PUT_PIXEL(5);							   \
    PUT_PIXEL(6);							   \
    PUT_PIXEL(7);							   \
    pz+=NB_INTERP;							   \
    pp+=NB_INTERP;							   \
    n-=NB_INTERP;							   \
    sz+=ndszdx;\
    tz+=ndtzdx;\
  }									   \
    {\
      float ss,tt;\
      ss=(sz * zinv);\
      tt=(tz * zinv);\
      s=(int) ss;\
      t=(int) tt;\
      dsdx= (int)( (dszdx - ss*fdzdx)*zinv );\
      dtdx= (int)( (dtzdx - tt*fdzdx)*zinv );\
    }\
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    pp+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "TinyGL/gl_ztriangle.h"

#undef PUT_PIXEL
}

#endif

#if 0

/* version correcte */

void ZB_fillTriangleMappingPerspective(ZBuffer *zb,
                            ZBufferPoint *p0,ZBufferPoint *p1,ZBufferPoint *p2)
{
  unsigned short *texture;

#define INTERP_Z
#define INTERP_STZ

#define DRAW_INIT()				\
{						\
  texture=zb->current_texture;			\
}

#define PUT_PIXEL(_a)				\
{						\
   float zinv; \
   int s,t; \
   zz=z >> ZB_POINT_Z_FRAC_BITS;		\
     if (ZCMP(zz,pz[_a])) {				\
       zinv= 1.0 / (float) z; \
       s= (int) (sz * zinv); \
       t= (int) (tz * zinv); \
       pp[_a]=texture[((t & 0x3FC00000) | s) >> 14];	\
       pz[_a]=zz;				\
    }						\
    z+=dzdx;					\
    sz+=dszdx;					\
    tz+=dtzdx;					\
}

#define DRAW_LINE()				\
{						\
  register unsigned short *pp,*pz;		\
  register unsigned int z,zz;		\
  register int n;		\
  float sz,tz; \
  n=(x2>>16)-x1;                             \
  pp=pp1+x1;					\
  pz=pz1+x1;					\
  z=z1;						\
  sz=sz1;                                         \
  tz=tz1;						\
  while (n>=3) {							   \
    PUT_PIXEL(0);							   \
    PUT_PIXEL(1);							   \
    PUT_PIXEL(2);							   \
    PUT_PIXEL(3);							   \
    pz+=4;								   \
    pp+=4;								   \
    n-=4;								   \
  }									   \
  while (n>=0) {							   \
    PUT_PIXEL(0);							   \
    pz+=1;								   \
    pp+=1;								   \
    n-=1;								   \
  }									   \
}
  
#include "TinyGL/gl_ztriangle.h"

#undef PUT_PIXEL
}


#endif
