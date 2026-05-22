// EnsReqMem: Jeudi 31-Déc-92 par Gilles Dridi
// Héritez la classe EnsReqMem et placez les requêtes. Utilisez
// le constructeur EnsReqMem(): Req0(100) pour les initialiser.
// Utiliser fixe_nbr_entree pour fixer le nombre de champ initialise

#ifndef  EXEC_ENSREQMEM_H
#define  EXEC_ENSREQMEM_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

#ifndef  EXEC_REQMEM_H
#include <exec/reqMem.h>
#endif  !EXEC_REQMEM_H

classe EnsReqMem: public Noeud {
protegee:
   MOTN     NbrDEntree;
//   ReqMem   Req0;   // première requête
//   ReqMem   Req1;   // deuxième ...

   amie EnsReqMem *AllocEntry(EnsReqMem *lm);
   amie NEANT FreeEntry(EnsReqMem *lm);
public:
   EnsReqMem(TEXTE *nomEns= "");
   NEANT fixe_nbr_entree(MOTN n) { NbrDEntree= n; }
   MOTN nbrDEntree() { renvoie NbrDEntree; }
   EnsReqMem *alloue() { renvoie AllocEntry(moiMeme); }
   NEANT libere() { FreeEntry(moiMeme); }
};

#endif
