// NoeudMin: Vendredi 14-Août-92 par Gilles Dridi
// Type abstrait de la classe NoeudMin
// Utilise: NoeudMin, Booléen
// Opérations:
//  succ: NM -> NM
//  pred: NM -> NM
//  estPrem: NM -> B
//  estDern: NM -> B
//  estFin: NM -> B
//  enleve: NM ->
// Axiomes: X E L
//  succ(X.pred) = X

#ifndef EXEC_NOEUDMIN_H
#define EXEC_NOEUDMIN_H

classe NoeudMin {
protegee:
   NoeudMin *Succ;
   NoeudMin *Pred;

   amie classe ListeMin;
   amie classe IterListe;
   amie NEANT Remove(NoeudMin *);
public:
   NoeudMin(): Succ(NUL), Pred(NUL) {}
   NoeudMin *succ() { renvoie Succ; }
   NoeudMin *pred() { renvoie Pred; }
   BOOLEEN estPrem() { renvoie Pred->Pred == NUL; }
   BOOLEEN estDern() { renvoie Succ->Succ == NUL; }
   BOOLEEN estFin() { renvoie Succ == NUL; }
   NEANT enleve() { Remove(moiMeme); }
};

#endif
