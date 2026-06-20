#ifndef _STDDEF_H
#define _STDDEF_H

#define NULL    (void *)0

typedef long ptrdiff_t;
typedef unsigned long size_t;
typedef long wchar_t;

#define offsetof(type, member)  ((size_t)&(((type *)0)->member))

#endif
