// Message: Dimanche 16-Août-92 par Gilles Dridi
// Les messages avec contenu sont obtenus par héritage de cette classe.

#ifndef  EXEC_MESSAGE_H
#define  EXEC_MESSAGE_H

#ifndef EXEC_NOEUD_H
#include <exec/noeud.h>
#endif !EXEC_NOEUD_H

classe PortMsg;

classe Message: public Noeud {
protegee:
   PortMsg  *PortReponse;
   MOTN     Longueur;

   amie NEANT ReplyMsg(Message *m);
   amie NEANT PutMsg(PortMsg *pm, Message *m);
public:
   Message(PortMsg *portRep= NUL, TEXTE *nomMsg= NUL, OCTET pri= 0);
   PortMsg *portReponse() { renvoie PortReponse; }
   MOTN longueur() { renvoie Longueur; }
   NEANT reponds() { ReplyMsg(moiMeme); }
   NEANT envoie(PortMsg *portDest) { PutMsg(portDest, moiMeme); }
};

#endif

