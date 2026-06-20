#include "wchar.h"

int wcscmp(const wchar_t *cs, const wchar_t *ct)
{
    while (*cs == *ct && *cs && *ct)
    {
	cs++;
	ct++;
    }

    return (*cs == *ct ? 0 : (*cs < *ct ? -1 : 1));
}
