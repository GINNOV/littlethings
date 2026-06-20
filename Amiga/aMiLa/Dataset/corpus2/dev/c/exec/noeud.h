// Noeud: Vendredi 14-Août-92 par Gilles Dridi
// Attention: pas de Noeud.enleve() automatique quand Noeud.~Noeud();
// Remarque: aussi lors d'une destruction par delete!
// Utilise: Noeud, OctetNonSigné, Octet, Texte
// Opérations:
//  succ: N -> N
//  pred: N -> N
//  type: N -> ON
//  pri: N -> O
//  nom: N -> T
//  Z opérations de NoeudMin

#ifndef EXEC_NOEUD_H
#define EXEC_NOEUD_H

#ifndef EXEC_NOEUDMIN_H
#include <exec/noeudMin.h>
#endif !EXEC_NOEUDMIN_H

enum Type_Noeud {
   TN_INCONNU=       0,
   TN_TACHE=         1,
   TN_INTERRUPTION=  2,
   TN_PERIPHERIQUE=  3,
   TN_PORTMSG=       4,
   TN_MESSAGE=       5,
   TN_MSGLIBRE=      6,
   TN_MSGREPONSE=    7,
   TN_RESSOURCE=     8,
   TN_BIBLIOTHEQUE=  9,
   TN_MEMOIRE=      10,
   TN_INTLOGICIELLE=11, // utilisé uniquement par Exec
   TN_POLICE=       12,
   TN_PROCESSUS=    13,
   TN_SEMAPHORE=    14,
   TN_SEMSIGNAL=    15, // sémaphore système
   TN_AMORCE=       16, // BOOTNODE
   TN_MEMAMORCE=    17, // KICKMEM
   TN_GRAPHIQUE=    18,
   TN_MESSAGEFATAL= 19,
   TN_UTILISATEUR= 254,
   TN_EXTENSION=   255
};

classe Noeud: public NoeudMin {
protegee:
   OCTETN   Type;
   OCTET    Pri;
   TEXTE    *Nom;

public:
   Noeud(TEXTE *nom= NUL, Type_Noeud type= TN_INCONNU, OCTET prio= 0);
   Noeud *succ() { renvoie (Noeud *)Succ; }
   Noeud *pred() { renvoie (Noeud *)Pred; }
   OCTETN type() { renvoie Type; }
   OCTET pri() { renvoie Pri; }
   TEXTE *nom() { renvoie Nom; }
};

#endif
