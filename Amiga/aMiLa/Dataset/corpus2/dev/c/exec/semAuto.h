// SemAuto: Lundi 05-Oct-92 par Gilles Dridi
// Semaphore du système, mieux vaut utiliser semaphore.h pour ses prg.

#ifndef  EXEC_SEMAUTO_H
#define  EXEC_SEMAUTO_H

#ifndef EXEC_SEMSIG_H
#include <exec/semSig.h>
#endif !EXEC_SEMSIG_H

classe SemAuto: public SemSig {
privee:
   NEANT ajoute();
   NEANT enleve();
public:
   SemAuto(TEXTE *nomPort= NUL, OCTET priPort= 0);
   ~SemAuto();
};

#endif
