/*
**	Misc.c
**
**	Copyright (C) 1993,94,95 Bernardo Innocenti
**
**	Parts of this file are:
**
**	Copyright © 1990-1993 by Olaf `Olsen' Barthel & MXM
**		All Rights Reserved
**
**	Miscellaneus useful functions
*/

#include <exec/ports.h>


#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <clib/graphics_protos.h>

#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/icon_pragmas.h>
#include <pragmas/graphics_pragmas.h>

#include "XModule.h"
#include "Gui.h"


/* Function pointers to Kickstart-sensitive RastPort query code */
ULONG (*ReadAPen)(struct RastPort *RPort);
ULONG (*ReadBPen)(struct RastPort *RPort);
ULONG (*ReadDrMd)(struct RastPort *RPort);



/* Local function prototypes */
static ULONG OldGetAPen (struct RastPort *RPort);
static ULONG OldGetBPen (struct RastPort *RPort);
static ULONG OldGetDrMd (struct RastPort *RPort);
static ULONG NewGetAPen (struct RastPort *RPort);
static ULONG NewGetBPen (struct RastPort *RPort);
static ULONG NewGetDrMd (struct RastPort *RPort);



struct DiskObject *GetProgramIcon (void)

/*	Get program associated icon.
 *	This function will fail if we are not a son of Workbench.
 *	The returned DiskObject must be freed by FreeDiskObject().
 */
{
	struct DiskObject *dobj;
	BPTR olddir;

	if (!WBenchMsg) return NULL;

	olddir = CurrentDir (WBenchMsg->sm_ArgList->wa_Lock);
	dobj = GetDiskObject (WBenchMsg->sm_ArgList->wa_Name);
	CurrentDir (olddir);

	return dobj;
}



struct Library *MyOpenLibrary (STRPTR name, ULONG ver)
{
	struct Library *lib;

	while (!(lib = OpenLibrary (name, ver)))
	{
		if (!ShowRequest (MSG_OPENLIB_FAIL, MSG_RETRY_OR_CANCEL, (volatile)name, ver))
			break;
	}

	return lib;
}



void CantOpenLib (STRPTR name, LONG ver)

/* Notify the user that a library didn't open */
{
	ShowRequest (MSG_OPENLIB_FAIL, MSG_CONTINUE, (volatile)name, ver);
}



void KillMsgPort (struct MsgPort *mp)

/* Reply all pending messages and DeletePort() */
{
	struct Message *msg;

	Forbid();	/* is this really useful? */

	/* Reply all pending Messages */
	while (msg = GetMsg (mp))
		ReplyMsg (msg);

	DeleteMsgPort (mp);

	Permit();
}



struct TextAttr *CopyTextAttr (struct TextAttr *source, struct TextAttr *dest)

/* Copy <source> textattr structure over <dest>, allocating and copying
 * the ta_Name field.  <dest>->ta_Name if FreeVec()ed before
 * allocating the new one.
 *
 * Returns: <dest> if everything was ok, NULL for failure.
 */

{
	FreeVec (dest->ta_Name);

	memcpy (dest, source, sizeof (struct TextAttr));

	if (dest->ta_Name = AllocVec (strlen (source->ta_Name) + 1, MEMF_PUBLIC))
	{
		strcpy (dest->ta_Name, source->ta_Name);
		return dest;
	}
	return NULL;
}


UWORD CmpTextAttr (struct TextAttr *ta1, struct TextAttr *ta2)

/* Compares two TextAttr structures and returns 0 if they refer to
 * the same font, a non-zero value otherwise.
 */
{
	if (ta1->ta_YSize == ta2->ta_YSize && ta1->ta_Style == ta2->ta_Style)
	{
		if (!ta1->ta_Name && !ta2->ta_Name)
				return 0;

		if (!ta1->ta_Name || !ta2->ta_Name)
				return 1;

		if (!strcmp (ta1->ta_Name, ta2->ta_Name))
			return 0;
	}

	return 1;
}


void FilterName (STRPTR name)

/* Finds and blanks out invalid characters in a name.
 * Will also strip blanks at the end.
 */
{
	UWORD i = 0;

	while (name[i])
	{
		if (name[i] < ' ' ||
			(name[i] >'~' && name[i] < '¡'))
			name[i] = ' ';

		i++;
	}

	/* Kill ending blanks */
	for (--i; i > 0 ; i--)
		if (name[i] == ' ') name[i] = '\0';
		else break;
}



LONG PutIcon (STRPTR source, STRPTR dest)

/* Add the <source> icon to <dest> file */
{
	struct DiskObject *dobj;
	UBYTE buf[PATHNAME_MAX];

	/* We do not alter existing icons */
	if (dobj = GetDiskObject (dest))
	{
		FreeDiskObject (dobj);
		return RETURN_WARN;
	}

	/* Get source icon */

	strcpy (buf, "PROGDIR:Icons");
	AddPart (buf, source, PATHNAME_MAX);
	if (!(dobj = GetDiskObject (buf)))
	{
		strcpy (buf, "ENV:Sys");
		AddPart (buf, source, PATHNAME_MAX);
		if (!(dobj = GetDiskObject (buf)))
		{
			/* Get default project icon */
			dobj = GetDefDiskObject (WBPROJECT);
		}
	}

	if (dobj)
	{
		dobj->do_CurrentX = NO_ICON_POSITION;
		dobj->do_CurrentY = NO_ICON_POSITION;

		if (!(dobj->do_DefaultTool[0]))
		{
			/* Get program path and store in icon's Default Tool */

			BPTR progdir;

			dobj->do_DefaultTool = NULL;

			if (WBenchMsg)	/* WB */
				progdir = WBenchMsg->sm_ArgList->wa_Lock;
			else			/* CLI */
				progdir = GetProgramDir();

			if (progdir)
			{
				if (NameFromLock (progdir, buf, PATHNAME_MAX))
				{
					UBYTE progname[32];

					if (WBenchMsg)	/* WB */
						strncpy (progname, WBenchMsg->sm_ArgList->wa_Name, 32);
					else			/* CLI*/
						GetProgramName (progname, 32);

					if(AddPart (buf, progname, PATHNAME_MAX))
						dobj->do_DefaultTool = buf;
				}
			}
		}

		if (!dobj->do_DefaultTool) dobj->do_DefaultTool = BaseName;
		PutDiskObject (dest, dobj);
		FreeDiskObject (dobj);
		return RETURN_OK;
	}

	return RETURN_FAIL;
}



void InstallGfxFunctions (void)

/* Install the correct routines to query
 * the rendering colours and drawing mode.
 */
{
	if(Kick30)
	{
		ReadAPen = NewGetAPen;
		ReadBPen = NewGetBPen;
		ReadDrMd = NewGetDrMd;
	}
	else
	{
		ReadAPen = OldGetAPen;
		ReadBPen = OldGetBPen;
		ReadDrMd = OldGetDrMd;
	}
}



/* OldGetAPen(struct RastPort *RPort):
 *
 *	Query the current primary rendering colour (old style).
 */

static ULONG OldGetAPen (struct RastPort *RPort)
{
	return((ULONG)RPort->FgPen);
}



/* OldGetBPen(struct RastPort *RPort):
 *
 *	Query the current seconary rendering colour (old style).
 */

static ULONG OldGetBPen (struct RastPort *RPort)
{
	return((ULONG)RPort->BgPen);
}



/* OldGetDrMd(struct RastPort *RPort):
 *
 *	Query the current drawing mode (old style).
 */

static ULONG OldGetDrMd (struct RastPort *RPort)
{
	return((ULONG)RPort->DrawMode);
}



/* NewGetAPen(struct RastPort *RPort):
 *
 *	Query the current primary rendering colour (new style).
 */

static ULONG NewGetAPen (struct RastPort *RPort)
{
	return(GetAPen (RPort));
}



/* NewGetBPen(struct RastPort *RPort):
 *
 *	Query the current seconary rendering colour (new style).
 */

static ULONG NewGetBPen (struct RastPort *RPort)
{
	return (GetBPen (RPort));
}



/* NewGetDrMd(struct RastPort *RPort):
 *
 *	Query the current drawing mode (new style).
 */

static ULONG NewGetDrMd (struct RastPort *RPort)
{
	return(GetDrMd (RPort));
}
