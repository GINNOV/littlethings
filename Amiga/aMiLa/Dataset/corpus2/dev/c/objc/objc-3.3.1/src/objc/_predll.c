
/*
 * Portable Object Compiler - PreLink Source File
 * $Id: _predll.c,v 1.1.1.1 2000/06/07 21:09:25 stes Exp $
 */
 
/*
 * Just a dummy file with the symbols that "postlink"
 * is going to define.  The driver will link (a compiled version of)
 * this file into the program, for a first link.
 *
 */

char *_objcModules = 0;

/* dummy definition for building LCC WIN32 DLL's */

#if defined(__LCC__) && defined(WIN32)
#include <stdio.h>
#include <windows.h>
int __stdcall LibMain(HANDLE h,DWORD w,LPVOID r) { return 0; }
#endif

/* dummy definition for building WATCOM WIN32 DLL's */

#if defined(__WATCOMC__)
int LibMain() { return 0; }
#endif

