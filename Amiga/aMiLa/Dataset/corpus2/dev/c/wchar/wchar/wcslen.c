#include "wchar.h"

size_t wcslen(const wchar_t *cs)
{
    int n = 0;
    while (*cs++)
	n++;

    return n;
}
