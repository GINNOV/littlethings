#include <exec/types.h>

#include "BulletData.h"

WORD BLT_Direction[4][2]={
   {  0,- 6},
   {  0, 6},
   {- 9,  0},
   {  9,  0}
};

BYTE BulletHeights[4]={16,16,16,16};

WORD Pow0_StartOffsets[][2]={
   {-2,-25},
   {-14,10},
   {-15,-14},
   {6,-1}
};

WORD Pow1_HitBox[][4]={
   { 0, 0, 3,15},
   {12, 4,15,15},
   { 0,12,15,15},
   { 0, 0,15, 3}
};

WORD Pow0_HitBox[][4]={
   { 0, 0, 3,15},
   {12, 4,15,15},
   { 0,12,15,15},
   { 0, 0,15, 3}
};

extern UWORD *UBulletShapes[];
extern UWORD *DBulletShapes[];
extern UWORD *LBulletShapes[];
extern UWORD *RBulletShapes[];

extern UWORD *UBulletShapes2[];
extern UWORD *DBulletShapes2[];
extern UWORD *LBulletShapes2[];
extern UWORD *RBulletShapes2[];

UWORD **Pow0_Shapes[4]={
   UBulletShapes,
   DBulletShapes,
   LBulletShapes,
   RBulletShapes
};

UWORD **Pow1_Shapes[4]={
   UBulletShapes2,
   DBulletShapes2,
   LBulletShapes2,
   RBulletShapes2
};

UWORD Pow0_Colors[]={
   3840,
   4032,
   4095,
};

UWORD Pow1_Colors[]={
   3840,
   4032,
   4095,
};

BulletDescriptor BulletTypes[]={
   {Pow0_StartOffsets,
    Pow0_HitBox,
    Pow0_Shapes,
    Pow0_Colors},
   {
    Pow0_StartOffsets,
    Pow1_HitBox,
    Pow1_Shapes,
    Pow1_Colors}
};

UWORD Sprite_BUpBullet[36]={
    0x0000,0x0000,
   0x4000, 0x0000,
   0xa000, 0x4000,
   0x5000, 0xe000,
   0xf000, 0xe000,
   0x5000, 0xe000,
   0x5000, 0xe000,
   0x1000, 0xe000,
   0x5000, 0xe000,
   0x1000, 0xe000,
   0xe000, 0x4000,
   0xa000, 0x4000,
   0x0000, 0x4000,
   0x4000, 0x0000,
   0x0000, 0x4000,
   0x4000, 0x0000,
   0x0000, 0x0000,
    0x0000,0x0000
};

UWORD Sprite_UpBullet[36]={
    0x0000,0x0000,
   0xe000, 0x0000,
   0x1000, 0xe000,
   0xf000, 0xe000,
   0x5000, 0xe000,
   0xa000, 0x4000,
   0xa000, 0x4000,
   0xa000, 0x4000,
   0x4000, 0x0000,
   0x0000, 0x4000,
   0x4000, 0x0000,
   0x4000, 0x0000,
   0x0000, 0x0000,
   0x4000, 0x0000,
   0x0000, 0x0000,
   0x4000, 0x0000,
   0x0000, 0x0000,
    0x0000,0x0000
};

UWORD Sprite_RoundBullet[16]={
  0x0000,0x0000,     
  0x7800,0x0000,	/* 011110 */
  0xfc00,0x7800,	/* 133331 */
  0xcc00,0x7800,	/* 132231 */
  0xcc00,0x7800,	/* 132231 */
  0xfc00,0x7800,	/* 133331 */
  0x7800,0x0000,	/* 011110 */
  0x0000,0x0000
};

UWORD SatelliteSprite[36]={
    0x0000,0x0000,
   0x9200, 0x8200,
   0x6c00, 0x1000,
   0x5400, 0x3800,
   0xba00, 0x7c00,
   0x5400, 0x3800,
   0x6c00, 0x1000,
   0x9200, 0x8200,
   0x0000, 0x0000
};

