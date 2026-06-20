#ifndef __IOMANIP_H
#define __IOMANIP_H

/*-------------------------------------------------------------------*/
/* Copyright (c) 1993-1996        by SAS Institute Inc., Cary NC     */
/*                                                                   */
/* NAME:       iomanip.h                                             */
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
/*    Added __alignmem to each class def.             94/03/16  led  */
/*    Made include "iostream.h" be <iostream.h>       93/07/15  hlc  */
/*    Added #ifndef's around each #include            93/07/02  hlc  */
/*    Added this description header.                  93/03/18  gww  */
/*             Changed __alignmem to #define          94/10/04  gak  */
/* NOTES:                                                            */
/* ALGORITHM:                                                        */
/* END                                                               */
/*-------------------------------------------------------------------*/
/*


A manipulator is a value which can be used to effect some change
to a stream by inserting them into or extracting them from the stream.
For example the 'flush' funtion is a manipulator of ostreams:

    cout << flush;     // will cause cout to be flushed.

In fact any function of one the following types is a manipulator:

   ostream& (ostream&)     - is a manipulator for ostreams
   istream& (istream&)     - is a manipulator for istreams
   ios&     (ios&)         - is a manipulator of ios's for
                                     istreams or ostreams


Manipulators can also be created with arguments.  This
file contains some single argument manipulator creation functions
as well as support classes and functions for creating other
single argument manipulator creators.

SMANIP(T) - (where T is a typedef name)
   is the name of a class whos instances are single argument
   manipulators of ios's.  The type of the argument is T.

Similarly, the following are class names for other kinds of
single argument manipulators.

    IMANIP(T)   for istreams
    OMANIP(T)   for ostreams
    IOMANIP(T)  for iostreams


---------------------------------------------------------
This header file contains the following:


First this file declares some single argument manipulator
creators:

---------------------------------------------------------
SMANIP(int) setw( int w )

    setw returns a manipulator (a SMANIP(int)) that will set
    the 'ios::width()' value of the ios it is sent to.

    Example usage:
        cout << setw( 10 )

    is similar to:
         cout.width( 10 )

    except that the first version returns an (ios&).

---------------------------------------------------------
SMANIP(int) setfill( int f )

    setfill returns a minipulator that will set the 'ios::fill()'
    value of the ios it is sent to.

    Example usage:
        cout << setfill( '\t' )


---------------------------------------------------------
SMANIP(int) setprecision( int p )

    returns a manipulator that will set the ios::precision
    value of the ios it is sent to.

    Example usage:
        cout << setprecision( 10 )

---------------------------------------------------------
SMANIP(long) setiosflags( long flags )

    returns a manipulator that will set the ios::flags
    value of the ios it is sent to.

    Example usage:
        cout << setiosflags( ios::skipws )

---------------------------------------------------------
SMANIP(long) resetiosflags( long flags )

    returns a manipulator that will reset the 'flag' bits
    of ios::flags value of the ios it is sent to.

    Example usage:
        cout << resetiosflags( ios::skipws )

---------------------------------------------------------

This header file also declares the following macro:

IOMANIPdeclare( T )

   which when envoked with a typedef name for 'T' will
   declare the following classes:

       SMANIP(T), SAPP(T), IMANIP(T), IAPP(T), OMANIP(T),
       OAPP(T), IOMANIP(T), IOAPP(T)

   the usage of these classes is discribed below.

---------------------------------------------------------

This header file also declares:

IOMANIPdeclare(int);
IOMANIPdeclare(long);

    which will expand as expected.

---------------------------------------------------------

This section discribes the classes created by IOMANIPdeclare(t).

class SMANIP(T) { T must always be a typedef name.
    public:
        SMANIP(T)( ios& (*f)(ios&, T ), T d );

            Construct an SMANIP(T).

            Returns a single argument manipulator by collecting
            the function 'f' and argument 'd' into a single
            manipulator value.

            It is assumed that 'f' will be a function that
            changes ios' in some way using the value of 'd'.

        friend istream& operator>> ( istream& i, const SMANIP(T)& m );
        friend ostream& operator<< ( ostream& o, const SMANIP(T)& m );

            These are the functions that allow SMANIP(T)'s to be
            'inserted-into' istreams and 'extracted-from' ostreams
            respectivly.

            They each take the values of 'f' and 'd' from 'm'.
            They then call

                  f( ios, d)

            where 'ios' is the ios part of 'i' or 'o' respectivly.

            It is assumed that 'f' will be a function that
            changes ios' in some way using the value of 'd'.
     };



SAPP(T)'s make it easier to use SMANIP(T)'s.

Example usage:

    ios& setwidth(ios& i, int w ) { i.width( w ); return i; }
    SAPP(int) setwidth( setwidth );

    This will create a manipulator 'setwidth' which works
    like the library's 'setw'.

class SAPP(T) {
    public:
       SAPP(T) ( ios& (*f)( ios&, T ) );
           Initializes a SAPP(T) to contain 'f'.

       SMANIP(T) operator() ( T d );
           Creates and returns an SMANIP(T) using the 'f'
           from the SAPP(T) and the 'd' argument.
     };

The rest of the classes are the same except that the types of the
user manipulating functions ('f') are different:

   IMANIP(T) and IAPP(T)  'f' is istream& (*f)( istream&, T)
   OMANIP(T) and OAPP(T)  'f' is ostream& (*f)( ostream&, T)
   IOMANIP(T) and IOAPP(T)  'f' is iostream& (*f)( iostream&, T)

IN addition IMANIP(T) does not have 'operator<<', and OMANIP(T) does
not have an 'operator>>'.

*/

#ifndef __IOBASE_H
#include <iobase.h>
#endif

#define SMANIP(T) __smanip_ ## T
#define SAPP(T)   __sapp_ ## T
#define IMANIP(T) __imanip_ ## T
#define IAPP(T)   __iapp_ ## T
#define OMANIP(T) __omanip_ ## T
#define OAPP(T)   __oapp_ ## T
#define IOMANIP(T) __iomanip_ ## T
#define IOAPP(T)   __ioapp_ ## T


#define IOMANIPdeclare(T)                                             \
                                                                      \
                                                                      \
class SMANIP(T) {                                                     \
    public:                                                           \
      SMANIP(T) ( ios& (* _F)(ios&,T), T _D )                         \
          : _FUNC(_F), _DATA(_D) {}                                   \
                                                                      \
      friend istream& operator>> ( istream& _I, const SMANIP(T)& _M ) \
          {                                                           \
          (*_M._FUNC)( _I, _M._DATA );                                \
          return _I;                                                  \
          }                                                           \
                                                                      \
      friend ostream& operator<< (ostream& _O, const SMANIP(T)& _M )  \
          {                                                           \
          (*_M._FUNC)( _O, _M._DATA );                                \
          return _O;                                                  \
          }                                                           \
                                                                      \
    private:                                                          \
      T _DATA;                                                        \
      ios& (*_FUNC)(ios&,T);                                          \
    };                                                                \
                                                                      \
class SAPP(T) {                                                       \
    public:                                                           \
      SAPP(T) ( ios& (* _F)( ios&, T ) )                              \
          : _FUNC(_F) {}                                              \
                                                                      \
      SMANIP(T) operator() ( T _D )                                   \
          {                                                           \
          return SMANIP(T)(_FUNC,_D);                                 \
          }                                                           \
                                                                      \
    private:                                                          \
      ios& (*_FUNC)(ios&, T );                                        \
    };                                                                \
                                                                      \
                                                                      \
class IMANIP(T) {                                                     \
    public:                                                           \
      IMANIP(T) ( istream& (* _F)(istream&,T), T _D )                 \
          : _FUNC(_F), _DATA(_D) {}                                   \
                                                                      \
      friend istream& operator>> ( istream& _I, const IMANIP(T)& _M ) \
          {                                                           \
          (*_M._FUNC)( _I, _M._DATA );                                \
          return _I;                                                  \
          }                                                           \
                                                                      \
    private:                                                          \
      T _DATA;                                                        \
      istream& (*_FUNC)(istream&,T);                                  \
    };                                                                \
                                                                      \
class IAPP(T) {                                                       \
    public:                                                           \
      IAPP(T) ( istream& (* _F)( istream&, T ) )                      \
          : _FUNC(_F) {}                                              \
                                                                      \
      IMANIP(T) operator() ( T _D )                                   \
          {                                                           \
          return IMANIP(T)(_FUNC,_D);                                 \
          }                                                           \
                                                                      \
    private:                                                          \
      istream& (*_FUNC)(istream&, T );                                \
    };                                                                \
                                                                      \
                                                                      \
class OMANIP(T) {                                                     \
    public:                                                           \
      OMANIP(T) ( ostream& (* _F)(ostream&,T), T _D )                 \
          : _FUNC(_F), _DATA(_D) {}                                   \
                                                                      \
      friend ostream& operator<< ( ostream& _I, const OMANIP(T)& _M ) \
          {                                                           \
          (*_M._FUNC)( _I, _M._DATA );                                \
          return _I;                                                  \
          }                                                           \
                                                                      \
    private:                                                          \
      T _DATA;                                                        \
      ostream& (*_FUNC)(ostream&,T);                                  \
    };                                                                \
                                                                      \
class OAPP(T) {                                                       \
    public:                                                           \
      OAPP(T) ( ostream& (* _F)( ostream&, T ) )                      \
          : _FUNC(_F) {}                                              \
                                                                      \
      OMANIP(T) operator() ( T _D )                                   \
          {                                                           \
          return OMANIP(T)(_FUNC,_D);                                 \
          }                                                           \
                                                                      \
    private:                                                          \
      ostream& (*_FUNC)(ostream&, T );                                \
    };                                                                \
                                                                      \
                                                                      \
class IOMANIP(T) {                                                    \
    public:                                                           \
      IOMANIP(T) ( iostream& (* _F)(iostream&,T), T _D )              \
          : _FUNC(_F), _DATA(_D) {}                                   \
                                                                      \
   friend iostream& operator>> ( iostream& _I, const IOMANIP(T)& _M ) \
          {                                                           \
          (*_M._FUNC)( _I, _M._DATA );                                \
          return _I;                                                  \
          }                                                           \
                                                                      \
   friend iostream& operator<< (iostream& _O, const IOMANIP(T)& _M )  \
          {                                                           \
          (*_M._FUNC)( _O, _M._DATA );                                \
          return _O;                                                  \
          }                                                           \
                                                                      \
    private:                                                          \
      T _DATA;                                                        \
      iostream& (*_FUNC)(iostream&,T);                                \
    };                                                                \
                                                                      \
class IOAPP(T) {                                                      \
    public:                                                           \
      IOAPP(T) ( iostream& (* _F)( iostream&, T ) )                   \
          : _FUNC(_F) {}                                              \
                                                                      \
      IOMANIP(T) operator() ( T _D )                                  \
          {                                                           \
          return IOMANIP(T)(_FUNC,_D);                                \
          }                                                           \
                                                                      \
    private:                                                          \
      iostream& (*_FUNC)(iostream&, T );                              \
    };                                                                \
// end of IOMANIPdeclare(T) -- leave this comment


IOMANIPdeclare(long);
IOMANIPdeclare(int);



inline ios& setbase( ios& _IOS, int _ARG )
    {
    if ( _ARG == 16 )
        return hex( _IOS );
    else if ( _ARG == 8 )
        return oct( _IOS );
    else
        return dec( _IOS );
    }

inline SMANIP(int) setbase( int _ARG )
    {
    return SMANIP(int)( setbase, _ARG );
    }


inline ios& setw( ios& _IOS, int _ARG )
    {
    _IOS.width( _ARG );
    return _IOS;
    }

inline SMANIP(int) setw( int _ARG )
    {
    return SMANIP(int)( setw, _ARG );
    }

inline ios& setfill( ios& _IOS, int _ARG )
    {
    _IOS.fill(_ARG);
    return _IOS;
    }

inline SMANIP(int) setfill( int _ARG )
    {
    return SMANIP(int)(setfill,_ARG);
    }

inline ios& setprecision( ios& _IOS, int _ARG )
    {
    _IOS.precision( _ARG );
    return _IOS;
    }

inline SMANIP(int) setprecision( int _ARG )
    {
    return SMANIP(int)( setprecision, _ARG );
    }

inline ios& setiosflags( ios& _IOS, long _ARG )
    {
    _IOS.setf( _ARG );
    return _IOS;
    }

inline SMANIP(long) setiosflags( long _ARG )
    {
    return SMANIP(long)( setiosflags, _ARG);
    }

inline ios& resetiosflags( ios& _IOS, long _ARG )
    {
    _IOS.setf(0,_ARG);
    return _IOS;
    }

inline SMANIP(long) resetiosflags( long _ARG )
    {
    return SMANIP(long)( resetiosflags, _ARG);
    }


#endif /* __IOMANIP_H */











