/* 
 *
 *  Array dinamico con ordinamento soft
 *
 *  Dynamic array with soft sort
 */

#ifndef ARRAY
#define ARRAY
#include <stdio.h>
#include <stdlib.h>
#include "myerror.h"

typedef int TA;
typedef struct sa {
    TA* array;
    int size;
    short int *ptarray;
} TARRAY;

extern void ArrayPut(TARRAY *a,int indice,TA valore);
extern TA ArrayRead(TARRAY *a,int indice);
extern TA ArrayRead2(TARRAY *a,int indice);
extern void ArrayCreate(TARRAY *a,int size);
extern void ArrayBubbleSort (TARRAY *);
#endif
