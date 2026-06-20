/** DoRev Header ** Do not edit! **
*
* Name             :  DropBox.h
* Copyright        :  Copyright 1993 Steve Anichini. All Rights Reserved.
* Creation date    :  11-Jun-93
* Translator       :  SAS/C 5.1b
*
* Date       Rev  Author               Comment
* ---------  ---  -------------------  ----------------------------------------
* 21-Jun-93    3  Steve Anichini       Added support for underscore in gadgets.
* 21-Jun-93    2  Steve Anichini       First Release.
* 12-Jun-93    1  Steve Anichini       Beta Release 1.0
* 11-Jun-93    0  Steve Anichini       None.
*
*** DoRev End **/


#ifndef DROPBOX
#define DROPBOX

/* Defines */

/* Lowest Revision supported */
#define DEF_LOWEST_REV 37

/* Used for AppEvents */
#define APPICON 0
#define APPMENU 1
 
/* Strings */
#define NAME string[0]
#define TITLE string[1]
#define DESC  string[2]

#define ABOUT string[3]
#define TEXTFORMAT string[4]
#define GADGETFORMAT string[5]

#define NEW	string[6]
#define NEWTEXTFORMAT string[7]
#define NEWGADGETFORMAT string[8]

#define SAFE string[9]
#define SAFETEXTFORMAT string[10]
#define SAFEGADGETFORMAT string[11]

#define ENTRY string[12]
#define ENTRYTEXTFORMAT string[13]
#define ENTRYGADGETFORMAT string[14]

#define FILEHAIL string[15]
#define FILEPREF string[16]
#define DIRPREF  string[17]
#define PATPREF  string[18]

/* Stuff for commodities */
#define THEHOTKEY string[19]
#define EVT_HOTKEY 0x01

/* Stuff for parsing the commands */
#define COM	string[20]
#define SOURCE string[21]
#define DEST1	string[22]
#define SOURCEDIR	string[23]
#define SOURCEFILE	string[24]

#define IOTITLE	string[25]

/* Node types */
#define NT_DBNODE	256
#define NT_PATNODE 257

/* Number of gadgets with key shortcuts */
#define GLU_NUM 2

/* Error Codes */
#define NO_ERROR 			0x0000
#define NO_ICONLIB			0x0001
#define NO_WORKLIB			0x0002
#define NO_GFXLIB			0x0003
#define NO_INTUILIB		0x0004
#define NO_ICON			0x0005
#define NO_PORT			0x0006
#define NO_APPICON			0x0007
#define NO_APPITEM			0x0008
#define NO_CXLIB			0x0009
#define NO_BROKER			0x000A
#define NO_FILTER			0x000B
#define NO_SENDER 			0x000C
#define NO_GADLIB			0x000D
#define NO_UTILLIB			0x000E
#define NO_DATABASE		0x000F
#define NO_WINDOW			0x0010
#define NO_IFFLIB			0x0011
#define NO_FILE			0x0012
#define NO_DIR				0x0013
#define NO_FILEREQ			0x0014
#define NO_ASLLIB			0x0015
#define NO_MEM				0x0016
#define STAGS_FAIL			0x0017
#define NO_MEMFILE			0x0018
#define PT_BADTOKEN		0x0019
#define PT_COMUNKNOWN		0x001a
#define NO_CREATEDIR		0x001b

/* Special Errors (Non Fatal) */
#define ASLCANCEL				-1


/* Database Flags */
#define DFLG_NOFLAG			0x0000
#define DFLG_SUPINPUT			0x0001
#define DFLG_SUPOUTPUT			0x0002
#define DFLG_CREATE			0x0004

/* Pattern Flags */
#define PFLG_NOFLAG			0x0000

/* General Preferences flags */
#define GPRF_VERSION 1

#define GFLG_NONE   	0x0000
#define GFLG_SAVEICON 	0x0001
#define GFLG_CHECKCOM	0x0002
#define GFLG_SELECTWIN 0x0004

/* String Lengths */
#define DEFLEN 256
#define PATLEN 10
#define DESTLEN 128
#define COMLEN 128
#define TEMPLEN 128

struct DBNode
{
	struct Node db_Nd;
	char db_Name[30],
			db_Pat[PATLEN],/* Ignored */
			db_Dest[DESTLEN],
			db_Com[COMLEN],
			db_Template[TEMPLEN];
	ULONG db_Flags;
	struct List *db_Pats;
};

struct PatNode
{
	struct Node pat_Nd;
	char pat_Str[PATLEN];
	ULONG pat_Flags;
	ULONG pat_Reserved;
};

struct AlertMessage 
{
	WORD LeftEdge;
	BYTE TopEdge;
	char AlertText[60];
	BYTE Flag;
};

struct GadLookUp
{
	UBYTE *gl_Key;
	UWORD gl_Gad;
};

struct GenPref
{
	ULONG gp_Version;
	ULONG gp_Nodes; /* ignored in version 1 of file */
	ULONG gp_Flags;
	WORD gp_IOLeft, gp_IOTop;
	WORD gp_IOWidth, gp_IOHeight;
	ULONG reserved[3];
};

extern struct List *DataBase;
extern struct Library *SysBase;
extern char *error[];
extern char *string[];
extern struct Image logoimage;
extern struct GadLookUp glu[];
extern struct DBNode *curnode;
extern struct DBNode *Clip;
extern BOOL FirstSave, end_flag, modified;
extern ULONG winsigflag;
extern struct GenPref MainPrefs;

/* External Functions */
extern void leave(ULONG );

extern void InitDB();

/* Macro for now */
#define CleanDB() (CleanList(DataBase))

extern struct List *MyNewList(ULONG);
extern void CleanList(struct List *);
extern struct Node *NewNode(ULONG);
extern void FreeNode(struct Node *);

/* A Macro for now */
#define AddNode(x,l)  (AddTail((l),(x)))

extern void InsertNode(struct Node *, struct Node *,struct List *);
extern struct Node *RemoveNode(struct Node *, struct List *);
extern void FillDBNode(struct DBNode *, char *, char *, char *, 
				char *, ULONG,struct List *);
extern void FillPatNode(struct PatNode *, char *, ULONG);
extern struct List *FindDBNode(char *);
extern ULONG CreateCommand(struct DBNode *, struct WBArg *, char *);
extern struct Node *OrdToPtr(UWORD,struct List *);
extern UWORD PtrToOrd(struct Node *, struct List *);
extern ULONG CountNodes(struct List *);
extern ULONG Sort(struct List **);

extern ULONG SavePrefs(char *);
extern ULONG LoadPrefs(char *);
extern ULONG FileRequest(char *, char *, char *, BOOL, BOOL);
extern void PrefIO(BOOL);
extern ULONG JustSave();
extern ULONG JustLoad();
extern void InitIO(char *, char *, char *);
extern void GetDest(char *);
extern void GetCom(char *);

extern void DisplayErr(ULONG);
extern void UpdateGadgets();
extern void UpdateDB();
extern int  ShowWindow();
extern void HideWindow();
extern void Select(struct DBNode *);
extern void HandleIntuiMsg();
extern void CleanWindow(struct Window *);
extern BOOL Safe(struct Window *);

extern struct MenuItem *GetItem(struct Menu *, UWORD, UWORD);

/* Macros */
#define IsEmpty(x) (((x)->lh_TailPred) == ((struct Node *)(x)))

#define FindGad(gad) (DropBoxGadgets[(gad)])

/* For CHECKIT menuitems */
#define IsChecked(item) (((item)->Flags) & CHECKED)

/* For any type of toggled flag */
#define ToggleFlag(flag, which) ((flag)&(which))?((flag)&(~(which))):((flag)|(which))
 
/* For getting the status of CHECKIT menuitems */
/* Returns the correct state of flag */
#define StatusCheck(item, oflag, flag) (IsChecked((item))?((oflag)|(flag)):((oflag)&(~(flag))))

/* Max and Min */
#define max(a,b) (((a)>(b))?(a):(b))
#define min(a,b) (((a)<(b))?(a):(b))

#endif

