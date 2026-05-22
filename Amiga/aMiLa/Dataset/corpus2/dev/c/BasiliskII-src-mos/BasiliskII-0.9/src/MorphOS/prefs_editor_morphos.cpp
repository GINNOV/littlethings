/*
 *  prefs_editor_morphos.cpp - Preferences editor, MorphOS implementation
 *
 *  Basilisk II (C) 1997-2001 Christian Bauer
 * 					  2005-2007 Ilkka Lehtoranta
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <dos/filehandler.h>
#include <libraries/asl.h>
#include <libraries/gadtools.h>
#include <libraries/iffparse.h>

#include <proto/alib.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/muimaster.h>

#include "guithread.h"
#include "mui.h"

#include "sysdeps.h"
#include "main.h"
#include "xpram.h"
#include "cdrom.h"
#include "user_strings.h"
#include "version.h"
#include "prefs.h"
#include "prefs_editor.h"

#include "locale/locale.h"

/*
 *  ReturnIDs
 */

enum
{
	PREFS_DONE = 1,
	PREFS_ADD_DISK,
	PREFS_EDIT_DISK,
	PREFS_REMOVE_DISK,
	PREFS_VOLUMEWIN_DONE,
	PREFS_VOLUMEWIN_CANCELLED,
	PREFS_ABOUT
};

#define MAX_STRING_LENGTH 256

/*
 *  External variables
 */

extern Object *app;

/*
 *
 */

STATIC CONST_STRPTR PrefPages[] =
{
	(CONST_STRPTR)MSG_PAGE_VOLUMES,
	(CONST_STRPTR)MSG_PAGE_SCSI,
	(CONST_STRPTR)MSG_PAGE_COMMUNICATION,
	(CONST_STRPTR)MSG_PAGE_EMULATION,
	NULL
};

STATIC CONST CONST_STRPTR ModelNames[] =
{
	"Mac IIci (MacOS 7.x)",
	"Quadra 900 (MacOS 8.x)",
	NULL
};

STATIC CONST_STRPTR VolumeTypes[] =
{
	(CONST_STRPTR)MSG_PREFS_VOLUMETYPE_FILE_GAD,
	(CONST_STRPTR)MSG_PREFS_VOLUMETYPE_DEVICE_GAD,
	NULL
};

STATIC struct NewMenu menustrip[] =
{
	{ NM_TITLE	, (STRPTR)MSG_MENU_TITLE_BASILISK, NULL, 0, 0, NULL },
	{ NM_ITEM	, (STRPTR)MSG_MENU_BASILISK_ABOUT, NULL, 0, 0, (APTR)PREFS_ABOUT },
	{ NM_ITEM	, NM_BARLABEL                    , NULL, 0, 0, NULL },
	{ NM_ITEM	, (STRPTR)MSG_MENU_BASILISK_START, NULL, 0, 0, (APTR)PREFS_DONE },
	{ NM_ITEM	, NM_BARLABEL                    , NULL, 0, 0, NULL },
	{ NM_ITEM	, (STRPTR)MSG_MENU_BASILISK_QUIT , NULL, 0, 0, (APTR)MUIV_Application_ReturnID_Quit },
	{ NM_END		, NULL                           , NULL, 0, 0, NULL }
};

STATIC CONST ULONG ramsizes[7] = { 16, 32, 64, 128, 256, 512, 1024 };

static void localize_array(CONST_STRPTR *p)
{
	do
	{
		*p = _L((LONG)*p);
		p++;
	}
	while (*p);
}

static void localize(void)
{
	struct NewMenu *menu;

	localize_array(PrefPages);
	localize_array(VolumeTypes);

	menu = menustrip;

	while (menu->nm_Type != NM_END)
	{
		if (menu->nm_Type != NM_ITEM || menu->nm_UserData)
			menu->nm_Label = (STRPTR)_L((LONG)menu->nm_Label);

		menu++;
	}
}

static void read_volumes_settings(Object *str_cdromdev, Object *str_cdromunit, Object *ch_bootfromcd, Object *ch_nocdrom, Object *str_extfs)
{
	CONST_STRPTR str;

	str = (CONST_STRPTR)getv(str_cdromdev, MUIA_String_Contents);

	if (*str)
	{
		char buf[MAX_STRING_LENGTH + 128];
		sprintf(buf, "/dev/%s/%ld/%d/%d/%d/%d", str, getv(str_cdromunit, MUIA_String_Integer), 0, 0, 0, 2048);
		PrefsReplaceString("cdrom", buf);
	}
	else
	{
		PrefsRemoveItem("cdrom");
	}

	PrefsReplaceInt32("bootdriver", getv(ch_bootfromcd, MUIA_Selected) ? CDROMRefNum : 0);
	PrefsReplaceBool("nocdrom", getv(ch_nocdrom, MUIA_Selected));

	str = (CONST_STRPTR)getv(str_extfs, MUIA_String_Contents);

	if (*str)
	{
		PrefsReplaceString("extfs", str);
	}
}

static void read_scsi_settings(Object **str_scsidev, Object **str_scsiunit)
{
	for (int i=0; i<7; i++)
	{
		CONST_STRPTR scsi_dev;
		char prefs_name[16];

		sprintf(prefs_name, "scsi%d", i);
		scsi_dev = (CONST_STRPTR)getv(str_scsidev[i], MUIA_String_Contents);

		if (*scsi_dev)
		{
			char str[MAX_STRING_LENGTH + 32];
			sprintf(str, "%s/%ld", scsi_dev, getv(str_scsiunit[i], MUIA_String_Integer));
			PrefsReplaceString(prefs_name, str);
		}
		else
		{
			PrefsRemoveItem(prefs_name);
		}
	}
}

static void make_serial_prefs(const char *prefs, Object *str_name, Object *str_unit, Object *ch_ispar)
{
	CONST_STRPTR dev;

	dev = (CONST_STRPTR)getv(str_name, MUIA_String_Contents);

	if (*dev)
	{
		char str[MAX_STRING_LENGTH + 32];
		sprintf(str, "%s%s/%ld", getv(ch_ispar, MUIA_Selected) ? "*" : "", dev, getv(str_unit, MUIA_String_Integer));
		PrefsReplaceString(prefs, str);
	}
	else
	{
		PrefsRemoveItem(prefs);
	}
}

static void read_serial_settings(Object *str_serdev, Object *str_serunit, Object *ch_isserpar, Object *str_pardev, Object *str_parunit, Object *ch_isparpar, Object *str_ethername, Object *str_etherunit)
{
	CONST_STRPTR ether_dev;

	make_serial_prefs("seriala", str_serdev, str_serunit, ch_isserpar);
	make_serial_prefs("serialb", str_pardev, str_parunit, ch_isparpar);

	ether_dev = (CONST_STRPTR)getv(str_ethername, MUIA_String_Contents);

	if (*ether_dev)
	{
		char str[MAX_STRING_LENGTH + 32];

		sprintf(str, "%s/%ld", ether_dev, getv(str_etherunit, MUIA_String_Integer));
		PrefsReplaceString("ether", str);
	}
	else
	{
		PrefsRemoveItem("ether");
	}
}

static void read_emulation_settings(Object *str_width, Object *str_height, Object *ch_fullscreen, Object *ch_8bitgfx, Object *sound, Object *slider, Object *model, Object *romfile, Object *sl_frameskip)
{
	CONST_STRPTR str;
	char buf[128];

	sprintf(buf, "win/%ld/%ld", getv(str_width, MUIA_String_Integer), getv(str_height, MUIA_String_Integer));
	PrefsReplaceString("screen", buf);
	PrefsReplaceBool("fullscreen", getv(ch_fullscreen, MUIA_Selected));
	PrefsReplaceBool("8bitgfx", getv(ch_8bitgfx, MUIA_Selected));
	PrefsReplaceBool("nosound", getv(sound, MUIA_Selected));
	PrefsReplaceInt32("ramsize", ramsizes[getv(slider, MUIA_Slider_Level)] << 20);
	PrefsReplaceInt32("modelid", getv(model, MUIA_Cycle_Active) == 0 ? 5 : 14);
	PrefsReplaceInt32("frameskip", getv(sl_frameskip, MUIA_Slider_Level));

	str = (CONST_STRPTR)getv(romfile, MUIA_String_Contents);

	if (*str)
	{
		PrefsReplaceString("rom", str);
	}
	else
	{
		PrefsRemoveItem("rom");
	}
}

static void set_volumes_settings(Object *lv_volumes, Object *str_cdromdev, Object *str_cdromunit, Object *ch_bootfromcd, Object *ch_nocdrom, Object *str_extfs)
{
	CONST_STRPTR str;

	for (int i=0; (str = PrefsFindString("disk", i)) != NULL; i++)
	{
		DoMethod(lv_volumes, MUIM_List_InsertSingle, str, MUIV_List_Insert_Bottom);
	}

	str = PrefsFindString("cdrom");

	if (str)
	{
		ULONG cdrom_unit, cdrom_dummy;
		UBYTE	cdrom_name[MAX_STRING_LENGTH];

		cdrom_unit		= 0;
		cdrom_name[0]	= 0;

		sscanf(str, "/dev/%[^/]/%ld/%ld/%ld/%ld/%ld", cdrom_name, &cdrom_unit, &cdrom_dummy, &cdrom_dummy, &cdrom_dummy, &cdrom_dummy);

		SetAttrs(str_cdromdev, MUIA_String_Contents, &cdrom_name, TAG_DONE);
		SetAttrs(str_cdromunit, MUIA_String_Integer, cdrom_unit, TAG_DONE);
	}

	SetAttrs(ch_bootfromcd, MUIA_Selected, PrefsFindInt32("bootdriver") == CDROMRefNum ? TRUE : FALSE, TAG_DONE);
	SetAttrs(ch_nocdrom, MUIA_Selected, PrefsFindBool("nocdrom"), TAG_DONE);

	str = PrefsFindString("extfs");

	if (str)
	{
		SetAttrs(str_extfs, MUIA_String_Contents, str, TAG_DONE);
	}
}

static void set_scsi_settings(Object **str_scsidev, Object **str_scsiunit)
{
	for (int i=0; i<7; i++)
	{
		char prefs_name[16];
		sprintf(prefs_name, "scsi%d", i);
		const char *str = PrefsFindString(prefs_name);

		if (str)
		{
			UBYTE scsi_dev[MAX_STRING_LENGTH];
			ULONG scsi_unit;

			scsi_dev[0] = 0;
			scsi_unit = 0;

			sscanf(str, "%[^/]/%ld", scsi_dev, &scsi_unit);

			SetAttrs(str_scsidev[i], MUIA_String_Contents, scsi_dev, TAG_DONE);
			SetAttrs(str_scsiunit[i], MUIA_String_Integer, scsi_unit, TAG_DONE);
		}
	}
}

static void parse_ser_prefs(const char *prefs, Object *str_devname, Object *str_unit, Object *ch_ispar)
{
	LONG	unit, ispar;
	UBYTE	dev[MAX_STRING_LENGTH];

	dev[0] = 0;
	unit = 0;
	ispar = false;

	const char *str = PrefsFindString(prefs);
	if (str)
	{
		if (str[0] == '*')
		{
			ispar = true;
			str++;
		}
		sscanf(str, "%[^/]/%ld", dev, &unit);

		SetAttrs(str_devname, MUIA_String_Contents, &dev, TAG_DONE);
		SetAttrs(str_unit, MUIA_String_Integer, unit, TAG_DONE);
		SetAttrs(ch_ispar, MUIA_Selected, ispar, TAG_DONE);
	}
}

static void set_serial_settings(Object *str_serdev, Object *str_serunit, Object *ch_isserpar, Object *str_pardev, Object *str_parunit, Object *ch_isparpar, Object *str_ethername, Object *str_etherunit)
{
	CONST_STRPTR str;

	parse_ser_prefs("seriala", str_serdev, str_serunit, ch_isserpar);
	parse_ser_prefs("serialb", str_pardev, str_parunit, ch_isparpar);

	str = PrefsFindString("ether");

	if (str)
	{
		UBYTE	ether_dev[MAX_STRING_LENGTH];
		ULONG	ether_unit;

		const char *FirstSlash = strchr(str, '/');
		const char *LastSlash = strrchr(str, '/');

		if (FirstSlash && FirstSlash && FirstSlash != LastSlash)
		{
			// Device name contains path, i.e. "Networks/xyzzy.device"
			const char *lp = str;
			UBYTE *dp = ether_dev;

			while (lp != LastSlash)
				*dp++ = *lp++;
			*dp = '\0';

			sscanf(LastSlash, "/%ld", &ether_unit);
		}
		else
		{
			sscanf(str, "%[^/]/%ld", ether_dev, &ether_unit);
		}

		SetAttrs(str_ethername, MUIA_String_Contents, &ether_dev, TAG_DONE);
		SetAttrs(str_etherunit, MUIA_String_Integer, ether_unit, TAG_DONE);
	}
}

static void set_emulation_settings(Object *str_width, Object *str_height, Object *ch_fullscreen, Object *ch_8bitgfx, Object *sound, Object *slider, Object *model, Object *romfile, Object *sl_frameskip)
{
	CONST_STRPTR str;
	ULONG ramsize_mb, value, i, width, height;
	LONG	id;

	// Window width and height

	str		= PrefsFindString("screen");
	width		= 512;
	height	= 384;

	if (str)
	{
		sscanf(str, "win/%ld/%ld", &width, &height);
	}

	SetAttrs(str_width, MUIA_String_Integer, width, TAG_DONE);
	SetAttrs(str_height, MUIA_String_Integer, height, TAG_DONE);
	SetAttrs(ch_fullscreen, MUIA_Selected, PrefsFindBool("fullscreen"), TAG_DONE);
	SetAttrs(ch_8bitgfx, MUIA_Selected, PrefsFindBool("8bitgfx"), TAG_DONE);
	SetAttrs(sl_frameskip, MUIA_Slider_Level, PrefsFindInt32("frameskip"), TAG_DONE);

	// Sound

	SetAttrs(sound, MUIA_Selected, PrefsFindBool("nosound"), TAG_DONE);

	// RAM

	ramsize_mb	= PrefsFindInt32("ramsize") >> 20;
	value			= 0;

	for (i = 0; i < 6; i++)
	{
		if (ramsize_mb > ramsizes[i])
			value++;

	}

	SetAttrs(slider, MUIA_Slider_Level, value, TAG_DONE);

	// Model

	id = PrefsFindInt32("modelid");
	SetAttrs(model, MUIA_Cycle_Active, id == 5 ? 0 : 1, TAG_DONE);	// id is 5 or 14

	// ROM

	str = PrefsFindString("rom");
	SetAttrs(romfile, MUIA_String_Contents, str, TAG_DONE);
}

/*
 *  RAM Size slider class
 */

static ULONG SliderDispatcher(void)
{
	struct IClass	*cl;
	Object	*obj;
	Msg	msg;

	cl		= (struct IClass *)REG_A0;
	msg	= (Msg)REG_A1;
	obj	= (Object *)REG_A2;

	switch (msg->MethodID)
	{
		case MUIM_Numeric_Stringify:
		{
			struct MUIP_Numeric_Stringify *m = (struct MUIP_Numeric_Stringify *)msg;
			static TEXT str[32];

			snprintf((char *)&str, sizeof(str), _L(MSG_PREFS_RAMSIZE_GAD), ramsizes[m->value]);

			return (ULONG)str;
		}
	}

	return DoSuperMethodA(cl, obj, msg);
}

static struct EmulLibEntry SliderTrap = {TRAP_LIB, 0, (void (*)())&SliderDispatcher };

static struct MUI_CustomClass *SliderClass;

/*
 *  Init classes
 */

static int init_classes(void)
{
	if ((SliderClass = MUI_CreateCustomClass(NULL, MUIC_Slider, NULL, 0, (APTR)&SliderTrap)))
	{
		return 1;
	}

	return 0;
}

static void delete_prefs(Object *win)
{
	if (win)
	{
		DoMethod(app, OM_REMMEMBER, win);
		MUI_DisposeObject(win);
	}

	if (SliderClass)
	{
		MUI_DeleteCustomClass(SliderClass);
	}
}

static void closesubwin(Object *mainwin, Object *subwin)
{
	SetAttrs(mainwin, MUIA_Window_Sleep, FALSE, TAG_DONE);
	DoMethod(app, OM_REMMEMBER, subwin);
	MUI_DisposeObject(subwin);
}

/**********************************************************************
	Volume Window

	We could handle this in Window subclass.. blah
**********************************************************************/

static Object *str_vol_hardfile, *str_vol_unit, *str_vol_flags, *str_vol_start, *str_vol_size, *str_vol_bsize;
static Object *ch_vol_readonly, *vol_pagegrp, *tx_vol_device;
static Object *grp_show_hf_size, *tx_hf_size, *str_hf_size, *bt_create;

static void analyze_partition(void)
{
	struct FileRequester *req = (struct FileRequester *)REG_A1;
	LONG	unit, flags, start, size, bsize;
	char	devname[MAX_STRING_LENGTH];
	BPTR lock;

	lock			= Lock(strlen(req->fr_Drawer) ? req->fr_Drawer : req->fr_File, ACCESS_READ);
	unit			= flags	= start	= size	= bsize	= -1;
	devname[0]	= '\0';

	if (lock)
	{
		struct MsgPort *task;
		struct DosList	*dl;
		char	*colon;

		// Look for partition

		NameFromLock(lock, (STRPTR)&devname, sizeof(devname));
		UnLock(lock);

		colon	= strchr(devname, ':');

		if (colon)
		{
			*colon	= 0;
		}

		dl = LockDosList(LDF_VOLUMES | LDF_READ);
		dl	= FindDosEntry(dl, devname, LDF_VOLUMES);
		task	= dl ? dl->dol_Task : NULL;
		UnLockDosList(LDF_VOLUMES | LDF_READ);

		if (task)
		{
			dl = LockDosList(LDF_DEVICES | LDF_READ);

			while ((dl = NextDosEntry(dl, LDF_DEVICES | LDF_READ)))
			{
				if (dl->dol_Task == task)
				{
					// Get File System Startup Message
					struct FileSysStartupMsg *fssm = (struct FileSysStartupMsg *)(dl->dol_misc.dol_handler.dol_Startup << 2);
					UBYTE	*dev;

					dev	= (UBYTE *)BADDR(dl->dol_Name);
					memcpy(&devname, dev+1, *dev);
					devname[*dev] = 0;

					if (fssm)
					{
						// Get DOS environment vector
						struct DosEnvec *de = (struct DosEnvec *)(fssm->fssm_Environ << 2);

						if (de && de->de_TableSize >= DE_UPPERCYL)
						{
							unit	= fssm->fssm_Unit;
							flags	= fssm->fssm_Flags;
							start	= de->de_BlocksPerTrack * de->de_Surfaces * de->de_LowCyl;
							size	= de->de_BlocksPerTrack * de->de_Surfaces * (de->de_HighCyl - de->de_LowCyl + 1);
							bsize	= de->de_SizeBlock << 2;
						}
					}

					break;
				}
			}

			UnLockDosList(LDF_DEVICES | LDF_READ);
		}
	}

	SetAttrs(tx_vol_device, MUIA_Text_Contents, &devname, TAG_DONE);
	SetAttrs(str_vol_unit, MUIA_String_Integer, unit, TAG_DONE);
	SetAttrs(str_vol_flags, MUIA_String_Integer, flags, TAG_DONE);
	SetAttrs(str_vol_start, MUIA_String_Integer, start, TAG_DONE);
	SetAttrs(str_vol_size, MUIA_String_Integer, size, TAG_DONE);
	SetAttrs(str_vol_bsize, MUIA_String_Integer, bsize, TAG_DONE);
}

static struct EmulLibEntry	StopGate	= { TRAP_LIBNR, 0, (void (*)())&analyze_partition };
static struct Hook StopHook 			= { {NULL, NULL }, (HOOKFUNC)&StopGate, NULL, NULL };

static void check_hardfile(void)
{
	STRPTR filename;

	filename = (STRPTR)getv(str_vol_hardfile, MUIA_String_Contents);

	if (filename)
	{
		BPTR lock;

		lock	= Lock(filename, ACCESS_READ);

		SetAttrs(grp_show_hf_size, MUIA_Group_ActivePage, lock ? 0 : 1, TAG_DONE);
		SetAttrs(bt_create, MUIA_Disabled, lock ? TRUE : FALSE, TAG_DONE);
		SetAttrs(str_hf_size, MUIA_String_Integer, 1024, TAG_DONE);

		if (lock)
		{
			struct FileInfoBlock fib;

			Examine(lock, &fib);
			UnLock(lock);
			DoMethod(tx_hf_size, MUIM_SetAsString, MUIA_Text_Contents, "%ld", fib.fib_Size / 1024 / 1024);
		}
	}
}

static void set_hardfile(void)
{
	struct FileRequester *req = (struct FileRequester *)REG_A1;
	STRPTR dir, file, buf;
	ULONG	size;

	dir	= req->fr_Drawer;
	file	= req->fr_File;
	size	= strlen(dir) + strlen(file) + 10;
	buf	= (STRPTR)AllocTaskPooled(size);

	if (buf)
	{
		strcpy(buf, dir);
		AddPart(buf, file, size);
		SetAttrs(str_vol_hardfile, MUIA_String_Contents, buf, TAG_DONE);
		FreeTaskPooled(buf, size);
		check_hardfile();
	}
}

static void create_hardfile(void)
{
	STRPTR filename;

	filename = (STRPTR)getv(str_vol_hardfile, MUIA_String_Contents);

	if (filename)
	{
		BPTR fh;

		fh	= Open(filename, MODE_OLDFILE);

		if (!fh)
		{
			ULONG size;

			fh = Open(filename, MODE_NEWFILE);

			if (!fh)
			{
				return;
			}

			size = getv(str_hf_size, MUIA_String_Integer);

			if (size == 0)
			{
				size	= 128;
			}
			else if (size > 2047)
			{
				size	= 2047;
			}

			SetFileSize(fh, size * 1024 * 1024, OFFSET_BEGINNING);
			DoMethod(app, MUIM_Application_ReturnID, PREFS_VOLUMEWIN_DONE);
		}

		Close(fh);
	}
}

#if 0
static VOID drive_display(void)
{
	CONST_STRPTR *array = (CONST_STRPTR *)REG_A2;

	array[0] = (STRPTR)REG_A1;

	if ((IPTR)array[-1] % 2)
		array[ -9 ] = (STRPTR)10;
}
#endif

static struct EmulLibEntry	CheckFileGate			= { TRAP_LIBNR, 0, (void (*)())&check_hardfile };
static struct Hook CheckFileHook 					= { {NULL, NULL }, (HOOKFUNC)&CheckFileGate, NULL, NULL };
static struct EmulLibEntry	SetHardfileGate		= { TRAP_LIBNR, 0, (void (*)())&set_hardfile };
static struct Hook SetHardfileHook 					= { {NULL, NULL }, (HOOKFUNC)&SetHardfileGate, NULL, NULL };
static struct EmulLibEntry	CreateHardfileGate	= { TRAP_LIBNR, 0, (void (*)())&create_hardfile };
static struct Hook CreateHardfileHook 				= { {NULL, NULL }, (HOOKFUNC)&CreateHardfileGate, NULL, NULL };

#if 0
static struct EmulLibEntry	DispHookGate			= { TRAP_LIBNR, 0, (void (*)())&drive_display };
static struct Hook DispHook 							= { {NULL, NULL }, (HOOKFUNC)&DispHookGate, NULL, NULL };
#endif

static void update_volume(Object *prefswin, Object *subwin, Object *lv_volumes, ULONG add_volume)
{
	ULONG	is_device, read_only;
	char str[MAX_STRING_LENGTH + 128];

	is_device	= getv(vol_pagegrp, MUIA_Group_ActivePage);
	read_only	= getv(ch_vol_readonly, MUIA_Selected);

	if (is_device)
	{
		sprintf(str, "%s/dev/%s/%ld/%ld/%ld/%ld/%ld", read_only ? "*" : "", (STRPTR)getv(tx_vol_device, MUIA_Text_Contents), getv(str_vol_unit, MUIA_String_Integer), getv(str_vol_flags, MUIA_String_Integer), getv(str_vol_start, MUIA_String_Integer), getv(str_vol_size, MUIA_String_Integer), getv(str_vol_bsize, MUIA_String_Integer));
	}
	else
	{
		sprintf(str, "%s%s", read_only ? "*" : "", (STRPTR)getv(str_vol_hardfile, MUIA_String_Contents));
	}

	if (add_volume)
	{
		// Add new item
		int i;
		PrefsAddString("disk", str);
		for (i=0; PrefsFindString("disk", i); i++) ;
		DoMethod(lv_volumes, MUIM_List_InsertSingle, PrefsFindString("disk", i - 1), MUIV_List_Insert_Bottom);
	}
	else
	{
		// Replace existing item
		ULONG entry, pos = getv(lv_volumes, MUIA_List_Active);

		PrefsReplaceString("disk", str, pos);
		DoMethod(lv_volumes, MUIM_List_GetEntry, pos, &entry);
		DoMethod(lv_volumes, MUIM_List_Remove, pos);
		DoMethod(lv_volumes, MUIM_List_InsertSingle, str, pos);
		SetAttrs(lv_volumes, MUIA_List_Active, pos, TAG_DONE);
	}

	closesubwin(prefswin, subwin);
}

static Object *add_edit_volume(Object *prefswin, Object *lv_volumes, ULONG adding)
{
	UBYTE	dev_name[MAX_STRING_LENGTH], file_name[MAX_STRING_LENGTH];
	LONG	read_only, is_device, dev_unit, dev_flags, dev_start, dev_size, dev_bsize;

	Object *win, *pop;
	Object *bt_ok, *bt_cancel;
	Object *cy_page;

	dev_name[0]		= 0;
	file_name[0]	= 0;
	read_only		= FALSE;
	is_device		= FALSE;
	dev_unit			= -1;
	dev_flags		= -1;
	dev_start		= -1;
	dev_size			= -1;
	dev_bsize		= -1;
	win				= NULL;

	if (!adding)
	{
		CONST_STRPTR str = PrefsFindString("disk", getv(lv_volumes, MUIA_List_Active));

		if (str == NULL)
			return win;

		if (str[0] == '*')
		{
			read_only = TRUE;
			str++;
		}

		if (strstr(str, "/dev/") == str)
		{
			is_device = TRUE;
			sscanf(str, "/dev/%[^/]/%ld/%ld/%ld/%ld/%ld", dev_name, &dev_unit, &dev_flags, &dev_start, &dev_size, &dev_bsize);
		}
		else
		{
			stccpy((char *)file_name, (char *)str, sizeof(file_name));
		}
	}

	win = WindowObject,
			MUIA_Window_Title, adding ? _L(MSG_TITLE_ADD_VOLUME) : _L(MSG_TITLE_EDIT_VOLUME),
			MUIA_Window_ID, MAKE_ID('V','O','L','W'),
			WindowContents, VGroup,
				Child, HGroup,
					Child, MakeLabel(MSG_PREFS_TYPE_GAD),
					Child, VGroup,
						Child, cy_page = MakeCycle(MSG_PREFS_TYPE_GAD, VolumeTypes),
						Child, MakeCheck(MSG_PREFS_READ_ONLY_GAD, &ch_vol_readonly),
					End,
				End,

				Child, vol_pagegrp = PageGroup,
					GroupFrame,
					MUIA_Background, MUII_GroupBack,

					Child, VGroup,
						Child, HGroup,
							Child, MakeLabel(MSG_PREFS_FILE_GAD),
							Child, PopaslObject,
								MUIA_Popasl_Type, ASL_FileRequest,
								MUIA_Popasl_StopHook, &SetHardfileHook,
								MUIA_Popstring_Button, pop = PopButton(MUII_PopDrawer),
								MUIA_Popstring_String, str_vol_hardfile = MakeString(MSG_PREFS_FILE_GAD, 1024),
							End,
							/* Child, MakePopFile("_File", 1024, &str_vol_hardfile), */
						End,
						Child, MakeRect(100),
						Child, HGroup,
							Child, MakeLabel(MSG_SIZE),
							Child, grp_show_hf_size = PageGroup,
								Child, tx_hf_size = TextObject, TextFrame, MUIA_Background, MUII_TextBack, End,
								Child, str_hf_size = MakeInteger(NULL, 10),
							End,
							Child, TextObject, MUIA_Text_Contents, _L(MSG_MB), End,
							Child, bt_create = MakeButton(MSG_PREFS_CREATE_GAD),
						End,
					End,

					Child, ColGroup(2),
						Child, MakeLabel(MSG_PREFS_DEVICE_GAD),
						Child, PopaslObject,
							MUIA_Popasl_Type, ASL_FileRequest,
							MUIA_Popasl_StopHook, &StopHook,
							MUIA_Popstring_Button, pop = PopButton(MUII_PopDrawer),
							MUIA_Popstring_String, tx_vol_device = TextObject, TextFrame, MUIA_Background, MUII_TextBack, End,
							End,
						Child, MakeLabel(MSG_PREFS_UNIT_GAD),
						Child, str_vol_unit = MakeInteger(MSG_PREFS_UNIT_GAD, 5),
						Child, MakeLabel(MSG_PREFS_FLAGS_GAD),
						Child, str_vol_flags = MakeInteger(MSG_PREFS_FLAGS_GAD, 16),
						Child, MakeLabel(MSG_PREFS_START_BLOCK_GAD),
						Child, str_vol_start = MakeInteger(MSG_PREFS_START_BLOCK_GAD, 16),
						Child, MakeLabel(MSG_PREFS_BLOCKS_GAD),
						Child, str_vol_size = MakeInteger(MSG_PREFS_BLOCKS_GAD, 16),
						Child, MakeLabel(MSG_PREFS_BLOCK_SIZE_GAD),
						Child, str_vol_bsize = MakeInteger(MSG_PREFS_BLOCK_SIZE_GAD, 16),
					End,
				End,

				Child, RectangleObject, MUIA_Rectangle_HBar, TRUE, MUIA_Weight, 0, End,
				Child, HGroup,
					Child, bt_ok = MakeButton(MSG_OK_GAD),
					Child, bt_cancel = MakeButton(MSG_CANCEL_GAD),
				End,

			End,
		End;

	if (win)
	{
		DoMethod(_app(lv_volumes), OM_ADDMEMBER, win);

		SetAttrs(pop, MUIA_CycleChain, 1, TAG_DONE);
		SetAttrs(ch_vol_readonly, MUIA_Selected, read_only, TAG_DONE);
		SetAttrs(str_vol_hardfile, MUIA_String_Contents, &file_name, TAG_DONE);
		SetAttrs(tx_vol_device, MUIA_Text_Contents, &dev_name, TAG_DONE);
		SetAttrs(str_vol_unit, MUIA_String_Integer, dev_unit, TAG_DONE);
		SetAttrs(str_vol_flags, MUIA_String_Integer, dev_flags, TAG_DONE);
		SetAttrs(str_vol_start, MUIA_String_Integer, dev_start, TAG_DONE);
		SetAttrs(str_vol_size, MUIA_String_Integer, dev_size, TAG_DONE);
		SetAttrs(str_vol_bsize, MUIA_String_Integer, dev_bsize, TAG_DONE);
		SetAttrs(bt_create, MUIA_Disabled, TRUE, TAG_DONE);

		DoMethod(win, MUIM_Notify, MUIA_Window_CloseRequest, TRUE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_VOLUMEWIN_CANCELLED);
		DoMethod(bt_ok, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_VOLUMEWIN_DONE);
		DoMethod(bt_cancel, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_VOLUMEWIN_CANCELLED);
		DoMethod(cy_page, MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime, vol_pagegrp, 3, MUIM_Set, MUIA_Group_ActivePage, MUIV_TriggerValue);
		DoMethod(str_vol_hardfile, MUIM_Notify, MUIA_String_Acknowledge, MUIV_EveryTime, MUIV_Notify_Self, 2, MUIM_CallHook, &CheckFileHook);
		DoMethod(bt_create, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Self, 2, MUIM_CallHook, &CreateHardfileHook);

		if (!adding)
		{
			SetAttrs(cy_page, MUIA_Cycle_Active, is_device ? 1 : 0, MUIA_Disabled, TRUE, TAG_DONE);

			if (!is_device)
			{
				check_hardfile();
			}
		}
		else
		{
			SetAttrs(str_hf_size, MUIA_String_Integer, 1024, TAG_DONE);
		}

		SetAttrs(prefswin, MUIA_Window_Sleep, TRUE, TAG_DONE);
		SetAttrs(win, MUIA_Window_Open, TRUE, TAG_DONE);
	}

	return win;
}

static void remove_volume(Object *lv_volumes, Object *bt_editdisk, Object *bt_removedisk)
{
	CONST_STRPTR entry;

	DoMethod(lv_volumes, MUIM_List_GetEntry, MUIV_List_GetEntry_Active, &entry);

	if (entry)
	{
		PrefsRemoveItem("disk", getv(lv_volumes, MUIA_List_Active));
		DoMethod(lv_volumes, MUIM_List_Remove, MUIV_List_Remove_Active);

		if (getv(lv_volumes, MUIA_List_Active) == (ULONG)MUIV_List_Active_Off)
		{
			SetAttrs(bt_editdisk, MUIA_Disabled, TRUE, TAG_DONE);
			SetAttrs(bt_removedisk, MUIA_Disabled, TRUE, TAG_DONE);
		}
	}
}

/*
 *  Show preferences editor
 *  Returns true when user clicked on "Start", false otherwise
 */

bool PrefsEditor(void)
{
	return SendGUICmd(GUICMD_Prefs);
}

bool RunPrefs(void)
{
	static int localized = 0;
	Object *str_scsidev[7], *str_scsiunit[7];
	Object *win, *bt_start, *bt_quit, *bt_adddisk, *bt_editdisk, *bt_removedisk;
	Object *str_width, *str_height, *str_serdev, *str_serunit, *str_pardev, *str_parunit, *str_ethername, *str_etherunit;
	Object *str_cdromdev, *str_cdromunit;
	Object *ch_sound, *ch_8bitgfx, *ch_fullscreen, *ch_isserpar, *ch_isparpar, *ch_bootfromcd, *ch_nocdrom;
	Object *sl_ramsize, *cy_model, *str_romfile, *str_extfs, *sl_frameskip;
	Object *lv_volumes;
	bool retval;

	#if 0
	LONG is_mui4 = (MUIMasterBase->lib_Version > 20 || (MUIMasterBase->lib_Version == 20 && MUIMasterBase->lib_Revision >= 5341) ? TRUE : FALSE);
	#endif

	retval	= false;
	win		= NULL;

	if (!localized)
	{
		localized = 1;
		localize();
	}

	if (init_classes() == 0)
		goto quit;

	win = WindowObject,
			MUIA_Window_Menustrip, MUI_MakeObject(MUIO_MenustripNM, &menustrip, MUIO_MenustripNM_CommandKeyCheck),
			MUIA_Window_Title, _L(MSG_TITLE_BASILISK_SETTINGS),
			MUIA_Window_ID, MAKE_ID('P','R','F','S'),
			WindowContents, VGroup,

				Child, RegisterGroup(PrefPages),

					Child, VGroup,
						Child, VGroup,
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_MAC_VOLUMES),
							Child, lv_volumes = ListviewObject, MUIA_CycleChain, 1, MUIA_Listview_List, ListObject, InputListFrame, MUIA_List_ConstructHook, MUIV_List_ConstructHook_String, MUIA_List_DestructHook, MUIV_List_DestructHook_String, /* is_mui4 ? MUIA_List_DisplayHook : TAG_IGNORE, &DispHook,*/ End, End,
							Child, HGroup,
								Child, bt_adddisk = MakeButton(MSG_PREFS_ADD_GAD),
								Child, bt_editdisk = MakeButton(MSG_PREFS_EDIT_GAD),
								Child, bt_removedisk = MakeButton(MSG_PREFS_REMOVE_GAD),
							End,
						End,
						Child, ColGroup(2),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_CDROM),

							Child, MakeLabel(MSG_PREFS_CD_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_CD_DEVICE_GAD, MAX_STRING_LENGTH, &str_cdromdev),
							Child, MakeLabel(MSG_PREFS_CD_UNIT_GAD),
							Child, str_cdromunit = MakeInteger(MSG_PREFS_CD_UNIT_GAD, 5),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_CD_BOOT_GAD, &ch_bootfromcd),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_CD_DISABLE_DRIVER_GAD, &ch_nocdrom),
						End,
						Child, HGroup,
							Child, MakeLabel(MSG_PREFS_MORPHOS_ROOT_GAD),
							Child, MakePopFile(MSG_PREFS_MORPHOS_ROOT_GAD, 1024, &str_extfs),
						End,
					End,

					Child, VGroup,
						Child, ColGroup(4),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_VIRTUAL_SCSI_DEVICES),
							Child, MakeLabel(MSG_PREFS_ID_0_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_0_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[0]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[0] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_1_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_1_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[1]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[1] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_2_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_2_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[2]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[2] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_3_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_3_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[3]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[3] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_4_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_4_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[4]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[4] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_5_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_5_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[5]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[5] = MakeInteger(NULL, 5),
							Child, MakeLabel(MSG_PREFS_ID_6_DEVICE_GAD),
							Child, MakePopFile(MSG_PREFS_ID_6_DEVICE_GAD, MAX_STRING_LENGTH, &str_scsidev[6]),
							Child, MakeLabel(MSG_PREFS_SCSI_UNIT_GAD),
							Child, str_scsiunit[6] = MakeInteger(NULL, 5),
						End,
					End,

					Child, VGroup,
						Child, ColGroup(2),
						Child, ColGroup(2),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_MODEM),
							Child, MakeLabel(MSG_PREFS_MODEM_DEVICE_GAD),
							Child, MakePopFile(NULL, MAX_STRING_LENGTH, &str_serdev),
							Child, MakeLabel(MSG_PREFS_MODEM_UNIT_GAD),
							Child, str_serunit = MakeInteger(NULL, 5),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_MODEM_PARALLEL_GAD, &ch_isserpar),
						End,
						Child, VGroup,
							Child, ColGroup(2),
								GroupFrame,
								MUIA_Background, MUII_GroupBack,
								MUIA_FrameTitle, _L(MSG_ETHERNET),
								Child, MakeLabel(MSG_PREFS_ETHERNET_DEVICE_GAD),
								Child, MakePopFile(NULL, MAX_STRING_LENGTH, &str_ethername),
								Child, MakeLabel(MSG_PREFS_ETHERNET_UNIT_GAD),
								Child, str_etherunit = MakeInteger(NULL, 5),
							End,
							Child, MakeRect(100),
						End,
						Child, ColGroup(2),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_PRINTER),
							Child, MakeLabel(MSG_PREFS_PRINTER_DEVICE_GAD),
							Child, MakePopFile(NULL, MAX_STRING_LENGTH, &str_pardev),
							Child, MakeLabel(MSG_PREFS_PRINTER_UNIT_GAD),
							Child, str_parunit = MakeInteger(NULL, 5),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_PRINTER_PARALLEL_GAD, &ch_isparpar),
						End,
						End,
					End,

					Child, VGroup,
						Child, ColGroup(2),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_GRAPHICS),
							Child, MakeLabel(MSG_PREFS_GFX_WIDTH_GAD),
							Child, str_width = MakeInteger(MSG_PREFS_GFX_WIDTH_GAD, 8),
							Child, MakeLabel(MSG_PREFS_GFX_HEIGHT_GAD),
							Child, str_height = MakeInteger(MSG_PREFS_GFX_HEIGHT_GAD, 8),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_GFX_FULLSCREEN_GAD, &ch_fullscreen),
							Child, MakeRect(0),
							Child, MakeCheck(MSG_PREFS_GFX_8BIT_GAD, &ch_8bitgfx),
							Child, MakeLabel(MSG_PREFS_GFX_FRAMESKIP_GAD),
							Child, sl_frameskip = MakeSlider(MSG_PREFS_GFX_FRAMESKIP_GAD, 0, 7),
						End,
						Child, VGroup,
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_SOUND),
							Child, MakeCheck(MSG_PREFS_DISABLE_SOUND, &ch_sound),
						End,

						Child, ColGroup(2),
							GroupFrame,
							MUIA_Background, MUII_GroupBack,
							MUIA_FrameTitle, _L(MSG_SYSTEM),
							Child, MakeLabel(MSG_PREFS_SYSTEM_RAM_GAD),
							Child, sl_ramsize		= (Object *)NewObject(SliderClass->mcc_Class, NULL, MUIA_Numeric_Max, 6, TAG_DONE),
							Child, MakeLabel(MSG_PREFS_SYSTEM_MODEL_GAD),
							Child, cy_model		= MakeCycle(MSG_PREFS_SYSTEM_MODEL_GAD, ModelNames),
							Child, MakeLabel(MSG_PREFS_SYSTEM_ROM_GAD),
							Child, MakePopFile(MSG_PREFS_SYSTEM_ROM_GAD, 1024, &str_romfile),
						End,
					End,

				End,

				Child, RectangleObject, MUIA_Rectangle_HBar, TRUE, MUIA_Weight, 0, End,
				Child, HGroup,
					Child, bt_start = MakeButton(MSG_PREFS_START_GAD),
					Child, bt_quit = MakeButton(MSG_PREFS_QUIT_GAD),
				End,

			End,
		End;

	if (win)
	{
		Object *win_volume = win_volume;
		ULONG add_volume = add_volume, signals = 0;

		DoMethod(app, OM_ADDMEMBER, win);

		DoMethod(win, MUIM_Notify, MUIA_Window_CloseRequest, TRUE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);
		DoMethod(bt_start, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_DONE);
		DoMethod(bt_quit, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit);
		DoMethod(bt_adddisk, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_ADD_DISK);
		DoMethod(bt_editdisk, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_EDIT_DISK);
		DoMethod(bt_removedisk, MUIM_Notify, MUIA_Pressed, FALSE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_REMOVE_DISK);

		DoMethod(lv_volumes, MUIM_Notify, MUIA_List_Active, MUIV_EveryTime, bt_removedisk, 3, MUIM_Set, MUIA_Disabled, FALSE);
		DoMethod(lv_volumes, MUIM_Notify, MUIA_List_Active, MUIV_EveryTime, bt_editdisk, 3, MUIM_Set, MUIA_Disabled, FALSE);
		DoMethod(lv_volumes, MUIM_Notify, MUIA_Listview_DoubleClick, TRUE, MUIV_Notify_Application, 2, MUIM_Application_ReturnID, PREFS_EDIT_DISK);

		SetAttrs(win, MUIA_Window_ActiveObject, bt_start, TAG_DONE);
		SetAttrs(bt_editdisk, MUIA_Disabled, TRUE, TAG_DONE);
		SetAttrs(bt_removedisk, MUIA_Disabled, TRUE, TAG_DONE);

		set_volumes_settings(lv_volumes, str_cdromdev, str_cdromunit, ch_bootfromcd, ch_nocdrom, str_extfs);
		set_scsi_settings(&str_scsidev[0], &str_scsiunit[0]);
		set_serial_settings(str_serdev, str_serunit, ch_isserpar, str_pardev, str_parunit, ch_isparpar, str_ethername, str_etherunit);
		set_emulation_settings(str_width, str_height, ch_fullscreen, ch_8bitgfx, ch_sound, sl_ramsize, cy_model, str_romfile, sl_frameskip);

		SetAttrs(win, MUIA_Window_Open, TRUE, TAG_DONE);

		for (;;)
		{
			LONG ret = DoMethod(app, MUIM_Application_NewInput, &signals);

			if (ret == MUIV_Application_ReturnID_Quit)
			{
				break;
			}

			switch (ret)
			{
				case PREFS_DONE:
					retval = true;
					goto done;

				case PREFS_ADD_DISK:
					add_volume	= 1;
					win_volume	= add_edit_volume(win, lv_volumes, TRUE);
					break;

				case PREFS_EDIT_DISK:
					add_volume	= 0;
					win_volume	= add_edit_volume(win, lv_volumes, FALSE);
					break;

				case PREFS_REMOVE_DISK:
					remove_volume(lv_volumes, bt_editdisk, bt_removedisk);
					break;

				case PREFS_VOLUMEWIN_DONE:
					update_volume(win, win_volume, lv_volumes, add_volume);
					break;

				case PREFS_VOLUMEWIN_CANCELLED:
					closesubwin(win, win_volume);
					break;

				case PREFS_ABOUT:
					DoMethod(_app(lv_volumes), MM_Application_About);
					break;
			}

			if (signals)
			{
				signals = Wait(signals | SIGBREAKF_CTRL_C);

				if (signals & SIGBREAKF_CTRL_C)
				{
					break;
				}
			}
		}

done:
		if (retval)
		{
			read_volumes_settings(str_cdromdev, str_cdromunit, ch_bootfromcd, ch_nocdrom, str_extfs);
			read_scsi_settings(&str_scsidev[0], &str_scsiunit[0]);
			read_serial_settings(str_serdev, str_serunit, ch_isserpar, str_pardev, str_parunit, ch_isparpar, str_ethername, str_etherunit);
			read_emulation_settings(str_width, str_height, ch_fullscreen, ch_8bitgfx, ch_sound, sl_ramsize, cy_model, str_romfile, sl_frameskip);
			SavePrefs();
		}
	}

quit:
	delete_prefs(win);

	return retval;
}
