/* routines for reading directory contents	*/
/* ---------------------------------------	*/

/* For instructions:									*/
/* - read comments in this listing				*/
/* - look at example program						*/
/* - read autodocs at dos.library/ExAll		*/
/* - look at includes dos/exall.h				*/

/* MINIMUM REQUIRED: AmigaOS 2.0					*/
/* by Daniel Mealha Cabrita (dancab@polbox.com)	 19th june, 1998	*/

/* THIS SOURCE CAN FREELY DISTRIBUTED AND USED BY PERSONALS						*/
/* THE ONLY COMERCIAL PRODUCT ALLOWED TO DISTRIBUTE IS THE AMINET CDs		*/
/* other commercial-related interests about distributing it, contact			*/
/* the author first.																			*/

#include "GimmeDir.c"
#include <clib/dos_protos.h>
#include <dos/exall.h>
#include <clib/exec_protos.h>

extern struct tGimmeDir;

extern struct tGimmeDir *InitGimmeDir (char *DirName, long oTipo, char *aChave);
extern void EndGimmeDir (struct tGimmeDir *pGimmeDir);
extern void EndGimmeDir39 (struct tGimmeDir *pGimmeDir);
extern struct ExAllData *GimmeDir (struct tGimmeDir *pGimmeDir);

