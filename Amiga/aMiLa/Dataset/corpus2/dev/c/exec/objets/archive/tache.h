// Tâche: Lundi 17-Août-1992 par Gilles Dridi
// Remarque: le destructeur de la classe Noeud ne doit pas appeler enleve().

#ifndef  EXEC_TACHE_H
#define  EXEC_TACHE_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

#ifndef  EXEC_LISTE_H
#include <exec/liste.h>
#endif  !EXEC_LISTE_H

#ifndef  EXEC_ENSSIG_H
#include <exec/ensSig.h>
#endif  !EXEC_ENSSIG_H

#ifndef  EXEC_TRAPPE_H
#include <exec/trappe.h>
#endif  !EXEC_TRAPPE_H

#ifndef  EXEC_PILE_H
#include <exec/pile.h>
#endif  !EXEC_PILE_H

#define TrouveTache FindTask
#define MonoTache Forbid
#define MultiTache Permit

enum Bit_Natures {
   BN_NORMAL=       0,
   BN_ETACHE=       3,
   BN_CONTROLEPILE= 4,
   BN_SPECIAL=      5,
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
   TE_INTERROMPUE, // 5
   TE_TERMINEE     // 6
};

enum Bit_SigDefini {
   BS_AVORTE=    0,
   BS_ORPHELIN=  1,
   BS_SEMAPHORE= 2,
   BS_MONITEUR=  3,
   BS_BLIT=      4,
   BS_UNIQUE=    4,
   BS_INTUITION= 5,
   BS_SED=       6,
};

classe Tache: public Noeud {
protegee:
   OCTETN      Natures;
   OCTETN      Etat;
   OCTET       Cpt0IT;        // compteur interdisant les interruptions
   OCTET       Cpt0MT;        // compteur interdisant le multitâche
   EnsSig      SigAlloues;    // signaux alloués
   EnsSig      SigAttendus;   // signaux attendus
   EnsSig      SigRecus;      // signaux recus
   EnsSig      SigSpeciaux;   // signaux à traitement particulier
   Trappe      TrapAllouees;  // trappes allouées
   Trappe      TrapPermises;  // trappes permis
   PTRNEANT    DonneeSpeciale; // pointeur donnée trait.(s) particulier(s)
   PTRNEANT    CodeSpecial;   // pointeur code trait.(s) particulier(s)
   PTRNEANT    DonneeTrappe;  // pointeur donnée trappe(s) // sert pas
   PTRNEANT    CodeTrappe;    // pointeur code trappe(s)
   PTRNEANT    RegistrePile;  // pointeur de pile
   PTRNEANT    BasRegPile;    // pointeur bas de la pile
   PTRNEANT    HautRegPile;   // pointeur haut de la pile + 2
   NEANT       (*CodePostQ)(); // pointeur fonction en cas de perte CPU
   NEANT       (*CodePreQ)(); // pointeur fonction en cas d'obtention CPU
   Liste       Memoire;       // facilité pour memoire allouée par la tâche
   PTRNEANT    DonneeUtilisateur; // données de la tâche

   amie Tache *AddTask(Tache *t, PTRNEANT initalPC, PTRNEANT finalPC);
   amie Tache *FindTask(TEXTE *nom);
   amie NEANT RemTask(Tache *t);
   amie OCTET SetTaskPri(Tache *t, const OCTET pri);
   amie NEANT Forbid(NEANT);
   amie NEANT Permit(NEANT);
public:
   Tache(Pile &pile, TEXTE *nomTache= NUL, OCTET priTache= 0,
         PTRNEANT codeSpecial= NUL, PTRNEANT codeTrappe= NUL,
         NEANT (*codePerd)()= NUL, NEANT (*codeObtient)()= NUL);
   OCTETN natures() { return Natures; }
   OCTETN etat() { return Etat; }
   PTRNEANT donneeSpeciale() { return DonneeSpeciale; }
   PTRNEANT codeSpeciale() { return CodeSpecial; }
   PTRNEANT codeTrappe() { return CodeTrappe; } // pas DonneeTrappe
   Tache *ajoute(PTRNEANT pointEntree, PTRNEANT codeTerminal= NUL);
   EnsSig attends(EnsSig es);
   NEANT signale(Tache *t, EnsSig es);
   OCTET changePri(OCTET priTache); // priorité statique
   NEANT passeTour(); // hum!
   NEANT enleve();
   ~Tache();
};

#endif
