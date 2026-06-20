/* alloca(), setjmp(), longjmp() */

#ifndef _ALLOCA_H
#define _ALLOCA_H 1

#ifndef __SASC
#error Wrong compiler (SAS/C required)
#endif

/* do not include setjmp.h later */
#ifndef _SETJMP_H
#define _SETJMP_H 1
#endif

#include <stddef.h>


typedef unsigned long jmp_buf[40];


extern unsigned long __alloca_virtual_SP;

extern void __asm _EPILOG(register __a0 char *);
extern int __setjmp(jmp_buf);
extern void longjmp(jmp_buf, int);
extern void *alloca(size_t size);


#define setjmp(jb)      __setjmp(((jb)[39] = __alloca_virtual_SP, (jb)))
#define longjmp(jb,rc)  do { __alloca_virtual_SP = (jb)[39] + 1; _EPILOG(NULL); longjmp((jb), (rc)); } while (0)


#endif /* _ALLOCA_H */

