#ifndef _AWINGCCSTUBS_H
#define _AWINGCCSTUBS_H

/* this stuff don't need to be ppc aligned.
   if you're including these with ppc you're lost already... */

struct bltbitmapargs {
  WORD srcx,srcy,dstx,dsty,sizex,sizey,minterm,mask;
  struct BitMap *srcbm,*dstbm;
  UWORD *tempa;
  struct Library *base;
};

struct scalepixelarrayargs {
  UWORD srcw,srch,srcmod,dstx,dsty,dstw,dsth,srcf;
  APTR srcrect;
  struct RastPort *rastport;
  struct Library *base;
};

struct readpixelarrayargs {
  UWORD dstx,dsty,destmod,srcx,srcy,sizex,sizey,destf;
  APTR destrect;
  struct RastPort *rastport;
  struct Library *base;
};

struct writepixelarrayargs {
  WORD srcx,srcy,srcmod,dstx,dsty,sizex,sizey,srcf;
  APTR srcrect;
  struct RastPort *rastport;
  struct Library *base;
};

struct writelutpixelarrayargs {
  WORD srcx,srcy,srcmod,dstx,dsty,sizex,sizey,ctabf;
  APTR srcrect;
  struct RastPort *rastport;
  APTR ctable;
  struct Library *base;
};

#ifdef __GNUC__

ULONG bltbitmap(struct bltbitmapargs *args __asm("a0"));
LONG scalepixelarray(struct scalepixelarrayargs *args __asm("a0"));
LONG readpixelarray(struct readpixelarrayargs *args __asm("a0"));
LONG writepixelarray(struct writepixelarrayargs *args __asm("a0"));
LONG writelutpixelarray(struct writelutpixelarrayargs *args __asm("a0"));

#endif /* __GNUC__ */


#ifdef __SASC

ULONG __asm bltbitmap(register __a0 struct bltbitmapargs *args);
LONG __asm scalepixelarray(register __a0 struct scalepixelarrayargs *args);
LONG __asm readpixelarray(register __a0 struct readpixelarrayargs *args);
LONG __asm writepixelarray(register __a0 struct writepixelarrayargs *args);
LONG __asm writelutpixelarray(register __a0 struct writelutpixelarrayargs *args);

#endif /* __SASC */


#endif /* _AWINGCCSTUBS_H */
