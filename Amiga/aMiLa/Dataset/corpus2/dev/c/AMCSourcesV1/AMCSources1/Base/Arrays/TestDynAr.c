/* 
 *
 *  Prova array dinamico
 *
 *  Dynamic array test
 *
 */

#include "arraydin.h"

void main()
{
    int ind=0,i,max;
    TA num;
    TARRAY ad;
    printf("\n massimo numero di elementi");
    scanf ("%d",&max);
    ArrayCreate(&ad,max);
    do {
        printf("\nInserisci numero %d ",ind);
        scanf ("%d",&num);
        if (num==-1) break;
        ArrayPut (&ad,ind,num);
        ind++;
    } while (ind<=max-1);

    for (i=0;i<=ad.size-1;i++)
        printf("Posizione %d  Numero %d\n",i,ArrayRead(&ad,i));
}
