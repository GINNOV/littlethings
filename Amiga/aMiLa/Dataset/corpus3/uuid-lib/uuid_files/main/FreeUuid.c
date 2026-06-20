/* :ts=4
 *  $VER: FreeUuid.c $Revision$ (07-Oct-2018)
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

/****** uuid/main/FreeUuid ******************************************
*
*   NAME
*      FreeUuid -- Free a UUID object
*
*   SYNOPSIS
*      void FreeUuid(void * uuid);
*
*   FUNCTION
*
*   INPUTS
*       uuid - UUID object to free
*
*   RESULT
*       This function does not return a result
*
*   EXAMPLE
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
*****************************************************************************
*
*/

void FreeUuid(void *uuid)
{
	IExec->FreeVec(uuid);
	return;
}

void _uuid_FreeUuid(struct UuidIFace *Self,
       void * uuid)
{
  FreeUuid(uuid);
}

