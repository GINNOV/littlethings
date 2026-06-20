
/*
 *  SETJMP.H
 *
 *  (c)Copyright 1990, Matthew Dillon, All Rights Reserved
 */

#ifndef SETJMP_H
#define SETJMP_H

typedef long jmp_buf[16];

extern int setjmp(jmp_buf);
extern void longjmp(jmp_buf, int);

#endif

