// PortAuto: Dimanche 16-Août-92 par Gilles Dridi

#ifndef  EXEC_PORTAUTO_H
#define  EXEC_PORTAUTO_H

#ifndef EXEC_PORTMSG_H
#include <exec/portMsg.h>
#endif !EXEC_PORTMSG_H

classe PortAuto: public PortMsg {
privee:
   NEANT ajoute(); // fonctions non utiles car
   NEANT enleve(); // faites par PortAuto / ~PortAuto
public:
   PortAuto(TEXTE *nomPort= NUL, OCTET priPort= 0);
   ~PortAuto();
};

#endif
