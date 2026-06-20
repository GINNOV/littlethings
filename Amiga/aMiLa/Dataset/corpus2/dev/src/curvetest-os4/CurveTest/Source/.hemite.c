#include <stdio.h>
#include <SDL/SDL.h>
#include "matrix.h"

#define ORDER 1
#define SEGMENTS 15
/* calculates <t^3, t^2, t^1, t^0> */
void t_vect(float *T, float ti);

/*static const float basis_values[]={  2.0f,-2.0f, 1.0f, 1.0f,
                                    -3.0f, 3.0f,-2.0f,-1.0f,
                                     0.0f, 0.0f, 1.0f, 0.0f,
                                     1.0f, 0.0f, 0.0f, 0.0f };*/

static const float basis_values[]={-1.0f, 1.0f,
                                    1.0f, 0.0f};

static const float vector_values[]={  10.0f,  20.0f, 0.0f,
                                     310.0f, 180.0f, 0.0f };

MATRIX_STATIC_CONST(basis,ORDER+1,ORDER+1,basis_values)
MATRIX_STATIC_CONST(vectors,3,2,vector_values)

int main(int argc, char *argv[])
{
  int n;
  float T_values[4]={0,0,0,0};
  MATRIX_STACK(T,1,ORDER+1, T_values)

  matrix_print("vectors",vectors);

  for(n=0; n<=SEGMENTS; n++)
  {
    t_vect(T_values,n/(float)SEGMENTS);
    printf("{%+.2f, %+.2f}\n",T_values[0],T_values[1]);

    {
      matrix *pbasis=matrix_mult(basis,vectors);
      matrix *point;
      point=matrix_mult(pbasis,T);
      matrix_print("basis",basis);
      matrix_print("vectors",vectors);
      matrix_print("point",point);
      matrix_free(point);
      matrix_free(pbasis);
    }
  }

//  SDL_Quit();
  return(0);
}

void t_vect(float *T, float ti)
{
  T[0]=1.0f-ti;
  T[1]=ti;
/*
  int n;
  float t=1;
  for(n=ORDER; n>=0; n--)
//  for(n=0; n<=ORDER; n++)
  {
    T[n]=t;
    t*=ti;
  }*/
}

/*  if(SDL_Init(SDL_INIT_VIDEO)<0)
  {
    fprintf(stderr,"Couldn't init SDL: %s\n",SDL_GetError());
    return(1);
  }*/


/*  if(SDL_SetVideoMode(320,240,32,SDL_ANYFORMAT)<0)
  {
    fprintf(stderr,"Couldn't set video mode: %s\n",SDL_GetError());
    SDL_Quit();
    return(2);
  }*/
