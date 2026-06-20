// SemSig: Vendredi 02-Oct-92 par Gilles Dridi
// Semaphore du système, mieux vaut utiliser semaphore.h pour ses prg.

#ifndef EXEC_SEMSIG_H
#define EXEC_SEMSIG_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif   !EXEC_NOEUD_H

#ifndef  EXEC_LISTEMIN_H
#include <exec/listeMin.h>
#endif   !EXEC_LISTEMIN_H

#ifndef  EXEC_PATIENT_H
#include <exec/patient.h>
#endif   !EXEC_PATIENT_H

#define TrouveSemaphore FindSemaphore

classe TacMin;

classe SemSig: public Noeud {
   MOT      Compteur;
   ListeMin QueueDAttente;
   Patient  LienMultiple;
   TacMin   *Proprietaire;
   MOT      CompteurDeQueue;

   amie NEANT AddSemaphore(SemSig *s);
   amie BOOLEEN AttemptSemaphore(SemSig *s);
   amie SemSig *FindSemaphore(TEXTE *t);
   amie NEANT InitSemaphore(SemSig *s);
   amie NEANT ObtainSemaphore(SemSig *s);
   amie NEANT ObtainSemaphoreList(SemSig *s);
   amie NEANT ReleaseSemaphore(SemSig *s);
   amie NEANT ReleaseSemaphoreList(SemSig *s);
   amie NEANT RemSemaphore(SemSig *s);
public:
   SemSig(TEXTE *ns= NUL, OCTET ps= 0);
   NEANT ajoute() { AddSemaphore(moiMeme); }
   NEANT enleve() { RemSemaphore(moiMeme); }
   NEANT puisJe() { ObtainSemaphore(moiMeme); }
   NEANT vasY() { ReleaseSemaphore(moiMeme); }
};

#endif
