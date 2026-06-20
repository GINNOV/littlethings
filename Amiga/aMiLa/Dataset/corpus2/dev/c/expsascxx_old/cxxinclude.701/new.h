/*-------------------------------------------------------------------*/
/* Copyright (c) 1993-1994        by SAS Institute Inc., Cary NC     */
/*                                                                   */
/* NAME:       new.h                                                 */
/* AUTHOR:     Gavin Koch - IBM 370 C Compiler department            */
/* DATE:                                                             */
/* SUPPORT:    sasgak - IBM 370 C Compiler department                */
/* PRODUCT:    C++ Library                                           */
/* LANGUAGE:   C++                                                   */
/* MACHINE:    all                                                   */
/* PURPOSE:                                                          */
/*                                                                   */
/* HISTORY:    action                                   date   name  */
/*             add placement new                      96/03/20  gak  */
/*             Added #ifndef's around each #include   93/07/02  hlc  */
/*             Added this description header.         93/03/18  gww  */
/*             Changed __alignmem to #define          94/10/04  gak  */
/* NOTES:                                                            */
/* ALGORITHM:                                                        */
/* END                                                               */
/*-------------------------------------------------------------------*/
#ifndef __NEW_H
#define __NEW_H

#ifndef _STDDEFH
#include <stddef.h>
#endif
                                                                                
void* operator new( size_t bytes );                                             
void operator delete( void* pointer );                                          
                                                                                
void (*set_new_handler (void(*handler)()))();                    
                                                                               inline void* operator new( size_t bytes, void* where )
    {
    return where;
    }
 
#endif /* __NEW_H */



