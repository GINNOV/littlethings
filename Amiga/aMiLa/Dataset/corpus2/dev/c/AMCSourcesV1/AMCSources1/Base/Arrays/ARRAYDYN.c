/*
 *      Array dinamico
 *      Dynamic array
 */

#include "arraydyn.h"

void ArrayCreate(TARRAY *a,int isize) {
    TA *p;
    a->size=isize;
    CALLOC(p,TA*,isize,sizeof(TA));
    a->array=p;
    }

void ArrayPut(TARRAY *a,int indice,TA valore) {
    if (indice>=0 && indice< a->size) *(a->array+indice)=valore;
        else FATAL ("indice fuori limite");
}

TA ArrayRead(TARRAY *a,int indice) {
    TA valore;
    if (indice>=0 && indice< a->size) {
        valore=*(a->array+indice);
        return (valore);
   } else
       FATAL ("indice fuori limite");
}

void ArrayFree(TARRAY *a) {
    free(a->array);
    a->size=0;
}
