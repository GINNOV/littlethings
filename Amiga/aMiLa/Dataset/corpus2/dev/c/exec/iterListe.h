// IterListe: Dimanche 25-Avr-93 par Gilles Dridi

#ifndef  EXEC_ITERLISTE_H
#define  EXEC_ITERLISTE_H

// définition d'une classe itérateur pour la classe Liste
classe IterListe {
   NoeudMin    *Debut;
   NoeudMin    *Fin;
   NoeudMin    *Courant;

public:
   IterListe(Liste *lst) {
      Debut= Courant= &lst->Tete; Fin= (NoeudMin *)&lst->Queue_Succ;
   }
   NEANT fixeListe(Liste *lst) {
      Debut= Courant= &lst->Tete; Fin= (NoeudMin *)&lst->Queue_Succ;
   }
    NoeudMin *courant() { renvoie Courant; }
   // utiliser ce trio pour le parcours
   NEANT debute() { Courant= Debut; avance(); }
   BOOLEEN estFin() { renvoie Courant == Fin; }
   NEANT avance() { Courant= Courant->Succ; }
   // ou celui-ci
   NEANT termine() { Courant= Fin; recule(); }
   BOOLEEN estDebut() { renvoie Courant == Debut; }
   NEANT recule() { Courant= Courant->Pred; }
};

#endif
