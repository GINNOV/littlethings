// Remanent: Vendredi 23-Avr-93 par Gilles Dridi

#ifndef  EXEC_REMANENT_H
#define  EXEC_REMANENT_H

#ifndef  EXEC_RESIDENT_H
#include <exec/resident.h>
#endif  !EXEC_RESIDENT_H

#ifndef  EXEC_LISTE_H
#include <exec/liste.h>
#endif  !EXEC_LISTE_H

#ifndef  EXEC_ENSREQMEM_H
#include <exec/ensReqMem.h>
#endif  !EXEC_ENSREQMEM_H

#ifndef  EXEC_TBLMOD_H
#include <exec/tblMod.h>
#endif  !EXEC_TBLMOD_H

classe Remanent: public Resident {
//   Liste    DesEnsMemRemanents;
   TblMod   TabDuMod;

public:
   // nomRes= "nomEnAnglais[.qqch]"
   // chaineId= "nom version.revision (dd MON yyyy)",<cr>,<lf>,<null>
   Remanent(TEXTE *nomRem, TEXTE *chaineId, OCTETN type= TN_INCONNU);
   NEANT initialise(); // virtuelle
   NEANT ajoute(EnsReqMem *);
   NEANT enleve();
};

#endif

