/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
#ifndef ABPREFS_SYMS_H
#define ABPREFS_SYMS_H
/*	___________________

	ABackup Prefs
	syms.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 19-Aug-93
	Modified: 20-Jun-95
	___________________
*/

#define __USE_SYSBASE

#include <clib/macros.h>
#include <devices/scsidisk.h>
#include <exec/devices.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <graphics/rpattr.h>
#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>
#include <intuition/intuitionbase.h>
#include <libraries/reqtools.h>
#include <libraries/xpk.h>
#include <prefs/prefhdr.h>
#include <workbench/icon.h>

#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#include <proto/amigaguide.h>
#include <proto/asl.h>
#include <proto/commodities.h>
#include <proto/datatypes.h>
#include <proto/diskfont.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/gadtools.h>
#include <proto/graphics.h>
#include <proto/icon.h>
#include <proto/iffparse.h>
#include <proto/intuition.h>
#include <proto/reqtools.h>
#include <proto/utility.h>
#include <proto/wb.h>

// We are not including SAS/C <proto/locale.h> here, since it defines LocaleBase
// as a global pointer to a Library structure instead of a LocaleBase structure.
#include <clib/locale_protos.h>
#include <pragmas/locale_pragmas.h>

#endif	// ABPREFS_SYMS_H
