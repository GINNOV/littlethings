#include "main.h"

int main(int ac, char *av)
{
	char *a;
	void *b;
	char n[]="This is a sample text";

	a = AllocMem(20, 0);  /* Note that we never free this memory */

	a = AllocMem(10, 0);

	FreeMem(a, 9);  /* Note that we free an incorrect length here */

	a = AllocVec(10, 0);

	free(a);  /* Freed with wrong free routine */

	a = strdup("test"); /* Note that we never free this memory */

	a = getcwd(NULL, 1000);
	free(a);
	free(a);  /* Note that we're freeing the memory twice! */


	/* now use standard malloc and free functions */
	b = (void *)malloc(10);
	free(b);

	/* now, how about assigning in a an if-statement */
	if ((b = (void *)malloc(strlen(n)+1)) == NULL)
		b = (void *)0xdeadbeef;

	free(b);

	putenv("MWTest=xx");
	a = getenv("MWTest");
	if(a) a[strlen(a)+1] = 0;  /* Note we're trashing a byte!!!      */
                               /* This shouldn't cause a real crash  */
                               /* since malloc() allocates in clumps */
                               /* of 4 bytes, and 'a' is 3 bytes.    */

	MWReport("At end of main()", MWR_FULL);  /* Generate a memory usage report */

	return(0);
}
