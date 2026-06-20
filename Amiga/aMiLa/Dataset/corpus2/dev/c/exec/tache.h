// Tache: Samedi 24-Avr-93 par Gilles Dridi
// Pour deboguer cette classe utiliser, le faire avec la classe TacMin

#ifndef  EXEC_TACHE_H
#define  EXEC_TACHE_H

#ifndef  EXEC_TACMIN_H
#include <exec/tacMin.h>
#endif  !EXEC_TACMIN_H

classe Tache: public TacMin {
privee:
   TacMin *ajoute(Procedure ); // fonction non héritée
   NEANT prologue();
   NEANT prologueExc(EnsSigExc exceptions);
public:
   Tache(Pile *pile, TEXTE *nom= NUL, OCTET pri= 0);
   Tache *ajoute() { renvoie (Tache *)TacMin::ajoute(Tache::prologue); }
   virtuelle NEANT debute();
   virtuelle NEANT interrompu(EnsSigExc exceptions);
};

#endif
