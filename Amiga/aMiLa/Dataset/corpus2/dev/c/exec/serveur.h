// Serveur: Mercredi 31-Mars-93 par Gilles Dridi

#ifndef  EXEC_TACHE_H
#include <exec/tache.h>
#endif  !EXEC_TACHE_H

#ifndef  EXEC_PILE1K_H
#include <exec/pile1K.h>
#endif  !EXEC_PILE1K_H

classe Serveur: public Tache {
   Pile1K   PileServeur;

   NEANT debute() { sers(); } // virtuelle
public:
   Serveur(TEXTE *nom= NULL, OCTET pri= 0);
   virtuelle NEANT sers();
};
