#ifndef _STRUTIL_H
#define _STRUTIL_H

#include <string.h>

extern char * strichr(char *str,short c);
extern short stristr(char *bigstr,char *substr);
extern char * strnchr(char *str,short c,int len);
extern void strtolower(register char *str);
extern void strins(char *to,char *fm);
  /* strins drops fm at head of to */

extern char *strupr(char *str);
extern char *strrev(char *str);

#endif
