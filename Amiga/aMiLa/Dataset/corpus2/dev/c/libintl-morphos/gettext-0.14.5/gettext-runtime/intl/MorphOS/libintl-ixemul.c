#include <stdlib.h>

#include <proto/exec.h>
#include <proto/muimaster.h>

#include "libintl-ixemul.h"

/* Lame but couldn not find better way to do it.
 */

struct Library *IntlBase;

STATIC VOID close_libintl(void)
{
	CloseLibrary(IntlBase);
}

STATIC struct Library *open_libintl(void)
{
	struct Library *MyBase = IntlBase;

	if (!MyBase)
	{
		for (;;)
		{
			MyBase = OpenLibrary("intl.library", 0);

			if (!MyBase)
			{
				struct Library *MUIMasterBase = OpenLibrary("muimaster.library", 0);

				if (MUIMasterBase)
				{
					ULONG try_again;

					try_again = MUI_RequestA(NULL, NULL, 0, "Program message", "Retry|Abort program", "Need version 1 of intl.library", NULL);
					CloseLibrary(MUIMasterBase);

					if (try_again)
						continue;
				}

				exit(20);
			}

			break;
		}

		IntlBase = MyBase;

		atexit(close_libintl);
	}

	return MyBase;
}

#define GETLIB struct Library *IntlBase = open_libintl();

char *libintl_gettext(const char *__msgid)
{
  GETLIB
  return call_libintl_gettext (__msgid);
}

char *libintl_dgettext (const char *__domainname, const char *__msgid)
{
  GETLIB
  return call_libintl_dgettext (__domainname, __msgid);
}

char *libintl_dcgettext (const char *__domainname, const char *__msgid, int __category)
{
  GETLIB
  return call_libintl_dcgettext (__domainname, __msgid, __category);
}

char *libintl_ngettext(const char *__msgid1, const char *__msgid2, unsigned long int __n)
{
  GETLIB
  return call_libintl_ngettext (__msgid1, __msgid2, __n);
}

char *libintl_dngettext(const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n)
{
  GETLIB
  return call_libintl_dngettext (__domainname, __msgid1, __msgid2, __n);
}

char *libintl_dcngettext (const char *__domainname, const char *__msgid1, const char *__msgid2, unsigned long int __n, int __category)
{
  GETLIB
  return call_libintl_dcngettext (__domainname, __msgid1, __msgid2, __n, __category);
}

char *libintl_textdomain (const char *__domainname)
{
  GETLIB
  return call_libintl_textdomain (__domainname);
}

char *libintl_bindtextdomain (const char *__domainname, const char *__dirname)
{
  GETLIB
  return call_libintl_bindtextdomain (__domainname, __dirname);
}

char *libintl_bind_textdomain_codeset(const char *__domainname, const char *__codeset)
{
  GETLIB
  return call_libintl_bind_textdomain_codeset(__domainname, __codeset);
}
