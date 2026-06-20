/* 
 *  Tabella di Hash
 *
 *  Hash table
 *
 */

#ifndef HASH
#define HASH
#include <stdio.h>
#include <stdlib.h>
#include "myerror.h"

#define FREE    -1
#define DELETED -2

   typedef int TKEY;
   typedef int THASHITEM;  /* informazione associata */
   typedef struct s0 {
                      TKEY       key;
                      THASHITEM  info;
                      } THASHELEM;

   typedef struct s1 {
                      int        size;
                      THASHELEM *hash;
                      } THASH;

   extern void HashCreate (THASH *h, int size);
     /*
      * Alloca lo spazio in memoria dinamica
      */

   extern int HashPut     (THASH *h, THASHITEM i,TKEY k);
     /*
      * Ritorna FALSE se non riesce ad allocare il dato desiderato
      * TRUE se tutto ok
      */

   extern THASHITEM HashGet(THASH *h, TKEY k, int *trovato);
   extern THASHITEM HashRead (THASH *h, TKEY k, int *trovato);
     /*
      * Entrambe ritornano il dato data la chiave;
      * get rimuove il dato, read no
      *
      * se il dato e' stato trovato trovato = TRUE
      * altrimenti trovato = FALSE
      */

#endif

