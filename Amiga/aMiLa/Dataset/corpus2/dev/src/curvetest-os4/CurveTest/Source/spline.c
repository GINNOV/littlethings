#include <string.h>
#include <SDL/SDL.h>
#include "matrix.h"
#include "parametric.h"
#include "midpoint_line.h"

#define SPLINES 4
#define SEGMENTS 20
#define DKEY 10.0f
#define SPOINTS (SPLINES+3)

#define SPLINE_POS(x) ((x)%(SPOINTS))

static float P[3+SPLINES][AXES]={
  { 160.0f,  10.0f, 0.0f },
  { 210.0f, 120.0f, 0.0f },
  { 300.0f, 200.0f, 0.0f },
  { 160.0f, 160.0f, 0.0f },
  {  40.0f, 200.0f, 0.0f },
  { 140.0f, 120.0f, 0.0f },
  { 160.0f,  10.0f, 0.0f } };


/*static float P1[AXES]={  320.0f,  240.0f,  0.0f};
static float P2[AXES]={  320.0f,  240.0f,  0.0f};
static float P3[AXES]={  10.0f ,   10.0f,  0.0f};
static float P4[AXES]={  10.0f ,   10.0f,  0.0f};*/

/*static float R1[AXES]={ -400.0f, -600.0f,  0.0f};
static float R4[AXES]={ -800.0f,    0.0f,  0.0f};*/
//static const float *grows[]={P1,P2,P3,P4,NULL};

static float T_values[AXES],C_values[AXES*VECTORS],G_values[AXES*VECTORS];

/* bezier spline curve */
static const float M_values[VECTORS*VECTORS] =
    { -1.0f/6.0f,  3.0f/6.0f, -3.0f/6.0f,  1.0f/6.0f,
       3.0f/6.0f, -6.0f/6.0f,  3.0f/6.0f,  0.0f/6.0f,
      -3.0f/6.0f,  0.0f/6.0f,  3.0f/6.0f,  0.0f/6.0f,
       1.0f/6.0f,  4.0f/6.0f,  1.0f/6.0f,  0.0f/6.0f };

MATRIX_STRUCT(T,AXES+1,1,T_values);
MATRIX_STRUCT(C,AXES,VECTORS,C_values)
MATRIX_STRUCT(G,AXES,VECTORS,G_values);
MATRIX_STATIC_CONST(M,VECTORS,VECTORS,M_values);

void set_C(matrix *m), set_T(const float t);
void draw_line(SDL_Surface *screen,const float prev[AXES],const float cur[AXES]);

int main()
{
  int n,redraw=0,running=1,m;
  int vect=0;

  matrix *tm;
  SDL_Surface *screen;
  float *prev;

  if(SDL_Init(SDL_INIT_VIDEO)<0)
  {
    fprintf(stderr,"Couldn't init video: %s\n",SDL_GetError());
    return(1);
  }

  screen=SDL_SetVideoMode(320,240,32,SDL_ANYFORMAT);
  if(screen==NULL)
  {
    fprintf(stderr,"Can't set video mode: %s\n",SDL_GetError());
    SDL_Quit();
    return(2);
  }

  for(n=0; n<SPOINTS; n++)
  {
    SDL_Rect r={ P[n][0]-2, P[n][1]-2,4,4};
    if(n==vect)
      SDL_FillRect(screen,&r,SDL_MapRGBA(screen->format,255,255,0,255));
    else
      SDL_FillRect(screen,&r,SDL_MapRGBA(screen->format,0,0,255,255));
  }

  for(m=0; m<SPOINTS; m++)
  {
    matrix *mg;

    for(n=0; n<4; n++) matrix_setrow(G,n,P[SPLINE_POS(n+m)]);
    mg=matrix_mult(M,G);

    set_T(0.0f);
    tm=matrix_mult(T,mg);
    prev=tm->values;
    free(tm);

    SDL_LockSurface(screen);
    for(n=1; n<=SEGMENTS; n++)
    {
      float t=n/(float)SEGMENTS;
      set_T(t);
      tm=matrix_mult(T,mg);
//      print_matrix("P(T)",tm);
      draw_line(screen,prev,tm->values);
      free(prev);
      prev=tm->values;
      free(tm);
    }
    SDL_UnlockSurface(screen);
    free(prev);
    free(mg);
  }

  SDL_Flip(screen);

  while(running)
  {
    SDL_Event event;
    while(SDL_PollEvent(&event))
    switch(event.type)
    {
    SDLMod mod;
    float delta;
    case SDL_KEYDOWN:
      mod=SDL_GetModState();
      if(mod&KMOD_SHIFT) delta=-DKEY;
      else               delta=DKEY;

      switch(event.key.keysym.sym)
      {
      case SDLK_x:
        P[vect][0] += delta;
        redraw=1;
        break;
      case SDLK_y:
        P[vect][1] += delta;
        redraw=1;
        break;
      case '0': case '1': case '2': case '3': case '4': case '5':
      case '6': case '7': case '8': case '9':
        vect=SPLINE_POS(event.key.keysym.sym-'0');
        redraw=1;
        break;

      case SDLK_ESCAPE:
        fprintf(stderr,"ESC, quitting\n");
        running=0;
        break;
      default:
        break;
      }
      break;

    case SDL_QUIT:
      running=0;
      break;
    }


    if(redraw)
    {
      redraw=0;

      SDL_FillRect(screen,NULL,0);

      for(n=0; n<SPOINTS; n++)
      {
        SDL_Rect r={ P[n][0]-2, P[n][1]-2,4,4};
        if(n==vect)
          SDL_FillRect(screen,&r,SDL_MapRGBA(screen->format,255,255,0,255));
        else
          SDL_FillRect(screen,&r,SDL_MapRGBA(screen->format,0,0,255,255));
      }

      for(m=0; m<SPOINTS; m++)
      {
        matrix *mg;

        for(n=0; n<4; n++) matrix_setrow(G,n,P[SPLINE_POS(n+m)]);
        mg=matrix_mult(M,G);

        set_T(0.0f);
        tm=matrix_mult(T,mg);
        prev=tm->values;
        free(tm);

        SDL_LockSurface(screen);
        for(n=1; n<=SEGMENTS; n++)
        {
          float t=n/(float)SEGMENTS;
          set_T(t);
          tm=matrix_mult(T,mg);
//          print_matrix("P(T)",tm);
          draw_line(screen,prev,tm->values);
          free(prev);
          prev=tm->values;
          free(tm);
        }
        SDL_UnlockSurface(screen);
        free(prev);
        free(mg);
      }
      SDL_Flip(screen);
    }
    else
      SDL_Delay(50);

  }


  SDL_Quit();

  return(0);
}

void set_C(matrix *m)
{
  memcpy(C_values,m->values,sizeof(float)*AXES*VECTORS);
}

void set_T(const float t)
{
  int n;
  float to=1.0f;

  for(n=AXES; n>=0; n--)
//  for(n=0; n<=AXES; n++)
  {
    T_values[n]=to;
    to*=t;
  }
}

void GetLineRect(int x1, int y1, int x2, int y2, SDL_Rect *r)
{
  if(x1<x2)
  {
    r->w=x2-x1;
    r->x=x2;
  }
  else
  {
    r->w=(x1-x2)+1;
    r->x=x1;
  }

  if(y1<y2)
  {
    r->h=(y2-y1)+1;
    r->y=y2;
  }
  else
  {
    r->h=(y1-y2)+1;
    r->y=y1;
  }
}

void draw_line(SDL_Surface *screen,
               const float prev[AXES], 
               const float  cur[AXES])
{
  midpoint_line(screen,prev[0],prev[1],cur[0],cur[1],
    SDL_MapRGBA(screen->format,255,255,255,255));
//  lineRGBA(screen,prev[0],prev[1],cur[0],cur[1],255,255,255,255);
//  GetLineRect(prev[0],prev[1],cur[0],cur[1],rarray+(rpos%(SEGMENTS*2)));
//  rpos++;
}

