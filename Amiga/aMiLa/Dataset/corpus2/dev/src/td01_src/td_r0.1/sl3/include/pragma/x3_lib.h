#ifndef _INCLUDE_PRAGMA_X3_LIB_H
#define _INCLUDE_PRAGMA_X3_LIB_H

#ifndef CLIB_X3_PROTOS_H
#include <clib/x3_protos.h>
#endif

#pragma amicall(x3Base,0x01E,tdo3XSave(d1,d2,a0))
#pragma amicall(x3Base,0x024,tdo3XLoad(d1,d2,d3,a0))
#pragma amicall(x3Base,0x02A,tdo3XCheckFile(d2))
#pragma amicall(x3Base,0x030,tdo3XExt())
#pragma amicall(x3Base,0x036,tdo3XName())

#endif  /*  _INCLUDE_PRAGMA_X3_LIB_H  */
