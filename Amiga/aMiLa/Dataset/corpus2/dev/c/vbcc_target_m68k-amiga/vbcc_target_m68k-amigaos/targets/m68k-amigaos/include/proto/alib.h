#ifndef PROTO_ALIB_H
#define PROTO_ALIB_H

#include <clib/alib_protos.h>

void __BeginIO(__reg("a1")struct IORequest *ioReq) =
  "\tmove.l\ta6,-(sp)\n"
  "\tmove.l\t20(a1),a6\n"
  "\tjsr\t-30(a6)\n"
  "\tmove.l\t(sp)+,a6";
#define BeginIO(x) __BeginIO(x)

__regsused("") void __NewList(__reg("a0")struct List *list) =
  "\tmove.l\ta0,8(a0)\n"
  "\taddq.l\t#4,a0\n"
  "\tclr.l\t(a0)\n"
  "\tmove.l\ta0,-(a0)";
#define NewList(x) __NewList(x)

#endif /* PROTO_ALIB_H */
