#include "wchar.h"

wchar_t *wcscat(wchar_t *s, const wchar_t *ct)
{
    wchar_t *ptr = s;

    while (*ptr)
	ptr++;
    wcscpy(ptr, ct);

    return s;
}
