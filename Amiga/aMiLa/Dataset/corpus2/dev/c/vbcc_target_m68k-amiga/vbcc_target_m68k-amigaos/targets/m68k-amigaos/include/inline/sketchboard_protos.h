#ifndef _VBCCINLINE_SKETCHBOARD_H
#define _VBCCINLINE_SKETCHBOARD_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __SKETCHBOARD_GetClass(__reg("a6") void *)="\tjsr\t-30(a6)";
#define SKETCHBOARD_GetClass() __SKETCHBOARD_GetClass(SketchBoardBase)

#endif /*  _VBCCINLINE_SKETCHBOARD_H  */
