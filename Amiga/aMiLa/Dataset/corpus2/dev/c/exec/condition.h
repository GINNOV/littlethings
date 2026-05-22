// Condition: Jeudi 12-Nov-92 par Gilles Dridi
// Remarque: un "signal" sur une condition que personne "n'attend" est
// perdu; le prochain attends() sera bloquant sur cette condition.
// Utilisation:
// Une condition ne peut pas être testée, seules les fonctions(primitives)
// signale() et attends() sur une condition sont possibles.
// Une variable est généralement associée à une condition pour mémoriser
// la réalisation d'une condition. On dit souvent variable-condition.

#ifndef  EXEC_CONDITION_H
#define  EXEC_CONDITION_H

#ifndef  EXEC_SEMAPHORE_H
#include <exec/semaphore.h>
#endif  !EXEC_SEMAPHORE_H

#ifndef  EXEC_MONITEUR_H
#include <exec/moniteur.h>
#endif  !EXEC_MONITEUR_H

classe Condition: public Semaphore {
   Moniteur    *DuMoniteur;
   MOTN        CptAttends; // incrémenté(déc.) par Condition.attends()

public:
   Condition(Moniteur *duMoniteur);
   NEANT attends();
   NEANT signale();
};

#endif
