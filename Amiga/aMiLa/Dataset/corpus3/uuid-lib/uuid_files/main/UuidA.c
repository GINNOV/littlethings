/* :ts=4
 *  $VER: UuidA.c $Revision$ (07-Oct-2018)
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
#include <proto/utility.h>
#include <dos/dos.h>
#include <libraries/uuid.h>
#include <proto/uuid.h>
#include <stdarg.h>
#include <stdio.h>

#include "uuid_v1.h"
#include "uuid_v4.h"
#include "uuid_v5.h"
#include "uuid_preset.h"
#include "uuid_string.h"

/****** uuid/main/UuidA ******************************************
*
*   NAME
*      UuidA -- Ceate a UUID object
*      Uuid -- Vararg stub
*
*   SYNOPSIS
*      void * UuidA(const struct TagItem * taglist);
*      void * Uuid(...);
*
*   FUNCTION
*       Creates a UUID as per RFC4122
*
*   INPUTS
*       taglist - see below
*
*   TAGS
*       UUID_Version (ULONG)
*       Version of UUID to create.
*       Currently supported versions are 1, 4 and 5.
*       Defaults to 1.
*
*       UUID_Namespace (void *)
*       A UUID object to use as a namspace.
*       This is only used when creating v5 UUIDs, and
*       is REQUIRED to create a v5 UUID.
*
*       UUID_Name (char *)
*       A string to use as a name within a namespace.
*       This is only used when creating v5 UUIDs, and
*       is REQUIRED to create a v5 UUID.
*
*       UUID_Preset (ULONG)
*       A predefined UUID to return. These are usually
*       used as namespaces when creating v5 UUIDs.
*       If UUID_Preset is provided, no other tags should
*       be specified.
*       Choices are:
*         UUID_NULL    - NULL UUID
*         UUID_NS_DNS  - DNS namespace
*         UUID_NS_URL  - URL namespace
*         UUID_NS_OID  - OID namespace
*         UUID_NS_X500 - X500 namespace
*
*       UUID_String (char *)
*       A UUID string to convert to a UUID object.
*       This is the opposite of UuidToText()
*       If UUID_String is provided, no other tags should
*       be specified.
*
*   RESULT
*       A UUID object which must be freed with FreeUuid(),
*       or NULL on error.
*
*   EXAMPLE
*       Create and print a v4 UUID:
*
*       void *uuid = IUuid->Uuid(UUID_Version, 4, TAG_DONE);
*       if(uuid != NULL) {
*         char uuid_s[37];
*         IUuid->UuidToText(uuid, uuid_s);
*         printf("%s\n", uuid_s);
*         IUuid->FreeUuid(uuid);
*       }
*
*   NOTES
*       If tags UUID_Preset or UUID_String are provided
*       along with other tags, the behaviour is undefined.
*
*       This library can currently generate a maximum of
*       ten v1 UUIDs per microsecond.  If this limit is
*       reached, NULL will be returned. Be prepared to
*       handle this!
*
*   BUGS
*
*   SEE ALSO
*       FreeUuid(), UuidToText()
*
*****************************************************************************
*
*/

void *UuidA(const struct TagItem * taglist)
{
	struct TagItem *ti;
	ULONG ver = 1;
	ULONG preset = 0;
	uuid_t *namespace = NULL;
	char *name = NULL;
	char *uuid_str = NULL;
	bool ret = false;
	
	if((ti = IUtility->FindTagItem(UUID_Version, taglist)))
		ver = (ULONG)ti->ti_Data;

	if((ti = IUtility->FindTagItem(UUID_Preset, taglist)))
		preset = (ULONG)ti->ti_Data;

	if((ti = IUtility->FindTagItem(UUID_String, taglist)))
		uuid_str = (char *)ti->ti_Data;

	if((ti = IUtility->FindTagItem(UUID_Namespace, taglist)))
		namespace = (uuid_t *)ti->ti_Data;

	if((ti = IUtility->FindTagItem(UUID_Name, taglist))) {
		name = (char *)ti->ti_Data;
		#ifdef DEBUG
		IExec->DebugPrintF("%s\n", name);
		#endif
	}

	if((ver == 5) && ((name == NULL) || (namespace == NULL)))
		return NULL;
		
	uuid_t *uuid = IExec->AllocVecTags(sizeof(uuid_t),
				AVT_Type, MEMF_PRIVATE,
				TAG_DONE);

	if(uuid == NULL) return NULL;

	if(preset != 0) {
		ret = uuid_preset(uuid, preset);
	} else if (uuid_str != NULL) {
		ret = uuid_string(uuid, uuid_str);
	} else if(ver == 1) {
		ret = uuidv1(uuid);
	} else if(ver == 5) {
		ret = uuidv5(uuid, namespace, name);
	} else if(ver == 4) {
		ret = uuidv4(uuid);
	}
	
	if(ret == true) {
		return uuid;
	} else {
		IExec->FreeVec(uuid);
		return NULL;
	}
}

void * VARARGS68K _uuid_Uuid(struct UuidIFace *Self,
       ...);

void * _uuid_Uuid(struct UuidIFace *Self,
       ...)
{
    va_list ap;
    struct TagItem *tags;

    va_startlinear(ap, Self);
    tags = va_getlinearva(ap, struct TagItem *);

    return Self->UuidA(
        tags);

}

void * _uuid_UuidA(struct UuidIFace *Self,
       const struct TagItem * taglist)
{
  return UuidA(taglist);
}

