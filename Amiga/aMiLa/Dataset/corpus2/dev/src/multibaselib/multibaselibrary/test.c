;/*

gcc -noixemul -O3 test.c -o test
quit

;*/

#include <proto/dos.h>
#include <proto/exec.h>

int main(void)
{
	struct Library *base;

	base = OpenLibrary("multibase.library", 0);

	if (base)
	{
		PutStr("Opened multibase.library successfully!\n");
		CloseLibrary(base);
	}

	return 0;
}
