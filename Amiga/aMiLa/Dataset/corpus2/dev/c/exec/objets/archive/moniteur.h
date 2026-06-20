// Moniteur: Jeudi 12-Nov-92 par Gilles Dridi
// Moniteur est constitué d'un sémaphore d'exclusion mutuelle (SemExcl)
// afin d'avoir au plus un processus dans le moniteur.
// Le sémaphore hérité sert à bloquer le processus signaleur, toujours,
// pour n'avoir qu'un seul processus à la fois dans le moniteur.

#ifndef EXEC_MONITEUR_H
#define EXEC_MONITEUR_H

#ifndef EXEC_SEMAPHORE_H
#include <exec/semaphore.h>
#endif !EXEC_SEMAPHORE_H

classe Moniteur: public Semaphore {
   Semaphore   SemExcl;
   MOTN        CptSignale; // incrémenté(déc.) par Condition.signale()

   amie class Condition;
public:
   Moniteur();
   NEANT entre();
   NEANT sors();
   ~Moniteur();
};

#endif
