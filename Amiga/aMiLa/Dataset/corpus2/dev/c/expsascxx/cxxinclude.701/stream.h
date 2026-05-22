/* Copyright (c) 1993-1994        by SAS Institute Inc., Cary NC     */

#ifndef __STREAM_H
#define __STREAM_H

#ifndef __IOSTREAM_H
#include <iostream.h>
#endif

#ifndef __IOMANIP_H
#include <iomanip.h>
#endif

#ifndef __STDIOSTREAM_H
#include <stdiostream.h>
#endif

#ifndef __FSTREAM_H
#include <fstream.h>
#endif

#ifndef NULL
#define NULL    0
#endif



char* form( char* format, ... );
    // This function is very similar to printf except that
    // instead of printing to standard output, 'form' returns
    // a string formated as specified in 'format'.

/*
  These functions format the value of 'l' into a string
  which they return.
  
  oct - formats as an octal number using the digits 0-7.
  hex - as a hexidecimal number using the digits 0-9 and
          upper case digits A-F.
  dec - as a decimal number using the digits 0-9.
  chr - format 'i' as a char.
  str - format 'st' as a string.

  If 'size' is zero the returned string will be exactly as
  long as needed to represent the value of 'l'.  Otherwise
  is 'size' is less than the length of the represtation
  the represtation will be truncated on the right, and if 'size'
  is greater than the length of the represtation spaces will be
  added to the left of the representation.
  */

inline char* oct( long l, int size = 0 ) 
    { return form( "%*lo", size, l ); }

inline char* hex( long l, int size = 0 ) 
    { return form( "%*lx", size, l ); }

inline char* dec( long l, int size = 0 ) 
    { return form( "%*ld", size, l ); }

inline char* chr( int i, int size = 0 )
    { return form( "%*c",  size, i ); }

inline char* str( char* st, int size = 0 ) 
    { return form( "%*s", size, st ); }

inline istream& WS(istream& i )
    { return i >> ws; }

inline void eatwhite( istream& i ) 
    { i >> ws; }

__NORENT static const int input = (ios::in) ;
__NORENT static const int output = (ios::out) ;
__NORENT static const int append = (ios::app) ;
__NORENT static const int atend = (ios::ate) ;
__NORENT static const int _good = (ios::goodbit) ;
__NORENT static const int _bad = (ios::badbit) ;
__NORENT static const int _fail = (ios::failbit) ;
__NORENT static const int _eof = (ios::eofbit) ;

typedef ios::io_state state_value ;

#endif /* __STREAM_H */


