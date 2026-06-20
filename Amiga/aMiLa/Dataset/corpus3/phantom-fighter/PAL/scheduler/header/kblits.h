/*********************************************************
 * Header file for interrupt driven blitter routines
 ********************************************************/
 

#include <exec/types.h>
#include <hardware/blit.h>

struct BlitPlane {
  char *bltapt;
  char *bltbpt;
  char *bltcpt;
  char *bltdpt;
};

struct BlitterObject {
  struct BlitterObject *flink;
  struct BlitterObject *blink;
  struct bltnode Sys;
  short PlneNo;
  char *PlneAd;
  short bltcon0;
  short bltcon1;
  short bltamod;
  short bltbmod;
  short bltcmod;
  short bltdmod;
  short bltafwm;
  short bltalwm;
  struct BlitPlane Plane[3];
};

typedef struct BlitterObject BLT_Object;
typedef struct BlitterObject *BLT_PObject;

extern BLT_PObject AllocBLT();
extern void FreeBLT();

extern BLT_PObject FreeBLT_ObjectList;
extern BLT_PObject BLT_ObjectList;

