
#include <stdio.h>
#include <exec/types.h>
#include <hardware/cia.h>

extern struct CIA ciaa;
extern struct CIA ciab;

struct CIA * pciaa = &ciaa;
struct CIA * pciab = &ciab;

/* Program to monitor the parallel port's output bytes! */
void main(void)
{
	UBYTE ubIn, ubDir, ubControl, ubDDRB;
	
	while(1)
	{
		Delay(1);
		ubIn      = pciaa->ciaprb;
		ubDir     = pciab->ciaddra;
		ubControl = pciab->ciapra;
		ubDDRB    = pciaa->ciaddrb;
		printf("data=%02x direction=%02x control=%02x ubDDRB=%02x\n", ubIn, ubDir, ubControl, ubDDRB);
	}
}
