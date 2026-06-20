#ifndef _VBCCINLINE_GETCOLOR_H
#define _VBCCINLINE_GETCOLOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __GETCOLOR_GetClass(__reg("a6") void *)="\tjsr\t-30(a6)";
#define GETCOLOR_GetClass() __GETCOLOR_GetClass(GetColorBase)

#endif /*  _VBCCINLINE_GETCOLOR_H  */
