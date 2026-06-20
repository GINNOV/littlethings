#include <wchar.h>

wchar_t *wcsncpy(wchar_t *s, const wchar_t *ct, int n)
{
    wchar_t *ptr;
    for (ptr = s; *ct && n-- > 0; ptr++, ct++)
	*ptr = *ct;
    while (n-- > 0)
	*ptr++ = U_NULL;

    return s;
}
