#include <stdio.h>

int
main(void)
{
	char buffer[256];

	fprintf(stderr, "write something: ");
	fflush(stderr);
	if (gets(buffer))
		printf("(%s)\n", buffer);
	else
		printf("I/O error\n");
	return(0);
}
