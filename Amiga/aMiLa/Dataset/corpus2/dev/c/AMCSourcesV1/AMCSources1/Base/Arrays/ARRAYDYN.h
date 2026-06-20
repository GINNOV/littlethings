/*
 *  array dinamico
 *
 *  Dynamic array
 *
 */

#ifndef ARRAY
#define ARRAY
#include <stdio.h>
#include <stdlib.h>
#include "myerror.h"

typedef int TA;
typedef struct sa{TA* array;int size;} TARRAY;

extern void ArrayPut(TARRAY *,int,TA);
extern TA ArrayRead(TARRAY *,int);
extern void ArrayCreate(TARRAY *,int);
extern void ArrayFree(TARRAY *a);

#endif
