// ExecBase: Mardi 20-Avr-93 par Gilles Dridi

#ifndef  EXEC_EXECBASE_H
#define  EXEC_EXECBASE_H

#ifndef  EXEC_BIBLIMIN_H
#include <exec/bibliMin.h>
#endif  !EXEC_BIBLIMIN_H

#ifndef  EXEC_VECTEURINT_H
#include <exec/vecteurInt.h>
#endif  !EXEC_VECTEURINT_H

#ifndef  EXEC_ENSSIG_H
#include <exec/ensSig.h>
#endif  !EXEC_ENSSIG_H

#ifndef  EXEC_ENSTRP_H
#include <exec/ensTrp.h>
#endif  !EXEC_ENSTRP_H

#ifndef  EXEC_TACMIN_H
#include <exec/tacMin.h>
#endif  !EXEC_TACMIN_H

#ifndef  EXEC_LISTEINTLOG_H
#include <exec/listeIntLog.h>
#endif  !EXEC_LISTEINTLOG_H

#ifndef  EXEC_TBLMOD_H
#include <exec/tblMod.h>
#endif  !EXEC_TBLMOD_H

enum Bit_Processeurs {
   BP_68010= 0,
   BP_68020= 1,
   BP_68881= 4
};

classe ExecBase: public BibliMin {
public:
   MOTN     Version;
   MOT      SomDeCtrlMemBasse;
   LONGN    BaseCtrl;
   PTRNEANT ColdCapture;
   PTRNEANT CoolCapture;
   PTRNEANT WarmCapture;
   LONGN    *PileSysHaut;
   LONGN    *PileSysBas;
   LONGN    MaxLocMem;
   PTRNEANT DebugEntry;
   PTRNEANT DebugData;
   PTRNEANT AlertData;
   PTRNEANT MaxExtMem;
   MOTN     SomDeCtrl;
   VecteurInt  Vecteurs[16];

   TacMin   *TacheCourante;
   LONGN    CptSysPatient;
   LONGN    CptDelection;
   MOTN     Quantum;
   MOTN     Qecoule;   // tâche courante
   MOTN     DrapeauxSys;
   OCTET    Cpt0IT;
   OCTET    Cpt0MT;
   MOTN     Processeurs;
   MOTN     ReOrdonnancement;

   TblMod   *Modules;

   PTRNEANT CodeTrappe;
   PTRNEANT CodeException;
   PTRNEANT CodeTerminaison;
   EnsSig   EnsSigAlloues;
   EnsTrp   EnsTrpAlloues;

   Liste    Memoires;
   Liste    Ressources;
   Liste    Peripheriques;
   Liste    Interruptions;
   Liste    Bibliotheques;
   Liste    Ports;
   Liste    TachesPretes;
   Liste    TachesPatientes;
   ListeIntLog IntLogicielles[5]; // -32, -16, 0, +16, +32

   LONG     LastAlert[4];
   OCTETN   FrequenceTrame;
   OCTETN   FrequenceDalimentation;

   Liste    Semaphores;

   Noeud    *AdrDesEnsMemRemanents;
   TblMod   *Remanents;
   LONGN    SomDeCtrlRemanence;

   OCTETN   ExecBaseReserved[10];
   OCTETN   ExecBaseNewReserved[20];

public:
   ExecBase(); // il faudrait tout initialisé (c'est du boulot !)
};

extern ExecBase *SysBase;

#endif
