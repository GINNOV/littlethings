/* ---------------------------  I N C L U D E S  -------------------------- */
#include "global.h"
#include <stdio.h>

/* ----------------------------  D E F I N E S  --------------------------- */

/* GENERAL DEFINES */
#define SUCCESS 0
#define ESC 27
#define KEYBOARD 0
#define JOYSTICK 1

/* BIT FLAGS FOR THE BLOCKTYPE */
#define NORTH 1
#define EAST  2
#define SOUTH 4
#define WEST  8
#define DOOR  16

#define N 0
#define E 1
#define S 2
#define W 3
#define DRN 4
#define DRE 5
#define DRS 6
#define DRW 7

#define NbrBlocks 19
#define NbrObjects 0

/* -----------------------------  G L O B A L  ---------------------------- */

extern unsigned byte *WallGfx[NbrWallBMPs];

/* ----------------  I N T E R N A L   S T R U C T U R E S  --------------- */


struct BLOCKTYPE
{
    long bmp1;		// 4
    long bmp2;		// 4
    word x;		// 2
    word z;		// 2
    word flags;		// 2
    word junk;		// 2 = 16 bytes
};

struct xBUFFTYPE
{
    word column;
    word height;
    long *bitmap;
};

struct DOORTYPE
{
    long *doorXZ;	/* Pointer into block array for either x or z */
    byte delta;		/* change in door position? */
    byte status;
    byte length;
    byte ticks;		/* Timing counter for the close delay */
};

/* ------------------  E X T E R N A L   R O U T I N E S  ------------------ */

extern void Rotate(long *, long *, word );
extern void UpdatePlayerPosition( struct PLAYER * );
extern word GetIDCMP( void );
extern void FetchEvaluateInput( struct PLAYER * );
extern void TransformBlocks( struct PLAYER * );
extern word CreateZbuffer( void );
extern void CreateXbuffer( word );

extern void __asm AsmRenderMaze(register __a0 long *,register __a1 long *);
extern void __asm AsmChunky2Planar(register __a0 long *,register __a1 long *);
extern void __asm AsmClearBackground(register __a0 long *,register __d0 long,register __d1 long);
extern void __asm chunky2planar(register __a0 long *,register __a1 long *);
