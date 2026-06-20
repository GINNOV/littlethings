#include <stdio.h>

#include <proto/intuition.h>

int main(void)
{
	char string[200], *c = string;
	ULONG result;
	
	*((UWORD *)c) = 32;
	c += 2;
	*((UBYTE *)c) = 32;
	c++;
	c += sprintf(c, "DisplayAlert");
	c++;
	*c = 0;
	
	result = (ULONG)TimedDisplayAlert(0x80001234, string, 100, 20*50*20);
	printf("result: %08lx\n", result);
	
	return(0);
}
