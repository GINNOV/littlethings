#ifndef GIRAFFE_PROTO
#define GIRAFFE_PROTO

#include <giraffe.h>

void G_Pixel( G_Drawable, struct G_GC *, LONG x, LONG y );
void G_Line( G_Drawable, struct G_GC *, LONG x1, LONG y1, LONG x2, LONG y2 );
void G_Rectangle( G_Drawable, struct G_GC *, LONG left, LONG top, ULONG width, ULONG height );
void G_RectangleFill( G_Drawable, struct G_GC *, LONG left, LONG top, ULONG width, ULONG height );
void G_Polygon( G_Drawable, struct G_GC *, union G_Point *, SHORT );
void G_Arc( G_Drawable, struct G_GC *, LONG, LONG, ULONG, ULONG, LONG, LONG );
void G_Wedge( G_Drawable, struct G_GC *, LONG, LONG, ULONG, ULONG, LONG, LONG );
void G_Spline( G_Drawable, struct G_GC *, G_PointPtr );

void G_Blit( G_Drawable, struct G_GC *, LONG, LONG, ULONG, ULONG, G_BitMapPtr, LONG, LONG );
void G_BlitMask( G_Drawable, struct G_GC *, LONG, LONG, ULONG, ULONG, G_BitMapPtr, LONG, LONG, G_BitMapPtr, LONG, LONG );
void G_Template( G_Drawable, struct G_GC *, LONG, LONG, ULONG, ULONG, G_BitMapPtr, LONG, LONG );

G_Font G_OpenFont( STRPTR, ULONG );
void G_CloseFont( G_Font );
void G_Text( G_Font, G_Drawable, struct G_GC *, LONG, LONG, STRPTR, LONG );
ULONG G_TextLength( G_Font, struct G_GC *, STRPTR, LONG );
ULONG G_JustifyText( G_Font, struct G_GC *, STRPTR, LONG, ULONG, ULONG, ULONG );
void G_ClearSwath( G_Font, G_Drawable, struct G_GC *, LONG, LONG );

G_Layer G_OpenRootLayer( G_BitMapPtr, struct TagItem * );
G_Layer G_OpenLayer( G_Layer, struct TagItem * );
G_Layer G_OpenOverlay( G_Layer, LONG, LONG, ULONG, ULONG, struct TagItem * );
void G_CloseLayer( G_Layer );
G_Layer G_UseLayer( G_Layer );
void G_DropLayer( G_Layer );
G_Layer G_OwnLayer( G_Layer );
G_Layer G_DisownLayer( G_Layer );

void G_LockLayer( G_Layer );
void G_UnlockLayer( G_Layer );
void G_LockLayers( G_Layer );
void G_UnlockLayers(G_Layer );

BOOL G_MapLayer( G_Layer );
void G_UnmapLayer( G_Layer );
void G_PushLayer( G_Layer );
void G_PullLayer( G_Layer );
void G_CycleLayer( G_Layer );
void G_SizeLayer( G_Layer, ULONG, ULONG );
void G_MoveLayer( G_Layer, LONG, LONG );
void G_MoveSizeLayer( G_Layer, LONG, LONG, ULONG, ULONG );
void G_G_RefreshLayer( G_Layer );

G_Layer G_WhichLayer( G_Layer, union G_Point * );
BOOL G_BeginUpdate( G_Layer );
void G_EndUpdate( G_Layer );
ULONG G_LayerRelative( G_Layer, union G_Point * );

G_Layer G_GetLayerParent( G_Layer );
G_BitMapPtr G_GetLayerBitMap( G_Layer );
BOOL G_GetLayerOrigin( G_Layer, union G_Point *, BOOL );
ULONG G_GetLayerSize( G_Layer );
BOOL G_GetLayerFrame( G_Layer, struct G_Frame *, BOOL );
BOOL G_GetLayerBounds( G_Layer, struct G_Rectangle * );
ULONG G_GetLayerMinimum( G_Layer );

G_Layer G_GetLayerHead( G_Layer );
G_Layer G_GetLayerTail( G_Layer );
G_Layer G_GetLayerNext( G_Layer );
G_Layer G_GetLayerPrev( G_Layer );

UBYTE G_GetLayerId( G_Layer );

G_Region G_NewRegion( struct G_Rectangle * );
void G_DisposeRegion( void );
G_Region G_CopyRegion( G_Region );
G_Region G_ConcatRegions( G_Region, G_Region );
void G_ClearRegion( G_Region );
void G_AndRectRegion( G_Region, struct G_Rectangle * );
void G_AndRegionRegion( G_Region, G_Region );
void G_ClearRectRegion( G_Region, struct G_Rectangle * );
void G_ClearRegionRegion( G_Region, G_Region );
void G_OrRectRegion( G_Region, struct G_Rectangle * );
void G_OrRegionRegion( G_Region, G_Region );
void G_XorRectRegion( G_Region, struct G_Rectangle * );
void G_XorRegionRegion( G_Region, G_Region );

G_Stack G_NewStack( ULONG *, struct TagItem * );
void G_DisposeStack( G_Stack );
G_Stack G_UseStack( G_Stack );
void G_Interpret( G_Drawable, G_Stack );
void G_InterpretArg( G_Drawable, G_Stack, ULONG arg );
void G_InterpretArgArg( G_Drawable, G_Stack, ULONG arg1, ULONG arg2 );
void G_InterpretArgArgArg( G_Drawable, G_Stack, ULONG arg1, ULONG arg2, ULONG arg3 );

#endif /* giraffe_protos.h */
