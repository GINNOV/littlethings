// ReqES: Lundi 28-Déc-92 par Gilles Dridi

#ifndef  EXEC_REQES_H
#define  EXEC_REQES_H

#ifndef  EXEC_REQESMIN_H
#include <exec/reqESmin.h>
#endif  !EXEC_REQESMIN_H

#ifndef  EXEC_PORTMSG_H
#include <exec/portMsg.h>
#endif  !EXEC_PORTMSG_H

classe ReqES: public ReqESmin {
//protegee:
public:
   LONGN    DonneeEchangee;
   LONG     LongueurDonnee;
   OCTETN   *TamponDonnee;
   LONGN    Deplacement;

   amie classe Peripherique;
public:
   ReqES(PortMsg *portRep, TEXTE *nomReq= 0, OCTET pri= 0);
   LONGN donneeEchangee() { renvoie DonneeEchangee; }
   LONG longueurDonnee() { renvoie LongueurDonnee; }
   OCTETN *tamponDonnee() { renvoie TamponDonnee; }
   LONGN deplacement() { renvoie Deplacement; }
   // lectures et écritures synchrones
   LONGN ecris(OCTETN *tpDon, LONG lg);
   LONGN lis(OCTETN *tpDon, LONG lg= -1); // lire jusqu'à fin
   LONGN metAjour(OCTETN *tpDon, LONG lg);
};

#endif
