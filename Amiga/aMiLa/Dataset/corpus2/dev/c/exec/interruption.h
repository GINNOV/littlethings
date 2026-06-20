// Interruption: Lundi 19-Avr-93 par Gilles Dridi
// Le serveur d'interruption s'occupe d'activer son niveau lors du premier
// ajout d'une "instance interruption" et le désactive lors du dernier
// retrait, par l'intermédiaire du registre INTENA (INTerrupt ENAble).
// Pour un Handler il faudra récupérer l'ancien handler pour faire le
// chainage: la nouvelle routine appelera l'ancienne quand elle aura terminée.
// De plus, s'il l'ancien Handler n'existe pas; c'est qu'on est le premier
// pour ce niveau, il faut donc activé le niveau correspondant dans le
// registre INTENA (faire l'inverse quand on l'enlève).
// Procéder par héritage, redéfinition de interrompu() pour ses propres INT.

#ifndef  EXEC_INTERRUPTION_H
#define  EXEC_INTERRUPTION_H

#ifndef  EXEC_LISTE_H
#include <exec/liste.h>
#endif  !EXEC_LISTE_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

// Remarque: les priorités sont croissantes et les numéros n'ont rien à voir
// avec ceux des bits des registres INTENA INTREQ, bien qu'il y ait des
// correspondances avec les numéros des bits des registres matériels.

// Type pour les serveurs d'interruptions
enum Type_IntS {
   TI_PORTS=   3, // interruption physique de niveau 2 (externe) & CIAA
   TI_COPPER=  4, // coprocesseur graphique (niveau 3)
   TI_IVERT=   5, // intervalle entre 2 trames (50/60Hz, niveau 3)
   TI_EXTERN= 13, // interruption physique de niveau 6 (externe) & CIAB
   TI_NMI=    15  // interruption physique de niveau 7 (externe) ou NMI (!= INTEN)
};

// Type pour les handlers d'interruptions
// Pas sur des priorités logiques de INTLOGIC, BLOCDISC et TPTVIDE ?
enum Type_IntH {
   TI_INTLOGIC=   0, // interruption logicielle                : niveau 1
   TI_BLOCDISC=   1, // bloc de donnée du disque rempli        : niveau 1
   TI_TPTVIDE=    2, // tampon de transmission vide            : niveau 1
   TI_BLITTER=    6, // blitter a terminé                      : niveau 3
   TI_AUDIO2=     7, // fin de l'échantillon canal 2 (compteur ADM-C2 à 0)
   TI_AUDIO0=     8, // idem canal 0                           : niveau 4
   TI_AUDIO3=     9, // idem canal 3                           :    "   4
   TI_AUDIO1=    10, // idem canal 1                           :    "   4
   TI_TPRPLEIN=  11, // tampon reception plein                 : niveau 5
   TI_SYNCDISC=  12  // trame de synchronisation disque trouvée: niveau 5
};

classe Interruption: public Noeud {
   PTRNEANT    Donnee;  // pointe sur soi-même (passé dans A1 à INT)
   Procedure   Code;    // pointe sur asmPrologue() (voir asmInterruption.a)

   NEANT prologue(); // appeler par la routine d'INT
   amie NEANT AddIntServer(Type_IntS , Interruption *);
   amie NEANT Cause(Interruption *);
   amie NEANT RemIntServer(Type_IntS , Interruption *);
   amie Interruption *SetIntVector(Type_IntH , Interruption *);
public:
   Interruption(TEXTE *nom, OCTET pri);
   PTRNEANT donnee() { renvoie Donnee; }
   Procedure code() { renvoie Code; }
   virtuelle NEANT interrompu() {}  // attention: pas de DEBOGUE (INT)
   NEANT ajoutePORTS() { AddIntServer(TI_PORTS, moiMeme); }
   NEANT ajouteCOPPER() { AddIntServer(TI_COPPER, moiMeme); }
   NEANT ajouteIVERT() { AddIntServer(TI_IVERT, moiMeme); }
   NEANT ajouteEXTERN() { AddIntServer(TI_EXTERN, moiMeme); }
   NEANT ajouteNMI() { AddIntServer(TI_NMI, moiMeme); }
   NEANT enlevePORTS() { RemIntServer(TI_PORTS, moiMeme); }
   NEANT enleveCOPPER() { RemIntServer(TI_COPPER, moiMeme); }
   NEANT enleveIVERT() { RemIntServer(TI_IVERT, moiMeme); }
   NEANT enleveEXTERN() { RemIntServer(TI_EXTERN, moiMeme); }
   NEANT enleveNMI() { RemIntServer(TI_NMI, moiMeme); }
   cause();
   Interruption *fixeVecteurIntH(Type_IntH numInt) {
      renvoie SetIntVector(numInt, moiMeme);
   }
};

#endif
