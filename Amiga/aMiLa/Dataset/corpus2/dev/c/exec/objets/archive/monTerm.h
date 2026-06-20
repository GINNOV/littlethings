// MonTerm: Vendredi 05-Fév-93 par Gilles Dridi
// Ce moniteur de terminaison sert à la synchronisation de fin de
// tâche (entre l'enfante et la parente qui l'a lancée)

#ifndef  EXEC_MONTERM_H
#define  EXEC_MONTERM_H

#ifndef  EXEC_MONITEUR_H
#include <exec/moniteur.h>
#endif  !EXEC_MONITEUR_H

#ifndef  EXEC_CONDITION_H
#include <exec/condition.h>
#endif  !EXEC_CONDITION_H

classe MonTerm: public Moniteur {
   Condition   Deces;
   BOOLEEN     BoolDeces;

public:
   MonTerm();
   NEANT sigTerm(); // la tâche enfante se termine
   NEANT attTerm(); // la tâche parente attend la terminaison d'une enfante
};

#endif
