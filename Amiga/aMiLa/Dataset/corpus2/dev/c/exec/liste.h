// Liste: Samedi 15-Août-92 par Gilles Dridi
// Utilise: Liste, OctetN, Noeud
// Opérations:
//  type: L -> ON
//  bourre: L -> ON
//  trouve: L -> N
//  Z opérations de ListeMin

#ifndef EXEC_LISTE_H
#define EXEC_LISTE_H

#ifndef EXEC_NOEUD_H
#include <exec/noeud.h>
#endif !EXEC_NOEUD_H

#ifndef EXEC_LISTEMIN_H
#include <exec/listeMin.h>
#endif !EXEC_LISTEMIN_H

classe Liste: public ListeMin {
protegee:
   OCTETN   Type;
   OCTETN   Bourre;

   amie Noeud *FindName(Liste *nd, const TEXTE *n);
public:
   Liste(Type_Noeud type= TN_INCONNU);
   OCTETN type() { renvoie Type; }
   OCTETN &bourre() { renvoie Bourre; }
   Noeud *trouve(TEXTE *n) { renvoie FindName(moiMeme, n); }
};

#endif

