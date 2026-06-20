#include <stdio.h>

int main(void)
{
	FILE *fp = popen("io_test", "w");
	fprintf(fp, "pescestocco\n");
	pclose(fp);
	return(0);
}
