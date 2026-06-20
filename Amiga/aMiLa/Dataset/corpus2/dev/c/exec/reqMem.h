// ReqMem: Jeudi 31-Déc-92 par Gilles Dridi
// Utilisée par la classe ListeMem, la requête contiendra l'adresse du
// bloc de mémoire allouée à la place des exigences fournies.

#ifndef  EXEC_REQMEM_H
#define  EXEC_REQMEM_H

#ifndef  EXEC_CHAINONMEM_H
#include <exec/chainonMem.h>
#endif  !EXEC_CHAINONMEM_H

classe ReqMem {
protegee:
   LONGN Exigences;
   LONGN Taille;

public:
   ReqMem(LONGN taille= 8 /* tailleDe(*moiMeme) */,
          LONGN exigences= 1<<BM_PUBLIQUE);
   LONGN exigences() { renvoie Exigences; }
   PTRNEANT adresse() { renvoie (PTRNEANT)Exigences; }
   LONGN taille() { renvoie Taille; }
   NEANT fixe_adresse(PTRNEANT adr) { Exigences= (LONGN)adr; }
   NEANT fixe_taille(LONGN t) { Taille= t; }
};

#endif
