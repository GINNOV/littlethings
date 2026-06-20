#ifndef GRIND_HEADER
#define GRIND_HEADER

#include <stdio.h>
#include <stdlib.h>
#include <SDL/SDL.h>
#include <time.h>
#include "define.h"
#include "graphic.h"
#include "struct.h"

void generate_map(int map[][NUM_COLS]);
void draw_map(SDL_Surface *surface, SDL_Rect grind, int map[][NUM_COLS]);
void get_free_cell(int map[][NUM_COLS], cell_ind * ind);
void dest_point(cell_ind dest_i, point * dest_p);
bool update_position(SDL_Rect * pos, point dest);

#endif
