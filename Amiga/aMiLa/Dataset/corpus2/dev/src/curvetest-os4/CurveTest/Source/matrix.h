#ifndef __MATRIX_H__
#define __MATRIX_H__

typedef struct matrix
{
  int w,h;
  int freeptr;
  float *values;
} matrix;

#include <SDL/begin_code.h>

#ifdef __cplusplus
extern "C" {
#endif

DECLSPEC matrix * SDLCALL matrix_create(int w, int h);
DECLSPEC void     SDLCALL matrix_free(matrix *m);
DECLSPEC matrix * SDLCALL matrix_mult(const matrix *a, const matrix *b);
DECLSPEC void     SDLCALL matrix_print(const char *title, const matrix *m);
DECLSPEC void     SDLCALL matrix_test();
DECLSPEC void     SDLCALL matrix_setrow(matrix *m, int r, const float *f);

#define print_matrix matrix_print

#ifdef __cplusplus
}
#endif

#include <SDL/close_code.h>

#define MATRIX_POS(matrix,x,y) (matrix->values[(x)+((y)*matrix->w)])

#define MATRIX_STRUCT(NAME,W,H,VALS) \
  static matrix __ ## NAME ={W,H,0,(float *)VALS}; \
  matrix * NAME = & __ ## NAME;

#define MATRIX_STATIC_CONST(NAME,W,H,VALS) \
  static const matrix __ ## NAME ={W,H,0,(float *)VALS}; \
  const matrix * NAME = &__ ## NAME;

#define MATRIX_STACK(NAME,W,H,VALS) \
  matrix __ ## NAME = {W,H,0,(float *)VALS}; \
  matrix * NAME = & __ ## NAME;

#endif/*__MATRIX_H__*/
