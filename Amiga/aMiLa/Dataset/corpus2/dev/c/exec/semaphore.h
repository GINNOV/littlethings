// Semaphore: Mercredi 27-Jan-93 par Gilles Dridi
// Implémentation du sémaphore de Dijkstra: la variable Processus représente
// le nombre de processus pouvant entrer dans la section critique.
// Processus < 0 indique le nombre de processus en attente.
// Remarque: N processus peuvent accéder à une ressource en lecture, mais
// un seul processus en écriture.

#ifndef  EXEC_SEMAPHORE_H
#define  EXEC_SEMAPHORE_H

#ifndef  EXEC_ENSSIG_H
#include <exec/ensSig.h>
#endif  !EXEC_ENSIG_H

#ifndef  EXEC_FILE_H
#include <exec/file.h>
#endif  !EXEC_FILE_H

#ifndef  EXEC_PATIENT_H
#include <exec/patient.h>
#endif  !EXEC_PATIENT_H

classe Semaphore: File {
protegee:
   MOT    Processus; // par défaut 1

public:
   Semaphore(MOTN processus= 1);
   MOT processus() { renvoie Processus; }
   NEANT puisJe();
   NEANT vasY();
};

#endif
