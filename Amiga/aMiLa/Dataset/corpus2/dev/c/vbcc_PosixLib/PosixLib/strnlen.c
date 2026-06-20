/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Peter Pettersson in 2021
 *
 * $Id: strnlen.c,v 1.1 2021/07/28 14:40:31 phx Exp $
 */

#include <string.h>

size_t strnlen(const char *s,size_t maxlen)
{
	size_t len = 0;
	while (len<maxlen && *s++)
		len++;
	return len;
}
