// TblMod: Vendredi 23-Avr-93 par Gilles Dridi
// Le TblMod est ici associé à un seul module résident.
// Les modules résidants en ROM sont accesibles pareillement.

#ifndef  EXEC_TABMOD_H
#define  EXEC_TABMOD_H

#ifndef  EXEC_PTRRES_H
#include <exec/ptrRes.h>
#endif  !EXEC_PTRRES_H

#ifndef  EXEC_ITERTBLMOD_H
#include <exec/iterTblMod.h>
#endif  !EXEC_ITERTBLMOD_H

classe TblMod {
   PtrRes   Module1; // la première entrée doit être en début de classe
   // ...
   PtrRes   Fin;

public:
   TblMod(Resident *mod1);
   NEANT chaine(TblMod *);
   // il faudrait memoriser l'@ de la structure precedente pour eviter
   // d'avoir a parcourir depuis le debut (on n'a pas le debut d'ailleurs !)
//   NEANT rompts();
};

#endif

