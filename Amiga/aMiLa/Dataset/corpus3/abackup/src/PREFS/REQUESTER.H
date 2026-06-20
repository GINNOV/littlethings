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
#ifndef ABPREFS_REQUESTER_H
#define ABPREFS_REQUESTER_H
/*	___________________

	ABackup Prefs
	requester.h

	© 1993-1995
	by Reza Elghazi & Denis Gounelle

	All Rights Reserved
	___________________

	Version : 38.0
	Created : 11-Sep-93
	Modified: 08-May-95
	___________________
*/

STATIC BOOL __saveds __asm
ScreenModeHook (register __a0 struct Hook *,
				register __a2 struct ScreenModeRequester *,
				register __a1 ULONG);
STATIC struct Hook smHook = {NULL,NULL,(HOOKFUNC)ScreenModeHook,NULL,NULL};

struct TagItem	ASLFRTags[] = { {ASLFR_Window,			NULL			},
								{ASLFR_SleepWindow,		TRUE			},
								{ASLFR_TextAttr,		NULL			},
								{ASLFR_TitleText,		NULL			},
								{ASLFR_InitialLeftEdge, NULL			},
								{ASLFR_InitialTopEdge,	NULL			},
								{ASLFR_InitialFile,		NULL			},
								{ASLFR_InitialDrawer,	NULL			},
								{ASLFR_DoSaveMode,		NULL			},
								{ASLFR_DrawersOnly,		NULL			},
								{ASLFR_RejectIcons,		TRUE			},
								{TAG_DONE}},
				ASLFOTags[] = { {ASLFO_Window,			NULL			},
								{ASLFO_SleepWindow,		TRUE			},
								{ASLFO_TextAttr,		NULL			},
								{ASLFO_TitleText,		NULL			},
								{ASLFO_InitialLeftEdge, NULL			},
								{ASLFO_InitialTopEdge,	NULL			},
								{ASLFO_InitialWidth,	NULL			},
								{ASLFO_InitialName,		NULL			},
								{ASLFO_InitialSize,		NULL			},
								{ASLFO_FixedWidthOnly,	TRUE			},
								{TAG_DONE}},
				ASLSMTags[] = { {ASLSM_Window,			NULL			},
								{ASLSM_SleepWindow,		TRUE			},
								{ASLSM_TextAttr,		NULL			},
								{ASLSM_TitleText,		NULL			},
								{ASLSM_InitialLeftEdge, NULL			},
								{ASLSM_InitialTopEdge,	NULL			},
								{ASLSM_InitialWidth,	NULL			},
								{ASLSM_InitialDisplayID,NULL			},
								{ASLSM_FilterFunc,		(ULONG)&smHook  },
								{TAG_DONE}},
				RTPalTags[] = { {RT_Window,			NULL				},
								{RT_ReqPos,			REQPOS_TOPLEFTWIN	},
								{RT_TopOffset,		NULL				},
								{RT_LockWindow, 	TRUE				},
								{RT_ShareIDCMP, 	TRUE				},
								{RT_TextAttr,		NULL				},
								{TAG_DONE}};

STATIC struct TagItem RTSMTags[] =
{
  RT_Window,		NULL,
  RT_ReqPos,		REQPOS_TOPLEFTWIN,
  RT_LeftOffset,	0,
  RT_TopOffset, 	0,
  RT_TextAttr,		NULL,
  RT_LockWindow,	TRUE,
  RTSC_MinDepth,	2,
  RTSC_Flags,		SCREQF_GUIMODES,
  TAG_END,		0
};

#endif	// ABPREFS_REQUESTER_H
