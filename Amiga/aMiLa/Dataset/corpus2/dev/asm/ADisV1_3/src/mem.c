/*
 * Change history
 * $Log:	mem.c,v $
 * Revision 3.0  93/09/24  17:54:09  Martin_Apel
 * New feature: Added extra 68040 FPU opcodes
 * 
 * Revision 2.1  93/07/18  22:56:12  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 2.0  93/07/01  11:54:16  Martin_Apel
 * *** empty log message ***
 * 
 * Revision 1.7  93/06/03  20:28:35  Martin_Apel
 * 
 * 
 */

#include <stdlib.h>
#include "defs.h"

static char rcsid [] = "$Id: mem.c,v 3.0 93/09/24 17:54:09 Martin_Apel Exp $";

void *get_mem (ULONG size)

{
void *buf;
if ((buf = malloc (size)) == NULL)
  {
  fprintf (stderr, "Not enough memory. Terminating...\n");
  ExitADis ();
  }
return (buf);
}


void release_mem (void *buffer)

{
free (buffer);
}
