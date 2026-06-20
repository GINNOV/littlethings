#include <stdlib.h>
#include <errno.h>

#include <proto/exec.h>
#include <exec/execbase.h>
#include <dos/dosextens.h>
#include <proto/muimaster.h>

#include "iconv.h"
#include "libiconv-startup.h"

#define ICONV_LIBRARY_VERSION 2
#define ICONV_LIBRARY_NAME "iconv.library"

struct Library *ICONV_BASE_NAME;

int _libiconv_version = _LIBICONV_VERSION;


#ifdef BUILD_IXEMUL_LIB
STATIC VOID close_iconv(void)
{
	CloseLibrary(ICONV_BASE_NAME);
}
#else
#include <constructor.h>

void _INIT_4_IConvBase(void) __attribute__((alias("__CSTP_init_IConvBase")));
void _EXIT_4_IConvBase(void) __attribute__((alias("__DSTP_cleanup_IConvBase")));

static CONSTRUCTOR_P(init_IConvBase, 100)
{
	ICONV_BASE_NAME = OpenLibrary(ICONV_LIBRARY_NAME, ICONV_LIBRARY_VERSION);
	if (!(ICONV_BASE_NAME))
	{
		struct Library *MUIMasterBase = OpenLibrary("muimaster.library", 0);

		if (MUIMasterBase)
		{
			ULONG args[1] = { ICONV_LIBRARY_VERSION };
			MUI_RequestA(NULL, NULL, 0, "Startup message", "Abort", "Need version %.10ld of " ICONV_LIBRARY_NAME, &args);
			CloseLibrary(MUIMasterBase);
		}
	}

	return (ICONV_BASE_NAME == NULL);
}

static DESTRUCTOR_P(cleanup_IConvBase, 100)
{
	CloseLibrary(ICONV_BASE_NAME);
}
#endif

iconv_t libiconv_open(const char* tocode, const char* fromcode)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;
	iconv_t ret;

#ifdef BUILD_IXEMUL_LIB
	if (!ICONV_BASE_NAME)
	{
		for (;;)
		{
			ICONV_BASE_NAME = OpenLibrary(ICONV_LIBRARY_NAME, ICONV_LIBRARY_VERSION);

			if (!ICONV_BASE_NAME)
			{
				struct Library *MUIMasterBase = OpenLibrary("muimaster.library", 0);

				if (MUIMasterBase)
				{
					ULONG args[1] = { ICONV_LIBRARY_VERSION };
					ULONG try_again;

					try_again = MUI_RequestA(NULL, NULL, 0, "Program message", "Retry|Abort program", "Need version %.10ld of " ICONV_LIBRARY_NAME, &args);
					CloseLibrary(MUIMasterBase);

					if (try_again)
						continue;
				}

				exit(20);
			}

			break;
		}

		atexit(close_iconv);
	}
#endif

	ret = call_libiconv_open(tocode, fromcode);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;

	return ret;
}

size_t libiconv(iconv_t cd, const char* * inbuf, size_t *inbytesleft, char* * outbuf, size_t *outbytesleft)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;
	size_t ret;

	ret = call_libiconv(cd, inbuf, inbytesleft, outbuf, outbytesleft);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;

	return ret;
}

int libiconv_close(iconv_t cd)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;
	int ret;

	ret = call_libiconv_close(cd);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;

	return ret;
}

int libiconvctl(iconv_t cd, int request, void* argument)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;
	int ret;

	ret = call_libiconvctl(cd, request, argument);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;

	return ret;
}

void libiconvlist(int (*do_one) (unsigned int namescount, const char * const * names, void* data), void* data)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;

	call_libiconvlist(do_one, data);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;
}

void libiconv_set_relocation_prefix(const char *orig_prefix, const char *curr_prefix)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;

	call_libiconv_set_relocation_prefix(orig_prefix, curr_prefix);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;
}

const char *iconv_canonicalize(const char *name)
{
	struct Process *MyProc = (struct Process *)SysBase->ThisTask;
	LONG OldRes2 = MyProc->pr_Result2;
	const char *ret;

	ret = call_iconv_canonicalize(name);

	if (MyProc->pr_Result2)
		errno = MyProc->pr_Result2;
	MyProc->pr_Result2 = OldRes2;

	return ret;
}
