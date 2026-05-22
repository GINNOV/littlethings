// EnsSig: Dimanche 16-Août-92 par Gilles Dridi

#ifndef  EXEC_ENSSIG_H
#define  EXEC_ENSSIG_H

#ifndef  EXEC_SIGNAL_H
#include <exec/signal.h>
#endif  !EXEC_SIGNAL_H

classe TacMin;

classe EnsSig {
protegee:
   LONGBITS Signaux;

   amie LONGBITS SetSignal(LONGBITS nes, LONGBITS es);
   amie LONGBITS Wait(LONGBITS);
   amie NEANT Signal(TacMin *t, LONGBITS es);
public:
   EnsSig(LONGBITS es= 0): Signaux(es) {}
   EnsSig(classe Signal s): Signaux(1<<s.Numero) {}
   long signaux() { renvoie Signaux; }
   amie EnsSig operator |(EnsSig es1, EnsSig es2) {
      renvoie es1.Signaux|es2.Signaux;
   }
   amie EnsSig operator |(LONGBITS es1, EnsSig es2) {
      renvoie es1|es2.Signaux;
   }
   amie EnsSig operator |(EnsSig es1, LONGBITS es2) {
      renvoie es1.Signaux|es2;
   }
   BOOLEEN lis(classe Signal s) { renvoie Signaux&(1<<s.Numero); }
   EnsSig affirme(classe Signal s) { renvoie Signaux|= (1<<s.Numero); }
   EnsSig nie(class Signal s) { renvoie Signaux&= ~(1<<s.Numero); }
   EnsSig attends() { renvoie Wait(Signaux); }
   NEANT signale(TacMin *t) { Signal(t, Signaux); }
};

#endif

