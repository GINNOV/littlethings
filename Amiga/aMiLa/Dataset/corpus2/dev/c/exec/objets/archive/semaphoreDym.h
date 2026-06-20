// Semaphore: Jeudi 17-Sep-92 par Gilles Dridi
// Implémentation du sémaphore de Dijkstra: la variable Processus représente
// le nombre de processus pouvant entrer dans la section critique.
// Processus < 0 indique le nombre de processus en attente.
// Remarque: N processus peuvent accéder à une ressource en lecture, mais
// un seul processus en écriture.

#ifndef EXEC_SEMAPHORE_H
#define EXEC_SEMAPHORE_H

#ifndef EXEC_PORTMSG_H
#include "exec/portMsg.h"
#endif !EXEC_PORTMSG_H

#ifndef EXEC_PORTSTD_H
#include "exec/portStd.h"
#endif !EXEC_PORTSTD_H

#ifndef EXEC_TACHE_H
#include "exec/tache.h"
#endif !EXEC_TACHE_H

classe Semaphore: public PortMsg {
protegee:
   MOT    Processus; // par défaut 1

   // fonctions pour l'implémentation interne
   BOOLEEN procure(Message *msgDem);
   Message* vaque();
public:
   Semaphore(TEXTE *nomSem= NUL, OCTET priSem= 0, MOTN processus= 1);
   MOT processus() { renvoie Processus; }
   // puisJe(NUL) crée un msg & portRéponse associés à la tâche d'appel
   NEANT puisJe(Message *msgDem= NUL);
   NEANT vasY();
   ~Semaphore();
};

#endif
