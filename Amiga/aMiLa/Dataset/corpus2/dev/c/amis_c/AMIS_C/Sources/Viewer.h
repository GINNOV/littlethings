/*
	AMIS Include for Viewers. (V1.03)

	In this file you almost everything you need to create you own viewer.
	This file is still under development, see later versions for a more
	complete documentation.
*/

struct LineInfo
{
	short	li_length;				/* Don't change this !! */
	short	li_height;				/* For more information see the Viewer
											structure. */
	long	li_viewerdata;			/* This is for you... */
	long	li_viewerdata2;		/* and so is this... */
};

struct EditWin
{
	long	wn_next;
	long	wn_prev;
	char	wn_type;
	char	wn_pri;
	long	wn_name;
	struct Window	*wn_base;
	struct RastPort	*wn_rast;
	long	wn_gadget;
	short	wn_innerwidth;
	short	wn_innerheight;
	short	wn_left;
	short	wn_top;

	long	*ed_memlist;
	long	*ed_project;
	struct Font	*ed_font;
	struct Viewer	*ed_display;
	long	ed_bookmarks[10];
	long	ed_viewerdata;					/* This is for you  */
	long	ed_moreviewerdata[16];		/* and so is this   */
	long	ed_viewervar[10];				/* and some more    */
	long	ed_viewerobj;					/* and this one too */
	char	ed_flags;
	char	ed_flags2;
	char	ed_flags3;
	char	ed_flags4;
	char	ed_flags5;
	char	ed_flags6;
	char	ed_protectflags;
	char	ed_moreflags;
	long	ed_clip;
	short	ed_tabsize;
	long	ed_winchars;
	long	ed_winlines;
	short	ed_top_offset;
	short	ed_pl_y_offset;
	short	ed_pl_own_height;
	long	ed_pl_total_y;
	short	ed_bordertop;
	short	ed_first_y;
	short	ed_last_y;
	long	ed_visible_y;
	long	ed_topline;
	long	ed_topline_tick;
	long	ed_leftchar;
	long	ed_lines;
	long	ed_chars;
	long	ed_line;
	long	ed_oldtopline;
	long	ed_oldtoppos;
	struct LineInfo	*ed_linesinfo;
	char	*ed_buffer;							/* the text of this file */
	long	ed_bufsize;
	long	ed_bufpos;
	char	*ed_linebuf;						/* this lines text */
	char	*ed_linebuf_backup;
	long	ed_linebuflast;
	long	ed_oldlinelength;
	long	ed_char;
	long	ed_winpos;
	long	ed_cursoffset;
	short	ed_curs_px1;
	short	ed_curs_py1;
	short	ed_curs_px2;
	short	ed_curs_py2;
	short	ed_buttonwidth;
	void	*ed_buttonlist;
	long	ed_slidertopline;
	long	ed_sliderlines;
	short	ed_slidersize;
	long	ed_startpos;
	long	ed_endpos;
	long	ed_last_startpos;
	long	ed_last_endpos;
	long	ed_oldline;
	long	ed_oldchar;
	long	ed_mouseline;
	long	ed_mousechar;
	long	ed_mousepos;
	long	ed_blocktemp1;
	long	ed_blocktemp2;
	long	ed_blocktemp3;
	long	ed_blocktemp4;
	long	ed_subpos;
	short	ed_viewerbar_y;
	long	ed_removefunc;
	short	ed_statusbar_y;
	short	ed_codebar_y;
	short	ed_freebar;
	long	ed_title_msg;
	short	ed_tm_time;
	long	ed_timerioreq;
	short	ed_lineheight;

	char	ed_path[144];
	char	ed_filename[144];
	char	ed_name[144];
	char	ed_screenname[100];
	char	ed_comment[80];

/* PRIVATE !! */

	long	ed_tmprastport;
	long	ed_tmplayer;
	long	ed_tmpbitmap;
	long	ed_layerinfo;

	struct List	ed_linelist;
};

struct Viewer
{
	struct Node		vw_node;				/* Fill in the name and set ln_type to
													the version of AMIS this viewer was
													made for. (See Versions below). */
	long	vw_loadseg;						/* Set to zero! */

/*
	With the next three options you can tell AMIS for which files this viewer
	should be used. Note that the file must have all three before it will be
	recognized. You can set starttext and typicaltext to zero if neccessery.
*/

	char	*vw_filepattern;				/* filepattern, e.g. "#?" */
	char	*vw_starttext;					/* first text in file, e.g. "@database"*/
	char	*vw_typicaltext;				/* some text somewhere in every file of
													your type, e.g. "@node" */

	void	(*vw_switchfunction)();		/* function to be called after every
													switch to this viewer */

	char	vw_flags1;						/* flags for you, see below */
	char	vw_flags2;						/* AMIS private flags ! */

	long	(*vw_display)();				/* the display function it self */
	void	(*vw_newpos)();				/* function to be called every time the
													cursor is moved */
	void	(*vw_getwinpos)();			/* return winpos when char is given */
	void	(*vw_getchar)();				/* return char when winpos is given */
	void	(*vw_codebar)();				/* return text to be displayed in
													codebar */

/*
	With the following three options you can change the height of the text
	lines. First textheights is multiplied by the height of the selected font
	and then topspacing and bottomspacing are added. The result is the height
	of a line on the screen (in pixels).

	If you wish to give different lines different heights you can add an
	offset in the second word of the linesinfo structure of every line. In
	must cases you will then set the following three options to zero and set
	the whole line height in the linesinfo structure.
*/
	short	vw_textheights;
	short	vw_topspacing;
	short	vw_bottomspacing;

	char	vw_bg_color;					/* color to use for unused window
													space */
	char	vw_planes;						/* number of bitplanes to be
													cleared/scrolled */
/*
	The next variable is used to reserve some space in the window for the
	viewerbar. The two functions behind it are called every time the
	viewerbar should be drawn and removed (free memory etc., you don't have
	to remove the actual graphics).
*/
	short	vw_barheight;
	void	(*vw_viewerbar)();
	void	(*vw_remove_vb)();

/*
	The next two functions can be used to replace the normal cursright and
	cursleft functions. You can use this the jump the cursor over text
	commands or other places the cursor shouldn't be. Beware that when the
	cursor is in the codebar the normal functions will always be used!
*/
	void	(*vw_cursright)();
	void	(*vw_cursleft)();

/*
	In vw_font you MUST pass an opened font you wish to you use for
	displaying your text. If you wish to use the default font simply copy the
	font passed to you in the AMIS structure.
*/
	struct Font *vw_font;

/*
	The next function is used for breaking lines. When this function is
	called you should return the VISIBLE part of the line that is passed to
	you. This means you should filter out everything that will not appear on
	the screen. AMIS will check this line for spaces to break a line. If
	there are spaces on the screen where the line should be broken you sould
	set an '_' in the line you give back instead of a ' '. This way you have
	complete control over where lines may and may not be broken.
*/
	void	(*vw_plaintext)();

/*
	The next option will be used to make it possible to define different
	functions for keys in different viewers. This isn't completely working
	yet and for now it is best to point to an empty list (you may also pass a
	zero if you wish).
*/
	struct List	*vw_keyslist;

/*
	The next two functions are called every time a file is loaded / saved or
	the user switches to this viewer or an other viewer. You may use these
	functions to filter out text that should not be displayed or something
	like that. Please not that the savefilter should set back all this
	information, otherwise some text might 'get lost' without the user
	knowing about it (not very user friendly, don't you think ?).
*/
	void	(*vw_loadfilter)();
	void	(*vw_savefilter)();

/*
	The next function is the unload function wish will be called when AMIS is
	quiting. This function allows you to free recources, close fonts, free
	images, etc.
*/
	void	(*vw_unload)();

/*
	The next option is a pointer to the text you want to be displayed in the
	viewer info requester. Lines can be seperated with a '|' sign.
*/
	char	*vw_infotext;

/*
	The next function should set all your variables to there initial state.
	(As if a new window was opened without any text in it.)
*/
	void	(*vw_clear)();

/*
	The next function will be called after the AMIS screen is opened (bootup
	and UnIconify).
*/
	void	(*vw_openscreen)();

/*
	The next function will be called when the AMIS screen is close (quiting
	and Iconify).
*/
	void	(*vw_closescreen)();

/*
	The next function is called every time the cursor is drawn, return 1 if
	you rendered the cursor yourself, 0 otherwise.
*/
	long	(*vw_drawcurs)();

/*
	The next function called when the user tries to insert a character on a
	writeprotected line. Return 1 if it may be inserted, 0 otherwise.
*/
	void	(*vw_checkprotection)();

/*
	The next function is called when the user gives a Fold command.
	If you want to support folding you should set your fold function here.
*/
	void	(*vw_fold)();

/*
	The next function is called when the user gives a UnFold command.
	If you want to support folding you should set your unfold function here.
*/
	void	(*vw_unfold)();

/*
	The next function is called when the user gives a Fold TOGGLE command.
	If you want to support folding you should set your fold toggle function
	here.
*/
	void	(*vw_togglefold)();
/*
	The next function is called when the user asks for the viewer
	preferences.
*/
	void	(*vw_preferences)();
/*
	The next function is called instead of the display function when
	initializing.
*/
	void	(*vw_init)();
/*
	The next option is the same as the vw_keyslist field, only this one is
	used for smart-indent defenitions.
*/
	struct List	*vw_indslist;
};

/*
	Versions of AMIS that can be given in the ln_type field of the viewer
	structure.
*/

#define AMIS_0_97		0
#define AMIS_0_98		1		/* also has a vw_clear field. */
#define AMIS_0_99		2		/* also has vw_openscreen and vw_closescreen
										fields. */
#define AMIS_1_00		3		/* also has vw_drawcurs, vw_checkprotection,
										vw_fold, vw_unfold and vw_togglefold fields.
										*/
#define AMIS_1_01		4
#define AMIS_1_02		5		/* also has a vw_init field */
#define AMIS_1_03		6		/* also has a vw_indslist fields */

struct AMIS
{
	struct IntuitionBase	*AMIS_IntuitionBase;
	struct GfxBase			*AMIS_GfxBase;
	struct Library			*AMIS_GadToolsBase;
	struct Library			*AMIS_DatatypesBase;
	struct Library			*AMIS_DiskfontBase;
	struct Screen			*AMIS_ScreenBase;
	long						*AMIS_VisualInfo;
	struct DisplayInfo	*AMIS_DisplayInfo;
	struct ColorMap		*AMIS_ColorMap;
	char						*AMIS_Flags;
	struct Font				*AMIS_Normal_Font;		/* the default text font */
	char						*AMIS_PrintBuf;
	struct Catalog			*AMIS_Catalog;
	struct MsgPort			*AMIS_MsgPort;
	struct Library			*AMIS_AMISLibBase;
	struct DosLibrary		*AMIS_DOSBase;
	char						*AMIS_RunTimeFlags;
	struct IClass			*AMIS_PaletteClass;
};

#define EFLG_CHANGED		0
#define EFLG_LCHANGED	1
#define EFLG_CURS			2
#define EFLG_CURSMODE	3
#define EFLG_FLASHCURS	4
#define EFLG_HIDE			5
#define EFLG_PLUSSIGN	6
#define EFLG_UNTITLED	7

#define EFLG2_MOUSE		0
#define EFLG2_UP			1
#define EFLG2_DOWN		2
#define EFLG2_SELECTED	3
#define EFLG2_SELSTART	4
#define EFLG2_SELEND		5
#define EFLG2_MOUSESEL	6

#define EFLG3_MOUSEUP	0
#define EFLG3_MOUSEDOWN	1
#define EFLG3_PROTECT	2
#define EFLG3_MODECHNG	3
#define EFLG3_ICONIFIED	4
#define EFLG3_CODECURS	5
#define EFLG3_NOUPDATE	6
#define EFLG3_REVERT		7

#define EFLG4_RESIZED	0
#define EFLG4_TOOLBAR	1
#define EFLG4_VIEWERBAR	2
#define EFLG4_STATUSBAR	3
#define EFLG4_CODEBAR	4
#define EFLG4_OVERWRITE	5
#define EFLG4_LOCKED		6
#define EFLG4_ARRANGING	7

#define EFLG5_WORDWRAP	0
#define EFLG5_ANSIBOLD	1
#define EFLG5_NEWFONT	2
#define EFLG5_SMALLCURS	3
#define EFLG5_NOGETWINP	4
#define EFLG5_FASTMODE	5
#define EFLG5_AUTOLINE	6
#define EFLG5_VERTICAL	7

#define EFLG6_DRAGNDROP	0
#define EFLG6_LINEPROT	1

/* Some settings flags */

#define BACKUP_FLAG1		0
#define ICONS_FLAG1		1
#define FLASH_FLAG1		2
#define AUTOIND_FLAG1	3
#define TOOLBAR_FLAG1	4
#define VIEWERBAR_FLAG1	5
#define STATUSBAR_FLAG1	6
#define CODEBAR_FLAG1	7

#define CURSWRAP_FLAG2	0
#define FASTMODE_FLAG2	1
#define AUTOLINE_FLAG2	2
#define ANSISHINE_FLAG2	3
#define DRAGNDROP_FLAG2	4
#define NUMERIC_FLAG2	5

/*global flags for all files */

#define QUIT_FLAG3		0
#define VISIT_FLAG3		1
#define ICONIFIED_FLAG3	2
#define REDO_FLAG3		3
#define JOINUNDO_FLAG3	4
#define CUTBLOCK_FLAG3	5
#define ENDICON_FLAG3	6
#define REDRAW_FLAG3		7

#define CURSLINE_FLAG4	0
#define CURSDONE_FLAG4	1
#define CLOSEFONT_FLAG4	2
#define PRIVATE_FLAG4	3
#define ASKPRJ_FLAG4		4
#define MACRO_FLAG4		5
#define MACRO2_FLAG4		6
#define DEFAULT_FLAG4	7

#define MACROKEY_FLAG5	0
#define NOPRINT_FLAG5	1
#define SETTINGS_FLAG5	2
#define SETLBUF_FLAG5	3
#define REDRAWING_FLAG5	4
#define CANCEL_FLAG5		5
#define NO_ANSWER_FLAG5	6
#define INIT_FLAG5		7

#define BARLABEL_FLAG6	0
#define SUBITEMS_FLAG6	1
#define INIT_CHNG_FLAG6	2
#define COLORS_FLAG6		3
#define NEWPREFS_FLAG6	4
#define MENU_CHNG_FLAG6	5
#define ANSI_UPD_FLAG6	6
#define DRAWDONE_FLAG6	7

#define NOSLIDER_FLAG7	0
#define BOOTUP_FLAG7		1
#define SRCPASTE_FLAG7	2

#define VFLG1_TOTAL_Y	0
#define VFLG1_TEMP		1		/* Use a temporary rastport (this prevent
											blinking graphics, it works the same as a
											double buffered screen). */
#define VFLG1_INIT		2		/* Use initializing routine for this viewer */
#define VFLG1_CHAR_STAT	3		/* Use ed_char instead of ed_winpos in
											statusbar */
#define VFLG1_PROP		4		/* No fixed with font. */
#define VFLG1_PRINTINIT	5		/* use the display function for initializing.
											(or vw_init if available) */

#define VFLG2_ST_CASE	0
#define VFLG2_PRIVATE2	6
#define VFLG2_PRIVATE	7

#define LINEDATA			12


#pragma libcall ViewerLib InternalCommand			6	801
#pragma libcall ViewerLib CursLeft					c	0
#pragma libcall ViewerLib CursRight					12	0
#pragma libcall ViewerLib GetWinPos					18	0
#pragma libcall ViewerLib GetImage					1e	0
#pragma libcall ViewerLib LoadImage					24	0
#pragma libcall ViewerLib SetViewervar				2a	0
#pragma libcall ViewerLib SetViewervar2			30	0
#pragma libcall ViewerLib WordWrapSaveFilter		36	0
#pragma libcall ViewerLib CursUp						3c	0
#pragma libcall ViewerLib CursDown					42	0
#pragma libcall ViewerLib CursSOL					48	0
#pragma libcall ViewerLib DoReturn					4e	0
#pragma libcall ViewerLib NewViewerbar				54	0
#pragma libcall ViewerLib BuiltRequester			5a	9802
#pragma libcall ViewerLib ShowRequester			60	801
#pragma libcall ViewerLib CloseRequester			66	801
#pragma libcall ViewerLib FreeRequester			6c	801
#pragma libcall ViewerLib FileRequester			72	0
#pragma libcall ViewerLib GetYPos					78	0
#pragma libcall ViewerLib AddLineNode				7e	0
#pragma libcall ViewerLib GetLineNode				84	0
#pragma libcall ViewerLib ClearList					8a 801
#pragma libcall ViewerLib GetChar					90 0
#pragma libcall ViewerLib ImageSize					96 0
#pragma libcall ViewerLib ImageBitMap				9c 0
#pragma libcall ViewerLib StoreCursorPosition	a2 0
#pragma libcall ViewerLib RecallCursorPosition	a8	0
#pragma libcall ViewerLib SetLineBuf				ae	0
#pragma libcall ViewerLib RedrawViewerWindows	b4	801

#pragma libcall AMISLibBase GetListview		48 9802

ULONG GetListview(struct Gadget *listview,struct Window *window);

char *InternalCommand(char *command);

ULONG CursLeft(void);
ULONG CursRight(void);
ULONG CursUp(void);
ULONG CursDown(void);
ULONG CursSOL(void);
ULONG CursEOL(void);

void GetWinPos(void);

ULONG DoReturn(void);

void SetViewervar(long var, char *text);
void SetViewervar2(long var, char *text);

struct Object *Get_image(char *filename);
struct Object *Load_image(char *filename);

void WordWrapSaveFilter(void);

void NewViewerBar(void);

struct AMIS_Requester *BuiltRequester(struct AMIS_ReqDef *req, struct TagList *tags);
void ShowRequester(struct AMIS_Requester *req);
void CloseRequester(struct AMIS_Requester *req);
void FreeRequester(struct AMIS_Requester *req);

long GetYPos(void);

struct Node *AddLineNode(long size, long line, long character);
struct Node *GetLineNode(long line, long character);

void RedrawViewerWindows(struct Viewer *viewer);

struct AMIS_ReqDef {
	short	x;
	short	y;
	short	width;
	short height;
	short t1;
	short t2;
	short t3;
	char	*title;
};

#define AM_Screen				TAG_USER
#define AM_Locale				TAG_USER+1

#define AM_Gadgets			TAG_USER+2

#define AM_Button				TAG_USER+3
#define AM_CheckMark			TAG_USER+4
#define AM_Cycle				TAG_USER+5
#define AM_Listview			TAG_USER+6
#define AM_Slider				TAG_USER+7
#define AM_Integer			TAG_USER+8
#define AM_GNumber			TAG_USER+9
#define AM_String				TAG_USER+10
#define AM_GText				TAG_USER+11
#define AM_IText				TAG_USER+12
#define AM_BackLine			TAG_USER+13
#define AM_BackBox			TAG_USER+14
#define AM_UserGadget		TAG_USER+15

#define AM_SameWidth			TAG_USER+16
#define AM_SameLeft			TAG_USER+17
#define AM_Code				TAG_USER+18

#define AM_MessagePort		TAG_USER+19

#define AM_EscFunction		TAG_USER+20
#define AM_Return_Button	TAG_USER+21
#define AM_CloseFunction	TAG_USER+22

#define AM_MaxFontHeight	TAG_USER+23

#define AM_UpdateNumbers	TAG_USER+24
#define AM_UpdateTexts		TAG_USER+25

#define AM_LocaleOffset		TAG_USER+26

struct AMIS_Button {
	short	left;
	short	top;
	short width;
	short height;
	char	*name;
	struct Gadget	*gadget;
	char	type;
	char	locale;
	void	(*handler)();
};

struct AMIS_GText {
	short	left;
	short	top;
	short width;
	short height;
	char	*name;
	struct Gadget	*gadget;
	char	type;
	char	locale;
	char	*text;
	void	(*handler)();
};

struct AMIS_CheckMark {
	short	left;
	short	top;
	short width;
	short height;
	char	*name;
	struct Gadget	*gadget;
	char	type;
	char	locale;
	char	*variable;
	char	undo;
	char	mask;
	void	(*handler)();
};

struct AMIS_Backbox {
	short	left;
	short	top;
	short width;
	short height;
};

struct AMIS_Listview {
	short	left;
	short	top;
	short width;
	short height;
	char	*name;
	struct Gadget	*gadget;
	char	type;
	char	locale;
	struct List	*list;
	short	readonly;
	short	spacing;
	void	(*handler)();
	void	(*double_click)();
	void	(*hook)();
	struct Gadget	*string;
};

struct AMIS_Requester {
	struct Window	*ar_window;
	struct Screen 	*iw_screen;
	char				ar_type;
	char				ar_pad;
	long				ar_vinfo;
	struct MsgPort	*ar_msgport;
	struct Gadget	*ar_gadgetlist;
	struct Gadget  *ar_usergadgets;
	struct Gadget	*ar_gadgets;
	struct Gadget	*ar_gtexts;
	struct Gadget	*ar_gnumbers;
	long				*ar_interstruct;
	char				*ar_AMISLib_id;
	void				(*ar_esc_function)();
	void				(*ar_return_button)();
	void				(*ar_closefunction)();
	struct Font		*ar_font;
	struct Gadget	*ar_lastgadget;
	long				ar_reserved2;
	long				ar_reserved3;
	long				ar_locale;
	long				ar_localeoffset;
	short				ar_reserved4;
	short				ar_font_height;
	short				ar_top_border;
	struct Gadget	*ar_patterngadget;
	void				*ar_patternobject;
	struct Gadget	*ar_backboxes;
	long				ar_lastnormal;
	long				ar_userdata;
	void				*ar_temptags;
	short				ar_left;
	short				ar_top;
	short				ar_width;
	short				ar_height;
	short				ar_zoomleft;
	short				ar_zoomtop;
	short				ar_zoomed;
	char				*ar_title;
	short				ar_groupwidth;
	short				ar_groupleft;
};

#define PALGA_Color			TAG_USER
#define PALGA_Colors			TAG_USER+1
#define PALGA_ColorTable	TAG_USER+2
#define PALGA_Redraw			TAG_USER+3

#define AM_RELWIDTH		0x8000
#define AM_RELRIGHT		0x8000
#define AM_RELLASTRIGHT	0x1000
#define AM_TEXTLENGTH	0x4000
#define AM_SHAREDWIDTH	0x2000
#define AM_SHAREDLEFT	0x2000
