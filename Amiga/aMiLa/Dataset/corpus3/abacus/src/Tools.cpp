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
	Tools.cpp
-----------------------------------------------------------------------------------------

	Hilfsfunktionen und Creationmakros

-----------------------------------------------------------------------------------------
	29.12.1996
****************************************************************************************/

#define CATCOMP_NUMBERS
#define CATCOMP_STRINGS
#define CATCOMP_ARRAY
#include "LocStrings.h"

#include "Tools.hpp"
#include "Images.hpp"
#include "MCC.hpp"

#include <pragma/asl_lib.h>
#include <pragma/locale_lib.h>
#include <pragma/dos_lib.h>


/****************************************************************************************
	GetStr
****************************************************************************************/

struct Catalog* catalog;

char* GetStr(int num)
{
	struct CatCompArrayType* cca = (struct CatCompArrayType*)CatCompArray;
	while (cca->cca_ID != num) cca++;
	if (catalog) return GetCatalogStr(catalog, num, cca->cca_Str);
	return (char*)cca->cca_Str;
}


/****************************************************************************************
	MUI-Hilfstools
****************************************************************************************/

#define getatt(obj,attr,store) GetAttr(attr,obj,(ULONG *)store)
#define setatt(obj,attr,value) SetAttrs(obj,attr,value,TAG_DONE)

LONG xget(Object* obj, ULONG attribute)
{	
	LONG x;
	getatt(obj, attribute, &x);
	return x;
}

char* StringContents(Object* obj)
{
	char *tmp;
	getatt(obj, MUIA_String_Contents, &tmp);
	return tmp;
}

ULONG /*__stdargs*/ DoSuperNew(struct IClass* cl, Object* obj, ULONG tag1,...)
{
	return(DoSuperMethod(cl, obj, OM_NEW, &tag1, NULL));
}



/****************************************************************************************
	MUI-Creation"makros"
****************************************************************************************/

char GetControlChar(char* label)
{
	if (label)
	{
		char* c = strchr(label, '_');
		if (c) return ToLower(*(c+1));
	}
	return 0;
}

Object* HBar()
{
	return MUI_MakeObject(MUIO_HBar, 4);
}

Object* VBar()
{
	return MUI_MakeObject(MUIO_VBar, 8);
}

Object* MakeButton(int num, int help)
{
	Object* obj = MUI_MakeObject(MUIO_Button, GetStr(num));
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain, 1					 );
		setatt(obj, MUIA_ShortHelp , GetStr(help));
	}
	return obj;
}

Object *MakeString(int maxlen, int num, char* contents, int help)
{
	char* titel;
	if (num) titel = GetStr(num); else titel = NULL;
	Object *obj = MUI_MakeObject(MUIO_String, titel, maxlen);
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain			, 1						);
		setatt(obj, MUIA_String_Contents, contents		);
		setatt(obj, MUIA_ShortHelp			, GetStr(help));
	}
	return obj;
}

Object *MakeCycle(char** array, int num, int help)
{
	Object *obj = MUI_MakeObject(MUIO_Cycle, GetStr(num), array);
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain, 1					 );
		setatt(obj, MUIA_ShortHelp , GetStr(help));
	}
	return obj;
}

Object *MakeRadio(char** array, int num, int help)
{
	Object *obj = MUI_MakeObject(MUIO_Radio, GetStr(num), array);
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain, 1					 );
		setatt(obj, MUIA_ShortHelp , GetStr(help));
	}
	return obj;
}

Object *MakeCheck(int num, BOOL pressed, int help)
{
	Object *obj = MUI_MakeObject(MUIO_Checkmark, GetStr(num));
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain, 1					 );
		setatt(obj, MUIA_Selected  , pressed		 );
		setatt(obj, MUIA_ShortHelp , GetStr(help));
	}
	return obj;
}

Object *MakeNumerical(int num, LONG min, LONG max, LONG val, int help)
{
	Object* obj = MUI_MakeObject(MUIO_NumericButton, GetStr(num), min, max, "  %2ld  ");
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain   , 1  					);
		setatt(obj, MUIA_Numeric_Value, val					);
		setatt(obj, MUIA_ShortHelp		, GetStr(help));
	}
	return obj;
}

Object* MakeSlider(int min, int max, int val, int text, int help)
{
	Object *obj = MUI_MakeObject(MUIO_Slider, GetStr(text), min, max);
	if (obj) 
	{
		setatt(obj, MUIA_CycleChain	 , 1);
		setatt(obj, MUIA_Slider_Level, val);
		setatt(obj, MUIA_ShortHelp	 , GetStr(help));
	}
	return obj;
}

Object *MakeImageTextButton(int text, int help, int control, const UBYTE* data)
{
	return
		HGroup,

			MUIA_InputMode  , MUIV_InputMode_RelVerify,
			MUIA_ControlChar, GetStr(control)[0],
			MUIA_Background	, MUII_ButtonBack,
			MUIA_Frame			, MUIV_Frame_Button,
			MUIA_ShortHelp	, GetStr(help),
			MUIA_CycleChain	, 1,
			MUIA_Font       , MUIV_Font_Button,

			Child, BodychunkObject,
				MUIA_FixWidth             , IMG_SAVE_WIDTH,
				MUIA_FixHeight            , IMG_SAVE_HEIGHT,
				MUIA_Bitmap_Width         , IMG_SAVE_WIDTH,
				MUIA_Bitmap_Height        , IMG_SAVE_HEIGHT,
				MUIA_Bodychunk_Depth      , IMG_SAVE_DEPTH,
				MUIA_Bodychunk_Body       , data,
				MUIA_Bodychunk_Compression, IMG_SAVE_COMPRESSION,
		  	MUIA_Bodychunk_Masking    , IMG_SAVE_MASKING,
				MUIA_Bitmap_SourceColors  , IMG_Save_colors,
				MUIA_Bitmap_Transparent   , 0,
				End,

			Child, TextObject,
				MUIA_Text_Contents, GetStr(text),
				MUIA_Text_HiChar  , GetStr(control)[0],
				MUIA_Text_PreParse, "\33c",
				End,			

  		End;
}

Object *MakeImage(const UBYTE* data, LONG w, LONG h, LONG d, 
 							    LONG compr, LONG mask, const ULONG* colors)
{
	return BodychunkObject,
		MUIA_FixWidth             , w,
		MUIA_FixHeight            , h,
		MUIA_Bitmap_Width         , w,
		MUIA_Bitmap_Height        , h,
		MUIA_Bodychunk_Depth      , d,
		MUIA_Bodychunk_Body       , data,
		MUIA_Bodychunk_Compression, compr,
  	MUIA_Bodychunk_Masking    , mask,
		MUIA_Bitmap_SourceColors  , colors,
		MUIA_Bitmap_Transparent   , 0,
		MUIA_ShowSelState 				, FALSE,
		End;
}



Object *MakeLabel     (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), 0)); }
Object *MakeLabel1    (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_SingleFrame)); }
Object *MakeLabel2    (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_DoubleFrame)); }
Object *MakeLLabel    (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_LeftAligned)); }
Object *MakeLLabel1   (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_LeftAligned|MUIO_Label_SingleFrame)); }
Object *MakeLLabel2   (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_LeftAligned|MUIO_Label_DoubleFrame)); }
Object *MakeFreeLabel (int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_FreeVert)); }
Object *MakeFreeLLabel(int num) { return(MUI_MakeObject(MUIO_Label, GetStr(num), MUIO_Label_FreeVert|MUIO_Label_LeftAligned)); }


Object* MenuObj(Object* strip, int data)
{
	return (Object*)DoMethod(strip, MUIM_FindUData, data);
}



/****************************************************************************************
	ShowError

	Zeigt einen Fehler in einem Requester mit "Ok" Button
****************************************************************************************/

void ShowError(Object* app, Object* win, int msg)
{
	if (app)
		MUI_RequestA(app , win, 0, GetStr(MSG_ERRREQTITLE), GetStr(MSG_ERRREQGADGET   ), GetStr(msg), 0);
	else
		MUI_RequestA(NULL, win, 0, GetStr(MSG_ERRREQTITLE), GetStr(MSG_ERRREQGADGETSYS), GetStr(msg), 0);
}



/****************************************************************************************
	GetFilename

	Öffnet einen ASL-FileRequester, retourniert Auswahl - ansonsten NULL.
	Der rueckgegebene String ist bis zum naechsten Aufruf gueltig.
****************************************************************************************/

SAVEDS ASM VOID IntuiMsgFunc(REG(a1) struct IntuiMessage* imsg, 
														 REG(a2) struct FileRequester* req)
{
	if (imsg->Class == IDCMP_REFRESHWINDOW)
		DoMethod((Object*)req->fr_UserData, MUIM_Application_CheckRefresh);
}

char* GetFilename(Object* win, BOOL save, int title, char* pattern, char* initdrawer)
{
	static char buf[512];
	struct FileRequester* req;
	struct Window* w;
	static LONG left = -1, top = -1, width = -1, height = -1;
	Object* app = (Object*)xget(win, MUIA_ApplicationObject);
	char* res = NULL;
	static const struct Hook IntuiMsgHook = { { 0,0 }, (HOOKFUNC)IntuiMsgFunc, NULL, NULL };
	getatt(win, MUIA_Window_Window, &w);
	if (left == -1)
	{
		left   = w->LeftEdge+w->BorderLeft+2;
		top    = w->TopEdge+w->BorderTop+2;
		width  = w->Width-w->BorderLeft-w->BorderRight-4;
		height = w->Height-w->BorderTop-w->BorderBottom-4;
	}
	req = (FileRequester*)MUI_AllocAslRequestTags(ASL_FileRequest,

					ASLFR_Window         , w,
					ASLFR_TitleText      , GetStr(title),
/*
					ASLFR_InitialLeftEdge, left,
					ASLFR_InitialTopEdge , top,
					ASLFR_InitialWidth   , width,
					ASLFR_InitialHeight  , height,
*/
					ASLFR_InitialDrawer  , initdrawer,
					ASLFR_InitialPattern , pattern,
					ASLFR_DoSaveMode     , save,
					ASLFR_DoPatterns     , TRUE,
					ASLFR_RejectIcons    , TRUE,
					ASLFR_UserData       , app,
					ASLFR_IntuiMsgFunc   , &IntuiMsgHook,
					TAG_DONE);
	if (req)
	{
		setatt(app, MUIA_Application_Sleep, TRUE);
		if (MUI_AslRequestTags(req, TAG_DONE))
		{
			if (*req->fr_File)
			{
				strcpy(buf, req->fr_Drawer/*, sizeof(buf)*/);
				AddPart(buf, req->fr_File, sizeof(buf));
				res = buf;
			}
			left   = req->fr_LeftEdge;
			top    = req->fr_TopEdge;
			width  = req->fr_Width;
			height = req->fr_Height;
		}
		MUI_FreeAslRequest(req);
		setatt(app, MUIA_Application_Sleep, FALSE);
	}
	return(res);
}


