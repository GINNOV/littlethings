#include <exec/types.h>
#include <stdio.h>

extern __asm FillOutline(register __a0 APTR plane, register __d0 WORD width, register __d1 WORD height);
extern __far WORD plane[];

#define WIDTH 32
#define HEIGHT 7

void PutOut(void)
{
	int i, j;
	for(j = 0; j < HEIGHT; j++){
		for(i = 0; i < WIDTH; i++){
			if(plane[(j*(WIDTH/16)) + (i/(WIDTH/2))] & (1<<(15-(i%16))))
				printf("*");
			else
				printf(".");
		}
		printf("\n");
	}
}

int main(int argc, char **argv)
{
	PutOut();
	FillOutline(plane, WIDTH/8, HEIGHT);
	printf("done\n");
	PutOut();
	return(0);
}
