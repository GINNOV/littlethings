/* global information and includes shared by all modules. */

/* ---------------------------  I N C L U D E S  -------------------------- */

#include <intuition/intuition.h>
#include <graphics/gfx.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
//#include <clib/dos_protos.h>

#include <time.h>

/* -----------------------------  G L O B A L  ---------------------------- */

extern struct Window   *MyWIN;
extern struct RastPort *RASTPORT;
extern unsigned char   *fBUFFER;


/* ----------------------------  D E F I N E S  --------------------------- */

#define word short
#define byte char
#define NOT !

#define DISPLAY_WIDTH  320
#define DISPLAY_HEIGHT 200
#define DISPLAY_DEPTH  4   /* The number of bitplanes */

#define VIEW_WIDTH	128	/* This must be a multiple of 8 */
#define VIEW_HEIGHT	64
#define VIEW_LEFT	100	/* Must be a multiple of 4 */
#define VIEW_TOP	68
#define VIEW_RIGHT	(VIEW_LEFT+VIEW_WIDTH-1)
#define VIEW_BOTTOM	(VIEW_TOP+VIEW_HEIGHT-1)

#define VIEW_CENTER_COL ((VIEW_LEFT+VIEW_RIGHT)/2)
#define VIEW_CENTER_ROW	((VIEW_TOP+VIEW_BOTTOM)/2)

#define NbrWallBMPs 2
#define fBUFFER_SIZE (DISPLAY_WIDTH * DISPLAY_HEIGHT) /* nbr of bytes in the chunky framebuffer */

typedef struct PLAYER
{
    long X;	/* X and Z are used to maintain some fixed point precision */
    long Z;
    word Xcopy; /* Xcopy and Zcopy are used in normal calculations */
    word Zcopy;
    word speed;
    word attitude;
};
