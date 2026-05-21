#ifndef BULLETDAT_H

#define BULLETDAT_H

#include <exec/types.h>

typedef struct {
   WORD (*StartOffset)[2];
   WORD (*HitBox)[4];
   UWORD ***Shape;
   UWORD *Color;
} BulletDescriptor;

#endif
