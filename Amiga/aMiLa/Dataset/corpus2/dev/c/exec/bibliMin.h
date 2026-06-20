// BibliMin: Lundi 19-Oct-92 par Gilles Dridi

#ifndef EXEC_BIBLIMIN_H
#define EXEC_BIBLIMIN_H

#ifndef EXEC_NOEUD_H
#include <exec/noeud.h>
#endif !EXEC_NOEUD_H

#ifndef  EXEC_SAUTBIBLI_H
#include <exec/sautBibli.h>
#endif  !EXEC_SAUTBIBLI_H

typedef Procedure tabFonc[]; // ne sert qu'à MakeLibrary() (pas utilisée)

// Etats internes d'une bibliotheque
enum Bit_Statut {
   BS_INVENTAIRE, // 0, mis pendant le calcule de la somme de contrôle
   BS_MODIFIEE,   // 1, mis juste après une modification de la bibliothèque
   BS_SOMDECTRL,  // 2, mis si la somme de contrôle est à vérifier
   BS_SURSITAIRE, // 3, mis durant l'épuration (delayed expunge)
};

classe BibliMin: public Noeud {
protegee:
   OCTETN   Statut;
   OCTETN   Bourre;
   MOT      TailleNegative; // utiliser par inventorie(SumLibrary) et
   MOTN     TaillePositive; // peuvent être initialisées par MakeLibrary()
   MOTN     Version;
   MOTN     Revision;
   TEXTE    *ChaineId;
   LONGN    SommeDeControle;
   MOTN     Abonnes;

   amie NEANT AddLibrary(BibliMin *b);
   amie NEANT CloseLibrary(BibliMin *b);
   amie BibliMin *MakeLibrary(tabFonc tab,
                              PTRNEANT structureDInit,
                              Procedure routineDInit,
                              MOTN tailleDonnee,
                              PTRBCPL listeDeSegment);
   // Créer une bibliothèque:  une allocation dynamique(new) est faite par
   // la fonction elle-même !
   // Fabrique la table des vecteurs, recopie la structure et l'initialise.
   // PARAM1: table d'adresses de fonction: soit des MOTs, soit des LONGMOTs
   // si le premier MOT de la table est négatif: table de MOT (@ relatives)
   // sinon table de LONGMOT (@ absolues). La table est terminée par -1.
   // PARAM2: sert à initialiser les données de la bibliothèque (si NON NUL)
   // PARAM3: routine appelée avant d'ajouter la bibliothèque (si NON NUL)
   // PARAM5: adresse passée à la routineDInit, utile à enleve (RemLibrary/
   // EXPUNGE) lors du déchargement du code (UnLoadSegment)
   amie BibliMin *OpenLibrary(TEXTE *nomBibli, ENTIER version);
   amie NEANT RemLibrary(BibliMin *b);
   amie Procedure SetFunction(BibliMin *b,
                              ENTIER numeroFonction,
                              Procedure routine);
   amie NEANT SumLibrary(BibliMin *b);
   // appel la fonction privée ouvre()
   amie BibliMin *OuvreLaBibliMin(TEXTE *nomBibli,
                                  ENTIER version= 0) {
      renvoie OpenLibrary(nomBibli, version);
   }
public:
   const MOTN nbrDeFoncStd() { renvoie 4; }
   // nomBibli= "nomEnAnglais.library"
   // chaineId= "nom version.revision (dd MON yyyy)",<cr>,<lf>,<null>
   BibliMin(TEXTE *nomBibli, TEXTE *chaineId);
   OCTETN statut() { renvoie Statut; }
   MOTN version() { renvoie Version; }
   MOTN revision() { renvoie Revision; }
   TEXTE *chaineId() { renvoie ChaineId; }
   LONGN sommeDeControle() { renvoie SommeDeControle; }
   MOTN abonnes() { renvoie Abonnes; }
   // appel fonction privée ferme();
   NEANT fermeLa() { CloseLibrary(moiMeme); }
   // appel en plus inventorie()
   NEANT ajoute() {
      TailleNegative= -nbrDeFoncStd()*tailleDe(SautBibli);
      AddLibrary(moiMeme);
   }
   // appel la fonction privée epure() (EXPUNGE)
   NEANT enleve() { RemLibrary(moiMeme); }
   // déroute une fct de la bibliothèque, renvoie l'@ de l'ancienne fct
   // puis, appelle inventorie()
   Procedure deroute(ENTIER numeroFonction, Procedure routine) {
      renvoie SetFunction(moiMeme, numeroFonction, routine);
   }
   // calcule le membre SommeDeControle avec les fcts de la bibliothèque
   // sauf si le bit BS_SOMDECTRL n'est pas mis
   NEANT inventorie() { SumLibrary(moiMeme); }
};

#endif
