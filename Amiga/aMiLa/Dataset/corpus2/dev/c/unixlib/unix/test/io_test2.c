#include <stdio.h>

int
main(void)
{
	char buffer[256];

	printf("write something: ");
	fflush(stdout);
	if (gets(buffer))
		printf("(%s)\n", buffer);
	else
		printf("I/O error\n");
	return(0);
}
