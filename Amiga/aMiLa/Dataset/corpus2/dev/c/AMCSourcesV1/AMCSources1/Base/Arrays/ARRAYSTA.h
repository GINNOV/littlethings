/*
 *  Array statico, massimo SIZE elementi
 *
 *  Static array max SIZE elements
 *
 */

#ifndef ARRAY
#define ARRAY
#include <stdio.h>
#include <stdlib.h>
#include "myerror.h"

#define SIZE 30

typedef int TA;
typedef TA TARRAY[SIZE];

extern void ArrayPut(TARRAY,int,TA);
extern TA ArrayRead(TARRAY,int);
#endif
