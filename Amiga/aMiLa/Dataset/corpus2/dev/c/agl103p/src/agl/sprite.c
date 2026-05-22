/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: sprite.c,v 1.2.1.3 1994/12/09 05:29:56 jason Exp $

$Log: sprite.c,v $
 * Revision 1.2.1.3  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.2  1994/11/16  06:29:47  jason
 * added NOT_EXTERN check
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:22  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

#define SPRITESPACE	4
#define SPRITELINES	7

struct SimpleSprite MouseSprite;

UBYTE *SpriteChip;

UBYTE SpriteData[SPRITESPACE*SPRITELINES]=
	{
	0,0, 0,0,	/* position,control */

	0x20,0x00,0x00,0x00,
	0x20,0x00,0x00,0x00,
	0xF8,0x00,0x00,0x00,
	0x20,0x00,0x00,0x00,
	0x20,0x00,0x00,0x00,

	0,0, 0,0,	/* end */
	};

long SpriteID= -1;



/******************************************************************************
void	create_mousesprite(void)

******************************************************************************/
/*PROTOTYPE*/
void create_mousesprite(void)
	{
	SpriteChip=AllocMem(SPRITESPACE*SPRITELINES,MEMF_CHIP);
	memcpy(SpriteChip,SpriteData,SPRITESPACE*SPRITELINES);

	SpriteID=GetSprite(&MouseSprite,3);
	if(SpriteID!=3)
		{
		GL_error("Error creating mouse sprite");
		SpriteID= -1;
		return;
		}

	MouseSprite.height=SPRITELINES-2;

	SetRGB4(GLView,21,15,0,0);
	SetRGB4(GLView,22,0,15,0);
	SetRGB4(GLView,23,0,0,15);

	ChangeSprite(GLView,&MouseSprite,SpriteChip);
	printf("Sprite Created\n");

	move_mousesprite(0,0);
	}


/******************************************************************************
void	move_mousesprite(long mx,long my)

******************************************************************************/
/*PROTOTYPE*/
void move_mousesprite(long mx,long my)
	{
	static long lastx= -1,lasty= -1;

	if(mx!=lastx || my!=lasty)
		{
		WaitBOVP(GLView);
		MoveSprite(GLView,&MouseSprite,mx-6,GLScreen->Height-my-5);
/* 		printf("Sprite Moved %d %d\n",mx,my); */

		lastx=mx;
		lasty=my;
		}
	}


/******************************************************************************
void	free_mousesprite(void)

******************************************************************************/
/*PROTOTYPE*/
void free_mousesprite(void)
	{
	FreeSprite(SpriteID);
	FreeMem(SpriteChip,SPRITESPACE*SPRITELINES);
	printf("Sprite Freed\n");
	}
