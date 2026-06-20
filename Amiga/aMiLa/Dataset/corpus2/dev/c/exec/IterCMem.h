// IterCMem: Dimanche 25-Avr-93 par Gilles Dridi

#ifndef  EXEC_ITERCMEM_H
#define  EXEC_ITERCMEM_H

// définition d'une classe itérateur pour la classe ChaineMem
classe IterCMem {
	ChaineMem		*Debut;
	ChainonMem	*Courant;

public:
	IterCMem(ChaineMem *chaineMem) { Debut= chaineMem; }
 	NEANT fixe_CMem(ChaineMem *chaineMem) { Debut= chaineMem; }
	ChainonMem *courant() { renvoie Courant; }
   	// utiliser ce trio pour le parcours
	NEANT debute() { Courant= Debut->enTete(); }
	BOOLEEN estFin() { renvoie Courant == NUL; }
	NEANT avance() { Courant= Courant->suivant(); }
};

#endif
