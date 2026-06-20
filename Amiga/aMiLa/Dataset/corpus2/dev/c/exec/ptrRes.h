// PtrRes: Dimanche 25-Avr-93 par Gilles Dridi

#ifndef  EXEC_PTRRES_H
#define  EXEC_PTRRES_H

classe Resident;
classe TblMod;

// classe entièrement privée utiliser par TblMod & IterTblMod
classe PtrRes {
   Resident *Module;

   amie classe IterTblMod;
   amie classe TblMod;
   PtrRes(Resident *mod): Module(mod) {}
   Resident *module() { renvoie Module; }
   BOOLEEN saut() { renvoie (unsigned long)Module & 0x80000000; }
   PtrRes *saute() { renvoie (PtrRes *)((unsigned long)Module & ~0x80000000); }
   NEANT fixeSaut(TblMod *tbl) {
      Module= (Resident *)((unsigned long)tbl & 0x80000000);
   }
};

#endif
