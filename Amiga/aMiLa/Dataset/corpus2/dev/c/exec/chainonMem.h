// ChainonMem: Jeudi 31-Déc-92 par Gilles Dridi
// Pour allouer de la mémoire appeler AjouteChainonMem
// Pour libérer de la mémoire appeler EnleveChainonMem ou enleve()

#ifndef EXEC_CHAINONMEM_H
#define EXEC_CHAINONMEM_H

enum Bit_Memoire {
   BM_PUBLIQUE=      0,
   BM_SPECIALISEE=   1, // (CHIP)
   BM_RAPIDE=        2, // (FAST)
   BM_PROPRE=       16,
   BM_MAXIMUM=      17
};

classe ChainonMem {
protegee:
   ChainonMem  *Suivant;
   LONGN    Taille;

   amie PTRNEANT AllocMem(LONGN taille, LONGN exigences);  // pas utiliser
   amie PTRNEANT AllocAbs(LONGN taille, PTRNEANT adresse); // idem
   amie NEANT FreeMem(PTRNEANT adresse, LONGN taille);     // idem
   amie PTRNEANT AllocVec(LONGN taille, LONGN exigences);
   amie NEANT FreeVec(PTRNEANT adresse);
   inline amie PTRNEANT AjouteChainonMem(LONGN taille,
                                         LONGN exig= 1<<BM_PUBLIQUE) {
      renvoie AllocVec(taille, exig);
   }
   inline amie NEANT EnleveChainonMem(PTRNEANT adresse) {
      FreeVec(adresse);
   }
public:
   ChainonMem();
   ChainonMem *suivant() { renvoie Suivant; }
   LONGN taille() { renvoie Taille; }
   NEANT enleve() { FreeVec(moiMeme); }
};

#endif
