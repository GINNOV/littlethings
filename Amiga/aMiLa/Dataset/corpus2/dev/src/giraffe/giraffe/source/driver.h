#ifndef DRIVER_H
#define DRIVER_H

/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: driver.h                                */
/*    |< |          RTG interface definitions                 */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

/* header file to map to EGS commands. */

#include <egs/egs.h>
#include <egs/proto/egs.h>
#include <egs/proto/egsblit.h>

typedef E_EBitMapPtr BitMapPtr;

#define g_AllocBitMap(w,h,d,f) (E_AllocBitMap(w,h,d,(f)->Type,E_EB_CLEARMAP,(f)))
#define g_FreeBitMap(map) (E_DisposeBitMap(map))
#define g_AllocMask(w,h,fr) (E_AllocBitMap(w,h,1,E_BITPLANEMAP,E_EB_CLEARMAP,fr))
#define g_FreeMask(mask)  (E_DisposeBitMap(mask))
#define g_Width(map)      ((map)->Width)
#define g_Height(map)     ((map)->Height)
#define g_Depth(map)      ((map)->Depth)
#define g_Bounds(map,rect)   ((rect).min.xy=0, \
                              (rect).max.coor.x = (map)->Width-1, \
                              (rect).max.coor.y = (map)->Height-1)

#define g_SetPixel(map,c,x,y)      EB_WritePixel((map),(c),(x),(y),NULL)
#define g_Rectangle(map,c,l,t,w,h) EB_RectangleFill((map),(c),(l),(t),(w),(h),NULL)

#define g_FillPolygon(map,xy,count,w,h) ((((w)==1)&&((h)==1))?EB_WritePixel((map),1,0,0,NULL):EB_BitAreaPolygon((map),(EB_PolygonPtr)(xy),(count),(w),(h)))
#define g_Line(map,c,x1,y1,x2,y2) EB_Draw(map,c,x1,y1,x2,y2,NULL)
#define g_BitBlt(dst,l,t,w,h,src,sx,sy,term) EB_BitBlt(src,dst,sx,sy,w,h,l,t,term)
#define g_Copy(dst,l,t,w,h,src,sx,sy) EB_CopyBitMap(src,dst,sx,sy,w,h,l,t,NULL)

#define g_Message union
#define g_EndMessage msg;

#define g_PixelMsg      struct E_PixelMsg      pixel
#define g_RectangleMsg  struct E_RectFillMsg   rect
#define g_CopyMsg       struct E_CopyBitMapMsg copy
#define g_StencilMsg    struct E_RectFillMsg   stencil
#define g_StencilPattMsg struct E_RectFillMsg  spatt
#define g_BitBltMsg     struct E_BitBltMsg     blit
#define g_UnpackMsg     struct { \
                          struct E_UnpackMsg body; \
                          struct E_Image     image; \
			       }unpack
#define g_PixelMsgPrep(pen)   msg.pixel.Color = pen
#define g_RectangleMsgPrep(c1,c2) (msg.rect.Front = (c1), \
                                  msg.rect.Back  = (c2), \
                                  msg.rect.Mask  = NULL,  \
                                  msg.rect.MPatt = NULL, \
                                  msg.rect.Patt  = NULL)
#define g_StencilMsgPrep(map,c1,c2)   (msg.stencil.Mask  = (map), \
                                      msg.stencil.MPatt = NULL, \
                                      msg.stencil.Patt  = NULL, \
                                      msg.stencil.Front = (c1), \
                                      msg.stencil.Back  = (c2))

#define g_StencilPattMsgPrep(src,mask) (msg.spatt.Mask  = (mask), \
                                       msg.spatt.MPatt = (src), \
                                       msg.spatt.Patt  = NULL, \
                                       msg.spatt.Front = 0,   \
                                       msg.spatt.Back  = 0)

#define g_CopyMsgPrep(src) (msg.copy.Src = (src))
#define g_BitBltMsgPrep(src,terms,mask)   (msg.blit.Src = (src),     \
                                     msg.blit.Terms = (terms), \
                                     msg.blit.Mask  = (mask),      \
                                     msg.blit.Pad0  = NULL)
#define g_UnpackMsgPrep(raw,w,h,d,colors) (msg.unpack.body.Colors = (colors), \
                                          msg.unpack.body.Image  = &msg.unpack.image, \
                                          msg.unpack.image.Width = (w), \
                                          msg.unpack.image.Height = (h), \
                                          msg.unpack.image.Depth = 1, \
                                          msg.unpack.image.Pad = 0, \
                                          msg.unpack.image.Planes[0] = (raw))

#define g_PixelMsgSend(dst,x,y) (msg.pixel.Map = (dst), \
                                msg.pixel.X   = (x),   \
                                msg.pixel.Y   = (y),   \
                                E_Dispatch((dst),g_PixelMsgName,(E_EGSObjMsgPtr)&msg))
#define g_RectangleMsgSend(dst,l,t,w,h) (msg.rect.Map  = (dst), \
                                        msg.rect.Dx    = (l),  \
                                        msg.rect.Dy    = (t),  \
                                        msg.rect.W     = (w),  \
                                        msg.rect.H     = (h),  \
                                        E_Dispatch(dst,g_RectangleMsgName,(E_EGSObjMsgPtr)&msg))

#define g_CopyMsgSend(dst,l,t,w,h,sx,sy) (msg.copy.Dst = (dst), \
                                         msg.copy.Dx  = (l),   \
                                         msg.copy.Dy  = (t),   \
                                         msg.copy.W   = (w),   \
                                         msg.copy.H   = (h),   \
                                         msg.copy.Sx  = (sx),  \
                                         msg.copy.Sy  = (sy),  \
                                         E_Dispatch(dst,g_CopyMsgName,(E_EGSObjMsgPtr)&msg))

#define g_StencilMsgSend(dst,l,t,w,h,sx,sy) (msg.stencil.Map = (dst), \
                                         msg.stencil.Dx  = (l),   \
                                         msg.stencil.Dy  = (t),   \
                                         msg.stencil.W   = (w),   \
                                         msg.stencil.H   = (h),   \
                                         msg.stencil.Sx  = (sx),  \
                                         msg.stencil.Sy  = (sy),  \
                                         E_Dispatch((dst),(msg.stencil.Back==-1?g_StencilMsgName:g_Stencil2MsgName),(E_EGSObjMsgPtr)&msg))

#define g_StencilPattMsgSend(dst,l,t,w,h,sx,sy,mx,my) (msg.spatt.Map = (dst), \
                                         msg.spatt.Dx  = (l),   \
                                         msg.spatt.Dy  = (t),   \
                                         msg.spatt.W   = (w),   \
                                         msg.spatt.H   = (h),   \
                                         msg.spatt.Sx  = (mx),  \
                                         msg.spatt.Sy  = (my),  \
                                         msg.spatt.Ox  = (sx),  \
                                         msg.spatt.Oy  = (sy),  \
                                         E_Dispatch(dst,g_StencilPattMsgName,(E_EGSObjMsgPtr)&msg))
#define g_BitBltMsgSend(dst,l,t,w,h,sx,sy) (msg.blit.Dst = (dst), \
                                           msg.blit.Dx  = (l),   \
                                           msg.blit.Dy  = (t),   \
                                           msg.blit.W   = (w),   \
                                           msg.blit.H   = (h),   \
                                           msg.blit.Sx  = (sx),  \
                                           msg.blit.Sy  = (sy),  \
                                           E_Dispatch((dst),g_BitBltMsgName,(E_EGSObjMsgPtr)&msg))
#define g_UnpackMsgSend(map) (msg.unpack.body.Map = (map), \
                             E_Dispatch((map),g_UnpackMsgName,(E_EGSObjMsgPtr)&msg))

#define g_PixelMsgId       0
#define g_RectangleMsgId   1
#define g_CopyMsgId        2
#define g_StencilMsgId     3
#define g_Stencil2MsgId    4
#define g_StencilPattMsgId 5
#define g_BitBltMsgId      6
#define g_UnpackMsgId      7
#define g_SelCount         8
extern E_Symbol g_Selectors[];
#define g_PixelMsgName        (g_Selectors[g_PixelMsgId])
#define g_RectangleMsgName    (g_Selectors[g_RectangleMsgId])
#define g_CopyMsgName         (g_Selectors[g_CopyMsgId])
#define g_StencilMsgName      (g_Selectors[g_StencilMsgId])
#define g_Stencil2MsgName     (g_Selectors[g_Stencil2MsgId])
#define g_StencilPattMsgName  (g_Selectors[g_StencilPattMsgId])
#define g_BitBltMsgName       (g_Selectors[g_BitBltMsgId])
#define g_UnpackMsgName       (g_Selectors[g_UnpackMsgId])


#endif
