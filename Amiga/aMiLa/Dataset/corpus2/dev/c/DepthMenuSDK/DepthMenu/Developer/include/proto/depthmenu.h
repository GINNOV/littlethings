#ifndef PROTO_DEPTHMENU_H
#define PROTO_DEPTHMENU_H

/*
**  $VER: depthmenu_pragmas.h v3 (18.11.2002)
**
**  depthmenu.library base definition
**
**  (C) Copyright 2001-2002 Arkadiusz [Yak] Wahlig
**      All Rights Reserved.
*/

#include <exec/types.h>
extern struct DepthMenuBase *DepthMenuBase;
#ifdef __GNUC__
#include <inline/depthmenu.h>
#else
#include <clib/depthmenu_protos.h>
#include <pragmas/depthmenu_pragmas.h>
#endif

#endif /* PROTO_DEPTHMENU_H */
