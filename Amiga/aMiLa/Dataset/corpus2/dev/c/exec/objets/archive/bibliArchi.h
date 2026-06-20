// BibliArchi: Mercredi 10-Fév-93 par Gilles Dridi
// Construire une bibliothèque par agrégation de cette classe (!=héritage).
// Ne pas oublier de placer les SautBibli de fonctions en premier et
// d'ajouter/enlever la bibliothèque à travers le membre LaBibliotheque.

#ifndef EXEC_BIBLIARCHI_H
#define EXEC_BIBLIARCHI_H

#ifndef  EXEC_BIBLIOTHEQUE_H
#include <exec/bibliotheque.h>
#endif  !EXEC_BIBLIOTHEQUE_H

#ifndef  EXEC_SAUTBIBLI_H
#include <exec/sautBibli.h>
#endif  !EXEC_SAUTBIBLI_H

extern NEANT asmNulleBibli();
extern NEANT asmEpureBibli();
extern NEANT asmFermeBibli();
extern NEANT asmOuvreBibli();

classe BibliArchi {
protegee:
   SautBibli      Nulle; // respecter l'ordre des 4 fonctions
   SautBibli      Epure;
   SautBibli      Ferme;
   SautBibli      Ouvre;
   Bibliotheque   LaBibliotheque;

public:
   BibliArchi(TEXTE *nomBibli, MOTN nbrDeFonc, TEXTE *chaineId);
   Bibliotheque &laBibliotheque() { renvoie LaBibliotheque; }
};

#endif
