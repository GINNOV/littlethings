// ReqESmin: Samedi 21-Nov-92 par Gilles Dridi

#ifndef  EXEC_REQESMIN_H
#define  EXEC_REQESMIN_H

#ifndef  EXEC_MESSAGE_H
#include <exec/message.h>
#endif  !EXEC_MESSAGE_H

#ifndef  EXEC_PORTMSG_H
#include <exec/portMsg.h>
#endif  !EXEC_PORTMSG_H

#ifndef  EXEC_ERRES_H
#include <exec/errES.h>
#endif  !EXEC_ERRES_H

classe Peripherique;
classe Unite;

// L'utilisateur ne doit pas fixer le BT_IMMEDIAT pour une ES rapide; c'est
// en utilisant faisES() ou debuteES(), attendsES() que ce bit est géré.
enum Bit_Traitement {
   BT_IMMEDIAT
};

enum Type_Commande {
   CMD_INVALIDE,        // 0
   CMD_INITIALISATION,  // 1
   CMD_LECTURE,         // 2
   CMD_ECRITURE,        // 3
   CMD_MISEAJOUR,       // 4
   CMD_EFFACEMENT,      // 5
   CMD_ARRET,           // 6
   CMD_DEMARRAGE,       // 7
   CMD_VIDANGE,         // 8
};

classe ReqESmin: public Message {
protegee:
   // initialisé par ReqESmin.dialogue(OpenDevice) = adr. bibliothèque
   Peripherique   *AdrPeripherique;
   // initialisé par le pilote, pour mettre en attente la requête
   Unite          *AdrUnite;
   MOTN           Commande;
privee:
   OCTETN         Traitement;
//protegee:
public:
   OCTET          Erreur;

privee:
   // 2 fonctions non héritées; déclarées dans la partie privée
   NEANT reponds();
   NEANT envoie(PortMsg *pd);

   amie classe Peripherique;
   amie classe Unite;
   amie Type_Erreur OpenDevice(TEXTE *nomPeri,
                               OCTETN numUnite,
                               ReqESmin *reqESmin,
                               LONGN options);
   amie NEANT CloseDevice(ReqESmin *reqESmin);
   amie NEANT SendIO(ReqESmin *reqESmin);
   amie Type_Erreur WaitIO(ReqESmin *reqESmin);
   amie Type_Erreur DoIO(ReqESmin *reqESmin);
   amie ReqESmin *CheckIO(ReqESmin *reqESmin);
   amie NEANT AbortIO(ReqESmin *reqESmin);
public:
   ReqESmin(PortMsg *portRep, TEXTE *nomReq= NUL, OCTET pri= 0);
   MOTN commande() { return Commande; }
   OCTETN traitement() { return Traitement; }
   Type_Erreur erreur() { return Erreur; }
   // initialise AdrPeripherique, AdrUnite (appel OUVRE_BIBLI)
   BOOLEEN dialogueAvecLePeripherique(TEXTE *nomPeri,
                                      OCTETN numUnite= 0,
                                      LONGN options= 0) {
      renvoie (0 == OpenDevice(nomPeri, numUnite, moiMeme, options));
   }
   // (appel FERME_BIBLI)
   NEANT termineDialogue() { CloseDevice(moiMeme); }
   // BI_IMMEDIAT à 0 / appel à TraiteES (BeginIO)
   NEANT debuteES() { SendIO(moiMeme); }
   // en plus, enlève la requête du port réponse
   Type_Erreur attendsFinES() { renvoie WaitIO(moiMeme); }
   // BI_IMMEDIAT à 1 / TraiteES, attendsFinES()
   Type_Erreur faisES() { renvoie DoIO(moiMeme); }
   // renvoie la requête si terminée
   ReqESmin *examineES() { renvoie CheckIO(moiMeme); }
   NEANT avorteES() { AbortIO(moiMeme); }
   // fonctions de base
   NEANT initialise();
   NEANT efface();
   NEANT arrete();
   NEANT demarre();
   NEANT vide();
};

#endif
