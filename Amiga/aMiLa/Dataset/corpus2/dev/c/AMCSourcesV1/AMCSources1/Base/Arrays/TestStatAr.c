/*
 *  Prova array statico max 30
 *
 *  Test static array max 30
 *
 */

#include <array.h>

void main()
{
    int ind,i;
    TA num;
    TARRAY ad;
    do {
        printf("\nInserisci numero e indice ");
        scanf ("%d %d",&num,&ind);
        if (num==-1) break;
        ArrayPut (ad,ind,num);
    } while (1);
    for (i=0;i<=SIZE;i++)
        printf("Posizione %d  Numero %d\n",i,ArrayRead(ad,i));
}
