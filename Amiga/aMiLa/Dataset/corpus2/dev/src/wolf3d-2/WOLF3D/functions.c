#include "game.h"
#include "joystick.h"

#define FFPBitSize 14
#define SINE_TABLE_SIZE 900

long TBlock[ NbrBlocks ][2];
word Twalls[8][65][2];
byte walls[8][65][2];

extern struct BLOCKTYPE Level_One[ NbrBlocks ];
extern struct xBUFFTYPE xBUFFER[DISPLAY_WIDTH];

extern word zBUFFER[NbrBlocks + NbrObjects][2];
extern word *COSINE, SINE[SINE_TABLE_SIZE+1];
extern word INPUTMETHOD;
extern word FIN;

void Rotate(long *, long *, word );
void UpdatePlayerPosition( struct PLAYER * );
void TransformBlocks( struct PLAYER * );
word CreateZbuffer( void );
void CreateXbuffer( word );
void FetchEvaluateInput( struct PLAYER * );
word GetIDCMP( void );

/* -------------------------------------------------------------- */

/* To this routine, I still need to add object handling */

void CreateXbuffer( word zCount)
{
    extern struct xBUFFTYPE xBUFFER[DISPLAY_WIDTH];
    register long index, Tindex, z, x, y;
    word WALLDOOR, wall, face;
    word xAccess = 0;
    word aX,aZ,cX,cZ;
    word done, loop;
    word column, lastBMP;
    
    long lastY,lastX;
    
    for(index = VIEW_LEFT; index <= VIEW_RIGHT; index++) xBUFFER[index].height = 0;

    for(index = 0; index < zCount; index++)
    {
	Tindex = zBUFFER[index][0];

	if( Level_One[Tindex].flags & (1 << (W+1)) ) WALLDOOR = 4;
	else WALLDOOR = 0;
	
	for(wall = N; wall <= W; wall++)
	{
	    if( Level_One[Tindex].flags & (1 << wall) )
	    {
		face = wall + WALLDOOR;

		cX = -(Twalls[face][0][0] + TBlock[Tindex][0]);
		cZ =  Twalls[face][0][1]  + TBlock[Tindex][1];
		    
		aX =  Twalls[face][63][0] + TBlock[Tindex][0];
		aZ =  Twalls[face][63][1] + TBlock[Tindex][1];

		if( ((cX*aZ)+(cZ*aX)) > 0)
		{
		    column = 1;
		    done = 0;

		    x = Twalls[face][0][0] + TBlock[Tindex][0];
		    z = Twalls[face][0][1] + TBlock[Tindex][1];

		    if( (wall == 0) || (wall == 2) ) lastBMP = (long)Level_One[Tindex].bmp1;
		    else lastBMP = (long)Level_One[Tindex].bmp2;

		    if(z > 0)
		    {
			x = (( x<< 9)/(z+z+z) * VIEW_WIDTH)/256 + VIEW_CENTER_COL;
			lastY = ((40<<14)/(z+z+z) * VIEW_HEIGHT)/128;
		    }
		    else
		    {
			x = (x*VIEW_WIDTH)/256 + VIEW_CENTER_COL;
			lastY = VIEW_BOTTOM-VIEW_CENTER_ROW;
		    };

		    lastX = x;

		    if(x < VIEW_LEFT)
		    {
			lastX = VIEW_LEFT;
		    }
		    else if(x > VIEW_RIGHT)
		    {
			done = TRUE;
		    };

		    while( ! done)
		    {
			x = Twalls[face][column][0] + TBlock[Tindex][0];
			z = Twalls[face][column][1] + TBlock[Tindex][1];
	
			if(z > 0)
			{
			    x = (( x<< 9)/(z+z+z) * VIEW_WIDTH)/256 + VIEW_CENTER_COL;
			    y = ((40<<14)/(z+z+z) * VIEW_HEIGHT)/128;
			}
			else
			{
			    x = (x * VIEW_WIDTH)/256 + VIEW_CENTER_COL;
			    y = VIEW_BOTTOM-VIEW_CENTER_ROW;
			};
	
			if(  x < VIEW_LEFT  )
			{
			    x = VIEW_LEFT-1;
			    lastX = x;
			    lastY = y;
			    if( (wall == 0) || (wall == 2) ) lastBMP = (long)Level_One[Tindex].bmp1;
			    else lastBMP = (long)Level_One[Tindex].bmp2;
			}
			else if( x > VIEW_RIGHT)
			{
			    x = VIEW_RIGHT + 1-1;
			    z = 1;
			    done = TRUE;
			};
	
			if(z > 0)
			{
			    for(loop = lastX; loop <= x; loop++)
			    {
				if(xBUFFER[loop].height < lastY)
				{
				    if(xBUFFER[loop].height == 0) xAccess++;
				    xBUFFER[loop].height = lastY;
				    xBUFFER[loop].column = column-1;
				    xBUFFER[loop].bitmap = (long *)WallGfx[lastBMP];
				};
			    };
			};
				
			lastX = x;
			lastY = y;

			if( (wall == 0) || (wall == 2) ) lastBMP = (long)Level_One[Tindex].bmp1;
			else lastBMP = (long)Level_One[Tindex].bmp2;
			
			column++;
			if(column > 64) done = TRUE;

		    };// while not done

		};// if dot product

	    };// if wall exists

	};// for each wall

	if(xAccess == (VIEW_RIGHT - VIEW_LEFT + 1)) index = zCount;

    };// for each block not behind the viewer
}

/* -------------------------------------------------------------------------- */

word CreateZbuffer( void )
{
    register word zCount, index;
    
    /* ---------------------------------------------------------------- */
    /* ADD PARTIALLY VISIBLE BLOCKS TO THE zBUFFER			*/
    /* ---------------------------------------------------------------- */

    zCount = 0;	    
    for(index = 0; index < NbrBlocks; index++)
    {
	if( TBlock[index][1] > (-32 << 5))
	{
	    zBUFFER[zCount][0] = index;		   /* Add block if within */
	    zBUFFER[zCount][1] = TBlock[index][1]; /* player's 90 degree  */
	    zCount++;				   /* peripheral vision.  */
	    
	};
    };

/*
    /* ---------------------------------------------------------------- */
    /* ADD PARTIALLY VISIBLE OBJECTS TO zBUFFER				*/
    /* ---------------------------------------------------------------- */

        for(index = 0; index < NbrObjects; index++)
        {
            Object[index].draw = FALSE;
            
            Object[index].transX = Object[index].center[0] - playerX;
            Object[index].transZ = Object[index].center[1] - playerZ;

            Rotate(&Object[index].transZ, &Object[index].transX, player[playerDir]);

            if( Object[index].transZ > 32)
            {               
                zBUFFER[zCount][0] = 10000+index; // object key.
                zBUFFER[zCount][1] = Object[index].transZ;
                zCount++;
            };
        };
*/

    return ((word)zCount);

}

/* -------------------------------------------------------------------------- */

void TransformBlocks( struct PLAYER *player )
{
    register long index, wall, tpt1, tpt2, Degree;
    
    Degree = player->attitude;
    
    for(index = 0; index < NbrBlocks; index++)
    {
	tpt1 = ((long) Level_One[index].z) - player->Zcopy;
	tpt2 = ((long) Level_One[index].x) - player->Xcopy;

	TBlock[index][1] = ((COSINE[Degree] * tpt1) - (SINE[Degree] * tpt2)) >> 9;
	TBlock[index][0] = ((COSINE[Degree] * tpt2) + (SINE[Degree] * tpt1)) >> 9;
    };

    for(wall = N; wall <= (W+4); wall++)
    {
	for(index = 0; index <= 64; index++)
	{
	    tpt2 = walls[wall][index][0];
	    tpt1 = walls[wall][index][1];

	    Twalls[wall][index][0] = (word) (((COSINE[Degree] * tpt2) + (SINE[Degree] * tpt1)) >> 9);
	    Twalls[wall][index][1] = (word) (((COSINE[Degree] * tpt1) - (SINE[Degree] * tpt2)) >> 9);
	};
    };
}

/* -------------------------------------------------------------------------- */

void UpdatePlayerPosition( struct PLAYER *player )
{
    register word Degree;
    
    if(player->attitude > 720) player->attitude -= 720;
    else if(player->attitude < 0) player->attitude += 720;

    Degree = player->attitude;

    player->X = (player->X - (player->speed *   SINE[Degree]));
    player->Z = (player->Z + (player->speed * COSINE[Degree]));
    player->speed = 0;
        
    player->Xcopy = (word)(player->X >> FFPBitSize);
    player->Zcopy = (word)(player->Z >> FFPBitSize);
}

/* -------------------------------------------------------------------------- */

void Rotate(long *pt1, long *pt2, short Degree)
{
    register long tpt1, tpt2, tpt3;

    tpt1 = *pt1;
    tpt2 = *pt2;

    tpt3 = ((COSINE[Degree] * tpt1) - (SINE[Degree] * tpt2)) >> 9;//FFPBitSize;
    *pt1 = tpt3;
    
    tpt3 = ((COSINE[Degree] * tpt2) + (SINE[Degree] * tpt1)) >> 9;//FFPBitSize;
    *pt2 = tpt3;
}

/* -------------------------------------------------------------------------- */

word mouseX, mouseY;

void FetchEvaluateInput( struct PLAYER *player )
{
    register word code;
    
    code = GetIDCMP();

    if(code == 666)
    {
	player->attitude += (5*2*mouseX);
	player->speed = 8 * mouseY;
	
    }
    else if(code == ESC) {FIN = ESC;
    }
    else if(INPUTMETHOD == KEYBOARD)
    {
    }
    else // INPUTMETHOD == JOYSTICK
    {
	code = ReadJoystick();

        if(code & LBUTTON)  // FireButtonStatus
        {
	    FIN = TRUE;
        };
        
        if(code & YJOYUP)
        {
            player->speed = 8; // move forward
        }
        else if(code & YJOYDWN)
        {
            player->speed = -8;// move back
        };
        
        if(code & XJOYLFT)
        {
            player->attitude += (5*2); // 2 = 1 degree rotate left
        }
        else if(code & XJOYRGT)
        {
            player->attitude -= (5*2); // 2 = 1 degree rotate right
        };
    };
}

/* -------------------------------------------------------------------------- */

struct IntuiMessage *MyMSG;

word GetIDCMP( void )
{
    word code = 0;

    while(MyMSG = (struct IntuiMessage *) GetMsg(MyWIN->UserPort))
    {
    	if((MyMSG->Class == IDCMP_VANILLAKEY) || (MyMSG->Class == IDCMP_RAWKEY))
    	{
    	    code = MyMSG->Code;
    	}
	else if(MyMSG->Class == IDCMP_MOUSEMOVE)
	{
	    //printf("zoz\n");
	    mouseX = MyMSG->MouseX;
	    mouseY = MyMSG->MouseY;
	    if(mouseX < 0) mouseX = 1;
	    else if(mouseX > 0) mouseX = -1;
	    if(mouseY < 0) mouseY = 1;
	    else if(mouseY > 0) mouseY = -1;
	    
	    //printf("--> X%d Y%d <--\n",mouseX,mouseY);
	    code = 666;
	}
    
    	ReplyMsg((struct Message *)MyMSG);
    };

    return((word) code);
}

/* -------------------------------------------------------------------------- */
