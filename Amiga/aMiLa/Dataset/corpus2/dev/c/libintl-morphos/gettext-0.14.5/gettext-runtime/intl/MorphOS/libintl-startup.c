#include <stdio.h>

#include <proto/exec.h>
#include <proto/muimaster.h>
#include <constructor.h>

#define LIBRARY_BASENAME IntlBase
#define VERSION 1

void _INIT_4_IntlBase(void) __attribute__((alias("__CSTP_init_IntlBase")));
void _EXIT_4_IntlBase(void) __attribute__((alias("__DSTP_cleanup_IntlBase")));

struct Library * LIBRARY_BASENAME ;

STATIC CONST TEXT libname[] = "intl.library";

static CONSTRUCTOR_P(init_IntlBase, 100)
{
	LIBRARY_BASENAME = OpenLibrary(libname, VERSION);
	if (!(LIBRARY_BASENAME))
	{
		struct Library *MUIMasterBase = OpenLibrary("muimaster.library", 0);

		if (MUIMasterBase)
		{
			ULONG args[1] = { VERSION };
			MUI_RequestA(NULL, NULL, 0, "Startup message", "Abort", "Need version %.10ld of intl.library", &args);
			CloseLibrary(MUIMasterBase);
		}
	}

	return (LIBRARY_BASENAME == NULL);
}

static DESTRUCTOR_P(cleanup_IntlBase, 100)
{
	CloseLibrary(LIBRARY_BASENAME);
}

#if 0
int libintl_printf (const char *format, ...)
{
  va_list args;
  int retval;

  va_start (args, format);
  retval = vprintf (format, args);
  va_end (args);
  return retval;
}

int libintl_snprintf (char *resultbuf, size_t length, const char *format, ...)
{
  va_list args;
  int retval;

  va_start (args, format);
  retval = vsnprintf (resultbuf, length, format, args);
  va_end (args);
  return retval;
}
#endif
