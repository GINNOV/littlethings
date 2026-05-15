/**********************************************
 *               KNIGHT.H
 *
 * This holds all the serious structures and
 * useful macros to make emerald the serious
 * amiga games company.......
 *
 * Written by Kel & Billy 8-Apr-88
 */

#include <exec/types.h>

#define SCREENWIDTH  640
#define SCREENHEIGHT 200 
#define BOXWIDTH     32
#define BOXHEIGHT    16

/* Given a 3d xyz, return the 2D
 * X and Y co-ords. Two macros
 * obviously.
 */
 
#define TWODX(X1,Y1,Z1) (SCREENWIDTH/2-BOXWIDTH/2+(X1-Y1)*2)
#define TWODY(X1,Y1,Z1) (SCREENHEIGHT-BOXHEIGHT-5-(X1+Y1)/2-Z1)

#define MAXATOMS 64

#define GetAnAtom()  (struct KnightAtom *)RemQue(FreeList->flink)
#define GiveAnAtom(Atom) InsQue(FreeList->flink,RemQue(Atom))

struct KnightAtom {
   struct KnightAtom *flink,*blink; /* Queue Management Stuff */
   int nX,nY,nZ;                    /* 3d of Near corner      */
   int fX,fY,fZ;                    /* 3d of Far corner       */
   int Xl,Yt;                       /* 2d of Left Top         */
   int Xr,Yb;                       /* 2d of Right Bottom     */
   char *ID;                        /* Whoze who in the world */
};

extern struct KnightAtom *KnightList; /* The List of atoms in THE WORLD */
extern struct KnightAtom *FreeList;   /* The Free list of atoms         */

struct SCH_queue {
  struct SCH_queue *flink,
                   *blink;
};
