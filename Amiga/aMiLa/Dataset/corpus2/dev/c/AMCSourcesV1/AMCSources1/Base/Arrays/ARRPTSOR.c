/* 
 *
 *   Array  dinamico
 *   ordinamento soft (scambio di puntatori invece che di valori)
 *
 *   Dynamic Array
 *   soft sort ( swap pointers )
 */

#include "arrptsor.h"

void ArrayCreate(TARRAY *a,int isize) {
    TA *p;
    int i;
    a->size=isize;
    CALLOC(p,TA*,isize,sizeof(TA));
    a->array=p;
    CALLOC(a->ptarray,short int*,isize,sizeof(short int));
    for (i=0;i<a->size;i++) a->ptarray[i]=i;
}

void ArrayPut(TARRAY *a,int indice,TA valore) {
    if (indice>=0 && indice<a->size) *(a->array+indice)=valore;
        else FATAL ("indice fuori limite");
}

TA ArrayRead(TARRAY *a,int indice) {
    TA valore;
    if (indice>=0 && indice<a->size) valore=*(a->array+indice);
        else  FATAL ("indice fuori limite");
    return (valore);
}

TA ArrayRead2(TARRAY *a,int ind) {
    TA valore;
    int i;
    int puntatesta;
    int indicepuntatore;
    for (i=0;i<a->size;i++)
        if (a->ptarray[i]==ind)  valore=a->array[i];
    return (valore);
}

static void swap2 (TARRAY *a,int i1,int i2) {
    short int temp;
    temp=a->ptarray[i1];
    a->ptarray[i1]=a->ptarray[i2];
    a->ptarray[i2]=temp;
}

void ArrayBubbleSort(TARRAY *a) {
    int arrayflag,i,swapflag;
    do {
        swapflag=0;
        for (i=0;i<a->size-1;i++) {
            if (a->array[a->ptarray[i]]>a->array[a->ptarray[i+1]]) {
                swap2(a,i,i+1);
                swapflag=1;
            }
        }
    } while (swapflag);
}
