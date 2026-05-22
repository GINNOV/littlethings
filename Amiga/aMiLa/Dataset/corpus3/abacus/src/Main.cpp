/*
* This file is part of Abacus.
* Copyright (C) 1997 Kai Nickel
* 
* Abacus is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Abacus is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Abacus.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/****************************************************************************************
	Main.cpp
-----------------------------------------------------------------------------------------

  Hauptprogramm für Abacus

-----------------------------------------------------------------------------------------
	03.01.1997
****************************************************************************************/

#include <pragma/exec_lib.h> 
#include <clib/locale_protos.h>
#include "wbstartup.h"

#include "System.hpp"
#include "Tools.hpp"
#include "About.hpp"
#include "MsgWin.hpp"
#include "Rules.hpp"
#include "Settings.hpp"
#include "BoardClass.hpp"
#include "BoardWindow.hpp"
#include "StatusWin.hpp"
#include "Abacus.hpp"

#include "images/IMG_Save.c"
#include "images/IMG_Logo.c"
#include "images/IMG_Abacus.c"

char* version_string = "$VER: Abacus 2.20 (1997-01-03)";
char* version_number = "2.20";
char* version_date   = "1997-01-03";


/****************************************************************************************
	Init- / ExitLibs
****************************************************************************************/

Library *MUIMasterBase, *UtilityBase, *DiskFontBase, *LocaleBase;

BOOL InitLibs()
{
  MUIMasterBase = OpenLibrary(MUIMASTER_NAME     , MUIMASTER_VMIN);
	UtilityBase   = OpenLibrary("utility.library"  , 36);
	LocaleBase    = OpenLibrary("locale.library"   , 38);

	if (LocaleBase)	catalog = OpenCatalog(NULL, "Abacus.catalog", OC_Version, 0, TAG_DONE);
						 else catalog = NULL;

	if (MUIMasterBase && UtilityBase) return TRUE;
  //cerr << ("Failed to open "MUIMASTER_NAME" or utility.library.");
	return(FALSE);
}

void ExitLibs()
{
	if (catalog)    	 CloseCatalog(catalog      );
	if (LocaleBase) 	 CloseLibrary(LocaleBase   );
	if (UtilityBase)   CloseLibrary(UtilityBase  );
  if (MUIMasterBase) CloseLibrary(MUIMasterBase);
}


/****************************************************************************************
	Init- / ExitClasses
****************************************************************************************/

void ExitClasses()
{
	if (CL_Board			  ) MUI_DeleteCustomClass(CL_Board  			);
	if (CL_BoardWindow  ) MUI_DeleteCustomClass(CL_BoardWindow  );
	if (CL_StatusWin  	) MUI_DeleteCustomClass(CL_StatusWin	  );
	if (CL_MsgWin  			) MUI_DeleteCustomClass(CL_MsgWin	  		);
	if (CL_About  		  ) MUI_DeleteCustomClass(CL_About        );
	if (CL_Rules   		  ) MUI_DeleteCustomClass(CL_Rules        );
	if (CL_Settings		  ) MUI_DeleteCustomClass(CL_Settings     );
	if (CL_Abacus			  ) MUI_DeleteCustomClass(CL_Abacus       );
}

BOOL InitClasses()
{
	CL_Abacus        = MUI_CreateCustomClass(NULL, MUIC_Application, NULL, sizeof(struct Abacus_Data       ), Abacus_Dispatcher      );
	CL_Settings      = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct Settings_Data     ), Settings_Dispatcher    );
	CL_About         = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct About_Data        ), About_Dispatcher       );
	CL_Rules         = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct About_Data        ), Rules_Dispatcher       );
	CL_StatusWin   	 = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct StatusWin_Data  	 ), StatusWin_Dispatcher 	 );
	CL_MsgWin   	 	 = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct MsgWin_Data  	 	 ), MsgWin_Dispatcher 	 	 );
	CL_BoardWindow   = MUI_CreateCustomClass(NULL, MUIC_Window		 , NULL, sizeof(struct BoardWindow_Data  ), BoardWindow_Dispatcher );
	CL_Board		     = MUI_CreateCustomClass(NULL, MUIC_Area  		 , NULL, sizeof(struct Board_Data        ), Board_Dispatcher       );
	if (CL_Abacus && CL_BoardWindow && CL_Board  && CL_BoardWindow && CL_Settings && 
			CL_Rules	&& CL_StatusWin   && CL_MsgWin)
		return(TRUE);
	ShowError(NULL, NULL, MSG_NOCLASSES);
	return(FALSE);
}


/****************************************************************************************
	main
****************************************************************************************/

void main()
{
	if (InitLibs() && InitClasses())
	{
		Object* abacus = (Object*)NewObject(CL_Abacus->mcc_Class, NULL, TAG_DONE);
		if (abacus)
		{
			ULONG sigs = 0;
			while (DoMethod(abacus, MUIM_Application_NewInput, &sigs) != MUIV_Application_ReturnID_Quit)
			{
				if (sigs)
				{
					sigs = Wait(sigs | SIGBREAKF_CTRL_C);
					if (sigs & SIGBREAKF_CTRL_C) break;
				}
			}
			MUI_DisposeObject(abacus);
		}
	}
	ExitClasses();
	ExitLibs();
}
