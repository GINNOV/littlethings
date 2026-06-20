// Trappe: Lundi 17-Août-1992 par Gilles Dridi

#ifndef EXEC_TRAPPE_H
#define EXEC_TRAPPE_H

classe Trappe {
   OCTET    Numero;

   amie classe EnsTrp;
   amie LONG AllocTrap(long n);
   amie NEANT FreeTrap(long n);
public:
   Trappe(OCTET n= -1): Numero(n) {} // -1 allouera une trappe libre
   OCTET numero() { renvoie Numero; }
   OCTET alloue() { renvoie Numero= AllocTrap((LONG)Numero); }
   NEANT libere() { FreeTrap((long)Numero); }
};

#endif
