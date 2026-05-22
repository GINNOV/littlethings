// PortMsg: Dimanche 16-Août-92 par Gilles Dridi

#ifndef  EXEC_PORTMSG_H
#define  EXEC_PORTMSG_H

#ifndef EXEC_NOEUD_H
#include <exec/noeud.h>
#endif !EXEC_NOEUD_H

#ifndef EXEC_LISTE_H
#include <exec/liste.h>
#endif !EXEC_LISTE_H

#ifndef EXEC_SIGNAL_H
#include <exec/signal.h>
#endif !EXEC_SIGNAL_H

#ifndef EXEC_MESSAGE_H
#include <exec/message.h>
#endif !EXEC_MESSAGE_H

#define TrouvePort FindPort

enum Type_Action {
   AP_SIGNAL= 0,
   AP_INTLOGICIELLE= 1,
   AP_IGNORE= 2,
};

classe TacMin;

classe PortMsg: public Noeud {
protegee:
   // l'octet Action est le premier octet vide de la classe Signal
   Signal   SignalAssocie;
   TacMin   *TacheAreveiller;
   Liste    ListeDesMsg;

   amie NEANT AddPort(const PortMsg *p);
   amie NEANT RemPort(const PortMsg *p);
   amie Message *GetMsg(const PortMsg *p);
   amie Message *WaitPort(const PortMsg *p);
   amie PortMsg *FindPort(const TEXTE *nom);
public:
   PortMsg(TacMin *tacheAreveiller, TEXTE *np= NUL, OCTET pp= 0,
           Type_Action action= AP_SIGNAL);
   OCTETN action() { return SignalAssocie.bourre(); }
   Signal &signalAssocie() { renvoie SignalAssocie; }
   TacMin *tacheAreveiller() { renvoie TacheAreveiller; }
   Liste &listeDesMsg() { renvoie ListeDesMsg; }
   NEANT ajoute() { AddPort(moiMeme); }
   NEANT enleve() { RemPort(moiMeme); }
   Message *prends() { renvoie GetMsg(moiMeme); }
   Message *attends() { renvoie WaitPort(moiMeme); }
};

#endif

