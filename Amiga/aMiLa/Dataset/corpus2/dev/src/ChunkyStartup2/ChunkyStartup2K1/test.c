/*==========================================================*/
/*====                                                  ====*/
/*====                                                  ====*/
/*====      MKD's ChunkyStartup use test                ====*/
/*====      krabob@online.fr 5/04/2001                  ====*/
/*====                                                  ====*/
/*====                                                  ====*/
/*==========================================================*/
/*
 vbcc example:

vc +env:vc.config68k test.c ChunkyStartup.o  KZoomSprite.o ChunkyDebug.o  -v -o Test! -+ -lamiga

*/

/* C-Standard includes */
#include    <stdio.h>
/* Amiga-Standard Includes */
#include    <exec/types.h>

#include    "ChunkyStartup.h"   /* for ChunkyStartup.o */
#include    "KZoomSprite.h"     /* a drawing routine */
#include    "ChunkyDebug.h"     /* some debug help */

/*===================================================*/
/*====                                           ====*/
/*====      Example Main                         ====*/
/*====                                           ====*/
/*===================================================*/
int     main( void )
{
        /*--------------------------------------------*/
        char    *ChunkyScreen=NULL;
        struct  ScreenRenderContext     RC;
        struct  TextureContext          TC;
        struct  CSAllocCell             *TextureFile,*PaletteFile;
        int x1,y1,x2,y2;

        /*----- initiate screen stuffs and timer ----*/
        /* set (0,240) and you'll see an asl requester  */
        if ( ChunkyStartupInit(0,512)==0 ) ex_out("no screen");

        /*----- Load Texture and allocate chunky buffer -----*/
        if ( (ChunkyScreen = Allocatechunkyforscreen()) == 0L  ) ex_out(NULL);
        if ( (TextureFile=LoadRmb("Texture.Chunky")) == 0L ) ex_out("Texture.Chunky failed");
        if ( (PaletteFile=LoadRmb("Texture.LoadRGB32")) == 0L ) ex_out("palette load failed");

        /*----- Set Screen Palette  -----*/
        SetScreenPalette((ULONG*)(PaletteFile->csac_Buffer));

        /*----- Init structures for screen and texture for zoom effect -----*/
        RC.src_ChunkyScreen =   ChunkyScreen    ;
        RC.src_BytesModulo  =   ScreenWidth     ;
        RC.src_ClipX1       =   10 ;
        RC.src_ClipY1       =   10 ;
        RC.src_ClipX2       =   ScreenWidth -10 ;
        RC.src_ClipY2       =   ScreenHeight -10  ;

        TC.ttc_ChunkyTexture = TextureFile->csac_Buffer;
        TC.ttc_BytesModulo      =   256 ;
        TC.ttc_U1               =   10<<16;
        TC.ttc_V1               =   10<<16;
        TC.ttc_U2               =   240<<16;
        TC.ttc_V2               =   240<<16;

        x1 = ScreenWidth ; /* flipped at start */
        y1 = ScreenHeight ;
        x2 = 0;
        y2 = 0 ;

        /*-------------------------------------------*/
        /*----              main loop           -----*/
        while ( ListenEnd() == 0 )
        {
            /* draw a zooming texture  */
            KZoomSprite8bit68K( x1,y1,x2,y2, &RC, &TC );

            /* print the date value */
            ShowInt( GetTaskTime(),160+RC.src_BytesModulo*0,RC.src_BytesModulo,RC.src_ChunkyScreen );
            ShowInt( ScreenWidth,24+RC.src_BytesModulo*8,RC.src_BytesModulo,RC.src_ChunkyScreen );
            ShowInt( ScreenHeight ,24+RC.src_BytesModulo*17,RC.src_BytesModulo,RC.src_ChunkyScreen );

            /* draw everything */
            ScreenRefresh(ChunkyScreen);

            /**/
            x1-=1;
            y1-=1;
            x2+=1;
            y2+=1;

        }

        ex_out(NULL);
        return(0L);
}
/*===================================================*/
/*====                                           ====*/
/*====      Close Everything                     ====*/
/*====                                           ====*/
/*===================================================*/
void    ex_out( char *errorstring  )
{
    /*--- error string for an "easy request"---*/
    Exitmessage = errorstring;
    ChunkyStartupClose();  /* close what was opened by ChunkyStartupInit */

    /*----- quit task -----*/
    exit(0);
}
