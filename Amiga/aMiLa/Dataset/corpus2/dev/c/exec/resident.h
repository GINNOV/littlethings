// Resident: Jeudi 17-Nov-95 par Gilles Dridi
// Par défaut aucun drapeau; Init pointe sur la fonction d'initialisation.
// Par défaut fixe la priorité du module à -120.
// Si le drapeau INITAUTOMATIQUE est fixé Init pointe sur une table.
// Si le drapeau APRESDOS est fixé, priorité à -100 ou <.

#ifndef  EXEC_RESIDENT_H
#define  EXEC_RESIDENT_H

#ifndef  EXEC_NOEUD_H
#include <exec/noeud.h>
#endif  !EXEC_NOEUD_H

#define TrouveResident FindResident

extern geta4();

classe ListeDeSegment;  // defined in libraries/dosextens.h

enum Bit_Resident {
   BR_DEMARRAGEAFROID=	0,
	BR_TACHEUNIQUE=		1,
	BR_APRESDOS=			2,	
   BR_INITAUTOMATIQUE=	7 
};

classe Resident {
protegee:
   MOTN        InsILLEGAL;
   Resident    *Signature;
   PTRNEANT    AdrDePoursuite;   // où poursuivre la recherche de modules
   OCTETN      Drapeaux;
   OCTETN      Version;
   OCTETN      Type; // du module
   OCTET       Priorite;
   TEXTE       *Nom;
   TEXTE       *ChaineId;
   Procedure   Init; // pt. sur asmPrologueRes() (voir asmResident.a)

   amie NEANT SumKickData();
   amie NEANT InitResident(Resident *, ListeDeSegment *);
   NEANT prologue();
public:
   // nomRes= "nomEnAnglais.(library | device | resource | ...)"
   // chaineId= "nom version.revision (dd MON yyyy)",<cr>,<lf>,<null>
   Resident(TEXTE *nomRes, TEXTE *chaineId, OCTETN type, OCTET pri= -120);
   PTRNEANT adrDePoursuite() { renvoie AdrDePoursuite; }
   OCTETN drapeaux() { renvoie Drapeaux; }
   OCTETN version() { renvoie Version; }
   OCTETN type() { renvoie Type; }
   OCTET priorite() { renvoie Priorite; }
   TEXTE *nom() { renvoie Nom; }
   TEXTE *chaineId() { renvoie ChaineId; }
   Procedure init() { renvoie Init; }
};

#endif

