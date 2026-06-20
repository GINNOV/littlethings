#include "startup.h"
#include <intuition/screens.h>
#include <exec/memory.h>

extern byte walls[8][65][2];

void main() /* MAIN - handles initialization, starting the game, and cleaning up. */
{
    word result;
    
    result = StartUp();
    
    if(result == SUCCESS)
    	WOLF3D();
    else
    	ERROR_ALERT(result);
    
    CleanUp();
}


word StartUp( void )
{
    register long index;
    register word x, y, count;
    long result;
    FILE *fp, *fopen();
    

    /* ---- Make sure all these pointers start off as NULL ---- */
    /* ---- Ignore the compiler warnings ---- */

    fBUFFER = JoyStick1 = MyWIN = MySCR = MyBMP = GfxBase = IntuitionBase = NULL;
    for(index = 0; index < NbrWallBMPs; index++) WallGfx[index] = 0;
    

    IntuitionBase = OpenLibrary("intuition.library",0L);
    if(IntuitionBase == NULL) return(1);
    

    GfxBase = OpenLibrary("graphics.library",0L);
    if(GfxBase == NULL) return(2);


    MyBMP = (struct BitMap *) AllocMem((long)sizeof(struct BitMap), MEMF_CLEAR);
    if(NOT MyBMP) return(10);
    
    InitBitMap(MyBMP, DISPLAY_DEPTH, DISPLAY_WIDTH, DISPLAY_HEIGHT);
    
    /* ---- ALLOCATE GRAPHICS MEMORY AS ONE CONTIGUOUS BLOCK ---- */

    MyBMP->Planes[0] = (PLANEPTR)AllocRaster(DISPLAY_WIDTH, (DISPLAY_HEIGHT * DISPLAY_DEPTH) );
    if(NOT MyBMP->Planes[0]) return(11);

    for(index = 1; index < DISPLAY_DEPTH; index++)
        MyBMP->Planes[index] = MyBMP->Planes[index-1] + ((DISPLAY_WIDTH * DISPLAY_HEIGHT) / 8);

/* You may use this if compiling for V2.04+
    MySCR = OpenScreenTags(	NULL,
    				SA_Depth, DISPLAY_DEPTH,
				SA_Width, DISPLAY_WIDTH,
				SA_Height, DISPLAY_HEIGHT,
				SA_ShowTitle, FALSE,
				SA_Title, (char *) "WOLF 3D",
				SA_SysFont, NULL,
				SA_Type, CUSTOMSCREEN,
				SA_BitMap, MyBMP,
				SA_Quiet, TRUE,
				TAG_DONE);
*/

    NewScreen.LeftEdge	= 0;
    NewScreen.TopEdge	= 0;
    NewScreen.Width	= DISPLAY_WIDTH;
    NewScreen.Height	= DISPLAY_HEIGHT;
    NewScreen.Depth	= DISPLAY_DEPTH;
    NewScreen.DetailPen = (unsigned char) ~0;
    NewScreen.BlockPen	= (unsigned char) ~0;
    NewScreen.Type	= CUSTOMSCREEN|CUSTOMBITMAP|SCREENQUIET;
    NewScreen.ViewModes	= NULL;
    NewScreen.Font	= NULL;
    NewScreen.Gadgets	= NULL;
    NewScreen.DefaultTitle = (char *) "WOLF 3D";
    NewScreen.CustomBitMap = MyBMP;
    
    MySCR = OpenScreen( &NewScreen); /* Used for V1.3 compatibilty */
    if(MySCR == NULL) return(3);
    
    
/*	
    MyWIN = OpenWindowTags(	NULL,
    				WA_IDCMP, IDCMP_RAWKEY|IDCMP_VANILLAKEY,
    				WA_CustomScreen, MySCR,
				WA_NoCareRefresh, TRUE,
				WA_Activate, TRUE,
				WA_Borderless, TRUE,
				WA_Backdrop, TRUE,
				WA_RMBTrap, TRUE,
				WA_SimpleRefresh, TRUE,
				TAG_DONE);
*/
    NewWindow.LeftEdge	= 0;
    NewWindow.TopEdge	= 0;
    NewWindow.Width	= DISPLAY_WIDTH;
    NewWindow.Height	= DISPLAY_HEIGHT;
    NewWindow.DetailPen = (unsigned char) ~0;
    NewWindow.BlockPen	= (unsigned char) ~0;
    NewWindow.Flags	= WFLG_BACKDROP|WFLG_SIMPLE_REFRESH|WFLG_BORDERLESS|WFLG_ACTIVATE|WFLG_RMBTRAP|WFLG_NOCAREREFRESH|WFLG_REPORTMOUSE;
    NewWindow.IDCMPFlags  = IDCMP_RAWKEY|IDCMP_VANILLAKEY|IDCMP_DELTAMOVE|IDCMP_MOUSEMOVE;
    NewWindow.FirstGadget = NULL;
    NewWindow.CheckMark = NULL;
    NewWindow.Title	= NULL;
    NewWindow.Type	= CUSTOMSCREEN;
    NewWindow.Screen	= MySCR;
    NewWindow.BitMap	= NULL;
    NewWindow.MinWidth	= 0;
    NewWindow.MinHeight = 0;
    NewWindow.MaxWidth	= 0;
    NewWindow.MinHeight = 0;
    
    MyWIN = OpenWindow(&NewWindow);
    if(MyWIN == NULL) return(4);

    
    RASTPORT = MyWIN->RPort;
    
    
    JoyStick1 = AllocateJoystick();
    if(JoyStick1 == NULL) return(5);

   
    /* ---- CHANGE SCREEN COLOURS ---- */
    for(index = 0; index < 8; index++)
	SetRGB4(&MyWIN->WScreen->ViewPort, index, (index<<1)+1,(index<<1)+1,(index<<1)+1);


/* allocate sound channels, load samples */

    /* ALLOCATE MEMORY BUFFERS */
    /* FETCH BITMAP IMAGES */
    /* 1. WALLS */

/* ---------------------------------------- */
/* Fetch Bitmap images. (walls)             */
/* ---------------------------------------- */
    for(index = 0; index < NbrWallBMPs; index++)
    {
	WallGfx[index] = (unsigned char *)malloc(64*64);
	if(! WallGfx[index]) return(9);
    };

    fp = fopen("walls.bmp","r");
    
    if(fp)
    {
	for(index = 0; index < NbrWallBMPs; index++)
	{
	    for(y = 0; y < 64; y++)
	    	for(x = 0; x < 64; x++)
		{
		    result = fgetc(fp);
		    *(WallGfx[index]+x*64+y) = (byte) result;
		    if(result == -1)
		    {
			fclose(fp);
			return(7);
		    };
		};
	};
	
	fclose(fp);
    }
    else
	return(6);


    /* ---- fBUFFER is the graphics frame buffer ---- */
    
    fBUFFER = (unsigned char *)malloc(fBUFFER_SIZE);
    if(! fBUFFER) return (8);

    for(index = 0; index < fBUFFER_SIZE; index++)
        fBUFFER[index] = (byte) 13;

    /* ---------------------------------------------
       Initialize the wall array to contain
       coordinates for all the columns of the walls.
       --------------------------------------------- */

    /* north/west wall/door */

    count = 0;
    for(index = 32; index >= -32; index--)
    {
	walls[W][count][0] = -32;
	walls[W][count][1] = index;
	walls[DRW][count][0] = 0;
	walls[DRW][count][1] = index;

	walls[N][count][0] = index;
	walls[N][count][1] = 32;
	walls[DRN][count][0] = index;
	walls[DRN][count][1] = 0;
	count++;
    };
    
    /* east/south wall/door */

    count = 0;
    for(index = -32; index <= 32; index++)
    {
	walls[E][count][0] = 32;
	walls[E][count][1] = index;
	walls[DRE][count][0] = 0;
	walls[DRE][count][1] = index;

	walls[S][count][0] = index;
	walls[S][count][1] = -32;
	walls[DRS][count][0] = index;
	walls[DRS][count][1] = 0;

	count++;
    };

    return(SUCCESS);    
}


void CleanUp( void )
{
    register long index;

    for(index = 0; index < NbrWallBMPs; index++)
	if(WallGfx[index]) free(WallGfx[index]);
	
    if(fBUFFER) free(fBUFFER);
    if(JoyStick1) DeallocateJoystick();
    if(MyWIN) CloseWindow( MyWIN );
    if(MySCR) CloseScreen( MySCR );
    if(MyBMP)
       if(MyBMP->Planes[0]) FreeRaster(MyBMP->Planes[0], DISPLAY_WIDTH, DISPLAY_HEIGHT*DISPLAY_DEPTH);
    if(MyBMP) FreeMem(MyBMP, (long)sizeof(struct BitMap));
    if(GfxBase) CloseLibrary( GfxBase );
    if(IntuitionBase) CloseLibrary( IntuitionBase );

}


void ERROR_ALERT( word result )
{
    fprintf(stderr,"WOLF3D ERROR: %s\n",ErrorMesg[ result ]);
}



