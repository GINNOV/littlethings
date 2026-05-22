/* 
  Fading with alphablending
  (c) Patrick Kooman, 2002
  contact: patrick@2dgame-tutorial.com
*/

#include "fading.h"

/* Fades the given surface in or out to the given screen within the given time
 If the image surface is the screen surface (pointer are equal), a copy is made
 first. We must do that because we are overwriting the Screen Surface. */
void fade (SDL_Surface* p_surf_screen, SDL_Surface* p_surf_img, Uint32 ui_seconds, int b_fade_out) {
  /* Becomes the black surface */
  SDL_Surface* p_surf_black = NULL ;
  /* Used when the Screen Surface equals the Image Surface */
  SDL_Surface* p_surf_screen_copy = NULL ;
  /* Used to calculate the steps to make a fade in the given time: */
  Uint32 ui_old_time, ui_curr_time, ui_time_ms ;
  float f_alpha ;
  /* Becomes flag to pass when creating a Surface */
  Uint32 ui_flags = SDL_SRCALPHA ;
  /* Create the black surface in the format of the given screen */
  if ((p_surf_screen->flags & SDL_HWSURFACE)) {
    ui_flags |= SDL_HWSURFACE ;
  }
  else {
    ui_flags |= SDL_SWSURFACE ;
  }
  if ((p_surf_black = SDL_CreateRGBSurface (ui_flags,
    p_surf_screen->w, p_surf_screen->h, 
    p_surf_screen->format->BitsPerPixel, 
    p_surf_screen->format->Rmask, p_surf_screen->format->Gmask, p_surf_screen->format->Bmask,
    p_surf_screen->format->Amask)) == NULL) {
      /* Replace this line with you own error handling / logging */
      fprintf (stderr, "fade: could not create the black Surface. (%s)\n", SDL_GetError ()) ;
      return ;
  }
  /* Fill the Surface with black */
  SDL_FillRect (p_surf_black, NULL, SDL_MapRGB (p_surf_screen->format, 0, 0, 0)) ;
  /* Should we make a copy of the Screen? */
  if (p_surf_screen == p_surf_img) {
    if ((p_surf_screen_copy = SDL_CreateRGBSurface (ui_flags,
    p_surf_screen->w, p_surf_screen->h, 
    p_surf_screen->format->BitsPerPixel, 
    p_surf_screen->format->Rmask, p_surf_screen->format->Gmask, p_surf_screen->format->Bmask,
    p_surf_screen->format->Amask)) == NULL) {
      /* Replace this line with you own error handling / logging */
      fprintf (stderr, "fade: could not create a copy of the Screen Surface. (%s)\n", SDL_GetError ()) ;
      SDL_FreeSurface (p_surf_black) ;
      return ;
    }
    /* Ok, copy surfaces and set surfact pointer */
    SDL_BlitSurface (p_surf_screen, NULL, p_surf_screen_copy, NULL) ;
    p_surf_img = p_surf_screen_copy ;
  }
  /* Ok, we are now ready for the fade. These are the steps (looped):
  1. Draw p_surf_img onto p_surf_screen, just an ordinary blit.
  2. Decrease or increase (depends on fading in or out) the alpha value,
    based on the elapsed time since the previous loop-iteration.
  3. Draw p_surf_black onto p_surf_screen in the current alpha value.*/  
  ui_old_time = SDL_GetTicks () ;
  ui_curr_time = ui_old_time ;
  /* Convert the given time in seconds into miliseconds. */
  ui_time_ms = ui_seconds * 1000 ;
  if (b_fade_out) {
    f_alpha = 0.0 ;
    /* Loop until the alpha value exceeds 255 (this is the maximum alpha value) */
    while (f_alpha < 255.0) {
      /* Draw the image onto the screen */
      SDL_BlitSurface (p_surf_img, NULL, p_surf_screen, NULL) ;
      /* Draw the black surface onto the screen */
      SDL_SetAlpha (p_surf_black, SDL_SRCALPHA, (Uint8) f_alpha) ;
      SDL_BlitSurface (p_surf_black, NULL, p_surf_screen, NULL) ;
      /* Update the timer variables */
      ui_old_time = ui_curr_time ;
      ui_curr_time = SDL_GetTicks () ;
      /* Flip the screen Surface */
      SDL_Flip (p_surf_screen) ;
      /* Calculate the next alpha value */
      f_alpha += 255 * ((float) (ui_curr_time - ui_old_time) / ui_time_ms) ;
    }
  }
  else {
    f_alpha = 255.0 ;
    /* Loop until the alpha value exceeds 255 */
    while (f_alpha > 0.0) {
      /* Draw the image onto the screen */
      SDL_BlitSurface (p_surf_img, NULL, p_surf_screen, NULL) ;
      /* Draw the black surface onto the screen */
      SDL_SetAlpha (p_surf_black, SDL_SRCALPHA, (Uint8) f_alpha) ;
      SDL_BlitSurface (p_surf_black, NULL, p_surf_screen, NULL) ;
      /* Update the timer variables */
      ui_old_time = ui_curr_time ;
      ui_curr_time = SDL_GetTicks () ;
      /* Flip the screen Surface */
      SDL_Flip (p_surf_screen) ;
      /* Calculate the next alpha value */
      f_alpha -= 255 * ((float) (ui_curr_time - ui_old_time) / ui_time_ms) ;
    }
  }
  /* Free the black Surface */
  SDL_FreeSurface (p_surf_black) ;
  /* Free the Screen copy, if used */
  if (p_surf_screen_copy != NULL) {
    SDL_FreeSurface (p_surf_screen_copy) ;
  }
}

/* Cross-Fades the given surfaces onto the given screen within the given time
 If the image surface is the screen surface (pointer are equal), a copy is made
 first. We must do that because we are overwriting the Screen Surface. */
void crossFade (SDL_Surface* p_surf_screen, SDL_Surface* p_surf_img1, SDL_Surface* p_surf_img2, Uint32 ui_seconds) {
  /* Used to calculate the steps to make a fade in the given time: */
  Uint32 ui_old_time, ui_curr_time, ui_time_ms ;
  float f_alpha ;
  /* These are the steps to perform a cross-fade (looped):
  1. Draw p_surf_img1 onto p_surf_screen, just an ordinary blit.
  2. Increase the alpha value, based on the elapsed time since the previous loop-iteration.
  3. Draw p_surf_img2 onto p_surf_screen in the current alpha value.*/  
  ui_old_time = SDL_GetTicks () ;
  ui_curr_time = ui_old_time ;
  /* Convert the given time in seconds into miliseconds. */
  ui_time_ms = ui_seconds * 1000 ;
  f_alpha = 0.0 ;
  /* Loop until the alpha value exceeds 255 (this is the maximum alpha value) */
  while (f_alpha < 255.0) {
    /* Draw the image onto the screen */
    SDL_BlitSurface (p_surf_img1, NULL, p_surf_screen, NULL) ;
    /* Draw the black surface onto the screen */
    SDL_SetAlpha (p_surf_img2, SDL_SRCALPHA, (Uint8) f_alpha) ;
    SDL_BlitSurface (p_surf_img2, NULL, p_surf_screen, NULL) ;
    /* Update the timer variables */
    ui_old_time = ui_curr_time ;
    ui_curr_time = SDL_GetTicks () ;
    /* Flip the screen Surface */
    SDL_Flip (p_surf_screen) ;
    /* Calculate the next alpha value */
    f_alpha += 255 * ((float) (ui_curr_time - ui_old_time) / ui_time_ms) ;
  }
}