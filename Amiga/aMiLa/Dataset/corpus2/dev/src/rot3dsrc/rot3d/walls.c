#include "walls.h"
unsigned short palette[] = {
0x0004, 0x0974, 0x0864, 0x0863, 
0x0852, 0x0753, 0x0641, 0x0731, 
0x0641, 0x0631, 0x0531, 0x0521, 
0x0410, 0x0210, 0x000A, 0x000F, 
0x0004, 0x0EEE, 0x0DDD, 0x0CCC, 
0x0BBB, 0x0AAA, 0x0999, 0x0888, 
0x0777, 0x0666, 0x0555, 0x0444, 
0x0333, 0x0111, 0x00A0, 0x02E0, 
};
unsigned long *brushmem[NUMWALLS];
char brushpal[10]= {
 1, 1, 1, 1, 1, 1, 1, 1,
 0, 0,
};
void loadwalls() {
	FILE *file; int i;
	char *mem;

	mem=(char *)malloc(NUMWALLS*32768);
	if(!mem) exit(1);
	file=fopen("walls.dat","r");
	fread(mem,32768,NUMWALLS,file);
	for(i=0;i<NUMWALLS;i++)
		brushmem[i]=(unsigned long *)(mem+i*32768);
}
