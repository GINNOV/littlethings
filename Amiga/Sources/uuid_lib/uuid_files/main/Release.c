/* :ts=4
 *  $VER: Release.c $Revision$ (07-Oct-2018)
 *
 *  This file is part of uuid.
 *
 *  Copyright (c) 2018 Unsatisfactory Software
 *  All Rights Reserved.
 *
 * $Id$
 *
 * $Log$
 *
 *
 */


#include <exec/exec.h>
#include <proto/exec.h>
#include <dos/dos.h>
#include <libraries/uuid.h>
#include <proto/uuid.h>
#include <stdarg.h>

/* unused */

ULONG _uuid_Release(struct UuidIFace *Self)
{
  return (uint32)0;
}

