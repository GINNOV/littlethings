/* Resident.h - exec library function prototypes */

/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**	All rights reserved.
**
**	Function prototypes for the exec.library of Amiga EXEC
**
**	Updated: 11/17/86, TFH
*/

#ifndef	EXEC_RESIDENT_H
#define	EXEC_RESIDENT_H

#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif !EXEC_NODES_H

struct Resident {
    UWORD rt_MatchWord;		/* word to match on (ILLEGAL) 	*/
    Resident *rt_MatchTag;	/* pointer to the above	*/
    APTR  rt_EndSkip;		/* address to continue scan 	*/
    UBYTE rt_Flags;  		/* various tag flags 		*/
    UBYTE rt_Version;		/* release version number 	*/
    UBYTE rt_Type;   		/* type of module (NT_mumble) 	*/
    BYTE  rt_Pri;    		/* initialization priority */
    char  *rt_Name;   		/* pointer to node name 	*/
    char  *rt_IdString;		/* pointer to ident string 	*/
    APTR  rt_Init;   		/* pointer to init code 	*/

};

class SegList;		// defined in libraries/dosextens.h

Resident * FindResident(const TEXT *name);
void InitResident(struct Resident *r, const SegList *s);
void InitStruct(APTR init_table, APTR memory, const int size);
int MakeFunctions(const APTR target, const APTR functarray,
	const APTR funcDispBase);

const WORD RTC_MATCHWORD = 0x4AFC;

#define	RTF_AUTOINIT	(1<<7)
#define RTF_COLDSTART   (1<<0)

/* Compatibility: */
#define	RTM_WHEN 	3
enum StartClass {
	RTW_NEVER =	0,
	RTW_COLDSTART =	1
};

void SumKickData();
APTR SuperState();
void UserState(APTR syStack);
void Debug(int dummy);
int GetCC();
void InitCode(StartClass c, const int version);
int SetSR(const int newsr, const int mask);

#endif

