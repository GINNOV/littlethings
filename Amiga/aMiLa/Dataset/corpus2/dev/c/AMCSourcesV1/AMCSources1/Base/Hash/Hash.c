/* 
 *
 *  Tabella di Hash
 *
 *  Hash table
 *
 */



#include <hash.h>

static int hash (THASH *h, TKEY k) {
       return (k % h->size);
}

static int rehash ( THASH *h,int i) {
       return ((i+1)% h->size);
}




int HashPut (THASH *h, THASHITEM i, TKEY k){
    int j,f;
    f=j=hash (h,k);

    while(h->hash[j].key!=k 
                 &&
          h->hash[j].key!=FREE
                 &&
          h->hash[j].key!=DELETED){
                              j=rehash(h,j);
                              if (j==f) return(FALSE);
                              }
    if (h->hash[j].key == FREE || h->hash[j].key == DELETED) {
           h->hash[j].key = k;
           h->hash[j].info= i;
           return(TRUE);
    }
}

THASHITEM HashGet (THASH *h, TKEY k, int *trovato) {
    int j,i;
    i=j=hash(h,k);
    while (h->hash[j].key != k || h->hash[j].key == DELETED){
        j=rehash(h,j);
        if (i==j) break;
        }
    if (h->hash[j].key==k) {
        *trovato =TRUE; h->hash[j].key = DELETED;
        return h->hash[j].info; }
    else
        {
         *trovato =FALSE;
         return ;
        }
}


THASHITEM HashRead (THASH *h, TKEY k, int *trovato) {
    int j,i;
    i=j=hash(h,k);
    while (h->hash[j].key != k || h->hash[j].key == DELETED){
        j=rehash(h,j);
        if (i==j) break;
        }
    if (h->hash[j].key==k) {
        *trovato =TRUE;
        return h->hash[j].info; }
    else
        {
         *trovato =FALSE;
         return ;
        }
}


void HashCreate(THASH *a,int size){
  THASHELEM *p;
  int i;
  a->size=size;
  CALLOC(p,THASHELEM*,size,sizeof(THASHELEM));
  a->hash=p;
  for (i=0; i<size; i++){
  a->hash[i].key=FREE;
  }
  }
