#ifndef CLIP_H
#define CLIP_H
/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: clip.h                                  */
/*    |< |      created: June 14,1995                         */
/*    \_/|     version 1.0                                    */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <graphics/text.h>

#include <egs/egs.h>
#include <egs/egsblit.h>

#include "common.h"

/* flag bits for Cohen-Sutherland line clipping. */
#define OUTSIDE_LEFT   1
#define OUTSIDE_TOP    2
#define OUTSIDE_RIGHT  4
#define OUTSIDE_BOTTOM 8

struct cliprect {
  struct cliprect *next,*next_bitmap;
  E_EBitMapPtr     bitmap;
  union  point     origin;
  struct rectangle bounds;
};


struct cliplist {
  SHORT usecount;
  USHORT pad;
  struct cliprect *list;
};

#endif /* clip.h */

