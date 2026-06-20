#ifndef K_CHUNKYSTARTUP_H
#define K_CHUNKYSTARTUP_H
/*==========================================================*/
/*====                                                  ====*/
/*====                                                  ====*/
/*====      ChunkyStartup.h => Chunkystartup.o handler  ====*/
/*====      krabob@online.fr 23/04/2001                  ====*/
/*====                                                  ====*/
/*====                                                  ====*/
/*==========================================================*/
/*
    .o containing simple functions very needed to code 8bit demos,
    fully AGA-CGX (graphic card) compatible, usable in C
    or asm, compatible since 68020.
    Everything needed to code nice demos is here:

    8bit screen opening at any resolution.
    real aga-cgx stable 50Hz clock (using timer.device),

    See test.c for an example of use.

    This .h was designed for vbcc (68k) that means
    the primitives use the __reg("d0") syntax to notify
    what argument use what register:
    This syntax is not the same for other compiler
    -> just change that to fit your compiler.

    every extern function stack their regs correctly.

    this .o does not use fpu and should be compatible since 68020.
    it was tested with muforce: no enforce hits.

*/

/* Amiga-Standard Types */
#include    <exec/types.h>

/* structure for screen, window */
#include    <intuition/screens.h>
#include    <intuition/intuition.h>
/*==========================================================*/
/*====                                                  ====*/
/*====      ChunkyStartupInit  -  ChunkyStartupClose    ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  __reg("d0") int         ChunkyStartupInit(
                                    __reg("d0")int Width,
                                    __reg("d1")int Height
                                                );

extern  void                    ChunkyStartupClose(void);
/*
    This one should be launch one time at the very beginning
    of the main;

    you only provide Width and Height, intuition is used to
    find the best mode possible. IF Width=0 then Height is ignored,
    and an ASL screen requester ask a mode to the user.
    in that case, screen resolution will be variable (see below)
    ( don't try too funny resolution !! CGX only support "square"
    resolutions on most hardwares. Width must also be multiple of 32. )

    It opens these library:  Intuition,asl,graphics,cybergraphics if present,
    and the timer device (for synchro)

    Then it opens the screen, with triple  buffer under aga.
    (aga is used if no cgx libs is found.)

    Return !=0 if succesful. If the value returned is 0, it failed.
    From the moment it has been launch succesfully,
    you can read the Width and Height of the screen in the global vars:

    ScreenWidth and ScreenHeight

    You can use theses value to alloc your own chunky buffer
    ScreenWidth * ScreenHeight sized ! or maybe you could use:
    UBYTE *Allocatechunkyforscreen() that do the same thing with
    a buffer auto-freed when closing.

    To draw your chunk in the screen simply use in your loop(s):

    ScreenRefresh( ChunkyBuffer );

    when you USE ChunkyStartupInit(...) you must end your program
    by ChunkyStartupClose(); Even if ChunkyStartupInit failed.
    it will de-alloc and close back everything opened by the init
    and everything done by this .o functions.

*/
/*==========================================================*/
/*====                                                  ====*/
/*====      Allocate Chunky for screen                  ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  UBYTE                   *Allocatechunkyforscreen(void );
/*
    since the screen can be "resolution-free",this function
    automatically allocate a chunky buffer with the right size.
    This buffer is safe to be passed to ScreenRefresh(...)
    the dimension of the screen can be read in global vars
    ScreenWidth & ScreenHeight.
    This function can be used to open multiple buffers.
    all buffers opened by that functions will be freed by
    ChunkyStartupClose().
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      ListenEnd                                   ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  int                     ListenEnd();
/*
    ListenEnd use the screen's intuition port also available
    in the Window structure given with global var "TheWindow"
    to check for the 2 mouse buttons + the escape key.
    if one is pressed, it returns != 0. if nothing is pressed,
    it returns 0 immediately. Nice to test for exit !
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      ScreenRefresh                               ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  void                    ScreenRefresh(
                                    __reg("a0") UBYTE * ScreenBuffer
                                            );
/*
    Simply draw the 8bitperpixel chunk to the screen
    and make it appear. seems to be safe. triple buffer performed
    under aga (so it takes a lot of chipmem if 640*512)
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      SetScreenPalette                            ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  void                    SetScreenPalette(
                                    __reg("a0") ULONG *Table
                                            );
/*
    Simply set a palette for the screen.
    this function use Graphics/LoadRGB32,
    and the palette format must be RGB32 (see graphics.doc)

        The format of the table passed to this function is a series of records,
        each with the following format:

                1 Word with the number of colors to load
                1 Word with the first color to be loaded.
                3 longwords representing a left justified 32 bit rgb triplet.
                The list is terminated by a count value of 0.

           examples:
                ULONG table[]={1l<<16+0,0xffffffff,0,0,0} loads color register
                        0 with 100% red.
                ULONG table[]={256l<<16+0,r1,g1,b1,r2,g2,b2,.....0} can be used
                        to load an entire 256 color palette.

        Lower order bits of the palette specification will be discarded,
        depending on the color palette resolution of the target graphics
        device. Use 0xffffffff for the full value, 0x7fffffff for 50%,
        etc. You can find out the palette range for your screen by
        querying the graphics data base.
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      ResetTaskTime                               ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  void                    ResetTaskTime( void );
/*
    Simply set to 0 the inner clock provided by ChunkyStartupInit(...)
    It is already launch by this init. only needed if you want time
    to be reseted.
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      GetTaskTime                                 ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  __reg("d0") int         GetTaskTime( void );
/*
    Return a int value representing the time since the
    launch of ChunkyStartupInit(...) with units of 1/50 seconds.
    it means 100 stands for 2 seconds.
    timer.device/UNIT_MICROHZ based clock.
    (WaitTOF was not safe at all for cgx,and AGA could be NTSC.)
    so I myself use this function to synchronize the cinematics
    of my demos, with no other "synchro" task.
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      Chunkystartup's own AllocRmb                ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  __reg("d0") UBYTE * AllocRmb( __reg("d0") int size );
/*
    (Act a bit like intuition's allocremember)
    allocate a buffer "size" bytes long and return
    a pointer on the chunk.
    the buffer returned will be automatically freed by
    ChunkyStartupClose();
*/
/*==========================================================*/
/*====                                                  ====*/
/*====      Chunkystartup's own LoadRmb                 ====*/
/*====                                                  ====*/
/*==========================================================*/
struct CSAllocCell
{
        int      csac_private1;
        int      csac_private2;
        int      csac_ChunkSize;
        UBYTE   *csac_Buffer;
};

extern  __reg("d0") struct CSAllocCell * LoadRmb( __reg("a0") STRPTR);
/*
    allocate a buffer and load a file in.
    STRPTR is a 0-ended string which indicate a dos file.
    you can then access the buffer with csac_Buffer
    and take its size with csac_ChunkSize.

    the structure & buffer returned will be automatically freed by
    ChunkyStartupClose();
*/

/*==========================================================*/
/*====                                                  ====*/
/*====      Some useful global vars                     ====*/
/*====                                                  ====*/
/*==========================================================*/
extern  int                     ScreenWidth;    /* READ ONLY ! */
extern  int                     ScreenHeight;


extern  STRPTR                  Exitmessage;    /* a string or NULL for esayrequest while quitting */
                                                /* set this before ChunkyStartupClose  */

extern  struct  Screen                  *TheScreen;     /* the intuition screen*/
extern  struct  Window                  *TheWindow;

#endif  /* K_CHUNKYSTARTUP_H */

