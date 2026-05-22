// EnsSigExc: Mercredi 28-Avr-93 par Gilles Dridi

#ifndef  EXEC_ENSSIGEXC_H
#define  EXEC_ENSSIGEXC_H

#ifndef  EXEC_ENSSIG_H
#include <exec/ensSig.h>
#endif  !EXEC_ENSSIG_H

classe TacMin;

classe EnsSigExc: public EnsSig {
   // fonctions non hérités
   EnsSig attends() { renvoie 0; }
   NEANT signale(TacMin *t) {}
   amie LONGBITS SetExcept(LONGBITS nes, LONGBITS es);
public:
   EnsSigExc(LONGBITS es= 0): (es) {}
   EnsSigExc(classe Signal s): (1<<s.Numero) {}
};

#endif

