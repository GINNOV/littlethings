#include "game.h"
#include "JoyStick.h"
#include "sort.h"
#include "sine.h"

/* -------------------------------------------------------------------- */
extern byte walls[8][65][2];

word INPUTMETHOD, FIN;

struct BLOCKTYPE Level_One[ NbrBlocks+1 ] =
{
	{ 1,1,2,1, NORTH,NULL},
	{ 0,0,3,1, NORTH,NULL},
	{ 0,0,4,1, NORTH,NULL},
	{ 1,1,5,2, WEST,NULL},
	{ 0,0,5,3, WEST,NULL},
	{ 0,0,4,4, WEST|SOUTH|NORTH,NULL},
	{ 1,1,5,5, WEST,NULL},
	{ 0,0,5,6, WEST,NULL},
	{ 0,0,5,7, WEST,NULL},
	{ 1,1,4,8, SOUTH,NULL},
	{ 0,0,3,7, WEST|EAST|SOUTH,NULL},
	{ 0,0,2,8, SOUTH,NULL},
	{ 1,1,1,7, EAST,NULL},
	{ 0,0,1,6, EAST,NULL},
	{ 0,0,1,5, EAST,NULL},
	{ 0,1,2,4, EAST|SOUTH|NORTH,NULL},
	{ 0,0,1,3, EAST,NULL},
	{ 0,0,1,2, EAST,NULL},
	{ 1,1,3,4, DOOR|NORTH|SOUTH,NULL},
};

struct DOORTYPE myDoor;
struct PLAYER player1 = { 0,0,0,0,0,0 };
struct xBUFFTYPE xBUFFER[DISPLAY_WIDTH];
word zBUFFER[NbrBlocks + NbrObjects][2];



/* ------------------  I N T E R N A L   R O U T I N E S  ----------------- */

void WOLF3D( void );

/* ------------------------------------------------------------------------ */

void WOLF3D(void)
{
    register word index;
    
    word count;    
    unsigned long frame = 0,start,seconds;
    unsigned int clock[2];
  
    
    /* ------------------------------------------------------------------ */
    /* PRE-GAME INITIALIZATION                                            */
    /* ------------------------------------------------------------------ */

    COSINE = &SINE[90*2];

    INPUTMETHOD = JOYSTICK;
    FIN = 0;
        
    timer(clock);
    start = clock[0];

    /* Initialize level one's blocks to the proper coordinates (i*64) */
        
    for(index = 0; index < NbrBlocks; index++)
    {
	Level_One[index].x *= 64;
	Level_One[index].z *= 64;
    };

/* ---------------------------------------- */
    
    /* Setup the playing display. Ie: its initial graphics */
    
    SetAPen(RASTPORT,13);
    RectFill(RASTPORT,0,0,DISPLAY_WIDTH-1,DISPLAY_HEIGHT-1);


    player1.X = (long)(128) << FFPBitSize; /* Set the player start coords at 2,2 */
    player1.Z = (long)(128) << FFPBitSize;
    player1.Xcopy = (word)(player1.X >> FFPBitSize);
    player1.Zcopy = (word)(player1.Z >> FFPBitSize);
    
//  CreateDoorList();
//  CreateNpcList();

    /*-------------------------
    Object[0].ShipDefn = &Cube;
    Object[0].center[0] = 192;
    Object[0].center[1] = 0;
    Object[0].center[2] = 64;
    Object[0].attitude = 0;
    -------------------------*/
    
    
    /* ---------------------------------------------------------------- */
    /* MAIN GAME LOOP							*/
    /* ---------------------------------------------------------------- */

    while(! FIN  )
    {
	/* ------------------------------------------------------------ */
	/* TRANSFORM WORLD BLOCKS AND OBJECTS				*/
	/* ------------------------------------------------------------ */
	
	TransformBlocks( &player1 );
// 	TransformObjects( &player1 );

	
	/* ------------------------------------------------------------ */
	/* CREATE AND SORT THE ZDEPTHBUFFER				*/
	/* ------------------------------------------------------------ */

	count = CreateZbuffer();
	SORTWORLD(zBUFFER, count);


	/* ------------------------------------------------------------ */
	/* CREATE THE XIMAGEBUFFER					*/
	/* ------------------------------------------------------------ */

	CreateXbuffer(count);


	/* ------------------------------------------------------------ */
	/* RENDER THE WORLD AND OBJECTS INTO THE FRAMEBUFFER		*/
	/* ------------------------------------------------------------ */

	AsmClearBackground((long *)fBUFFER,151587081L,134744072L);
	AsmRenderMaze((long *)&xBUFFER[VIEW_LEFT],(long *)fBUFFER);
//	AsmRenderObjects();


	/* ------------------------------------------------------------ */
	/* COPY THE FRAMEBUFFER TO VIDEO MEMORY				*/
	/* ------------------------------------------------------------ */

	if(DISPLAY_DEPTH == 4)
	{
	    AsmChunky2Planar((long *)fBUFFER,(long *)RASTPORT->BitMap->Planes[0]);
	}
	else if(DISPLAY_DEPTH != 4)
	{
	    chunky2planar((long *)fBUFFER,(long *)RASTPORT->BitMap->Planes[0]);
	};

        /* ------------------------------------------------------------ */
        /* FETCH AND EVALUATE PLAYER INPUT				*/
        /* ------------------------------------------------------------ */

	FetchEvaluateInput( &player1 );
	UpdatePlayerPosition( &player1 );
	// in updateposition also handle collision events
	// collision with: blocks & objects

//	UpdateDoorList();
//	UpdateNpcList();	/* NonPlayerCharacters - bad guys */

	frame++;
//	if(frame == 1000) FIN = 27;
    };

    timer(clock);
    seconds = clock[0] - start;
    if(! seconds) seconds = 1;

//  DestroyDoorList();
//  DestroyNpcList();
    
    printf("Frames: %d & Seconds: %d\n",frame,seconds);
    printf("Est Frames per second:  %d\n",frame/seconds);
}

/* -------------------------------------------------------------------------- 
	if(code == ' ')
	{
	    myDoor.status = 1;
	};

	myDoor.length = myDoor.length + myDoor.XDIR * myDoor.status;
	if( (myDoor.length == 64) && (myDoor.status != 0))
	{
	    myDoor.status = 0;
	    myDoor.XDIR *= -1;
	}
	else
	if( (myDoor.length == 0) && (myDoor.status != 0))
	{
	    myDoor.status = 0;
	    myDoor.XDIR *= -1;
	};
	
	Level_One[18].x = myDoor.oldX + myDoor.length;

*/

/* HERE's the ORIGINAL RenderWorld routine I used - note this does not
   need a chunky to planar conversion routine
 */
 
/* To get this work with wolf3d, insert this into functions.c and add:
   	void RenderWorld( void );
   to the top of the file. Also add:
   	extern void RenderWorld( void );
   to maze.h
   Place the call to this routine into game.c, in place of AsmRenderWorld()
*/
   
/* notice that xBUFFER[x].column * BYTESPERROW implies that the images are stored
   sideways. This is for assembly since it is faster to traverse a single column
   if the bytes of that column are stored consecutively in memory */

/* RenderWorld() - handles the task of drawing the visible wall columns as determined
		   by the xBUFFER[];
		   
		   Each xBUFFER element represents a single column of the display.
		   It contains information on the bitmap image we are fetching graphic data from,
		   the height (in pixels) that this column will cover on the screen,
		   and a column value, which is an offset into the bitmap image where
		   this column's graphic data begins. 
		   
		   Each wall column starts off as 64 pixels high. This is scaled
		   up or down depending on the already calculated xBUFFER[x].height
		   value. Since the wall is centered on the middle row of the
		   display area, the xBUFFER[].height value is actually the height
		   of the top of the wall as measured from the middle row.
		   
*/
/* Thanks to Simon Watfa for his two-dimensional scaling code */
/*
#define BYTESPERROW 64

void RenderWorld( void )
{
    register word x, height, destY, srcY, yinc, yrinc, errY;
    byte *bitmapPtr;
    
    for(x = ViewLeft; x <= ViewRight; x++) /* Draw each column of the screen */
    {
	height = xBUFFER[x].height; /* The height/2 of this wall column */

	if(height)
	{
	    yinc = 32 / height; /* Calculate scaling factors for this column */
	    yrinc = 32 % height;
	
	    errY = srcY = 0;
	    
	    for(destY = (ViewCenterY-height+1); destY <=(height+ViewCenterY); destY++, srcY += yinc)
	    {
		if( (destY >= ViewTop) && (destY <= ViewBottom) )
		{
		    /* This pixel is within the drawing area so render it */

		    bitmapPtr = (byte *)xBUFFER[x].bitmap;
   
		    SetAPen(RASTPORT, *(bitmapPtr + (xBUFFER[x].column * BYTESPERROW) + srcY));

		    WritePixel(RASTPORT,(word)x,(word)destY);
		};
			
		errY += yrinc;
		if(errY >= height)
		{
		    srcY++;
		    errY -= height;
		};
	    };
	};
    };
}	


*/
