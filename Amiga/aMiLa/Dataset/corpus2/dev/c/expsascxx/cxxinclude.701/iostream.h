#ifndef __IOSTREAM_H
#define __IOSTREAM_H
/* Copyright (c) 1993-1994       by SAS Institute Inc., Cary NC      */

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








