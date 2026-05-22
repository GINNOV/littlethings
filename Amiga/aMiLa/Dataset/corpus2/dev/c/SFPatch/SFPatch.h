#ifndef SFPATCH_H
#define SFPATCH_H
/*
 * SFPatch.h 1.0
 *
 * Lee Kindness
 *
 * Public Domain
 *
 */

/* Includes */

#include <exec/types.h>
#include <exec/memory.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>

/* Structures */

enum {
	JMPINSTR = 0x4ef9
};

typedef struct JmpEntry {
	UWORD Instr;
	APTR Func;
} JmpEntry;

typedef struct SetFunc {
	APTR            sf_Func;
	APTR            sf_OriginalFunc;
	JmpEntry       *sf_Jmp;
	struct Library *sf_Library;
	LONG            sf_Offset;
	LONG            sf_QuitMethod;
	LONG            sf_Count;
} SetFunc;

/* Constants for SetFunc->sf_QuitMethod */
#define SFQ_WAIT 0 /* wait sf_Count seconds (defaults to 3) */
#define SFQ_COUNT 1 /* only quit if count == 0 (retry every 3 secs...) */

/* Prototypes */

BOOL SFReplace(SetFunc *sf);
void SFRestore(SetFunc *sf);

/* The functions... */

/*
 * The main method for replacing an Amiga OS function as safe as
 * possible is to place the function with a jump table that is
 * allocated.  While the function is replaced, the jump table simply
 * jumps to my routine:
 *
 * jmp  _new_Function
 *
 * When the user asks the program to quit, we can't simply put the
 * pointer back that SetFunction() gives us since someone else might
 * have replaced the function.  So, we first see if the pointer we
 * get back points to the out jump table.  If so, then we _can_ put
 * the pointer back like normal (no one has replaced the function
 * while we has it replaced).  But if the pointer isn't mine, then
 * we have to replace the jump table function pointer to the old
 * function pointer:
 *
 * jmp  _old_Function
 *
 * Finally, we only deallocate the jump table _if_ we did not have
 * to change the jump table.
 */


BOOL SFReplace(SetFunc *sf)
{
	BOOL ret;
	ret = FALSE;
	/* Allocate the jump table */
	if (sf->sf_Jmp = AllocVec(sizeof(JmpEntry), MEMF_CLEAR)) {
		Forbid();

		/* Replace the function with pointer to jump table */
		sf->sf_OriginalFunc = SetFunction(sf->sf_Library, sf->sf_Offset, (APTR)sf->sf_Jmp);

		/* Setup the jump table */
		sf->sf_Jmp->Instr = JMPINSTR;
		sf->sf_Jmp->Func = sf->sf_Func;

		// Clear the cpu's cache so the execution cache is valid
		CacheClearU();

		Permit();
		
		/* muck around with the quit stuff... */
		if (sf->sf_QuitMethod == SFQ_WAIT) {
			if (sf->sf_Count <= 0)
				sf->sf_Count = 3;
		} else
			sf->sf_Count = 0;
		ret = TRUE;
	}
	return ret;
}

void SFRestore(SetFunc *sf)
{
	BOOL my_table;
	ULONG (*func)();

	Forbid();

	/* Put old pointer back and get current pointer at same time */
	func = SetFunction(sf->sf_Library, sf->sf_Offset, sf->sf_OriginalFunc);

	/* Check to see if the pointer we get back is ours */
	if ((JmpEntry *)func != sf->sf_Jmp) {
		/* If not, leave jump table in place */
		my_table = FALSE;
		SetFunction(sf->sf_Library, sf->sf_Offset, func);
		sf->sf_Jmp->Func = sf->sf_OriginalFunc;
	} else {
		/* If so, free the jump table */
		my_table = TRUE;
		FreeVec(sf->sf_Jmp);
	}

	/* Clear the cpu's cache so the execution cache is valid */
	CacheClearU();

	Permit();

	/* Let the user know if the jump table couldn't be freed */
	if ((!my_table) && (IntuitionBase))
		DisplayBeep(NULL);
	
	/* Wait... */
	if (sf->sf_QuitMethod == SFQ_WAIT) {
		/* Wait n seconds */
		Delay(sf->sf_Count * 50);
	} else {
		/* wait until sf->sf_Count == 0 */
		while (sf->sf_Count)
			Delay(150);
	}
}

#endif /* SFPATCH_H */

