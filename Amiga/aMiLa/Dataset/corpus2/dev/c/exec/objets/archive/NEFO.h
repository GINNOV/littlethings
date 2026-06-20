// NulleEpureFermeOuvre: Vendredi 15-Jan-93 par Gilles Dridi

#ifndef EXEC_NEFO_H
#define EXEC_NEFO_H

#ifndef  EXEC_SAUTBIBLI_H
#include <exec/sautBibli.h>
#endif  !EXEC_SAUTBIBLI_H

extern NEANT asmNulle();
extern NEANT asmEpure();
extern NEANT asmFerme();
extern NEANT asmOuvre();

classe NEFO {
protegee:
   // ne pas changer l'ordre des 4 sauts
   SautBibli Nulle;
   SautBibli Epure;
   SautBibli Ferme;
   SautBibli Ouvre;

public:
   NEFO();
};

#endif
