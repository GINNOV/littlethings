#ifndef MAKE_ID
#define MAKE_ID(a,b,c,d) ((ULONG) (a)<<24 | (ULONG) (b)<<16 | (ULONG) (c)<<8 | (ULONG) (d))
#endif

/* Libraries */
#include <libraries/mui.h>
#include <libraries/gadtools.h> /* for Barlabel in MenuItem */
#include <exec/memory.h>

/* Prototypes */
#include <clib/muimaster_protos.h>
#include <clib/exec_protos.h>
#ifdef __GNUC__
#include <proto/alib.h>
#else
#include <clib/alib_protos.h>
#endif /* __GNUC__ */

#include "modules/modules.h"
#include "MeshWriterGUI.h"

#ifndef WITHMWLLIB
#include "/meshlib.h"
#else
#include <meshwriter/meshwriter.h>
#include <pragma/meshwriter_lib.h>
#endif

const char * meshshapes [] = {
  "Ground",
  "Circle",
  "Checkboard",
  "Pyramid",
  "Cube",
  "Cubetower",
  "Wave",
  "Ripples",
  "Galaxy",
  "Landscape",
  "Pawn",
  NULL
};

struct ObjApp * CreateApp(void)
{
	struct ObjApp * ObjectApp;

	APTR	GROUP_ROOT_0, GR_GROUPS, GR_MESH, GR_COPYRIGHT, LA_COPYRIGHT, GR_FILE3D;
	APTR	GR_FILEC, LA_FORMAT3D, LA_SAVEAS3D, LA_EXTENSION3D, Space_4, Space_5;
	APTR	GR_FILE2D, GR_FILECC, LA_FORMAT2D, LA_VIEWTYPE2D, LA_DRAWMODE2D, LA_SAVEASC2D;
	APTR	LA_EXTENSION2D, Space_6, Space_7, GROUP_ROOT_1, GR_CAMERA, GR_CPOSITION;
	APTR	LA_CX, LA_CY, LA_CZ, GR_CLOOKAT, LA_CLX, LA_CLY, LA_CLZ, GR_LIGHT;
	APTR	GR_LPOSITION, LA_LX, LA_LY, LA_LZ, GR_LCOLOR, LA_RED, LA_GREEN, LA_BLUE;

	if (!(ObjectApp = AllocVec(sizeof(struct ObjApp),MEMF_CLEAR)))
		return(NULL);

	ObjectApp->CY_MESHContent = (char **)meshshapes;
	ObjectApp->CY_FORMAT3DContent = (char **)MWL3DFileFormatNamesGet();
	ObjectApp->CY_FORMAT2DContent = (char **)MWL2DFileFormatNamesGet();
	ObjectApp->CY_DRAWMODE2DContent = (char **)MWLDrawModeNamesGet();

	ObjectApp->CY_VIEWTYPE2DContent[0] = "Top";
	ObjectApp->CY_VIEWTYPE2DContent[1] = "Bottom";
	ObjectApp->CY_VIEWTYPE2DContent[2] = "Left";
	ObjectApp->CY_VIEWTYPE2DContent[3] = "Right";
	ObjectApp->CY_VIEWTYPE2DContent[4] = "Front";
	ObjectApp->CY_VIEWTYPE2DContent[5] = "Back";
	ObjectApp->CY_VIEWTYPE2DContent[6] = "Perspective";
	ObjectApp->CY_VIEWTYPE2DContent[7] = "4 sides";
	ObjectApp->CY_VIEWTYPE2DContent[8] = NULL;

	ObjectApp->CY_MESH = CycleObject,
		MUIA_HelpNode, "CY_MESH",
		MUIA_Cycle_Entries, ObjectApp->CY_MESHContent,
	End;

	ObjectApp->BT_CALCULATE = SimpleButton("Cal_culate");

	ObjectApp->BT_INFO = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Background, MUII_ButtonBack,
		MUIA_ControlChar, 'I',
		MUIA_Text_Contents, "Information",
		MUIA_Text_PreParse, "\033c",
		MUIA_Text_HiChar, 'I',
		MUIA_HelpNode, "BT_INFO",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	ObjectApp->BT_CAMLIG = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Background, MUII_ButtonBack,
		MUIA_ControlChar, 'm',
		MUIA_Text_Contents, "Camera & light",
		MUIA_Text_PreParse, "\033c",
		MUIA_Text_HiChar, 'm',
		MUIA_HelpNode, "BT_CAMLIG",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	ObjectApp->BT_NEW = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Background, MUII_ButtonBack,
		MUIA_ControlChar, 'N',
		MUIA_Text_Contents, "New mesh",
		MUIA_Text_PreParse, "\033c",
		MUIA_Text_HiChar, 'N',
		MUIA_HelpNode, "BT_NEW",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	LA_COPYRIGHT = Label("Copyright");

	ObjectApp->STR_COPYRIGHT = StringObject,
		MUIA_Disabled, TRUE,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_COPYRIGHT",
	End;

	GR_COPYRIGHT = GroupObject,
		MUIA_HelpNode, "GR_COPYRIGHT",
		MUIA_Group_Columns, 2,
		Child, LA_COPYRIGHT,
		Child, ObjectApp->STR_COPYRIGHT,
	End;

	GR_MESH = GroupObject,
		MUIA_HelpNode, "GR_MESH",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Mesh",
		Child, ObjectApp->CY_MESH,
		Child, ObjectApp->BT_CALCULATE,
		Child, ObjectApp->BT_INFO,
		Child, ObjectApp->BT_CAMLIG,
		Child, ObjectApp->BT_NEW,
		Child, GR_COPYRIGHT,
	End;

	LA_FORMAT3D = Label("Format");

	ObjectApp->CY_FORMAT3D = CycleObject,
		MUIA_HelpNode, "CY_FORMAT3D",
		MUIA_Disabled, TRUE,
		MUIA_Cycle_Entries, ObjectApp->CY_FORMAT3DContent,
	End;

	LA_SAVEAS3D = Label("Save As");

	ObjectApp->STR_PA_FILE3D = String("", 80);

	ObjectApp->PA_FILE3D = PopButton(MUII_PopUp);

	ObjectApp->PA_FILE3D = PopaslObject,
		MUIA_HelpNode, "PA_FILE3D",
		MUIA_Disabled, TRUE,
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, ObjectApp->STR_PA_FILE3D,
		MUIA_Popstring_Button, ObjectApp->PA_FILE3D,
	End;

	LA_EXTENSION3D = Label("Extension");

	ObjectApp->STR_EXTENSION3D = StringObject,
		MUIA_Disabled, TRUE,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_EXTENSION3D",
		MUIA_String_MaxLen, 10,
	End;

	Space_4 = VSpace(0);

	Space_5 = VSpace(0);

	GR_FILEC = GroupObject,
		MUIA_HelpNode, "GR_FILEC",
		MUIA_Group_Columns, 2,
		Child, LA_FORMAT3D,
		Child, ObjectApp->CY_FORMAT3D,
		Child, LA_SAVEAS3D,
		Child, ObjectApp->PA_FILE3D,
		Child, LA_EXTENSION3D,
		Child, ObjectApp->STR_EXTENSION3D,
		Child, Space_4,
		Child, Space_5,
	End;

	ObjectApp->BT_SAVE3D = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Background, MUII_ButtonBack,
		MUIA_ControlChar, '3',
		MUIA_Text_Contents, "Save 3D",
		MUIA_Text_PreParse, "\033c",
		MUIA_Text_HiChar, '3',
		MUIA_HelpNode, "BT_SAVE3D",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	GR_FILE3D = GroupObject,
		MUIA_HelpNode, "GR_FILE3D",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "3D File",
		Child, GR_FILEC,
		Child, ObjectApp->BT_SAVE3D,
	End;

	LA_FORMAT2D = Label("Format");

	ObjectApp->CY_FORMAT2D = CycleObject,
		MUIA_HelpNode, "CY_FORMAT2D",
		MUIA_Disabled, TRUE,
		MUIA_Cycle_Entries, ObjectApp->CY_FORMAT2DContent,
	End;

	LA_VIEWTYPE2D = Label("Viewtype");

	ObjectApp->CY_VIEWTYPE2D = CycleObject,
		MUIA_HelpNode, "CY_VIEWTYPE2D",
		MUIA_Disabled, TRUE,
		MUIA_Cycle_Entries, ObjectApp->CY_VIEWTYPE2DContent,
	End;

	LA_DRAWMODE2D = Label("Drawmode");

	ObjectApp->CY_DRAWMODE2D = CycleObject,
		MUIA_HelpNode, "CY_DRAWMODE2D",
		MUIA_Disabled, TRUE,
		MUIA_Cycle_Entries, ObjectApp->CY_DRAWMODE2DContent,
	End;

	LA_SAVEASC2D = Label("Save As");

	ObjectApp->STR_PA_FILE2D = String("", 80);

	ObjectApp->PA_FILE2D = PopButton(MUII_PopUp);

	ObjectApp->PA_FILE2D = PopaslObject,
		MUIA_HelpNode, "PA_FILE2D",
		MUIA_Disabled, TRUE,
		MUIA_Popasl_Type, 0,
		MUIA_Popstring_String, ObjectApp->STR_PA_FILE2D,
		MUIA_Popstring_Button, ObjectApp->PA_FILE2D,
	End;

	LA_EXTENSION2D = Label("Extension");

	ObjectApp->STR_EXTENSION2D = StringObject,
		MUIA_Disabled, TRUE,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_EXTENSION2D",
		MUIA_String_MaxLen, 10,
	End;

	Space_6 = VSpace(0);

	Space_7 = VSpace(0);

	GR_FILECC = GroupObject,
		MUIA_HelpNode, "GR_FILECC",
		MUIA_Group_Columns, 2,
		Child, LA_FORMAT2D,
		Child, ObjectApp->CY_FORMAT2D,
		Child, LA_VIEWTYPE2D,
		Child, ObjectApp->CY_VIEWTYPE2D,
		Child, LA_DRAWMODE2D,
		Child, ObjectApp->CY_DRAWMODE2D,
		Child, LA_SAVEASC2D,
		Child, ObjectApp->PA_FILE2D,
		Child, LA_EXTENSION2D,
		Child, ObjectApp->STR_EXTENSION2D,
		Child, Space_6,
		Child, Space_7,
	End;

	ObjectApp->BT_SAVE2D = TextObject,
		ButtonFrame,
		MUIA_Disabled, TRUE,
		MUIA_Background, MUII_ButtonBack,
		MUIA_ControlChar, '2',
		MUIA_Text_Contents, "Save 2D",
		MUIA_Text_PreParse, "\033c",
		MUIA_Text_HiChar, '2',
		MUIA_HelpNode, "BT_SAVE2D",
		MUIA_InputMode, MUIV_InputMode_RelVerify,
	End;

	GR_FILE2D = GroupObject,
		MUIA_HelpNode, "GR_FILE2D",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "2D File",
		Child, GR_FILECC,
		Child, ObjectApp->BT_SAVE2D,
	End;

	GR_GROUPS = GroupObject,
		MUIA_HelpNode, "GR_GROUPS",
		MUIA_Group_Columns, 3,
		Child, GR_MESH,
		Child, GR_FILE3D,
		Child, GR_FILE2D,
	End;

	ObjectApp->BT_ABOUT = SimpleButton("_About");

	GROUP_ROOT_0 = GroupObject,
		Child, GR_GROUPS,
		Child, ObjectApp->BT_ABOUT,
	End;

	ObjectApp->WI_MAIN = WindowObject,
		MUIA_Window_Title, "MeshWriter",
		MUIA_Window_ID, MAKE_ID('0', 'W', 'I', 'N'),
		MUIA_Window_NoMenus, TRUE,
		WindowContents, GROUP_ROOT_0,
	End;

	LA_CX = Label("X");

	ObjectApp->STR_CX = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CX",
	End;

	LA_CY = Label("Y");

	ObjectApp->STR_CY = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CY",
	End;

	LA_CZ = Label("Z");

	ObjectApp->STR_CZ = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CZ",
	End;

	GR_CPOSITION = GroupObject,
		MUIA_HelpNode, "GR_CPOSITION",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Position",
		MUIA_Group_Columns, 2,
		Child, LA_CX,
		Child, ObjectApp->STR_CX,
		Child, LA_CY,
		Child, ObjectApp->STR_CY,
		Child, LA_CZ,
		Child, ObjectApp->STR_CZ,
	End;

	LA_CLX = Label("X");

	ObjectApp->STR_CLX = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CLX",
	End;

	LA_CLY = Label("Y");

	ObjectApp->STR_CLY = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CLY",
	End;

	LA_CLZ = Label("Z");

	ObjectApp->STR_CLZ = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_CLZ",
	End;

	GR_CLOOKAT = GroupObject,
		MUIA_HelpNode, "GR_CLOOKAT",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Look at",
		MUIA_Group_Columns, 2,
		Child, LA_CLX,
		Child, ObjectApp->STR_CLX,
		Child, LA_CLY,
		Child, ObjectApp->STR_CLY,
		Child, LA_CLZ,
		Child, ObjectApp->STR_CLZ,
	End;

	GR_CAMERA = GroupObject,
		MUIA_HelpNode, "GR_CAMERA",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Camera",
		MUIA_Group_Columns, 2,
		Child, GR_CPOSITION,
		Child, GR_CLOOKAT,
	End;

	LA_LX = Label("X");

	ObjectApp->STR_LX = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_LX",
	End;

	LA_LY = Label("Y");

	ObjectApp->STR_LY = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_LY",
	End;

	LA_LZ = Label("Z");

	ObjectApp->STR_LZ = StringObject,
		MUIA_Frame, MUIV_Frame_String,
		MUIA_HelpNode, "STR_LZ",
	End;

	GR_LPOSITION = GroupObject,
		MUIA_HelpNode, "GR_LPOSITION",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Position",
		MUIA_Group_Columns, 2,
		Child, LA_LX,
		Child, ObjectApp->STR_LX,
		Child, LA_LY,
		Child, ObjectApp->STR_LY,
		Child, LA_LZ,
		Child, ObjectApp->STR_LZ,
	End;

	LA_RED = Label("Red");

	ObjectApp->SL_RED = SliderObject,
		MUIA_HelpNode, "SL_RED",
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 255,
		MUIA_Slider_Level, 0,
	End;

	LA_GREEN = Label("Green");

	ObjectApp->SL_GREEN = SliderObject,
		MUIA_HelpNode, "SL_GREEN",
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 255,
		MUIA_Slider_Level, 0,
	End;

	LA_BLUE = Label("Blue");

	ObjectApp->SL_BLUE = SliderObject,
		MUIA_HelpNode, "SL_BLUE",
		MUIA_Weight, 0,
		MUIA_Frame, MUIV_Frame_Slider,
		MUIA_Slider_Min, 0,
		MUIA_Slider_Max, 255,
		MUIA_Slider_Level, 0,
	End;

	GR_LCOLOR = GroupObject,
		MUIA_HelpNode, "GR_LCOLOR",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Color",
		MUIA_Group_Columns, 2,
		Child, LA_RED,
		Child, ObjectApp->SL_RED,
		Child, LA_GREEN,
		Child, ObjectApp->SL_GREEN,
		Child, LA_BLUE,
		Child, ObjectApp->SL_BLUE,
	End;

	GR_LIGHT = GroupObject,
		MUIA_HelpNode, "GR_LIGHT",
		MUIA_Frame, MUIV_Frame_Button,
		MUIA_FrameTitle, "Light",
		MUIA_Group_Columns, 2,
		Child, GR_LPOSITION,
		Child, GR_LCOLOR,
	End;

	GROUP_ROOT_1 = GroupObject,
		Child, GR_CAMERA,
		Child, GR_LIGHT,
	End;

	ObjectApp->WI_CAMLIG = WindowObject,
		MUIA_Window_Title, "Camera and light",
		MUIA_Window_ID, MAKE_ID('1', 'W', 'I', 'N'),
		WindowContents, GROUP_ROOT_1,
	End;

	ObjectApp->App = ApplicationObject,
		MUIA_Application_Author, "Stephan Bielmann",
		MUIA_Application_Base, "MeshWriter",
		MUIA_Application_Title, "MeshWriter",
		MUIA_Application_Version, "$VER: MeshWriter 1.10 (27.03.99)",
		MUIA_Application_Copyright, "Stephan Bielmann",
		MUIA_Application_Description, "MeshWriter library testprogram",
		MUIA_Application_HelpFile, "MeshWriter.guide",
		SubWindow, ObjectApp->WI_MAIN,
		SubWindow, ObjectApp->WI_CAMLIG,
	End;


	if (!ObjectApp->App)
	{
		FreeVec(ObjectApp);
		return(NULL);
	}

	DoMethod(ObjectApp->WI_MAIN,
		MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, MUIV_Application_ReturnID_Quit
		);

	DoMethod(ObjectApp->WI_MAIN,
		MUIM_Notify, MUIA_Window_Activate, TRUE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_CAMLIGACT
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_CALCULATE,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->PA_FILE3D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_SAVE3D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_NEW,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_INFO,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_FORMAT3D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_MESH,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->STR_EXTENSION3D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->STR_COPYRIGHT,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_CAMLIG,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_FORMAT2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_VIEWTYPE2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->PA_FILE2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->STR_EXTENSION2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_SAVE2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_DRAWMODE2D,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_CALCULATE,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_CALCULATE
		);

	DoMethod(ObjectApp->BT_INFO,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_INFO
		);

	DoMethod(ObjectApp->BT_CAMLIG,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->WI_CAMLIG,
		3,
		MUIM_Set, MUIA_Window_Open, TRUE
		);

	DoMethod(ObjectApp->BT_CAMLIG,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_OPENCAMLIG
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_NEW
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->BT_CALCULATE,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->CY_FORMAT3D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->PA_FILE3D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->STR_EXTENSION3D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->BT_SAVE3D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->BT_NEW,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->BT_INFO,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->CY_MESH,
		3,
		MUIM_Set, MUIA_Disabled, FALSE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->STR_COPYRIGHT,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->BT_CAMLIG,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->CY_FORMAT2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->CY_VIEWTYPE2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->PA_FILE2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->STR_EXTENSION2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->BT_SAVE2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->BT_NEW,
		MUIM_Notify, MUIA_Pressed, TRUE,
		ObjectApp->CY_DRAWMODE2D,
		3,
		MUIM_Set, MUIA_Disabled, TRUE
		);

	DoMethod(ObjectApp->CY_FORMAT3D,
		MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_FORMAT3D
		);

	DoMethod(ObjectApp->BT_SAVE3D,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_SAVE3D
		);

	DoMethod(ObjectApp->CY_FORMAT2D,
		MUIM_Notify, MUIA_Cycle_Active, MUIV_EveryTime,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_FORMAT2D
		);

	DoMethod(ObjectApp->BT_SAVE2D,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_SAVE2D
		);

	DoMethod(ObjectApp->BT_ABOUT,
		MUIM_Notify, MUIA_Pressed, FALSE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_ABOUT
		);

	DoMethod(ObjectApp->WI_MAIN,
		MUIM_Window_SetCycleChain, ObjectApp->CY_MESH,
		ObjectApp->BT_CALCULATE,
		ObjectApp->BT_INFO,
		ObjectApp->BT_CAMLIG,
		ObjectApp->BT_NEW,
		ObjectApp->STR_COPYRIGHT,
		ObjectApp->CY_FORMAT3D,
		ObjectApp->PA_FILE3D,
		ObjectApp->STR_EXTENSION3D,
		ObjectApp->BT_SAVE3D,
		ObjectApp->CY_FORMAT2D,
		ObjectApp->CY_VIEWTYPE2D,
		ObjectApp->CY_DRAWMODE2D,
		ObjectApp->PA_FILE2D,
		ObjectApp->STR_EXTENSION2D,
		ObjectApp->BT_SAVE2D,
		ObjectApp->BT_ABOUT,
		0
		);

	DoMethod(ObjectApp->WI_CAMLIG,
		MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
		ObjectApp->App,
		2,
		MUIM_Application_ReturnID, ID_CANCELCAMLIG
		);

	DoMethod(ObjectApp->WI_CAMLIG,
		MUIM_Notify, MUIA_Window_CloseRequest, TRUE,
		ObjectApp->WI_CAMLIG,
		3,
		MUIM_Set, MUIA_Window_Open, FALSE
		);

	DoMethod(ObjectApp->WI_CAMLIG,
		MUIM_Window_SetCycleChain, ObjectApp->STR_CX,
		ObjectApp->STR_CY,
		ObjectApp->STR_CZ,
		ObjectApp->STR_CLX,
		ObjectApp->STR_CLY,
		ObjectApp->STR_CLZ,
		ObjectApp->STR_LX,
		ObjectApp->STR_LY,
		ObjectApp->STR_LZ,
		ObjectApp->SL_RED,
		ObjectApp->SL_GREEN,
		ObjectApp->SL_BLUE,
		0
		);

	set(ObjectApp->WI_MAIN,
		MUIA_Window_Open, TRUE
		);


	return(ObjectApp);
}

void DisposeApp(struct ObjApp * ObjectApp)
{
	MUI_DisposeObject(ObjectApp->App);
	FreeVec(ObjectApp);
}
