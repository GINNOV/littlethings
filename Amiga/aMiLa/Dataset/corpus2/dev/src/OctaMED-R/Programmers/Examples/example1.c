/* This is a very simple example how to play a module which is converted
   to an object file with Objconv.

Linking info (assuming the object file is 'module.o'):
slink from lib:c.o+example1.o+module.o+reloc.o+proplayer.o to example1
	lib lib:sc.lib+lib:amiga.lib nd sc sd

*/

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include "proplayer.h"

/* Use symbol name 'song' when using Objconv, or change this. */
extern struct MMD0 far song;

void main() /* this can be linked without c.o */
{
	RelocModule(&song);
	InitPlayer();
	PlayModule(&song);
	Wait(SIGBREAKF_CTRL_C); /* press Ctrl-C to quit */
	RemPlayer();
}
