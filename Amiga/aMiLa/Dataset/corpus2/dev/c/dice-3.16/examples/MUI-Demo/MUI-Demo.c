/*
**          C Source Code For The MUI Demo Program
**          --------------------------------------
**
**             written 1992-95 by Stefan Stuntz
**
** Even if it doesn't look so, all of the code below is pure C,
** just a little bit enhanced with some MUI specific macros.
**
** NOTE: This demo shows a few MUI techniques (like Return IDs)
** that are a little outdated. Be sure to also check the other
** demonstration programs for more object oriented GUI design!
*/

#include "demo.h"


/*
** A little array definition:
*/

static const char *LVT_Brian[] =
{
"Cheer up, Brian. You know what they say.",
"Some things in life are bad,",
"They can really make you mad.",
"Other things just make you swear and curse.",
"When you're chewing on life's grissle,",
"Don't grumble, give a whistle.",
"And this'll help things turn out for the best,",
"And...",
"",
"Always look on the bright side of life",
"Always look on the light side of life",
"",
"If life seems jolly rotten,",
"There's something you've forgotten,",
"And that's to laugh, and smile, and dance, and sing.",
"When you're feeling in the dumps,",
"Don't be silly chumps,",
"Just purse your lips and whistle, that's the thing.",
"And...",
"",
"Always look on the bright side of life, come on!",
"Always look on the right side of life",
"",
"For life is quite absurd,",
"And death's the final word.",
"You must always face the curtain with a bow.",
"Forget about your sin,",
"Give the audience a grin.",
"Enjoy it, it's your last chance anyhow,",
"So...",
"",
"Always look on the bright side of death",
"Just before you draw your terminal breath.",
"",
"Life's a piece of shit,",
"When you look at it.",
"Life's a laugh, and death's a joke, it's true.",
"You'll see it's all a show,",
"Keep 'em laughing as you go,",
"Just remember that the last laugh is on you.",
"And...",
"",
"Always look on the bright side of life !",
"",
"...",
NULL,
};



/*
** Convetional GadTools NewMenu structure, a memory
** saving way of definig menus.
*/

#define ID_ABOUT  1
#define ID_NEWVOL 2
#define ID_NEWBRI 3

struct NewMenu Menu[] =
{
	{ NM_TITLE, "Project"  , 0 ,0,0,(APTR)0            },
	{ NM_ITEM , "About..." ,"?",0,0,(APTR)ID_ABOUT     },
	{ NM_ITEM , NM_BARLABEL, 0 ,0,0,(APTR)0            },
	{ NM_ITEM , "Quit"     ,"Q",0,0,(APTR)MUIV_Application_ReturnID_Quit },
	{ NM_END  , NULL       , 0 ,0,0,(APTR)0            },
};


/*
** Here are all the little info texts
** that appear at the top of each demo window.
*/

static const char IN_Master[]    = "\tWelcome to the MUI demonstration program. \
This little toy will show you how easy it is to create graphical user interfaces \
with MUI and how powerful the results are.\n\tMUI is based on BOOPSI, Amiga's \
basic object oriented programming system. For details about programming, see the \
'ReadMe' file and the documented source code of this demo. Only one thing so far: \
it's really easy!\n\tNow go on, click around and watch this demo. Or use your \
keyboard (TAB, Return, Cursor-Keys) if you like that better. Hint: play \
around with the MUI preferences program and customize every pixel to fit \
your personal taste.";

static const char IN_Notify[]    = "\tMUI objects communicate with each other \
with the aid of a notifcation system. This system is frequently used in every \
MUI application. Binding an up and a down arrow to a prop gadget e.g. makes up \
a scrollbar, binding a scrollbar to a list makes up a listview. You can also \
bind windows to buttons, thus the window will be opened when the button is \
pressed.\n\tRemember: The main loop of this demo program simply consists of \
a Wait(). Once set up, MUI handles all user actions concerning the GUI \
automatically.";

static const char IN_Frames[]    = "\tEvery MUI object can have a surrounding \
frame. Several types are available, all adjustable with the preferences program.";

static const char IN_Images[]    = "\tMUI offers a vector image class, that allows \
images to be zoomed to any dimension. Every MUI image is transformed to match the \
current screens colors before displaying.\n\tThere are several standard images for \
often used GUI components (e.g. Arrows). These standard images can be defined via \
the preferences program.";

static const char IN_Groups[]    = "\tGroups are very important for MUI. Their \
combinations determine how the GUI will look. A group may contain any number of \
child objects, which are positioned either horizontal or vertical.\n\tWhen a \
group is layouted, the available space is distributed between all of its \
children, depending on their minimum and maximum dimensions and on their \
weight.\n\tOf course, the children of a group may be other groups. There \
are no restrictions.";

static const char IN_Backfill[]  = "\tEvery object can have its own background, \
if it wants to. MUI offers several standard backgrounds (e.g. one of the DrawInfo \
pens or one of the rasters below).\nThe prefs program allows defining a large number \
of backgrounds... try it!";

static const char IN_Listviews[] = "\tMUI's list class is very flexible. A list can \
be made up of any number of columns containing formatted text or even images. Several \
subclasses of list class (e.g. a directory class and a volume class) are available. \
All MUI lists have the capability of multi selection, just by setting a single \
flag.\n\tThe small info texts at the top of each demo window are made with floattext \
class. This one just needs a character string as input and formats the text according \
to its width.";

static const char IN_Cycle[]     = "\tCycle gadgets, radios buttons and simple lists \
can be used to let the user pick exactly one selection from a list of choices. In this \
example, all three possibilities are shown. Of course they are connected via notification, \
so every object will immediately be notified and updated when necessary.";

static const char IN_String[]    = "\tOf course, MUI offers a standard string gadget class \
for text input. The gadget in this example is attached to the list, you can control the \
list cursor from within the gadget.";


/*
** This are the entries for the cycle gadgets and radio buttons.
*/

static const char *CYA_Computer[] = { "Amiga 500","Amiga 600","Amiga 1000 :)","Amiga 1200","Amiga 2000","Amiga 3000","Amiga 4000", "Amiga 4000T", "Atari ST :(", NULL };
static const char *CYA_Printer[]  = { "HP Deskjet","NEC P6","Okimate 20",NULL };
static const char *CYA_Display[]  = { "A1081","NEC 3D","A2024","Eizo T660i",NULL };


/*
** Some Macros to make my life easier and the actual source
** code more readable.
*/

#define List(ftxt)               ListviewObject, MUIA_Weight, 50, MUIA_Listview_Input, FALSE, MUIA_Listview_List,\
                                 FloattextObject, MUIA_Frame, MUIV_Frame_ReadList, MUIA_Background, MUII_ReadListBack, MUIA_Floattext_Text, ftxt, MUIA_Floattext_TabSize, 4, MUIA_Floattext_Justify, TRUE, End, End
#define DemoWindow(name,id,info) WindowObject, MUIA_Window_Title, name, MUIA_Window_ID, id, WindowContents, VGroup, Child, List(info)
#define Image(nr)                ImageObject, MUIA_Image_Spec, nr, End
#define ScaledImage(nr,s,x,y)    ImageObject, MUIA_Image_Spec, nr, MUIA_FixWidth, x, MUIA_FixHeight, y, MUIA_Image_FreeHoriz, TRUE, MUIA_Image_FreeVert, TRUE, MUIA_Image_State, s, End
#define HProp                    PropObject, PropFrame, MUIA_Prop_Horiz, TRUE, MUIA_FixHeight, 8, MUIA_Prop_Entries, 111, MUIA_Prop_Visible, 10, End
#define VProp                    PropObject, PropFrame, MUIA_Prop_Horiz, FALSE, MUIA_FixWidth , 8, MUIA_Prop_Entries, 111, MUIA_Prop_Visible, 10, End


/*
** For every object we want to refer later (e.g. for notification purposes)
** we need a pointer. These pointers do not need to be static, but this
** saves stack space.
*/

static APTR AP_Demo;
static APTR WI_Master,WI_Frames,WI_Images,WI_Notify,WI_Listviews,WI_Groups,WI_Backfill,WI_Cycle,WI_String;
static APTR BT_Notify,BT_Frames,BT_Images,BT_Groups,BT_Backfill,BT_Listviews,BT_Cycle,BT_String,BT_Quit;
static APTR PR_PropA,PR_PropH,PR_PropV,PR_PropL,PR_PropR,PR_PropT,PR_PropB;
static APTR LV_Volumes,LV_Directory,LV_Computer,LV_Brian;
static APTR CY_Computer,CY_Printer,CY_Display;
static APTR MT_Computer,MT_Printer,MT_Display;
static APTR ST_Brian;
static APTR GA_Gauge1,GA_Gauge2,GA_Gauge3;
static APTR BP_Wheel;


/*
** This is where it all begins...
*/

int main(int argc,char *argv[])
{

/*
** The init() functions is define in demos.h and does nothing
** but open "muimaster.library".
*/

	init();


/*
** Every MUI application needs an application object
** which will hold general information and serve as
** a kind of anchor for user input, ARexx functions,
** commodities interface, etc.
**
** An application may have any number of SubWindows
** which can all be created in the same call or added
** later, according to your needs.
**
** Note that creating a window does not mean to
** open it, this will be done later by setting
** the windows open attribute.
*/

	AP_Demo = ApplicationObject,
		MUIA_Application_Title         , "MUI-Demo",
		MUIA_Application_Version       , "$VER: MUI-Demo 19.6 (12.02.97)",
		MUIA_Application_Copyright     , "Copyright ©1992-95, Stefan Stuntz",
		MUIA_Application_Author        , "Stefan Stuntz",
		MUIA_Application_Description   , "Demonstrate the features of MUI.",
		MUIA_Application_Base          , "MUIDEMO",
		MUIA_Application_Menustrip     , MUI_MakeObject(MUIO_MenustripNM,Menu,0),

		SubWindow,
			WI_String = DemoWindow("String",MAKE_ID('S','T','R','G'),IN_String),
				Child, LV_Brian = ListviewObject,
					MUIA_Listview_Input, TRUE,
					MUIA_Listview_List, ListObject, InputListFrame, End,
					End,
				Child, ST_Brian = StringObject, StringFrame, End,
				End,
			End,

		SubWindow,
			WI_Cycle = DemoWindow("Cycle Gadgets & RadioButtons",MAKE_ID('C','Y','C','L'),IN_Cycle),
				Child, HGroup,
					Child, MT_Computer = Radio("Computer:",CYA_Computer),
					Child, VGroup,
						Child, MT_Printer = Radio("Printer:",CYA_Printer),
						Child, VSpace(0),
						Child, MT_Display = Radio("Display:",CYA_Display),
						End,
					Child, VGroup,
						Child, ColGroup(2), GroupFrameT("Cycle Gadgets"),
							Child, KeyLabel1("Computer:",'c'), Child, CY_Computer = KeyCycle(CYA_Computer,'c'),
							Child, KeyLabel1("Printer:" ,'p'), Child, CY_Printer  = KeyCycle(CYA_Printer ,'p'),
							Child, KeyLabel1("Display:" ,'d'), Child, CY_Display  = KeyCycle(CYA_Display ,'d'),
							End,
						Child, LV_Computer =	ListviewObject,
							MUIA_Listview_Input, TRUE,
							MUIA_Listview_List, ListObject, InputListFrame, End,
							End,
						End,
					End,
				End,
			End,

		SubWindow,
			WI_Listviews = DemoWindow("Listviews",MAKE_ID('L','I','S','T'),IN_Listviews),
				Child, HGroup, GroupFrameT("Dir & Volume List"),
					Child, LV_Directory = ListviewObject,
						MUIA_Listview_Input, TRUE,
						MUIA_Listview_MultiSelect, TRUE,
						MUIA_Listview_List, DirlistObject, InputListFrame, MUIA_Dirlist_Directory, "ram:", MUIA_List_Title, TRUE, End,
						End,
					Child, LV_Volumes = ListviewObject,
						MUIA_Weight, 20,
						MUIA_Listview_Input, TRUE,
						MUIA_Listview_List, VolumelistObject, InputListFrame, MUIA_Dirlist_Directory, "ram:", End,
						End,
					End,
				End,
			End,

		SubWindow,
			WI_Notify = DemoWindow("Notifying",MAKE_ID('B','R','C','A'),IN_Notify),
				Child, HGroup, GroupFrameT("Connections"),
					Child, GA_Gauge1 = GaugeObject, GaugeFrame, MUIA_Gauge_Horiz, FALSE, MUIA_FixWidth, 16, End,
					Child, PR_PropL = VProp,
					Child, PR_PropR = VProp,
					Child, VGroup,
						Child, VSpace(0),
						Child, PR_PropA = HProp,
						Child, HGroup,
							Child, PR_PropH = HProp,
							Child, PR_PropV = HProp,
							End,
						Child, VSpace(0),
						Child, VGroup, GroupSpacing(1),
							Child, GA_Gauge2 = GaugeObject, GaugeFrame, MUIA_Gauge_Horiz, TRUE, End,
							Child, ScaleObject, MUIA_Scale_Horiz, TRUE, End,
							End,
						Child, VSpace(0),
						End,
					Child, PR_PropT = VProp,
					Child, PR_PropB = VProp,
					Child, GA_Gauge3 = GaugeObject, GaugeFrame, MUIA_Gauge_Horiz, FALSE, MUIA_FixWidth, 16, End,
					End,
				End,
			End,

		SubWindow,
			WI_Backfill = DemoWindow("Backfill",MAKE_ID('B','A','C','K'),IN_Backfill),
				Child, VGroup, GroupFrameT("Standard Backgrounds"),
					Child, HGroup,
						Child, RectangleObject, TextFrame, MUIA_Background, MUII_BACKGROUND            , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_FILL                  , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_SHADOW                , End,
						End,
					Child, HGroup,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_SHADOWBACK            , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_SHADOWFILL            , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_SHADOWSHINE           , End,
						End,
					Child, HGroup,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_FILLBACK              , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_SHINEBACK             , End,
		         	Child, RectangleObject, TextFrame, MUIA_Background, MUII_FILLSHINE             , End,
						End,
					End,
				End,
			End,

		SubWindow,
			WI_Groups = DemoWindow("Groups",MAKE_ID('G','R','P','S'),IN_Groups),
				Child, HGroup, GroupFrameT("Group Types"),
					Child, HGroup, GroupFrameT("Horizontal"),
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						End,
					Child, VGroup, GroupFrameT("Vertical"),
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						End,
					Child, ColGroup(3), GroupFrameT("Array"),
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						Child, RectangleObject, TextFrame, End,
						End,
					End,
				Child, HGroup, GroupFrameT("Different Weights"),
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33c25 kg" ,  MUIA_Weight,  25, End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33c50 kg" ,  MUIA_Weight,  50, End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33c75 kg" ,  MUIA_Weight,  75, End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33c100 kg",  MUIA_Weight, 100, End,
					End,
				Child, HGroup, GroupFrameT("Fixed & Variable Sizes"),
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "fixed"         ,  MUIA_Text_SetMax, TRUE , End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cfree"  ,  MUIA_Text_SetMax, FALSE, End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "fixed"         ,  MUIA_Text_SetMax, TRUE , End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cfree"  ,  MUIA_Text_SetMax, FALSE, End,
					Child, TextObject, TextFrame, MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "fixed"         ,  MUIA_Text_SetMax, TRUE , End,
					End,
				End,
			End,

		SubWindow,
			WI_Frames = DemoWindow("Frames",MAKE_ID('F','R','M','S'),IN_Frames),
				Child, ColGroup(2),
					Child, TextObject, ButtonFrame     , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cButton"     , End,
					Child, TextObject, ImageButtonFrame, InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cImageButton", End,
					Child, TextObject, TextFrame       , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cText"       , End,
					Child, TextObject, StringFrame     , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cString"     , End,
					Child, TextObject, ReadListFrame   , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cReadList"   , End,
					Child, TextObject, InputListFrame  , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cInputList"  , End,
					Child, TextObject, PropFrame       , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cProp Gadget", End,
					Child, TextObject, GroupFrame      , InnerSpacing(2,1), MUIA_Background, MUII_TextBack, MUIA_Text_Contents, "\33cGroup"      , End,
					End,
				End,
			End,

		SubWindow,
			WI_Images = DemoWindow("Images",MAKE_ID('I','M','G','S'),IN_Images),
				Child, HGroup,
					Child, ColGroup(2), GroupFrameT("Some Images"),
						Child, Label("ArrowUp:"    ), Child, Image(MUII_ArrowUp    ),
						Child, Label("ArrowDown:"  ), Child, Image(MUII_ArrowDown  ),
						Child, Label("ArrowLeft:"  ), Child, Image(MUII_ArrowLeft  ),
						Child, Label("ArrowRight:" ), Child, Image(MUII_ArrowRight ),
						Child, Label("RadioButton:"), Child, Image(MUII_RadioButton),
						Child, Label("File:"       ), Child, Image(MUII_PopFile    ),
						Child, Label("HardDisk:"   ), Child, Image(MUII_HardDisk   ),
						Child, Label("Disk:"       ), Child, Image(MUII_Disk       ),
						Child, Label("Chip:"       ), Child, Image(MUII_Chip       ),
						Child, Label("Drawer:"     ), Child, Image(MUII_Drawer     ),
						End,
					Child, VGroup, GroupFrameT("Scale Engine"),
						Child, VSpace(0),
						Child, HGroup,
							Child, ScaledImage(MUII_RadioButton,1,17, 9),
							Child, ScaledImage(MUII_RadioButton,1,20,12),
							Child, ScaledImage(MUII_RadioButton,1,23,15),
							Child, ScaledImage(MUII_RadioButton,1,26,18),
							Child, ScaledImage(MUII_RadioButton,1,29,21),
							End,
						Child, VSpace(0),
						Child, HGroup,
							Child, ScaledImage(MUII_CheckMark,1,13, 7),
							Child, ScaledImage(MUII_CheckMark,1,16,10),
							Child, ScaledImage(MUII_CheckMark,1,19,13),
							Child, ScaledImage(MUII_CheckMark,1,22,16),
							Child, ScaledImage(MUII_CheckMark,1,25,19),
							Child, ScaledImage(MUII_CheckMark,1,28,22),
							End,
						Child, VSpace(0),
						Child, HGroup,
							Child, ScaledImage(MUII_PopFile,0,12,10),
							Child, ScaledImage(MUII_PopFile,0,15,13),
							Child, ScaledImage(MUII_PopFile,0,18,16),
							Child, ScaledImage(MUII_PopFile,0,21,19),
							Child, ScaledImage(MUII_PopFile,0,24,22),
							Child, ScaledImage(MUII_PopFile,0,27,25),
							End,
						Child, VSpace(0),
						End,
					End,
				End,
			End,

		SubWindow,
			WI_Master = WindowObject,
			MUIA_Window_Title, "MUI-Demo",
			MUIA_Window_ID   , MAKE_ID('M','A','I','N'),
			WindowContents, VGroup,
				Child, TextObject, GroupFrame, MUIA_Background, MUII_SHADOWFILL, MUIA_Text_Contents, "\33c\0338MUI - \33bM\33nagic\33bU\33nser\33bI\33nnterface\nwritten 1992-95 by Stefan Stuntz",  End,

				Child, List(IN_Master),

				Child, VGroup, GroupFrameT("Available Demos"),
					Child, HGroup, MUIA_Group_SameWidth, TRUE,
						Child, BT_Groups    = SimpleButton("_Groups"),
						Child, BT_Frames    = SimpleButton("_Frames"),
						Child, BT_Backfill  = SimpleButton("_Backfill"),
						End,
					Child, HGroup, MUIA_Group_SameWidth, TRUE,
						Child, BT_Notify    = SimpleButton("_Notify"),
						Child, BT_Listviews = SimpleButton("_Listviews"),
						Child, BT_Cycle     = SimpleButton("_Cycle"),
						End,
					Child, HGroup, MUIA_Group_SameWidth, TRUE,
						Child, BT_Images    = SimpleButton("_Images" ),
						Child, BT_String    = SimpleButton("_Strings"),
						Child, BT_Quit      = SimpleButton("_Quit"   ),
						End,
					End,
				End,
			End,

		End;


/*
** See if the application was created. The fail function
** is defined in demos.h, it deletes every created object
** and closes "muimaster.library".
**
** Note that we do not need any
** error control for the sub objects since every error
** will automatically be forwarded to the parent object
** and cause this one to fail too.
*/

	if (!AP_Demo) fail(AP_Demo,"Failed to create application.");



/*
** Here comes the notifcation magic. Notifying means:
** When an attribute of an object changes, then please change
** another attribute of another object (accordingly) or send
** a method to another object.
*/

/*
** Lets bind the sub windows to the corresponding button
** of the master window.
*/

	DoMethod(BT_Frames   ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Frames   ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Images   ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Images   ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Notify   ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Notify   ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Listviews,MUIM_Notify,MUIA_Pressed,FALSE,WI_Listviews,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Groups   ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Groups   ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Backfill ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Backfill ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_Cycle    ,MUIM_Notify,MUIA_Pressed,FALSE,WI_Cycle    ,3,MUIM_Set,MUIA_Window_Open,TRUE);
	DoMethod(BT_String   ,MUIM_Notify,MUIA_Pressed,FALSE,WI_String   ,3,MUIM_Set,MUIA_Window_Open,TRUE);

	DoMethod(BT_Quit     ,MUIM_Notify,MUIA_Pressed,FALSE,AP_Demo,2,MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit);


/*
** Automagically remove a window when the user hits the close gadget.
*/

	DoMethod(WI_Images   ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Images   ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Frames   ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Frames   ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Notify   ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Notify   ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Listviews,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Listviews,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Groups   ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Groups   ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Backfill ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Backfill ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_Cycle    ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_Cycle    ,3,MUIM_Set,MUIA_Window_Open,FALSE);
	DoMethod(WI_String   ,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,WI_String   ,3,MUIM_Set,MUIA_Window_Open,FALSE);


/*
** Closing the master window forces a complete shutdown of the application.
*/

	DoMethod(WI_Master,MUIM_Notify,MUIA_Window_CloseRequest,TRUE,AP_Demo,2,MUIM_Application_ReturnID,MUIV_Application_ReturnID_Quit);


/*
** This connects the prop gadgets in the notification demo window.
*/

	DoMethod(PR_PropA,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropH,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);
	DoMethod(PR_PropA,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropV,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);
	DoMethod(PR_PropH,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropL,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);
	DoMethod(PR_PropH,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropR,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);
	DoMethod(PR_PropV,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropT,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);
	DoMethod(PR_PropV,MUIM_Notify,MUIA_Prop_First,MUIV_EveryTime,PR_PropB,3,MUIM_Set,MUIA_Prop_First,MUIV_TriggerValue);

	DoMethod(PR_PropA ,MUIM_Notify,MUIA_Prop_First   ,MUIV_EveryTime,GA_Gauge2,3,MUIM_Set,MUIA_Gauge_Current,MUIV_TriggerValue);
	DoMethod(GA_Gauge2,MUIM_Notify,MUIA_Gauge_Current,MUIV_EveryTime,GA_Gauge1,3,MUIM_Set,MUIA_Gauge_Current,MUIV_TriggerValue);
	DoMethod(GA_Gauge2,MUIM_Notify,MUIA_Gauge_Current,MUIV_EveryTime,GA_Gauge3,3,MUIM_Set,MUIA_Gauge_Current,MUIV_TriggerValue);


/*
** And here we connect cycle gadgets, radio buttons and the list in the
** cycle & radio window.
*/

	DoMethod(CY_Computer,MUIM_Notify,MUIA_Cycle_Active,MUIV_EveryTime,MT_Computer,3,MUIM_Set,MUIA_Radio_Active,MUIV_TriggerValue);
	DoMethod(CY_Printer ,MUIM_Notify,MUIA_Cycle_Active,MUIV_EveryTime,MT_Printer ,3,MUIM_Set,MUIA_Radio_Active,MUIV_TriggerValue);
	DoMethod(CY_Display ,MUIM_Notify,MUIA_Cycle_Active,MUIV_EveryTime,MT_Display ,3,MUIM_Set,MUIA_Radio_Active,MUIV_TriggerValue);
	DoMethod(MT_Computer,MUIM_Notify,MUIA_Radio_Active,MUIV_EveryTime,CY_Computer,3,MUIM_Set,MUIA_Cycle_Active,MUIV_TriggerValue);
	DoMethod(MT_Printer ,MUIM_Notify,MUIA_Radio_Active,MUIV_EveryTime,CY_Printer ,3,MUIM_Set,MUIA_Cycle_Active,MUIV_TriggerValue);
	DoMethod(MT_Display ,MUIM_Notify,MUIA_Radio_Active,MUIV_EveryTime,CY_Display ,3,MUIM_Set,MUIA_Cycle_Active,MUIV_TriggerValue);
	DoMethod(MT_Computer,MUIM_Notify,MUIA_Radio_Active,MUIV_EveryTime,LV_Computer,3,MUIM_Set,MUIA_List_Active ,MUIV_TriggerValue);
	DoMethod(LV_Computer,MUIM_Notify,MUIA_List_Active ,MUIV_EveryTime,MT_Computer,3,MUIM_Set,MUIA_Radio_Active,MUIV_TriggerValue);


/*
** This one makes us receive input ids from several list views.
*/

	DoMethod(LV_Volumes ,MUIM_Notify,MUIA_Listview_DoubleClick,TRUE,AP_Demo,2,MUIM_Application_ReturnID,ID_NEWVOL);
	DoMethod(LV_Brian   ,MUIM_Notify,MUIA_List_Active,MUIV_EveryTime,AP_Demo,2,MUIM_Application_ReturnID,ID_NEWBRI);


/*
** Now lets set the TAB cycle chain for some of our windows.
*/

	DoMethod(WI_Master   ,MUIM_Window_SetCycleChain,BT_Groups,BT_Frames,BT_Backfill,BT_Notify,BT_Listviews,BT_Cycle,BT_Images,BT_String,NULL);
	DoMethod(WI_Listviews,MUIM_Window_SetCycleChain,LV_Directory,LV_Volumes,NULL);
	DoMethod(WI_Cycle    ,MUIM_Window_SetCycleChain,MT_Computer,MT_Printer,MT_Display,CY_Computer,CY_Printer,CY_Display,LV_Computer,NULL);
	DoMethod(WI_String   ,MUIM_Window_SetCycleChain,ST_Brian,NULL);


/*
** Set some start values for certain objects.
*/

	DoMethod(LV_Computer,MUIM_List_Insert,CYA_Computer,-1,MUIV_List_Insert_Bottom);
	DoMethod(LV_Brian   ,MUIM_List_Insert,LVT_Brian,-1,MUIV_List_Insert_Bottom);
	set(LV_Computer,MUIA_List_Active,0);
	set(LV_Brian   ,MUIA_List_Active,0);
	set(ST_Brian   ,MUIA_String_AttachedList,LV_Brian);


/*
** Everything's ready, lets launch the application. We will
** open the master window now.
*/

	set(WI_Master,MUIA_Window_Open,TRUE);


/*
** This is the main loop. As you can see, it does just nothing.
** Everything is handled by MUI, no work for the programmer.
**
** The only thing we do here is to react on a double click
** in the volume list (which causes an ID_NEWVOL) by setting
** a new directory name for the directory list. If you want
** to see a real file requester with MUI, wait for the
** next release of MFR :-)
*/

	{
		ULONG signal;
		BOOL running = TRUE;
		char *buf;

		while (running)
		{
			switch (DoMethod(AP_Demo,MUIM_Application_Input,&signal))
			{
				case MUIV_Application_ReturnID_Quit:
					running = FALSE;
					break;

				case ID_NEWVOL:
					DoMethod(LV_Volumes,MUIM_List_GetEntry,MUIV_List_GetEntry_Active,&buf);
					set(LV_Directory,MUIA_Dirlist_Directory,buf);
					break;

				case ID_NEWBRI:
					get(LV_Brian,MUIA_List_Active,&buf);
					set(ST_Brian,MUIA_String_Contents,LVT_Brian[(int)buf]);
					break;

				case ID_ABOUT:
					MUI_Request(AP_Demo, WI_Master, 0, NULL, "OK", "MUI-Demo\n© 1992-95 by Stefan Stuntz");
					break;
			}
			if (running && signal) Wait(signal);
		}
	}



/*
** Call the fail function in demos.h, this will dispose the
** application object and close "muimaster.library".
*/

	fail(AP_Demo,NULL);
}


/*
** This is the end...
*/
