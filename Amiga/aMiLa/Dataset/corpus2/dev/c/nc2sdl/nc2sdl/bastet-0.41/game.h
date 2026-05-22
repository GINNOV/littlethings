/* game.h */

#ifndef _GAME_H_
#define _GAME_H_

#include "bastet.h"

/* Extern Functions in game.c */
extern POINTS play_game(int level);

/* Change this if you want more blocks or whatever. */
#define BLOCK_TYPES     7
#define BLOCK_ORIENTS   4
#define BLOCK_DOTS      4

/* A dot defines the color at relative (y,x) coordinates.
   Used to draw blocks. */
typedef struct _dot {
	unsigned char y;
	unsigned char x;
	unsigned char color;
} DOT;

unsigned char *yx2pointer(int y, int x);

#endif /* _GAME_H_ */
