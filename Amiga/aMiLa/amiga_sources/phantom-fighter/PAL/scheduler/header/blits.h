/*********************************************************
 * Header file for interrupt driven blitter routines
 ********************************************************/
 
#ifndef BLITS_H
#define BLITS_H

#include <exec/types.h>
#include <hardware/blit.h>

#define MAXBLITS 128

struct BlitPlane {
  char *bltcpt;
  char *bltbpt;
  char *bltapt;
  char *bltdpt;
};

struct BlitterObject {
  short bltcon0;
  short bltcon1;
  short bltcmod;
  short bltbmod;
  short bltamod;
  short bltdmod;
  short bltafwm;
  short bltalwm;
  short bltsize;
  struct BlitPlane Ptr[3];
};

typedef struct BlitterObject BLT_Object;
typedef struct BlitterObject *BLT_PObject;

extern BLT_Object BLT_ObjectList[MAXBLITS];
extern unsigned short BLTListRead;
extern unsigned short BLTListWrite;

#endif
