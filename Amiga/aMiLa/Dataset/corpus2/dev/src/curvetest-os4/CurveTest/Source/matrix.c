#include <stdio.h>
#include "matrix.h"

#define ALLOCSIZE(TYPE,N) (TYPE *)malloc(sizeof(TYPE)*(N))

static const float A_vals[]={ 0.0f,-1.0f, 2.0f,
                              4.0f,11.0f, 2.0f};
MATRIX_STATIC_CONST(A,3,2,A_vals)

static const float B_vals[]={ 3.0f,-1.0f,
                              1.0f, 2.0f,
                              6.0f, 1.0f };
MATRIX_STATIC_CONST(B,2,3,B_vals)

/*typedef struct matrix
{
  int w,h;
  int freeptr;
  float *values;
} matrix;*/

void matrix_setrow(matrix *m, int r, const float *f)
{
  float *pos=m->values+(r*(m->w));
  memcpy(pos,f,sizeof(float)*m->w);  
}

void matrix_free(matrix *m)
{
  if(m==NULL) return;
  if(m->freeptr) free(m->values);
  free(m);
}

void matrix_test()
{
  matrix *ab=matrix_mult(A,B);
  matrix *ba=matrix_mult(B,A);

  matrix_print("A",A);
  matrix_print("B",B);
  matrix_print("A*B",ab);
  matrix_print("B*A",ba);

  matrix_free(ab);
  matrix_free(ba);
}

void matrix_print(const char *title, const matrix *m)
{
  int x,y;
  if(m==NULL)
  {
    printf("%s:(NULL)\n",title);
    return;
  }


  printf("%s:(%dx%d)\n",title,m->w,m->h);
  for(y=0; y<m->h; y++)
  {
    int x;
    printf(" [");
    for(x=0; x<m->w; x++)
      printf("\t%+.2f",MATRIX_POS(m,x,y));
    printf("\t]\n");
  }

}

matrix *matrix_create(int w, int h)
{
  int n;
  matrix *m;
  if((w<=0)||(h<=0))
    return(NULL);

  m=ALLOCSIZE(matrix,1);

  if(m==NULL)
    return(NULL);

  m->w=w;
  m->h=h;
  m->values=ALLOCSIZE(float,w*h);
  if(m->values==NULL)
  {
    free(m);
    return(NULL);
  }

  for(n=0; n<(w*h); n++)
    m->values[n]=0.0f;

  m->freeptr=1;
  return(m);
}

matrix *matrix_mult(const matrix *a, const matrix *b)
{
//  int x,y;
  int i,j,k;
  matrix *out;
  if((a==NULL)||(b==NULL))
    return(NULL);

  if(a->w != b-> h)
  {
    fprintf(stderr,"Cannot multiply (%dx%d) with (%dx%d)\n",
      a->w,a->h,b->w,b->h);
    return(NULL);
  }

//  fprintf(stderr,"Multiplying (%dx%d) with (%dx%d), result (%dx%d)\n",
//      a->w,a->h,b->w,b->h, a->h, b->w);

//  out=matrix_create(a->h,b->w);
  out=matrix_create(b->w,a->h);
  if(out==NULL) return(NULL);

  for(i=0;i < a->h;i++)
    for(j=0;j < b->w;j++)
      for(k=0;k < a->w;k++)
        MATRIX_POS(out,j,i) += MATRIX_POS(a,k,i)*MATRIX_POS(b,j,k);
/*  for(y=0; y<a->w; y++)
  for(x=0; x<b->h; x++)
  {
    int col;
    for(col=0; col<a->w; col++)
    MATRIX_POS(out,y,x) += MATRIX_POS(a,col,x) * MATRIX_POS(b,y,col);
  }*/

  return(out);
}
