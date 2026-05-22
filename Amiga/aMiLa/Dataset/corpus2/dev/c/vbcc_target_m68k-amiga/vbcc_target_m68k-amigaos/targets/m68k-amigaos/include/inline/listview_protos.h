#ifndef _VBCCINLINE_LISTVIEW_H
#define _VBCCINLINE_LISTVIEW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __LISTVIEW_GetClass(__reg("a6") void *)="\tjsr\t-30(a6)";
#define LISTVIEW_GetClass() __LISTVIEW_GetClass(ListViewBase)

#endif /*  _VBCCINLINE_LISTVIEW_H  */
