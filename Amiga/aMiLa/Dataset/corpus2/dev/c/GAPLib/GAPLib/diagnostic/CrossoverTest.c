#include <stdio.h>
#include <string.h>
#include <GAP.h>

static const unsigned char data[5][8] = {
	{0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xfe},
	{0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00},
	{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00},
	{0xfe,0x00,0x00,0x00,0x00,0x00,0x00,0x00},
	{0xff,0xff,0xff,0xff,0xf8,0x00,0x00,0x00}
};

int main(void)
{
unsigned char t[8],u[8];
int i=0,s=0;

memset(t,0,8);
memset(u,0xff,8);

Crossover(t,u,63,8);
	if(memcmp(u,data[s++],8)) {
		i++;
	}

memset(t,0,8);
memset(u,0xff,8);

Crossover(t,u,32,8);
	if(memcmp(u,data[s++],8)) {
		i++;
	}

memset(t,0,8);
memset(u,0xff,8);

Crossover(t,u,0,8);
	if(memcmp(u,data[s++],8)) {
		i++;
	}

memset(t,0,8);
memset(u,0xff,8);

Crossover(t,u,7,8);
	if(memcmp(u,data[s++],8)) {
		i++;
	}

memset(t,0,8);
memset(u,0xff,8);

Crossover(t,u,37,8);
	if(memcmp(u,data[s++],8)) {
		i++;
	}

printf("Crossovertest: %s\n",(i!=0)?"Failed!":"Ok.");

return(i);
}
