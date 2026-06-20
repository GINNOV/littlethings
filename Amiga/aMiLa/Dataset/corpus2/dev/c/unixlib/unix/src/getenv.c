#include "amiga.h"
#include <string.h>

/* This __getenv removes trailing newlines & multiple calls don't
   destroy results */
char *__getenv(const char *varname)
{
    char *return_string;
    char buf[64];

    __chkabort();
    if (varname && varname[0]) {
	int len, size;

	len = GetVar(varname, buf, 64, LV_VAR);
	if (len >= 0) {
	    size = IoErr();
	    return_string = malloc(size + 1);
	    if (!return_string)
		return 0;
	    if (size != len) {
		if (GetVar(varname, return_string, size + 1, LV_VAR) > 0)
		    return return_string;
	    } else
		return strcpy(return_string, buf);
	}
    }
    return 0;
}
