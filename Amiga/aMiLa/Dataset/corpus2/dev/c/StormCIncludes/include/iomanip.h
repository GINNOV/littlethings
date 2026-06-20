#ifndef _INCLUDE_IOMANIP_H
#define _INCLUDE_IOMANIP_H

/*
**  $VER: iomanip.h 1.01 (7.2.97)
**  StormC Release 3.0
**
**  '(C) Copyright 1995/96/97 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef __cplusplus
#error <iomanip.h> must be compiled in C++ mode.
#pragma +
#endif

#ifndef _INCLUDE_IOSTREAM_H
#include <iostream.h>
#endif


template<class T> class SMANIP
{
public:
    SMANIP(ios &(*ff)(ios &,T), T ii) : f(ff), i(ii) { }
    friend istream &operator >>(istream &is, const SMANIP<T> &m)
    {
        (*m.f)(is,m.i);
        return is;
    }
    friend ostream &operator <<(ostream &os, const SMANIP<T> &m)
    {
        (*m.f)(os,m.i);
        return os;
    }
private:
    T i;
    ios& (*f)(ios &,T);
};

template<class T> class IMANIP
{
public:
    IMANIP(istream &(*ff)(istream &,T), T ii) : f(ff), i(ii) { }
    friend istream &operator >>(istream &is, const IMANIP<T> &m)
    {
        (*m.f)(is,m.i);
        return is;
    }
private:
    T i;
    istream &(*f)(istream &,T);
};

template<class T> class OMANIP
{
public:
    OMANIP(ostream &(*ff)(ostream &,T), T ii) : f(ff), i(ii) { }
    friend ostream &operator <<(ostream &os, const OMANIP<T> &m)
    {
        (*m.f)(os,m.i);
        return os;
    }
private:
    T i;
    ostream &(*f)(ostream &,T);
};


template<class T> class IOMANIP
{
public:
    IOMANIP(iostream &(*ff)(iostream &,T), T ii) : f(ff), i(ii) { }
    friend iostream &operator >>(iostream &io, const IOMANIP<T> &m)
    {
        (*m.f)(io,m.i);
        return io;
    }
    friend iostream &operator <<(iostream &io, const IOMANIP<T> &m)
    {
        (*m.f)(io,m.i);
        return io;
    }
private:
    T i;
    iostream &(*f)(iostream &,T);
};

inline ios &setbase(ios &is, int i)
{
    if (i == 16)
        return hex(is);
    else if (i == 8)
        return oct(is);
    else
        return dec(is);
}

inline SMANIP<int> setbase(int i)
{
    return SMANIP<int>(setbase,i);
}

inline ios &setw(ios &is, int i)
{
    is.width(i);
    return is;
}

inline SMANIP<int> setw(int i)
{
    return SMANIP<int>(setw,i);
}

inline ios &setfill(ios &is, int i)
{
    is.fill(i);
    return is;
}

inline SMANIP<int> setfill(int i)
{
    return SMANIP<int>(setfill,i);
}

inline ios &setprecision(ios &is, int i)
{
    is.precision(i);
    return is;
}

inline SMANIP<int> setprecision(int i)
{
    return SMANIP<int>(setprecision,i);
}

inline ios &setiosflags(ios &is, long i)
{
    is.setf(i);
    return is;
}

inline SMANIP<long> setiosflags(long i)
{
    return SMANIP<long>(setiosflags,i);
}

inline ios &resetiosflags(ios &is, long i)
{
    is.setf(0,i);
    return is;
}

inline SMANIP<long> resetiosflags(long i)
{
    return SMANIP<long>(resetiosflags,i);
}

#endif
