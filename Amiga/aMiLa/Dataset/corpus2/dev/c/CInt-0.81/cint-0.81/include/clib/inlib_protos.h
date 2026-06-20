/******************************************************************************

    MODUL
	clib/alib_protos.h

    DESCRIPTION
	Prototypes for libin.a

******************************************************************************/

#ifndef CLIB_ALIB_PROTOS_H
#define CLIB_ALIB_PROTOS_H

/***************************************
	       Includes
***************************************/
#ifndef IN_STDDEF_H
#   include <in_stddef.h>
#endif
#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif
#ifndef UNIX_H
#   include <unix.h>
#endif
#ifndef UTILITY_TAGITEM_H
#   include <utility/tagitem.h>
#endif


/***************************************
	       Prototypes
***************************************/
extern BOOL InitinLib P((void));
extern void ExitinLib P((void));
extern void AddStackStruct P((struct StructDescription *));
#ifndef ConvertStackTags
extern struct TagItem * ConvertStackTags P((va_list));
extern void FreeStackTags P((struct TagItem *));
#endif


#endif /* CLIB_ALIB_PROTOS_H */

/******************************************************************************
*****  ENDE clib/alib_protos.h
******************************************************************************/
