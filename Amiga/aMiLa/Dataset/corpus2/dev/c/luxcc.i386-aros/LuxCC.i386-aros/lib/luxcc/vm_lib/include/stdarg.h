#ifndef _STDARG_H
#define _STDARG_H

#define _INTSIZEOF(n)  ((sizeof(n)+sizeof(int)-1) & ~(sizeof(int)-1))

typedef char *va_list;

#define va_start(ap, last)  (ap = (char *)&(last))
#define va_arg(ap, type)    (ap-=_INTSIZEOF(type), *(type *)(ap))
#define va_copy(dest, src)  (dest) = (src)
#define va_end(ap)

#endif
