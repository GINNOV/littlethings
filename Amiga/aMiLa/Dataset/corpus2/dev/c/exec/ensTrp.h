// EnsTrp: Lundi 01-Fév-93 par Gilles Dridi

#ifndef  EXEC_ENSTRP_H
#define  EXEC_ENSTRP_H

#ifndef  EXEC_TRAPPE_H
#include <exec/trappe.h>
#endif  !EXEC_TRAPPE_H

classe EnsTrp {
   MOTN  Trappes;

public:
   EnsTrp(MOTN trp= 0): Trappes(trp) {}
   EnsTrp(classe Trappe trp): Trappes(1<<trp.Numero) {}
   EnsTrp trappes() { renvoie Trappes; }
   EnsTrp lisTrappe(classe Trappe trp) { renvoie Trappes&(1<<trp.Numero); }
   EnsTrp leveTrappe(classe Trappe trp) { renvoie Trappes|= (1<<trp.Numero); }
   EnsTrp abaisseTrappe(class Trappe trp) {
      renvoie Trappes&= ~(1<<trp.Numero);
   }
};

#endif

