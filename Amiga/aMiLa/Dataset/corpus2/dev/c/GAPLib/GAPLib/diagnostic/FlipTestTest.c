#include <stdio.h>
#include <stdlib.h>
#include <GAP.h>

static unsigned char testdata[3][8] = {
	{0,0,0,0,0,0,0,0},
	{0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF},
	{0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA,0xAA}
};


int main(void)
{
int bugs=0,i;

for(i=0;i!=64;i++) {
	if(Testbit(testdata[0],i)) {
		bugs++;
	}
}

for(i=0;i!=64;i++) {
	if(!Testbit(testdata[1],i)) {
		bugs++;
	}
}

if(!Testbit(testdata[2],0)) {
	bugs++;
}

if(Testbit(testdata[2],1)) {
	bugs++;
}

Flip(testdata[0],0);
Flip(testdata[0],7);
Flip(testdata[0],8);
Flip(testdata[0],13);
if(!Testbit(testdata[0],0)) {
	bugs++;
}

if(!Testbit(testdata[0],7)) {
	bugs++;
}

if(!Testbit(testdata[0],8)) {
	bugs++;
}

if(!Testbit(testdata[0],13)) {
	bugs++;
}

for(i=0;i!=32;i++) {
	Flip(testdata[2],i<<1);
}

for(i=0;i!=8;i++) {
	if(testdata[2][i]!=0) {
		bugs++;
	}
}

printf("Flip & Testbit tests: %s\n",(bugs!=0)?"Failed!":"Ok.");

return(bugs);
}

