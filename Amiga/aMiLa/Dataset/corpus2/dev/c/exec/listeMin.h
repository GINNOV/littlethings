// ListeMin: Samedi 15-Août-92 par Gilles Dridi
// Utilise: NoeudMin, ListeMin, Booléen
// Opérations:
//  estVide: LM -> B
//  premier: LM-{} -> NM
//  dernier: LM-{} -> NM
//  enTête: LM x NM -> LM-{}
//  enQueue: LM x NM -> LM-{}
//  après: LM x NM x NM ->

#ifndef  EXEC_LISTEMIN_H
#define  EXEC_LISTEMIN_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

// Remarque: une liste Exec a toujours une Tête et une Queue.
// Pour optimiser, le prédecesseur de Tête et le successeur de Queue
// qui sont nuls (la tête n'a pas de precédent et la queue n'a pas de suivant)
// sont regroupés en un seul champ pour n'occuper que la place d'un pointeur
// au lieu de deux.

#define Queue_Succ   Tete.Pred

classe ListeMin {
   NoeudMin    Tete;
   NoeudMin    *Queue_Pred;

   amie classe IterListe;
   amie NEANT AddHead(ListeMin *l, NoeudMin *n);
   amie NEANT AddTail(ListeMin *l, NoeudMin *n);
   amie NEANT Enqueue(ListeMin *l, NoeudMin *n);
   amie NEANT NewList(ListeMin *l);
   amie NEANT Insert(ListeMin *l, NoeudMin *n1, NoeudMin *n2);
   amie NoeudMin *RemHead(ListeMin *l);
   amie NoeudMin *RemTail(ListeMin *l);
public:
   ListeMin() { NewList(moiMeme); }
   BOOLEEN estVide() { renvoie ( Tete.Succ == (NoeudMin *)&Tete.Pred ); }
   NoeudMin *premier() { renvoie Tete.Succ; }
   NoeudMin *dernier() { renvoie Queue_Pred; }
   ListeMin *enTete(NoeudMin *n) { AddHead(moiMeme, n); renvoie moiMeme; }
   ListeMin *enQueue(NoeudMin *n) { AddTail(moiMeme, n); renvoie moiMeme; }
   NEANT apres(NoeudMin *n1, NoeudMin *n2) { Insert(moiMeme, n1, n2); }
   NoeudMin *enleveEnTete() { renvoie RemHead(moiMeme); }
   NoeudMin *enleveEnQueue() { renvoie RemTail(moiMeme); }
};

#endif
