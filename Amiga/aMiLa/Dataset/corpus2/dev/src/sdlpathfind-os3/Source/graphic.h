#ifndef GRAPHIC_HEADER
#define GRAPHIC_HEADER

#include <stdio.h>
#include <stdlib.h>
#include <SDL/SDL.h>
#include <time.h>
#include "define.h"
#include "grind.h"
#include "struct.h"

//graphic functions 
void draw_pixel(SDL_Surface *surface, int x, int y, SDL_Color s_color);
void draw_line(SDL_Surface *surface, point p0, point p1, SDL_Color color);
void draw_square(SDL_Surface *surface, point p, int lato, SDL_Color color);
void draw_square(SDL_Surface *surface,SDL_Rect *rect , SDL_Color border_color, SDL_Color fill_color);
void fill_square(SDL_Surface *surface, SDL_Rect *rect, SDL_Color fill_color);
void colour_path(cell_ind path[], int num_cells, SDL_Surface *surface, SDL_Color border_color, SDL_Color fill_color);
void decolour_path(cell_ind path[], int num_cells, SDL_Surface *surface, SDL_Color border_color, SDL_Color fill_color);

#endif
