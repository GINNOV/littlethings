// ReqESauto: Lundi 28-Déc-92 par Gilles Dridi

#ifndef  EXEC_REQESAUTO_H
#define  EXEC_REQESAUTO_H

#ifndef  EXEC_REQES_H
#include <exec/reqES.h>
#endif  !EXEC_REQES_H

#ifndef  EXEC_PORTAUTO_H
#include <exec/portAuto.h>
#endif  !EXEC_PORTAUTO_H

classe ReqESauto: public ReqES {
   PortAuto PortDeCom;

privee:
   BOOLEEN dialogueAvecLePeripherique(TEXTE *, OCTETN, LONGN);
   NEANT termineDialogue();
public:
   ReqESauto(TEXTE *nomPeri, OCTETN numUnite= 0, LONGN options= 0);
   ~ReqESauto();
};

#endif
