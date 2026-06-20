// TacMin: Lundi 17-Août-1992 par Gilles Dridi
// Remarque: le destructeur de la classe Noeud ne doit pas appeler enleve().
// C'est cette classe qui doit être hérité par la classe Processus.

// IMPORTANT: compiler les codes de tâches sans vérification de pile

#ifndef  EXEC_TACMIN_H
#define  EXEC_TACMIN_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

#ifndef  EXEC_LISTE_H
#include <exec/liste.h>
#endif  !EXEC_LISTE_H

#ifndef  EXEC_ENSSIG_H
#include <exec/ensSig.h>
#endif  !EXEC_ENSSIG_H

#ifndef  EXEC_ENSSIGEXC_H
#include <exec/ensSigExc.h>
#endif  !EXEC_ENSSIGEXC_H

#ifndef  EXEC_ENSTRP_H
#include <exec/ensTrp.h>
#endif  !EXEC_ENSTRP_H

#ifndef  EXEC_PILE1K_H
#include <exec/pile1K.h>
#endif  !EXEC_PILE1K_H

#define TrouveTache FindTask
#define MonoTache Forbid
#define MultiTache Permit

#define ENSSIGSYS 0xFFFF
#define ENSTRPSYS 0x8000

enum Bit_Natures {
   BN_TEMPSPROC=    0,
   BN_ETACHE=       3,
   BN_VERIFPILE=    4,  // ne marche pas
   BN_EXCEPTION=    5,  // utilisé uniquement par Exec
   BN_POSTQUANTUM=  6,
   BN_PREQUANTUM=   7
};

// Deux listes: Tâches prêtes(une tâche en exécution) / Tâches en attentes
enum Type_Etat {
   TE_INVALIDE,    // 0
   TE_CREEE,       // 1
   TE_ELUE,        // 2
   TE_PRETE,       // 3
   TE_BLOQUEE,     // 4
   TE_INTERROMPUE, // 5 ( correspond à une exception de tâche )
   TE_TERMINEE     // 6
};

enum Bit_SigDefini {
   BS_AVORTE=    0,
   BS_ORPHELIN=  1,
   BS_SEMAPHORE= 2,
   BS_BLIT=      4,
   BS_UNIQUE=    4,
   BS_INTUITION= 5,
   BS_SED=       6,
};

classe TacMin: public Noeud {
protegee:
   OCTETN      Natures;
   OCTETN      Etat;
   OCTET       Cpt0IT;        // compteur interdisant les interruptions
   OCTET       Cpt0MT;        // compteur interdisant le multitâche
   EnsSig      EnsSigAlloues; // signaux alloués
   EnsSig      EnsSigAttendus;// signaux attendus
   EnsSig      EnsSigRecus;   // signaux recus
   EnsSigExc   EnsSigExceptions; // signaux à traitement particulier
   EnsTrp      EnsTrpAllouees;// trappes allouées
   EnsTrp      EnsTrpPermises;// trappes permises
   PTRNEANT    DonneeException;  // pointeur donnée trait.(s) particulier(s)
   Procedure   CodeException; // pointeur code trait.(s) particulier(s)
   PTRNEANT    DonneeTrappe;  // pointeur donnée trappe(s) (ne sert pas)
   Procedure   CodeTrappe;    // pointeur code trappe(s)
   LONGN       *RegistrePile; // pointeur de pile
   LONGN       *BasRegPile;   // pointeur bas de la pile
   LONGN       *HautRegPile;  // pointeur haut de la pile + 2
   Procedure   CodePostQ;     // pointeur fonction en cas de perte CPU
   Procedure   CodePreQ;      // pointeur fonction en cas d'obtention CPU
   Liste       Memoire;       // facilité pour memoire allouée par la tâche
   PTRNEANT    DonneeUtilisateur;   // donnée utilisateur

privee:
   amie TacMin *AddTask(TacMin *, Procedure initalPC, Procedure finalPC);
   amie TacMin *FindTask(TEXTE *);
   amie NEANT RemTask(TacMin *);
   amie OCTET SetTaskPri(TacMin *, const OCTET pri);
   amie NEANT Forbid(NEANT);
   amie NEANT Permit(NEANT);
public:
   TacMin(Pile *pile, TEXTE *nom= NUL, OCTET pri= 0);
   OCTETN natures() { renvoie Natures; }
   OCTETN etat() { renvoie Etat; }
   EnsSigExc &ensSigExceptions() { renvoie EnsSigExceptions; }
   PTRNEANT donneeException() { renvoie DonneeException; }
   Procedure codeException() { renvoie CodeException; }
   Procedure codeTrappe() { renvoie CodeTrappe; } // pas de DonneeTrappe
   LONGN *registrePile() { renvoie RegistrePile; }
   LONGN *basRegPile() { renvoie BasRegPile; }
   LONGN *hautRegPile() { renvoie HautRegPile; }
   Procedure codePostQ() { renvoie CodePostQ; }
   Procedure codePreQ() { renvoie CodePreQ; }
   Liste *memoire() { renvoie &Memoire; }
   PTRNEANT donneeUtilisateur() { renvoie DonneeUtilisateur; }
   TacMin *ajoute(Procedure pointEntree);
   EnsSig attends(EnsSig es) { renvoie es.attends(); }
   NEANT signale(TacMin *t, EnsSig es) { es.signale(t); }
   // Amiga: système à priorité statique
   OCTET changePri(OCTET pri) { renvoie SetTaskPri(moiMeme, pri); }
   NEANT passeTour() { SetTaskPri(moiMeme, (OCTET)Pri-1); } // hum !
   NEANT enleve() {
      si ( Etat != TE_TERMINEE && Etat != TE_INVALIDE ) RemTask(moiMeme);
   }
};

#endif
