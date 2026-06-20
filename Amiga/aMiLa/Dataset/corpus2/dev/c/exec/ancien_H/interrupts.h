// exec/interrupts.h
//
// (C) 1987, MTS Associates
//
#ifndef EXEC_INTERRUPTS_H
#define EXEC_INTERRUPTS_H
#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif !EXEC_NODES_H
#ifndef EXEC_LISTS_H
#include "exec/lists.h"
#endif !EXEC_LISTS_H
#ifndef EXEC_PORTS_H
#include "exec/ports.h"
#endif !EXEC_PORTS_H

struct Interrupt : public Node {
    APTR    is_Data;
    VOID    (*is_Code)();

	Interrupt(const TEXT *n,
		 int p,
		 void (*code)() = NULL,
		 APTR data = NULL) : (NT_INTERRUPT, n, p)
	{ is_Code = code, is_Data = data; }
	Interrupt() {}
};

struct IntVector {
    APTR    iv_Data;
    VOID    (*iv_Code)();
    Node    *iv_Node;
};

struct SoftIntList : public List {
    UWORD  sh_Pad;
};

typedef int TrapNum;

void AddIntServer(int intnum, Interrupt *irpt);
void Cause( Interrupt *irpt);
void RemIntServer(int intnum, Interrupt *irpt);
Interrupt * SetIntVector(int intnum,  Interrupt *irpt);
TrapNum AllocTrap(TrapNum n);
void FreeTrap(TrapNum n);

SigBits SetExcept(const SigBits newexcept, const SigBits mask);

#define SIH_PRIMASK (0xf0)
#define INTB_NMI        15
#define INTF_NMI        (1<<15)
#endif
