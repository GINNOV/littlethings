// IterTblMod: Dimanche 25-Avr-93 par Gilles Dridi

#ifndef  EXEC_ITERTBLMOD_H
#define  EXEC_ITERTBLMOD_H

classe PtrRes;
classe TblMod;

// définition d'une classe itérateur pour la classe TblMod
classe IterTblMod {
   PtrRes   *Debut;
   PtrRes   *Courant;

public:
   IterTblMod(TblMod *tbl) { Debut= Courant= (PtrRes [])tbl; }
   NEANT fixeTblMod(TblMod *tbl) { Debut= Courant= (PtrRes [])tbl; }
   PtrRes *courant() { renvoie Courant; }
   NEANT debute() { Courant= Debut; }
   NEANT avance() {
      si ( Courant->saut() ) Courant= Courant->saute();
      sinon Courant++;
   }
   BOOLEEN estFin() { renvoie Courant->Module == 0; }
   Resident *resCourant() { renvoie Courant->Module; }
};

#endif
