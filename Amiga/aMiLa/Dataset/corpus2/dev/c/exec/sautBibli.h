// SautBibli: Vendredi 15-Jan-93 par Gilles Dridi
// Le constructeur est en ligne car le classe ne sera pas héritée

#ifndef EXEC_SAUTBIBLI_H
#define EXEC_SAUTBIBLI_H

classe SautBibli {
protegee:
   MOTN        InsDeSaut; // JMP @.L
   Procedure   AdrProcedure;

public:
   SautBibli(Procedure adrProc): InsDeSaut(0x4EF9), AdrProcedure(adrProc) {}
   Procedure adrProcedure() { renvoie AdrProcedure; }
};

#endif
