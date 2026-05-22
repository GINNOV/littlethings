/*
**      $VER: x3base.h 0.1 (15.5.99)
**
**      Creation date : 11.4.1999
**
**      definition of x3Base
**
**
**      Written by Stephan Bielmann
**
*/

#ifndef X3_X3BASE_H
#define X3_X3BASE_H

#ifdef   __MAXON__
#ifndef  EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif
#else
#ifndef  EXEC_LIBRARIES
#include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */
#endif

struct x3Base
{
 struct Library         x3b_LibNode;
 SEGLISTPTR             x3b_SegList;
 struct ExecBase       *x3b_SysBase;
};

#endif /* X3_X3BASE_H */
