#ifndef _INCLUDE_LIBBASE_H
#define _INCLUDE_LIBBASE_H

/*
**  $VER: libbase.h 1.01 (7.2.97)
**  StormC Release 4.0
**
**  '(C) Copyright 1995-2000 Haage & Partner Computer GmbH'
**   All Rights Reserved
*/

#ifndef __cplusplus
#error <libbase.h> must be compiled in C++ mode.
#pragma +
#endif

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

class LibBaseC
{
public:
    LibBaseC(STRPTR name, ULONG version, BOOL exitOnFail = TRUE);
    ~LibBaseC();
    BOOL isOpen() const { return Base != NULL; }
    static BOOL areAllOpen() { return !not_open; }
    operator struct Library *() const { return Base; }
    UWORD version() const;
private:
    LibBaseC(const LibBaseC &);
    LibBaseC &operator= (const LibBaseC &);
    struct Library *Base;
    static BOOL not_open;
};


// sLibBaseC is functional identical to LibBaseC but used for opening
// shared libraries from the init code of a shared library.
class sLibBaseC
{
public:
    sLibBaseC(STRPTR name, ULONG version, BOOL exitOnFail = TRUE);
    ~sLibBaseC();
    BOOL isOpen() const { return Base != NULL; }
    static BOOL areAllOpen() { return !not_open; }
    operator struct Library *() const { return Base; }
    UWORD version() const;
private:
    sLibBaseC(const sLibBaseC &);
    sLibBaseC &operator= (const sLibBaseC &);
    struct Library *Base;
    static BOOL not_open;
};

#endif  /* _INCLUDE_LIBBASE_H */
