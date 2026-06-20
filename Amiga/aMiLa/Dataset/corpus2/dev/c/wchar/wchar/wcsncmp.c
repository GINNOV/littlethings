#include "wchar.h"

int wcsncmp(const wchar_t *cs, const wchar_t *ct, int n)
{
    while (*cs == *ct && *cs && *ct && n-- > 0)
    {
	cs++;
	ct++;
    }

    return (n <= 0 || *cs == *ct ? 0 : (*cs < *ct ? -1 : 1));
}
