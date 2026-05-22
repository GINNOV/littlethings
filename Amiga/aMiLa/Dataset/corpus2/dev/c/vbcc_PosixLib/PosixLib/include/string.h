/*
 * POSIX Compatibility Library for AmigaOS
 *
 * Written by Frank Wille <frank@phoenix.owl.de> in 2003-2006
 *
 * $Id: string.h,v 1.4 2021/07/28 14:40:31 phx Exp $
 */

#ifndef _STRING_H_
#define _STRING_H_

#include <stddef.h>
#include_next <string.h>


/* Prototypes */
char *strdup(const char *);

#ifndef _STRINGS_H_
#include <strings.h>
#endif

size_t strlcat(char *, const char *, size_t);
size_t strlcpy(char *, const char *, size_t);
char *strsep(char **, const char *);
int strcoll(const char *, const char *);
size_t strnlen(const char *,size_t);

#endif /* _STRING_H_ */
