#include <proto/regex.h>
#include <proto/exec.h>
#include <dos/dosextens.h>

struct Library *RegexBase;

#ifdef __SASC
#include <constructor.h>

int CONSTRUCTOR_NAME(550, regexinit)(void)
{
	if((RegexBase = OldOpenLibrary("regex.library")) == NULL)
		{
		((struct Process *)FindTask(NULL))->pr_Result2 = ERROR_INVALID_RESIDENT_LIBRARY;
		return 1;
		}
	return 0;
}

void DESTRUCTOR_NAME(550, regexterm)(void)
{
	CloseLibrary(RegexBase);
}
#endif
