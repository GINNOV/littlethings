// TacAuto: Mercredi 20-Jan-93 par Gilles Dridi
// Remarque: la structure de tâche, la pile "en dur" sont réservées sur
// la pile de la tâche parente quand l'objet est automatique.
// Pour avoir un objet persistant, utiliser une construction dynamique.

#ifndef  EXEC_TACAUTO_H
#define  EXEC_TACAUTO_H

#ifndef  EXEC_TACHE_H
#include <exec/tache.h>
#endif  !EXEC_TACHE_H

#ifndef  EXEC_PILE1K_H
#include <exec/pile1K.h>
#endif  !EXEC_PILE1K_H

#ifndef  EXEC_SEMAPOHORE_H
#include <exec/semaphore.h>
#endif  !EXEC_SEMAPHORE_H

classe TacAuto: public Tache {
   Pile1K   PileTache;
   Semaphore SDT;

privee:
   // saute au corps de la fonction que définira l'utilisateur enfin,
   // se termine.
   NEANT debute() { corps(); termine(); } // virtuelle
   // termine() synchronise la tâche fille et sa parente
   NEANT termine();
   // fontions non héritées; plus publiques car, dès lors automatiques
   Tache *ajoute();
   NEANT enleve();
public:
   TacAuto(TEXTE *nom= NUL, OCTET pri= 0);
   virtuelle NEANT corps();
   ~TacAuto();
};

#endif
