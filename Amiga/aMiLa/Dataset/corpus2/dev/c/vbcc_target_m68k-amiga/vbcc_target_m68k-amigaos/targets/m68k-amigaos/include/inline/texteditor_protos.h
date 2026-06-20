#ifndef _VBCCINLINE_TEXTEDITOR_H
#define _VBCCINLINE_TEXTEDITOR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __TEXTEDITOR_GetClass(__reg("a6") void *)="\tjsr\t-30(a6)";
#define TEXTEDITOR_GetClass() __TEXTEDITOR_GetClass(TextFieldBase)

VOID __HighlightSetFormat(__reg("a6") void *, __reg("a0") APTR object, __reg("d0") ULONG pos, __reg("d1") ULONG end, __reg("d2") ULONG style)="\tjsr\t-36(a6)";
#define HighlightSetFormat(object, pos, end, style) __HighlightSetFormat(TextFieldBase, (object), (pos), (end), (style))

#endif /*  _VBCCINLINE_TEXTEDITOR_H  */
