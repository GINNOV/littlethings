/*
**
** Warp3D proto file
** $VER: Warp3D.h_proto 1.0 (06.08.98)
**
**
** This file is part of the Warp3D Project.
** Warp3D is copyrighted
** (C) 1998 Sam Jordan, Hans-Jörg Frieden, Thomas Frieden
** All rights reserved
**
** See the documentation for conditions.
**
*/
#ifndef PROTO_WARP3D_H
#define PROTO_WARP3D_H

#include <exec/types.h>
#ifdef __PPC__
extern struct Library *Warp3DPPCBase;
#else
extern struct Library *Warp3DBase;
#endif

#include <Warp3D/Warp3D.h>
#include <clib/Warp3D_protos.h>
#ifdef __VBCC__
#include <inline/Warp3D_protos.h>
#else
#include <pragmas/Warp3D_pragmas.h>
#endif

#endif
