;/* Execute me to compile with SAS/C 5.10+
Version exec.library 36 >NIL:
If WARN
   Echo "Running old OS release, compiling pre-V36 version*N"
   LC -b1 -cfirst -j73 -r1r -d0 -v -ms -O -oT:HelloWorld.o HelloWorld.c
Else
   Echo "Running Release 2+, compiling V36+ version*N"
   LC -b1 -cfirst -j73 -r1r -d0 -v -ms -O -DRELEASE_2 -oT:HelloWorld.o HelloWorld.c
EndIf
BLink T:HelloWorld.o TO HelloWorld SC SD ND
Protect HelloWorld +P
Delete T:HelloWorld.o QUIET
Quit
*/

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <libraries/dos.h>
#include <string.h>

#define MSG    "Hello world!\n"

#pragma syscall CloseLibrary 19e 901
#pragma syscall OpenLibrary 228 902

#ifdef RELEASE_2
#define VERSTR "\0$VER: HelloWorld2 1.0 (13.7.92)"
#define DOSVER 36L
#pragma libcall DOSBase PutStr 3b4 101
#else
#define VERSTR "\0$VER: HelloWorld 1.0 (13.7.92)"
#define DOSVER 0L
#pragma libcall DOSBase Output 3c 0
#pragma libcall DOSBase Write 30 32103
#endif

ULONG main(VOID)
{
   ULONG           RC      = RETURN_OK;
   struct Library *DOSBase = OpenLibrary(DOSNAME VERSTR, DOSVER);

   if(DOSBase)
   {
#ifdef RELEASE_2
      PutStr(MSG);
#else
      /* strlen result is put on stack. :-( */
      Write(Output(), MSG, strlen(MSG));
#endif
      CloseLibrary(DOSBase);
   }
   else
      RC = RETURN_FAIL;
   return RC;
}
