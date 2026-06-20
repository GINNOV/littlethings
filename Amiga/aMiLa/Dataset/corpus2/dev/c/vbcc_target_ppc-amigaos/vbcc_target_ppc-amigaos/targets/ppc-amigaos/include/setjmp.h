/* setjmp.h - PowerPC */

#ifndef __SETJMP_H
#define __SETJMP_H 1

typedef int jmp_buf[23+1+18*2];

int setjmp (jmp_buf);
void longjmp (jmp_buf, int);

#endif
