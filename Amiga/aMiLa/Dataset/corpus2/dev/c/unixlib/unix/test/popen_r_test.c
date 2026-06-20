#include <stdio.h>

int main(void)
{
	int c;
	int first = 1;
	FILE *fp = popen("io_test", "r");

	printf("This is the child output:");
	while ((c = getc(fp)) != EOF) {
		if (first) {
			printf("\n");
			first = 0;
		}
		printf("%4d %c\n", c, c);
	}
	pclose(fp);
	return(0);
}
