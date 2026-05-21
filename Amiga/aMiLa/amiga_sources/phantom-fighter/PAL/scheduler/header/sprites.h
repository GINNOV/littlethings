#ifndef SPRITES_H
#define SPRITES_H

#include <exec/memory.h>
#include <graphics/sprite.h>

#include "scheduler.h"

typedef struct {
   struct SCH_queue Q;
   struct SimpleSprite Sprite;
} SpriteDescriptor;

extern SpriteDescriptor *AllocSprite();

#endif
