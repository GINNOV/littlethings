#ifndef _INCLUDE_CTYPE_H
#define _INCLUDE_CTYPE_H

/*
**  $VER: ctype.h 1.3 (27.06.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _INLINE_INCLUDES
int isalnum(int);
int isalpha(int);
int iscntrl(int);
int isdigit(int);
int isgraph(int);
int islower(int);
int isprint(int);
int ispunct(int);
int isspace(int);
int isupper(int);
int isxdigit(int);
#endif

int tolower(int);
int toupper(int);
int which_xdigit(char);

#ifdef __cplusplus
}
#endif

#ifdef _INLINE_INCLUDES
extern short int __ctypetable[];
#define testbit(x) return __ctypetable[(short int) c] & x
__inline int isalnum(int c) { testbit(0x0001); }
__inline int isalpha(int c) { testbit(0x0002); }
__inline int iscntrl(int c) { testbit(0x0004); }
__inline int isdigit(int c) { testbit(0x0008); }
__inline int isgraph(int c) { testbit(0x0010); }
__inline int islower(int c) { testbit(0x0020); }
__inline int isprint(int c) { testbit(0x0040); }
__inline int ispunct(int c) { testbit(0x0080); }
__inline int isspace(int c) { testbit(0x0100); }
__inline int isupper(int c) { testbit(0x0200); }
__inline int isxdigit(int c) { testbit(0x0400); }
#undef testbit
#endif

#endif
