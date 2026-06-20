/* openlibrary.c */

#include <stdio.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"

struct Library * __rtl_OpenLibrary (UBYTE * libName, ULONG version, const char * file, int line)
{
    struct Library * lib;

    if ( (lib = OpenLibrary (libName, version)) )
	CHECK_ADD_RN(RTL_EXEC,RTLRT_OpenLibrary,lib,libName)

    return (lib);
} /* __rtl_OpenLibrary */


void __rtl_CloseLibrary (struct Library * library, const char * file, int line)
{
    ResourceNode * node;

    CHECK_REM_RN(library,RTLRT_OpenLibrary,CloseLibrary,CloseLibrary(library),
		RTL_EXEC,"(%p)",library)

} /* __rtl_CloseLibrary */


NRT_RET(struct Library *,OpenLibrary,(UBYTE * libName, ULONG version),(libName,version))
NRT(CloseLibrary,(struct Library * library),(library))


/* END openlibrary.c */
