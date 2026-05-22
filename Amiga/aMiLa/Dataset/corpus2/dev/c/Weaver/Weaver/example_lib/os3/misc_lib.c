/* 
 * NOTE: For compatibility reason upon using this for OS4 __USE_INLINE__ must be specified!
 *
 * Simple routines to allow the opening and closing of libraries in a fashion that OS4 related
 * macros can be avoided.
*/

#include <exec/libraries.h>

#include <utility/tagitem.h>

#include <proto/exec.h>

#if defined(__amigaos4__)
#include <exec/emulation.h>
#include <exec/interfaces.h>
#include <interfaces/exec.h>
#endif

#if defined(__amigaos4__) || defined(__MORPHOS__)
	#define MIN_SYS_LIB_VER (50)
#else
	#if defined(__AROS__)
		#define MIN_SYS_LIB_VER (41)
	#else
		#define MIN_SYS_LIB_VER (39)
	#endif
#endif

/*
 * Simple routine to open a library accordingly to the parameters passed in.
 *
 * Running in a surround of OS4 means also that the corresponding Interface will be retrieved.
 *
 * @libname     - e.g. "graphics.library"           (CONST_STRPTR)
 * @libversion  - e.g. 39                           (ULONG)
 * @libbase     - e.g. address variable >GfxBase<   (struct Library **)
 *
 * --- ! ONLY OS4 ! ---
 * ifacename    - e.g. "main"                       (CONST_STRPTR)
 *                NOTE: ifacename may be NULL - then "main" is used
 * ifaceversion - e.g. 1                            (ULONG)
 * iface        - e.g. address variable >IGraphics< (struct Interface **)
 * tags         - for now it should remain NULL     (struct TagItem *)
 *
 * Returns 1 (TRUE) for opening library (plus Interface on OS4) succeeded
 * or 0 (FALSE) if library could not be opened.
 */

#if defined (__amigaos4__)
LONG OpenLibShared( CONST_STRPTR libname, ULONG libversion, struct Library **libbase, CONST_STRPTR ifacename, ULONG ifaceversion, struct Interface **iface, struct TagItem * tagarray)
#else
LONG OpenLibShared( CONST_STRPTR libname, ULONG libversion, struct Library **libbase, struct TagItem *tagarray)
#endif
{
	#if defined(__amigaos4__)

	CONST_STRPTR ifacenameptr;
	static const TEXT _default_iface_name[] = "main";

	if (!ifacename)
		ifacenameptr = _default_iface_name;
	else
		ifacenameptr = ifacename;

	*libbase = OpenLibrary( libname, libversion);
	if (*libbase)
	{
		*iface = GetInterface( *libbase, ifacenameptr, ifaceversion, tagarray);
		if (*iface)
		{
			return 1;
		}
		else
		{
			CloseLibrary( *libbase);
			*libbase = NULL;
			return 0;
		}
	}
	else
	{
		*iface = NULL;
		return 0;
	}


	#else

	*libbase = OpenLibrary( libname, libversion);
	if (*libbase)
		return 1;
	else
		return 0;

	#endif
}


/*
 * Simple macro that allows to specify OS4 related stuff which will be ignored
 * for OS3, MorphOS, AROS
 */
#if defined(__amigaos4__)
	#define OPEN_LIB( libname, libversion, libbase, ifacename, ifaceversion, iface, tagarray) \
				OpenLibShared( (libname), (libversion), (libbase), (ifacename), (ifaceversion), (struct Interface **) (iface), (tagarray) )
#else				
	#define OPEN_LIB( libname, libversion, libbase, ifacename, ifaceversion, iface, tagarray) \
				OpenLibShared( (libname), (libversion), (libbase), (tagarray) )
#endif


/*
 * Counterpart for OpenLibShared()
 *
 * It expects the library base as address to the concerned variable
 * and additionally for OS4 the address of the variable holding the
 * Interface pointer.
 *
 * @libbase     - e.g. address variable >GfxBase<   (struct Library **)
 *
 * --- ! ONLY OS4 ! ---
 * iface        - e.g. address variable >IGraphics< (struct Interface **)
 *
 * Returns nothing but clears (zeroes) the corresponding variable(s).
 */

#if defined(__amigaos4__)
void CloseLibShared( struct Library **libbase, struct Interface **iface)
#else
void CloseLibShared( struct Library **libbase)
#endif
{
	if (*libbase)
	{
		#if defined(__amigaos4__)
		if (*iface)
		{
			DropInterface( *iface);
			*iface = NULL;											
		}
		#endif
		CloseLibrary( *libbase);
		*libbase = NULL;
	}
}


/*
 * Simplified call that allows to specify OS4 related stuff which will be ignored
 * for OS3, MorphOS, AROS
 */															
#if defined (__amigaos4__)			
	#define CLOSE_LIB( libbase, iface) \
				CloseLibShared( (libbase), (struct Interface **) (iface) )
#else
	#define CLOSE_LIB( libbase, iface) \
				CloseLibShared( (libbase) )
#endif


#if defined (__amigaos4__)
#define DUPLICATE(srclib, destlib, srciface, destiface) \
					(destlib) = (srclib); (destiface) = (srciface)
					
#else
#define DUPLICATE(srclib, destlib, srciface, destiface) \
					(destlib) = (srclib)
#endif

/* DEMO
	if ( (OPEN_LIB( "dos.library", 39, &_DOSBase, NULL, 1, &_IDOS, NULL)) )
	{
		if ( (OPEN_LIB( "graphics.library", 39, &GfxBase, NULL, 1, &IGraphics, NULL)) )
		{
			DUPLICATE( GfxBase, lb_GfxBase, IGraphics, lb_IGraphics);
			if ( (OPEN_LIB( "intuition.library", 39, &IntuitionBase, "main", 1, &IIntuition, NULL)) )
			{
				printf( "All libraries open...\n");
			}
		}			
	}

	CLOSE_LIB( &IntuitionBase, &IIntuition);
	CLOSE_LIB( &GfxBase, &IGraphics);
	CLOSE_LIB( &_DOSBase, &_IDOS);

  End Demo */
