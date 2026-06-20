/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: rsetjmp.h
 * Description: longjmp(),setjmp() replacements
 * Comments: replaces c.lib longjmp(),setjmp() which did not cooperate
 *   nicely with dynastack & alloca()
 */

#ifndef __RSETJMP_H
#define __RSETJMP_H

    /*
     * setjmp()/longjmp()
     *
     *   Set up for a non-local goto. (setjmp)
     *   Execution of a non-local goto. (longjmp)
     */
#   ifdef __SETJMP_H
#       undef __JBUFSIZE
#       undef setjmp
#       undef longjmp
#   else
#       define __SETJMP_H
#   endif   /* __SETJMP_H */

#   define jmp_buf new_jmp_buf

#   if defined(__ALLOCA_REPLACE) && defined(__DYNASTACK_STKCHK)
#       define __JBUFSIZE   (17*sizeof(char *))
#   elif defined(__ALLOCA_REPLACE) || defined(__DYNASTACK_STKCHK)
#       define __JBUFSIZE   (16*sizeof(char *))
#   else
#       define __JBUFSIZE   (15*sizeof(char *))
#   endif

    typedef char new_jmp_buf[__JBUFSIZE];

    int setjmp(jmp_buf _env);
    void longjmp(jmp_buf _env, int _val);

#endif  /* __RSETJMP_H */
