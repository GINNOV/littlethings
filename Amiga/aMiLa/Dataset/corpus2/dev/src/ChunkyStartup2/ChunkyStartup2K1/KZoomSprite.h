#ifndef K_ZOOMSPRITE_H
#define K_ZOOMSPRITE_H
/*==========================================================*/
/*====                                                  ====*/
/*====                                                  ====*/
/*====      KZoomSprite.h => KZoomSprite.o handler      ====*/
/*====      krabob@online.fr 5/04/2001                  ====*/
/*====                                                  ====*/
/*====                                                  ====*/
/*==========================================================*/
/*
    short .o containing functions to zoom 8bit
    rectangle chunky source in another.

    This .h was designed for vbcc (68k) that means
    the primitives use the __reg("d0") syntax to notify
    what argument use what register:
    This syntax is not the same for other compiler
    -> just change that to fit your compiler.

*/

/* Amiga-Standard Types */
#include    <exec/types.h>
#include    "RenderContext.h"
/*==========================================================*/
/*====                                                  ====*/
/*====      KZoomSprite8bit68K                          ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  void    KZoomSprite8bit68K( __reg("d0") int x1,
                                    __reg("d1") int y1,
                                    __reg("d2") int x2,
                                    __reg("d3") int y2,
                                    __reg("a0") struct ScreenRenderContext *SRC,
                                    __reg("a1") struct TextureContext      *TCT
                                    );
/*

    x1,y1
      +------+
      |      |
      +------+
           x2,y2

 This rectangle coordinates represent in PIXEL
 the position of the sprite rectangle in the screen.
 you can exchange x1 with x2, y1 with y2, the texture will FLIP.

 But this rectangle is CLIPPED by the rendercontext rectangle:
 (the pixel out are not drawn. ) -> see RenderContext.h

 src_ClipX1,src_ClipY1
           +-------------------------+
           |x1,y1                    |
           |  +-----+                |
           |  |     |                |
           |  +-----+                |
           |      x1,y2              |
           +-------------------------+
                           src_ClipX2,src_ClipY2

 TextureContext's rectangle  ttc_U1,ttc_V1,ttc_U2,ttc_V2
 stand for the corresponding rectangle ON the texture.
 this last coordinates are multiplicated by 65536
 (or shifted left by 16:  <<16 .Trick known as "fixed coma").

 EVERY DATA in ScreenRenderContext,TextureContext must be FILLED.

*/

#endif  /* K_ZOOMSPRITE_H */

