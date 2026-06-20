// Unité: Samedi 21-Nov-92 par Gilles Dridi
// C'est un (des) endroit où transites les requêtes d'Entrée/Sortie.
// Chaque unité d'un périphérique est associée à un serveur:
// une tâche qui traite les requêtes lorsqu'elles n'ont pas été
// servies immédiatement lors de l'appel à __Peripherique_faisES (BeginIO)
// Cette unité&serveur est construit/détruit (s'il n'y a plus d'abonnés)
// lors du premier/dernier appel à dialogueAv()/termineDialogue() pour
// cette unité. (Tant que la DOS n'est pas vu, c'est statique).

#ifndef  EXEC_UNITE_H
#define  EXEC_UNITE_H

#ifndef  EXEC_PORTMSG_H
#include <exec/portMsg.h>
#endif  !EXEC_PORTMSG_H

#ifndef  EXEC_REQESMIN_H
#include <exec/reqESmin.h>
#endif  !EXEC_REQESMIN_H

#ifndef  EXEC_PERIPHERIQUE_H
#include <exec/peripherique.h>
#endif  !EXEC_PERIPHERIQUE_H

#ifndef  EXEC_SEMAPHORE_H
#include <exec/semaphore.h>
#endif  !EXEC_SEMAPHORE_H

#ifndef  EXEC_SERVEUR_H
#include <exec/serveur.h>
#endif  !EXEC_SERVEUR_H

classe Unite: public PortMsg {
protegee:
   MOTN        Abonnes;
   Semaphore   ServeurActif; // positionne uniquement un drapeau
   Serveur     ServeurES;

   amie classe Serveur;
   amie classe Peripherique;
privee:
   Unite *ouvre(ReqESmin *reqES, LONGN options);
   NEANT ferme();
   NEANT faisES(ReqESmin *reqES);
   NEANT avorteES(ReqESmin *reqES);
   NEANT sersES();
   // fonctions non héritées de portMsg
   NEANT ajoute();
   NEANT enleve();
public:
   Unite(TEXTE *nomServ, OCTET priServ= 0);
   MOTN abonnes() { renvoie Abonnes; }
   BOOLEEN serveurActif() { renvoie ServeurActif.processus() == 0; }
};

#endif
