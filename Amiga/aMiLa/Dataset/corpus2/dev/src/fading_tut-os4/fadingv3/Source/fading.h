/* 
  Fading with alphablending
  (c) Patrick Kooman, 2002
  contact: patrick@2dgame-tutorial.com
*/

#include <stdio.h>
#include "sdl.h"

/* Fades the given surface in or out to the given screen within the given time */
void fade (SDL_Surface* p_surf_screen, SDL_Surface* p_surf_img, Uint32 ui_seconds, int i_fade_out) ;

/* Cross-Fades the given surfaces onto the given screen within the given time */
void crossFade (SDL_Surface* p_surf_screen, SDL_Surface* p_surf_img1, SDL_Surface* p_surf_img2, Uint32 ui_seconds) ;