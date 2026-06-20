// VecteurInt: Lundi 19-Avr-93 par Gilles Dridi

#ifndef  EXEC_VECTEURINT_H
#define  EXEC_VECTEURINT_H

classe Noeud;

classe VecteurInt {
   PTRNEANT    Donnee;
   Procedure   Code;
   Noeud       *AdrNoeud;

public:
   VecteurInt(Procedure code, PTRNEANT donnee, Noeud *adrNoeud);
   PTRNEANT donnee() { renvoie Donnee; }
   Procedure code() { renvoie Code; }
   Noeud *adrNoeud() { renvoie AdrNoeud; }
};

#endif
