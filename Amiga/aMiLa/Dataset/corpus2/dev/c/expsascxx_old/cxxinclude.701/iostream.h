#ifndef __IOSTREAM_H
#define __IOSTREAM_H
/*-------------------------------------------------------------------*/
/* Copyright (c) 1993-1994       by SAS Institute Inc., Cary NC      */
/*                                                                   */
/* NAME:       iostream.h                                            */
/* AUTHOR:     Gavin Koch - IBM 370 C Compiler department            */
/* DATE:                                                             */
/* SUPPORT:    sasgak - IBM 370 C Compiler department                */
/* PRODUCT:    C++ Library                                           */
/* LANGUAGE:   C++                                                   */
/* MACHINE:    all                                                   */
/* PURPOSE:                                                          */
/*                                                                   */
/* HISTORY:    action                                   date   name  */
/*             spilt iobase.h out of iostream.h       96/03/27  gak  */
/*             avoid use of limits.h                  96/03/26  gak  */
/*             little fixes from 6.00.02              96/03/20  gak  */
/*             allow assignments like cerr = cout     96/01/11  gak  */
/*             allow assignments like cerr = cout     96/01/11  gak  */
/*             Added this description header.         93/03/18  gww  */
/*             Added #ifndef's around each #include   93/07/02  hlc  */
/*             Big Error Message Handling Change      93/09/15  gak  */
/*             Big Error Message Handling Change      93/09/15  gak  */
/*             Fixed 0xFF to not be EOF #8460         93/12/01  hlc  */
/*             Added __alignmem to each class, struct                */
/*              and union definition.                 94/03/16  led  */
/*             Changed __alignmem to #define          94/10/04  gak  */
/*             Failure to track gcount                95/08/11  gak  */
/*             Propagate fixes from 5.50              95/09/22  jjr  */
/*             Fix EOF handling for ignore().         95/09/26  jjr  */
/* NOTES:                                                            */
/* ALGORITHM:                                                        */
/* END                                                               */
/*-------------------------------------------------------------------*/

#include <iobase.h>

#ifdef __I370__
#define __SASCXXLIB_CLASS_DEF_KEYS __alignmem
#define __RENT __rent
#define __NORENT __norent

#else
#define __SASCXXLIB_CLASS_DEF_KEYS 
#define __RENT
#define __NORENT
#endif 

__SASCXXLIB_CLASS_DEF_KEYS class Iostream_init
    {
    public:
      Iostream_init();
      ~Iostream_init();
    };

__RENT static Iostream_init iostream_init;

__RENT extern istream_withassign& cin;
__RENT extern ostream_withassign& cout;
__RENT extern ostream_withassign& cerr;
__RENT extern ostream_withassign& clog;


#undef __SASCXXLIB_CLASS_DEF_KEYS

#endif /* __IOSTREAM_H */








