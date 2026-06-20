// Bibliotheque: Samedi 24-Avr-93 par Gilles Dridi
// asmFoncBibli.a: les appels assembleurs à ouvre(), ferme(), ...
// Pour débogue cette classe, le faire avec la classe BibliMin
// FreeMem(moiMeme, TaillePositive-TailleNegative) lorsque MakeLibrary();

#ifndef EXEC_BIBLIOTHEQUE_H
#define EXEC_BIBLIOTHEQUE_H

#ifndef EXEC_BIBLIMIN_H
#include <exec/bibliMin.h>
#endif !EXEC_BIBLIMIN_H

// asmFoncBibli.a: Procedure pour SautBibli
extern	NEANT asmNulleBibli();
extern	NEANT asmEpureBibli();
extern	NEANT asmFermeBibli();
extern	NEANT asmOuvreBibli();

classe Bibliotheque: public BibliMin {
protegee:
   // fonctions définies dans foncBibli.cp
	Bibliotheque	* ouvre();
	PTRBCPL			ferme();
   PTRBCPL 			epure();
	long				nulle();	
   virtuelle PTRBCPL decharge() { renvoie NULLE; }
public:
   // nomBibli= "nomEnAnglais.library"
   // chaineId= "nom version.revision (dd.MON.yyyy)",<cr>,<lf>,<null>
   Bibliotheque(TEXTE *nomBibli, TEXTE *chaineId):
                (nomBibli, chaineId) {}
   virtuelle MOTN nbrDeFonc() { renvoie nbrDeFoncStd(); }
   // ajoute() est redéfinie pour utiliser la virtuelle nbrDeFonc()
   NEANT ajoute() {
      TailleNegative= -nbrDeFonc()*tailleDe(SautBibli);
      AddLibrary(moiMeme);
   }
};

#endif
