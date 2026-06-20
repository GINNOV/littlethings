/*
**  stringpatch.c
**
**    ©1995 by AMS-Aloha Microsystems
**    ©1995 by Thomas Herold
**
**    Patches bug in system stringclass (stringgadget).
*/

#include <intuition/intuition.h>
#include <intuition/sghooks.h>


#include "bgb/stringpatch.h"

/*
**    EditHook Function to patch bug in Stringclass
*/

ULONG __interrupt __asm StringPatchFunc( register __a0 struct Hook *hookptr,
										 register __a2 struct SGWork *sgw,
										 register __a1 ULONG *msg )
{
	if(*msg == SGH_KEY )
	{
		if( sgw->EditOp == EO_INSERTCHAR )
		{
			if( sgw->NumChars >= sgw->StringInfo->MaxChars-1 )
			{
				sgw->Actions |= SGA_BEEP;
				sgw->Actions &= ~SGA_USE;
			}
		}
	}
	else
		return( 0L );

	return( (ULONG)~0L );
}

/*
**    Hook Structure for the EditHook
*/

struct Hook StringPatchHook = { NULL, NULL, (HOOKFUNC)StringPatchFunc, NULL, NULL };

