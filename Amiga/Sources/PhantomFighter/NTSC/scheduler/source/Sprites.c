#include <graphics/view.h>
#include <exec/memory.h>

#include <graphics/sprite.h>
#include "view.h"
#include "sprites.h"

/* Use Sprites 0 to 5 */

#define MAXSPRITE 5

extern void *AllocMem();

SpriteDescriptor *FreeSpriteQ=NULL;

void AllocateSpriteList()
{
   FreeSpriteQ=AllocMem(sizeof(SpriteDescriptor)*(MAXSPRITE+2),MEMF_CLEAR);
   if(!FreeSpriteQ)
      DoAnAlert("AllocateSpriteList-F: No memory for spritelist");
}

void EmptyFreeSpriteList()
{
   int i;
   SpriteDescriptor *t;
   t=FreeSpriteQ;
   FreeSpriteQ->Q.flink=FreeSpriteQ->Q.blink=&t->Q;
   for(i=0;i<=MAXSPRITE;++i) {
      InsQue(FreeSpriteQ,++t);
      t->Sprite.num=i;
   }
}

SpriteDescriptor *AllocSprite()
{
   if(FreeSpriteQ->Q.flink==&FreeSpriteQ->Q)
      DoAlert("AllocSprite-F: No sprites left");
   return (SpriteDescriptor *)RemQue(FreeSpriteQ->Q.flink);
}

void Free_Sprite(Sprite)
SpriteDescriptor *Sprite;
{
   InsQue(&FreeSpriteQ->Q,&Sprite->Q);
}

UWORD SPR_BlankSprite[]={0,0};
UWORD SPR_AnotherBlankSprite[]={0,0};

extern UWORD *Copper;
extern UWORD MainCopper[];

void Change_Sprite(num,data)
UWORD num;
ULONG data;
{
  Copper[1+(num<<2)]=(UWORD)(data>>16);	/* High word */
  Copper[3+(num<<2)]=(UWORD)(data&0xffff); /* Low word */
}

void InitialiseSprites()
{
   WORD i;
   Copper=MainCopper;
   for(i=0;i<8;i++)
      Change_Sprite(i,SPR_AnotherBlankSprite);
   EmptyFreeSpriteList();
   
}

void Set_Spr_Color(num,c1,c2,c3)
UWORD num;
UWORD c1,c2,c3;
{
  register UWORD k;
  register UWORD *FC=Copper;
  k=((num&6)<<2);		/* Get Color Num *2 for later */
  FC+=k+32;		/* Offset to First Color 0*/
  FC[3]=c1;		/* Put in Copper LIST Color 1*/
  FC[5]=c2;		/* Put in Copper List Color 2*/
  FC[7]=c3;		/* Put in Copper List Color 3*/
}

void Move_Sprite(Sprite,pX,pY)
struct SimpleSprite *Sprite;
WORD pX,pY;
{
  register union {
     UWORD *SData;
     ULONG a;
  } Temp;
  register WORD H=Sprite->height;
  register WORD num=Sprite->num;
  register WORD X=pX;
  register WORD Y=pY;
  Temp.a=Copper[1+(num<<2)]<<16;	/* High word */
  Temp.a+=Copper[3+(num<<2)];		/* Low word */
  if(X<0||Y<0||X>VIEW_WIDTH||Y>VIEW_HEIGHT-H) {
     Temp.SData[0]=0;
     Temp.SData[1]=0;
     return;
  }
  X+=129;
  Y+=30;           
  Temp.SData[0]=((Y&0xff)<<8)+(X>>1);
  Temp.SData[1]=(((Y+H)&0xff)<<8)+((Y&0x100)>>6)+
           	    (((Y+H)&0x100)>>7)+(X&1);
}

void ClearMainSprites()
{
   int i;
   Copper=MainCopper;
   for(i=0;i<8;++i)
      Change_Sprite(i,SPR_BlankSprite);
}
