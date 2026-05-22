// ChaineMem: Jeudi 31-Déc-92 par Gilles Dridi

#ifndef EXEC_CHAINEMEM_H
#define EXEC_CHAINEMEM_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

#ifndef  EXEC_CHAINONMEM_H
#include <exec/chainonMem.h>
#endif  !EXEC_CHAINONMEM_H

#define MemDispo AvailMem
#define TypeDeMem TypeOfMem

classe ChaineMem: public Noeud {
protegee:
   MOTN        Attributs;
   ChainonMem  *EnTete;
   PTRNEANT    Bas;
   PTRNEANT    Haut; // Haut+1 ex: 10000 et non FFFF attention
   LONGN       OctetLibre;

   amie LONGN AvailMem(LONGN exigences);
   amie MOTN TypeOfMem(PTRNEANT adresse);
   amie ChainonMem *Allocate(ChaineMem *tm, LONGN taille);
   amie NEANT Deallocate(ChaineMem *tm, ChainonMem *bm, LONGN taille);
public:
   ChaineMem(MOTN att, PTRNEANT bas, PTRNEANT haut);
   MOTN attributs() { renvoie Attributs; }
   ChainonMem *enTete() { renvoie EnTete; }
   PTRNEANT bas() { renvoie Bas; }
   PTRNEANT haut() { renvoie Haut; }
   LONGN octetLibre() { renvoie OctetLibre; }
   ChainonMem *ajoute(LONGN taille) {
      renvoie Allocate(moiMeme, taille);
   }
   NEANT enleve(ChainonMem *bm, LONGN taille) {
      Deallocate(moiMeme, bm, taille);
   }
};

#endif
