/*
    * Opens a screen and gets a bitmap reference to it so we can directly draw on the screen
    * Prepares an offscreen bitmap and creates some graphics
    * Draw and animate a bouncing tile on screen
    * Listens for mouse clicks
    * Add a bouncing tile on left click (max 100)
    * Exit on right Mousebutton
*/

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <intuition/screens.h>
#include <intuition/intuition.h>
#include <hardware/custom.h>
#include <stdio.h>

typedef struct BitMap tBitMap;
__far extern struct Custom custom;
volatile UBYTE *custom_vhposr= (volatile UBYTE *) 0xdff006;

#include <exec/types.h>

#define SCREENWIDTH 320
#define SCREENHEIGHT 200


// BltCon0 channel enable bits
#define USEA 0x800
#define USEB 0x400
#define USEC 0x200
#define USED 0x100




#define PLANES 3 // 8 colors
#define LORES 0
#define MAXBUNNIES 100

static struct Screen *screen;
static struct Window *window;
static struct ViewPort *viewport;
static struct RastPort screenContext;
static struct BitMap screenBitmap;

static struct RastPort spriteContext;
static struct BitMap spriteBitmap;

static struct RastPort bufferContext;
static struct BitMap bufferBitmap;

static struct MouseInfo {
    SHORT button;
    SHORT x;
    SHORT y;
};

static struct Bunny {
    SHORT speedX;
    SHORT speedY;
    SHORT x;
    SHORT y;
};
struct Bunny bunnies[MAXBUNNIES];
int bunnyCount;

// libraries
struct IntuitionBase *IntuitionBase;

// functions
BOOL setup(void);
void cleanup(void);
void createAssets(void);
void drawTile(UBYTE index, UBYTE x, UBYTE y);
void bufferToScreen(void);
void addBunny(void);
struct MouseInfo getMouseInfo(struct Window *win);
char _blitRect(tBitMap *pDst, short wDstX, short wDstY, short wWidth, short wHeight,unsigned char ubColor, unsigned short uwLine, char *szFile);

int main() {
    int i;
    UBYTE done = 0;
    struct MouseInfo mouse;
    ULONG signalmask;
    BOOL success;

    bunnyCount = 0;

    success = setup();
    if (!success) return(1);

    createAssets();
    addBunny();

    // setup intuition signals we want to hear
    signalmask = 1L << window->UserPort->mp_SigBit;

    while (!done){

    	while (*custom_vhposr != 0xff) ; // wait for vblank


    	//BeginRefresh(window);

        for( i = 0; i < PLANES; i++ )
        {
            BltClear( screenBitmap.Planes[ i ], RASSIZE( SCREENWIDTH, SCREENHEIGHT ), 0 );
        }

        // update Bunnies
        for( i = 0;i < bunnyCount; i++ ){
            bunnies[i].x += bunnies[i].speedX;
            if (bunnies[i].x>250) bunnies[i].speedX = -1;
            if (bunnies[i].x<22) bunnies[i].speedX = 1;

            bunnies[i].speedY++;
            bunnies[i].y += bunnies[i].speedY;
            if (bunnies[i].y>150) bunnies[i].speedY = -15;

            drawTile(0,bunnies[i].x,bunnies[i].y);

        }

        //EndRefresh(window,TRUE);

        //bufferToScreen();

        // detect if the mouse button is pressed
        mouse = getMouseInfo(window);

        if (mouse.button == 1) {
            addBunny();
        }

        if (mouse.button == 2) done=1;

        WaitTOF();


    }

    cleanup();
    Delay(1);

    return(0);
}

void addBunny(){
    if (bunnyCount<MAXBUNNIES){
        bunnies[bunnyCount].x = 30;
        bunnies[bunnyCount].y = 130;
        bunnies[bunnyCount].speedX = 1;
        bunnies[bunnyCount].speedY = 1;

        bunnyCount++;
    }
};


void createAssets(){
    // create base tiles on offscreen bitmap
    SetDrMd(&spriteContext, JAM1);

    // clear background
    SetAPen(&spriteContext,0);
    RectFill(&spriteContext, 0, 0, 19,39);

    // tile 1
    SetAPen(&spriteContext,1);
    RectFill(&spriteContext, 0, 0, 17, 17);

    SetAPen(&spriteContext,2);
    Move(&spriteContext,18, 1);
    Draw(&spriteContext,18, 18);
    Draw(&spriteContext,1, 18);

    SetAPen(&spriteContext,3);
    RectFill(&spriteContext, 2, 2, 16,16);
    WritePixel(&spriteContext, 1, 1 );
    WritePixel(&spriteContext, 17, 17 );

    SetAPen(&spriteContext,4);
    Move(&spriteContext,2, 1);
    Draw(&spriteContext,17, 1);
    Draw(&spriteContext,17, 16);
    WritePixel(&spriteContext, 4, 4 );
    WritePixel(&spriteContext, 14, 4 );
    WritePixel(&spriteContext, 14, 14 );
    WritePixel(&spriteContext, 4, 14 );

    SetAPen(&spriteContext,5);
    Move(&spriteContext,1, 2);
    Draw(&spriteContext,1, 17);
    Draw(&spriteContext,16,17);

    // tile 2
    SetAPen(&spriteContext,2);
    RectFill(&spriteContext, 0, 20, 17, 37);

    SetAPen(&spriteContext,3);
    RectFill(&spriteContext, 2, 21, 18, 38);

    SetAPen(&spriteContext,4);
    RectFill(&spriteContext, 3, 24, 17, 37);

    SetAPen(&spriteContext,6);
    RectFill(&spriteContext, 2, 21, 17, 23);
    RectFill(&spriteContext, 2, 24, 4, 37);
    WritePixel(&spriteContext, 5, 25 );
    WritePixel(&spriteContext, 15, 25 );
    WritePixel(&spriteContext, 5, 35 );
    WritePixel(&spriteContext, 15, 35 );
}

void drawTile(UBYTE index, UBYTE x, UBYTE y){
    int sourceY = index*20;

    //ClipBlit(&spriteContext, 0, sourceY, &screenContext, x, y, 20, 20, ABC|ABNC);

   BltBitMap(
            &spriteBitmap,   // Source
            0, sourceY,      // Position, source.
            &screenBitmap,   // Destination.
            x,          // Position, destination.
            y,
            20, 20,          // Width and height.
            0xC0,            // Normal copy.
            0xFF,            // All bitplanes.
            NULL );          // No temporary storage.


          //_blitRect(&screenBitmap, x, y, 20, 20,1, 0, 0);

}

void bufferToScreen(){

    BltBitMap(
            &bufferBitmap,   // Source
            0, 0,      // Position, source.
            &screenBitmap,   // Destination.
            0,          // Position, destination.
            0,
            SCREENWIDTH, SCREENHEIGHT,          // Width and height.
            0xC0,            // Normal copy.
            0xFF,            // All bitplanes.
            NULL );          // No temporary storage.
}

struct MouseInfo getMouseInfo( struct Window *win )
{
    struct MouseInfo mouseInfo;
    struct IntuiMessage *message = NULL;
    USHORT code;
    ULONG classId;
    SHORT mx, my;

    mouseInfo.button = 0;

    /* Examine pending messages */
    while( message = (struct IntuiMessage *)GetMsg(win->UserPort) ) {

        classId = message->Class;
        code = message->Code;
        mx = message->MouseX;
        my = message->MouseY;

        /* When we're through with a message, reply */
        ReplyMsg( (struct Message *)message);

        /* See what events occurred */
        switch( classId ) {
            case MOUSEBUTTONS:
                switch( code )
                {
                    case SELECTUP:
                        printf( "Left Mouse UP at %d,%d\n",mx,my );
                        break;
                    case SELECTDOWN:
                        printf( "Left Mouse DOWN at %d,%d\n",mx,my );
                        mouseInfo.x = mx;
                        mouseInfo.y = my;
                        mouseInfo.button = 1;
                        break;
                    case MENUUP:
                        printf( "Right Mouse UP at %d,%d\n",mx,my );
                        mouseInfo.button = 2;
                        break;
                    case MENUDOWN:
                        printf( "Right Mouse DOWN at %d,%d\n",mx,my );
                        mouseInfo.button = 2;
                        break;
                    default:
                        printf("other %d\n",code);
                };
                break;
        }
    }

    /* Flush any remaining pending messages */
    while( message = (struct IntuiMessage *)GetMsg(win->UserPort)) ReplyMsg( (struct Message *)message );

    return(mouseInfo);
}

BOOL setup(){
    // setup screen and intuition
    // setup bitmaps

    // the screen
    static struct NewScreen screenProperties = {
            0,0,SCREENWIDTH,SCREENHEIGHT,PLANES,
            0, 0,
            LORES,
            CUSTOMSCREEN | CUSTOMBITMAP,
            NULL, NULL, NULL, NULL
    };

    // the window
    static struct NewWindow windowProperties = {
            0, 0, SCREENWIDTH,SCREENHEIGHT, 0,1,
            IDCMP_RAWKEY | IDCMP_MOUSEBUTTONS,
            WFLG_SIMPLE_REFRESH | WFLG_BACKDROP | WFLG_BORDERLESS | WFLG_ACTIVATE | WFLG_RMBTRAP | WFLG_NOCAREREFRESH,
            0, 0, 0, 0, 0,
            0, 0, 0, 0,
            CUSTOMSCREEN,
    };

    int i;
    static UWORD colours[8] = {
            0x036,
            0x469,
            0x025,
            0x679,
            0x457,
            0x89B,
            0x235,
            0xfff
    };

    // open intuition for mouse
    IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",0);

    // init screen bitmap
    InitRastPort(&screenContext);
    screenContext.BitMap = &screenBitmap;

    InitBitMap(&screenBitmap, PLANES, SCREENWIDTH, SCREENHEIGHT);
    for(i = 0; i < PLANES; i++) {
        screenBitmap.Planes[i] = AllocRaster(SCREENWIDTH, SCREENHEIGHT);
        if (screenBitmap.Planes[i] == 0) {
            fprintf(stderr, "%s (%dx%dx%d)\n", "failed to allocate screen pixmap", SCREENWIDTH, SCREENHEIGHT, PLANES);
            return(0);
        }
    }

    screenProperties.CustomBitMap = screenContext.BitMap;
    screen = OpenScreen(&screenProperties);
    if (!screen){
        fprintf(stderr, "failed to open screen");
        return(0);
    }

    // the window captures the mouse
    windowProperties.Screen = screen;
    window = OpenWindow(&windowProperties);
    if (!window){
        fprintf(stderr, "failed to open window");
        return(0);
    }

    // load palette
    viewport = &window->WScreen->ViewPort;
    LoadRGB4(viewport, colours, 8);

    // clear screen (this also removes the screen title etc.)
    SetAPen(&screenContext, 0);
    RectFill(&screenContext, 0, 0, SCREENWIDTH, SCREENHEIGHT);


    // init offscreen bitmap to hold our sprite
    InitRastPort(&spriteContext);
    spriteContext.BitMap = &spriteBitmap;
    InitBitMap(&spriteBitmap, PLANES, 20, 40);
    for(i = 0; i < PLANES; i++) {
        spriteBitmap.Planes[i] = AllocRaster(20,40);
        if (spriteBitmap.Planes[i] == 0) {
            fprintf(stderr, "failed to allocate sprite bitmap\n");
            return(1);
        }
    }

    // init buffer bitmap
    InitRastPort(&bufferContext);
    bufferContext.BitMap = &bufferBitmap;
    InitBitMap(&bufferBitmap, PLANES, SCREENWIDTH, SCREENHEIGHT);
    for(i = 0; i < PLANES; i++) {
        bufferBitmap.Planes[i] = AllocRaster(SCREENWIDTH, SCREENHEIGHT);
        if (bufferBitmap.Planes[i] == 0) {
            fprintf(stderr, "failed to allocate buffer bitmap\n");
            return(1);
        }
    }

    return(1);
}

void cleanup(void){
    int i;

    if (window) CloseWindow(window);
    if (screen) CloseScreen(screen);

    // Deallocate the display memory:

    for (i=0; i<PLANES; i++)
        if (screenBitmap.Planes[i]){
            FreeRaster(screenBitmap.Planes[i],SCREENWIDTH, SCREENHEIGHT);
            screenBitmap.Planes[i] = 0;
        }
        if (screenBitmap.Planes[i]){
            FreeRaster(bufferBitmap.Planes[i],SCREENWIDTH, SCREENHEIGHT);
            bufferBitmap.Planes[i] = 0;
        }
        if (spriteBitmap.Planes[i]){
            FreeRaster(spriteBitmap.Planes[i],20, 40);
            spriteBitmap.Planes[i] = 0;
        }

    if(IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);

}



/**
 * Fills rectangular area with selected color
 * A - rectangle mask, read disabled
 * C - destination read
 * D - destination write
 * Each bitplane has minterm depending if rectangular area should be filled or erased:
 * 	- fill: D = A+C
 * - erase: D = (~A)*C
 */
char _blitRect(tBitMap *pDst, short wDstX, short wDstY, short wWidth, short wHeight,unsigned char ubColor, unsigned short uwLine, char *szFile) {


	// Helper vars
	UWORD uwBlitWords;
	UWORD uwBlitWidth;
	ULONG ulDstOffs;
	UBYTE ubDstDelta;
	UBYTE ubMinterm;
	UBYTE ubPlane;
	// Blitter register values
	UWORD uwBltCon0;
	UWORD uwBltCon1;
	UWORD uwFirstMask;
	UWORD uwLastMask;
	WORD wSrcModulo;
	WORD wDstModulo;

	ubDstDelta = wDstX & 0xF;
	uwBlitWidth = (wWidth+ubDstDelta+15) & 0xFFF0;
	uwBlitWords = uwBlitWidth >> 4;

	uwFirstMask = 0xFFFF >> ubDstDelta;
	uwLastMask = 0xFFFF << (uwBlitWidth-(wWidth+ubDstDelta));
	uwBltCon1 = 0;
	ulDstOffs = pDst->BytesPerRow * wDstY + (wDstX>>3);
	wDstModulo = pDst->BytesPerRow - (uwBlitWords<<1);
	uwBltCon0 = USEC|USED;

	WaitBlit();
	custom.bltcon1 = uwBltCon1;
	custom.bltafwm = uwFirstMask;
	custom.bltalwm = uwLastMask;

	custom.bltcmod = wDstModulo;
	custom.bltdmod = wDstModulo;
	custom.bltadat = 0xFFFF;
	custom.bltbdat = 0;
	ubPlane = 0;

	do {
		if(ubColor & 1)
			ubMinterm = 0xFA;
		else
			ubMinterm = 0x0A;
		WaitBlit();
		custom.bltcon0 = uwBltCon0 | ubMinterm;
		// This hell of a casting must stay here or else large offsets get bugged!
		custom.bltcpt  = (UBYTE*)(((ULONG)(pDst->Planes[ubPlane])) + ulDstOffs);
		custom.bltdpt  = (UBYTE*)(((ULONG)(pDst->Planes[ubPlane])) + ulDstOffs);
		custom.bltsize = (wHeight << 6) | uwBlitWords;
		ubColor >>= 1;
		++ubPlane;
	}	while(ubPlane != pDst->Depth);


	return 1;
}