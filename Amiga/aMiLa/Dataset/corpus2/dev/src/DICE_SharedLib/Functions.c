//
//		Example Shared Library Code
//		Compiles with DICE
//		
//		By Wez Furlong <wez@twinklestar.demon.co.uk>
//
//		Based on code by Geert Uytterhoeven and Matt Dillon
//
//		This source was produced:	Monday 23-Jun-1997 
//
//		DISCLAIMER
//
//		Please read the code FULLY before use... I could have put ANYTHING in
//		here; I may have the code format your bootdrive for example.
//
//		NEVER trust example code without fully understanding what it does.
//
//		This code comes with no warranty; I am NOT responsible for any damage
//		that may ensue from its use, be it physical, mental or otherwise.
//
//		This code may be modified, so long as the names of myself, Geert and
//		Matt are mentioned within any release or distribution produced using it,
//		and a copy sent to myself.
//
//		This code may be redistributed freely; no profit is allowed to be made
//		from its distribution.
//
//		This code may be included on an Aminet or Fred Fish CD.
//

//		Example Functions; borrowed from the DICE example routines
//

#include "example.h"

//--	Our Init function sets this up

static struct SignalSemaphore SemLock;
static struct List	StrList;

//--- Prototypes
//-- Note: Public Library functions MUST have the LibCall qualifier

Prototype LibCall extern void PostString(__A0 const STRPTR name);
Prototype LibCall extern LONG GetString(__A0 STRPTR buf, __D0 LONG buflen);
Prototype void initstuff(void);

//-- Init some stuff: called from within Init()

void initstuff(void)
{
	NewList(&StrList);
	InitSemaphore(&SemLock);
}

//-- PostString
//
//	Puts a string into memory for later recall
//

LibCall void PostString(__A0 const STRPTR name)
{
	struct Node *node;

	ObtainSemaphore(&SemLock);
	node = MAlloc(sizeof(struct Node) + strlen(name) + 1);
	node->ln_Name = (char *)(node + 1);
	strcpy(node->ln_Name, name);
	AddTail(&StrList, node);
	ReleaseSemaphore(&SemLock);
}

//-- GetString
//
//	Recalls string and places it in buf
//

LibCall LONG GetString(__A0 STRPTR buf, __D0 LONG buflen)
{
	struct Node *node;
	long len;

	ObtainSemaphore(&SemLock);
	if (node = RemHead(&StrList))
	{
		len = strlen(node->ln_Name);
		strncpy(buf, node->ln_Name, buflen);
		if (len >= buflen)
			buf[buflen-1] = 0;
		Free(node, sizeof(struct Node) + len + 1);
	} 
	else 
	{
		len = -1;
		if (buflen > 0)
			buf[0] = 0;
	}
	ReleaseSemaphore(&SemLock);
	return (len);
}


