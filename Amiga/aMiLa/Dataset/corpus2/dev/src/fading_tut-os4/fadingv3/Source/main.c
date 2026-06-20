/* 
  Fading with alphablending
  (c) Patrick Kooman, 2002
  contact: patrick@2dgame-tutorial.com
  
    Demonstrated three ways of fading with the help of SDL:
    -fading in
    -fading out
    -cross fading

  This sample program shows the techniques in action.
  */

#include "fading.h"

/* Display dimemsions */
#define SCREEN_WIDTH          640
#define SCREEN_HEIGHT         480
#define BPP                    16

#undef main

/* Now, our sample main-function: */
int main(int argc, char *argv[]) {
  /* Surfaces */
  SDL_Surface* p_surf_screen = NULL ;
  SDL_Surface* p_surf_img1 = NULL ;
  SDL_Surface* p_surf_img2 = NULL ;
  /* Initialize SDL */
  if (SDL_Init (SDL_INIT_VIDEO) < 0) {
    fprintf (stderr, "Error: could not initialize SDL.\n") ;
    return 0 ;
  }
  /* Setup uup the display */
  if (SDL_VideoModeOK (SCREEN_WIDTH, SCREEN_HEIGHT, BPP, SDL_HWSURFACE) == BPP) {
    /* Hardware */
    if ((p_surf_screen = SDL_SetVideoMode (SCREEN_WIDTH, SCREEN_HEIGHT, BPP, SDL_HWSURFACE)) == NULL) {
      SDL_Quit () ;
      fprintf (stderr, "Error: could not set display. (%s)\n", SDL_GetError ()) ;
      return 0 ;
    }
  }
  else {
    /* Software */
    if ((p_surf_screen = SDL_SetVideoMode (SCREEN_WIDTH, SCREEN_HEIGHT, BPP, SDL_SWSURFACE)) == NULL) {
      SDL_Quit () ;
      fprintf (stderr, "Error: could not set display. (%s)\n", SDL_GetError ()) ;
      return 0 ;
    }
  }
  /* Load the images */
  p_surf_img1 = SDL_DisplayFormat (SDL_LoadBMP ("img1.bmp")) ;
  p_surf_img2 = SDL_DisplayFormat (SDL_LoadBMP ("img2.bmp")) ;
  if (p_surf_img1 == NULL || p_surf_img2 == NULL) {
    SDL_Quit () ;
    fprintf (stderr, "Error: could not load the image.\n") ;
    return 0 ;
  }
  /* Pause */
  SDL_Delay (100) ;
  /* Fade img 1 out */
  fade (p_surf_screen, p_surf_img1, 2, 1) ;
  /* Pause */
  SDL_Delay (2000) ;
  /* Fade img 1 in */
  fade (p_surf_screen, p_surf_img1, 2, 0) ;
  /* Pause */
  SDL_Delay (2000) ;
  /* Cross-fade img2 over img1 */
  crossFade (p_surf_screen, p_surf_img1, p_surf_img2, 2) ;
  /* End-delay of a second */
  SDL_Delay (2000) ;
  SDL_FreeSurface (p_surf_img1) ;
  SDL_FreeSurface (p_surf_img2) ;
  SDL_FreeSurface (p_surf_screen) ;
  SDL_Quit () ;
  return 1 ;
}