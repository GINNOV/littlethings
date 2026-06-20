#ifndef _INCLUDE_SETJMP_H
#define _INCLUDE_SETJMP_H

/*
**  $VER: setjmp.h 1.2 (27.06.2000)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __MIXEDBINARY__
#define _JMP_BUF_SIZE 96
#else   /* __MIXEDBINARY__ */
#ifdef __PPC__
#define _JMP_BUF_SIZE 96
#else   /* __PPC__ */
#define _JMP_BUF_SIZE 40
#endif  /* __PPC__ */
#endif  /* __MIXEDBINARY__ */
typedef int jmp_buf[_JMP_BUF_SIZE];

int setjmp(jmp_buf);
void longjmp(jmp_buf, int);

#ifdef __cplusplus
}
#endif

#endif
