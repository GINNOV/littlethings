// Pile1K: Mercredi 20-Jan-93 par Gilles Dridi

#ifndef  EXEC_PILE1K_H
#define  EXEC_PILE1K_H

#ifndef  EXEC_PILE_H
#include <exec/pile.h>
#endif  !EXEC_PILE_H

#define	KPILE	256	// ATTN: tailleDe(Vec)= 256*4 != 256

classe TacMin;

classe Pile1K: Pile {
   LONGN    Vec[KPILE];
   TacMin   *Tac;

public:
   Pile1K(TacMin *tac): (), Tac(tac) {}
   LONGN *fond() { renvoie Vec; }
   LONGN *sommet() { renvoie &Vec[KPILE]; }
};

#endif

