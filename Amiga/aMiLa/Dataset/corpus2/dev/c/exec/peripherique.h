// Périphérique: Vendredi 20-Nov-92 par Gilles Dridi
// Un périphérique est constitué d'une bibliothèque et d'unités
// Les communications avec celui-ci se font essentiellement par messages:
// voir les classes ReqESmin, ReqES, ReqESstd.

#ifndef  EXEC_PERIPHERIQUE_H
#define  EXEC_PERIPHERIQUE_H

#ifndef  EXEC_REQES_H
#include <exec/reqES.h>
#endif  !EXEC_REQES_H

#ifndef  EXEC_BIBLIOTHEQUE_H
#include <exec/bibliotheque.h>
#endif  !EXEC_BIBLIOTHEQUE_H

#ifndef	EXEC_UNITE_H
#include <exec/unite.h>
#endif	!EXEC_UNITE_H

#ifndef	EXEC_ERRES_H
#include <exec/errES.h>
#endif	!EXEC_ERRES_H

extern NEANT asmNullePeri();
extern NEANT asmEpurePeri();
extern NEANT asmFermePeri();
extern NEANT asmOuvrePeri();
extern NEANT asmFaisES();
extern NEANT asmAvorteES();

classe Peripherique: public Bibliotheque {
   NEANT fermeLa(); // fonction non héritée
protegee:
   // fonctions définies dans foncPeri.cpmry (elles sont redéfinies)
   Peripherique *ouvre(ReqESmin *reqES, OCTETN numUnite, LONGN options);
   PTRBCPL ferme(ReqESmin *reqES);
   PTRBCPL epure();
   NEANT faisES(ReqESmin *reqES);
   NEANT avorteES(ReqESmin *reqES);
   MOTN  nbrDeFonc() { renvoie nbrDeFoncStd()+2; } // virtuelle (6=fini)

   amie classe Unite;
   amie NEANT AddDevice(Peripherique *peri);
   amie ENTIER RemDevice(Peripherique *peri);
public:
   // nomPeri= "nomEnAnglais.device"
   // chaineId= "nom version.revision (dd MON yyyy)",<cr>,<lf>,<null>
   Peripherique(TEXTE *nomPeri, TEXTE *chaineId): 
		(nomPeri, chaineId) {}
   NEANT ajoute() {
      TailleNegative= -nbrDeFonc()*tailleDe(SautBibli);
      AddDevice(moiMeme);
   }
   NEANT enleve() { RemDevice(moiMeme); }
	// Ce périphérique n'a pas encore d'unité
   virtuelle Unite *uniteValide(OCTETN numUnite) { if (numUnite) {} renvoie NULLE; }
	// Les commandes périphériques sont toutes lentes (par défaut)
   virtuelle BOOLEEN estCmdImmediate(MOTN cmd) { if (cmd) {} renvoie FAUX; }

   virtuelle NEANT invalide(ReqESmin *reqES);
   virtuelle NEANT initialise(ReqESmin *reqES);
   virtuelle NEANT lis(ReqES *reqES);
   virtuelle NEANT ecris(ReqES *reqES);
   virtuelle NEANT metAjour(ReqES *reqES);
   virtuelle NEANT efface(ReqESmin *reqES);
   virtuelle NEANT arrete(ReqESmin *reqES);
   virtuelle NEANT demarre(ReqESmin *reqES);
   virtuelle NEANT vide(ReqESmin *reqES);
};

#endif
