/* ------------------------------------------------------------------ */
/* $VER: Funcs.h 39.01 (12.12.1999)                                   */
/*                                                                    */
/* My function headers for easyaudio.library                          */
/*                                                                    */
/* (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.  */
/* amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk            */
/* ------------------------------------------------------------------ */

#include "compiler.h"

/* debug or not to debug 1/0 */
/* a GLOBAL definition */
#define debug 0


extern ULONG __saveds ASM
EA_Request( register __d1 UBYTE *title_d1 GNUCREG(d1),
			register __d2 UBYTE *body GNUCREG(d2),
			register __d3 UBYTE *gadgets GNUCREG(d3)
		  );


extern ULONG __saveds ASM
EA_Speech( register __d1 char *text GNUCREG(d1)
		 );


extern ULONG __saveds ASM
EA_Beep( register __d1 ULONG frequency GNUCREG(d1),
		 register __d2 ULONG duration GNUCREG(d2)
	   );




extern struct SoundInfo * __saveds ASM
EA_PrepareSound( register __d1 STRPTR file GNUCREG(d1)
			   );


extern BOOL __saveds ASM
EA_PlaySound( register __d1 struct SoundInfo *info GNUCREG(d1),
			  register __d2 UWORD volume GNUCREG(d2),
			  register __d3 UBYTE channel GNUCREG(d3),
			  register __d4 BYTE priority GNUCREG(d4),
			  register __d5 WORD delta_rate GNUCREG(d5),
			  register __d6 UWORD times GNUCREG(d6),
			  register __a2 ULONG start GNUCREG(a2),
			  register __a3 ULONG time GNUCREG(a3),
			  register __a4 BOOL wait GNUCREG(a4)
			);


extern void __saveds ASM
EA_StopSound( register __d1 UBYTE channel GNUCREG(d1)
			);


extern void __saveds ASM
EA_RemoveSound( register __d1 struct SoundInfo *info GNUCREG(d1)
			  );





