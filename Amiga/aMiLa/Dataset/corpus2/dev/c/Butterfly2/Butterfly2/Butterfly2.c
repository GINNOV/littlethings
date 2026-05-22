#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h> // V2

#define MAXW 800
#define MAXH 600

SDL_Window *window;
SDL_Renderer *renderer;
SDL_Surface *butterfly;
SDL_Texture *texture_butterfly;
Mix_Music *musique; // V2

void fin() {
   if (musique) Mix_FreeMusic(musique); // V2
   Mix_CloseAudio(); // V2
   if (texture_butterfly) SDL_DestroyTexture(texture_butterfly);
   if (butterfly) SDL_FreeSurface(butterfly);
   if (renderer) SDL_DestroyRenderer(renderer);
   if (window) SDL_DestroyWindow(window);

   SDL_Quit();

   exit(0);
}

void gestion_evenements() {
   SDL_Event event;

   while (SDL_PollEvent(&event)) {
      switch (event.type) {
         case SDL_KEYDOWN:
            if (event.key.keysym.sym == SDLK_ESCAPE) fin();
            break;
         case SDL_WINDOWEVENT:
            if (event.window.event == SDL_WINDOWEVENT_CLOSE) fin();
            break;
      }
   }
}

int main(int argc, char *argv[]) {
   unsigned int y_ligne; // V2
   int couleur_ligne, couleur_coeff, couleur_debut=0, coeff_debut=1; // V2
   unsigned int butterfly_w=200, butterfly_h=113, vitesse=10;
   int x=0, y=0, sens_x=vitesse, sens_y=vitesse, butterfly_l=butterfly_w, battements=20;

   SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO); // V2

   window = SDL_CreateWindow("Butterfly 2", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, MAXW, MAXH, SDL_WINDOW_SHOWN); // V2
   renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
   SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);

   butterfly = SDL_LoadBMP("Butterfly.bmp");
   SDL_SetColorKey(butterfly, 1, SDL_MapRGB(butterfly->format, 0, 0, 0)); // V2
   texture_butterfly = SDL_CreateTextureFromSurface(renderer, butterfly);
   SDL_Rect srcrect_butterfly = { 0, 0, butterfly_w, butterfly_h };

   Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 1024); // V2
   musique = Mix_LoadMUS("SpaceLam3rs.mp3"); // V2
   Mix_PlayMusic(musique, -1); // V2

   while (1) {
      gestion_evenements();

      SDL_RenderClear(renderer);

      couleur_ligne = couleur_debut; // V2
      couleur_coeff = coeff_debut; // V2

      for (y_ligne=0; y_ligne<MAXH; y_ligne++) { // V2
         SDL_SetRenderDrawColor(renderer, couleur_ligne, couleur_ligne*0.55, 0, 0); // V2
         SDL_RenderDrawLine(renderer, 0, y_ligne, MAXW, y_ligne); // V2
         couleur_ligne = couleur_ligne + couleur_coeff * 5; // V2
         if (couleur_ligne >= 255 || couleur_ligne <= 0) couleur_coeff = -couleur_coeff; // V2
      } // V2

      couleur_debut = couleur_debut + coeff_debut * 15; // V2
      if (couleur_debut >= 255 || couleur_debut <= 0) coeff_debut = -coeff_debut; // V2

      x = x + sens_x;
      y = y + sens_y;
      if (x < 0 || x > MAXW) sens_x = -sens_x;
      if (y < 0 || y > MAXH-butterfly_h) sens_y = -sens_y;

      butterfly_l = butterfly_l + battements;
      if (butterfly_l < 0 || butterfly_l > butterfly_w) battements = -battements;

      SDL_Rect dstrect_butterfly = { x-butterfly_l/2, y, butterfly_l, butterfly_h };
      SDL_RenderCopy(renderer, texture_butterfly, &srcrect_butterfly, &dstrect_butterfly);

      SDL_RenderPresent(renderer);
   }
}
