/* Copyright (c) 1993-1994        by SAS Institute Inc., Cary NC     */
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



