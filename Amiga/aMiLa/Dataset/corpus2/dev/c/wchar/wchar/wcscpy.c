#include "wchar.h"

wchar_t *wcscpy(wchar_t *s, const wchar_t *ct)
{
    wchar_t *ptr;
    for (ptr = s; *ct; ptr++, ct++)
	*ptr = *ct;
    *ptr = U_NULL;

    return s;
}
