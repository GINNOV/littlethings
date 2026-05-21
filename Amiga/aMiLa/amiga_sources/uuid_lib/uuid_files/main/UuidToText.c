/* :ts=4
 *  $VER: UuidToText.c $Revision$ (07-Oct-2018)
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
#include <stdio.h>

#include "uuid_private.h"

/****** uuid/main/UuidToText ******************************************
*
*   NAME
*      UuidToText -- Convert a private UUID object to a string
*
*   SYNOPSIS
*      void UuidToText(void * uuid, char * text);
*
*   FUNCTION
*
*   INPUTS
*       uuid - Pointer to a UUID object
*       text - Pointer to a buffer of 37 bytes to hold the string representation
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

void UuidToText(uuid_t * uuid, char * text)
{
	sprintf(text,"%08lx-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x", uuid->time_low,
					uuid->time_mid,
					uuid->time_hi_and_version,
					uuid->clock_seq_hi_and_reserved,
					uuid->clock_seq_low,
					uuid->node[0],
					uuid->node[1],
					uuid->node[2],
					uuid->node[3],
					uuid->node[4],
					uuid->node[5]);
	return;
}

void _uuid_UuidToText(struct UuidIFace *Self,
       void * uuid,
       char * text)
{
  UuidToText((uuid_t *)uuid, text);
}

