#include <SDL2/SDL.h>

#define MAXW 800
#define MAXH 600

SDL_Window *window;
SDL_Renderer *renderer;
SDL_Surface *butterfly;
SDL_Texture *texture_butterfly;

void fin() {
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
   unsigned int butterfly_w=200, butterfly_h=113, vitesse=10;
   int x=0, y=0, sens_x=vitesse, sens_y=vitesse, butterfly_l=butterfly_w, battements=20;

   SDL_Init(SDL_INIT_VIDEO);

   window = SDL_CreateWindow("Butterfly", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, MAXW, MAXH, SDL_WINDOW_SHOWN);
   renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
   SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);

   butterfly = SDL_LoadBMP("Butterfly.bmp");
   texture_butterfly = SDL_CreateTextureFromSurface(renderer, butterfly);
   SDL_Rect srcrect_butterfly = { 0, 0, butterfly_w, butterfly_h };

   while (1) {
      gestion_evenements();

      SDL_RenderClear(renderer);

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
