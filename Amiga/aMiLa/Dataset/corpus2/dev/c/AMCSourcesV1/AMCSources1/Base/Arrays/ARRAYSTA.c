/* 
 *  Array statico max SIZE  elementi
 *  Static Array max SIZE elements
 */

#include "arraysta.h"

void ArrayPut(TARRAY a,int indice,TA valore) {
    if (indice>=0 && indice<SIZE)
        a[indice]=valore;
        else FATAL ("indice fuori limite");
}

TA ArrayRead(TARRAY a,int indice) {
    TA valore;
    if (indice>=0 && indice<SIZE) {
        valore=a[indice];
        return (valore);
    }
    else FATAL ("indice fuori limite");
}
