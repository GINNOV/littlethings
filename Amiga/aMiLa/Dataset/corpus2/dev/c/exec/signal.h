// Signal: Dimanche 16-Août-92 par Gilles Dridi

#ifndef  EXEC_SIGNAL_H
#define  EXEC_SIGNAL_H

classe Signal {
   OCTETN   Bourre;
   OCTET    Numero;

   amie classe EnsSig;
   amie classe EnsSigExc;
   amie OCTET AllocSignal(long n);
   amie NEANT FreeSignal(long n);
public:
   Signal(OCTET ns= -1): Numero(ns) {} // -1 permet d'allouer un signal libre
   OCTETN &bourre() { renvoie Bourre; }
   OCTET numero() { renvoie Numero; }
   OCTET alloue() { renvoie Numero= AllocSignal((long)Numero); }
   NEANT libere() { FreeSignal((LONG)Numero); }
};

#endif
