/*

 Viewer       : C.
 Version      : 1.21.
 Date         : 27 March 1997.
 Distribution : freeware.
 Author(s)    : Willem Mestrom & Vincent Groenewold.

 Comment      : This is the complete source code of the C-Source viewer. It
                may be useful when you want to create your own viewer. Most
                of the important options of AMIS are used so you can see
                how it all works.

*/

#include <exec/types.h>
#include <clib/graphics_protos.h>
#include "viewer.h"

long __saveds __asm Display(register __a0 char *text,
										register __a1 char *buf,
										register __d0 long length,
										register __a5 struct EditWin *editwin);
void __saveds __asm Init(register __a0 char *text,
									register __a1 char *buf,
									register __d0 long length,
									register __a5 struct EditWin *editwin);
void __saveds SwitchFunc(void);
void MyPrint(struct EditWin *editwin,char *text,long length,long color);

void __saveds screen_opens(void);
void __saveds screen_closes(void);

long __saveds __asm drawcurs(register __d0 long x1,
										register __d1 long y1,
										register __d2 long x2,
										register __d3 long y2,
										register __a5 struct EditWin *editwin);

void __saveds Quit(void);

void __saveds Preferences(void);
void __saveds ClosePrefs(void);
void __saveds LoadPrefs(void);
void __saveds SavePrefs(void);

void __saveds listselect(void);
void __saveds change_bold(void);
void __saveds change_italic(void);
void __saveds change_underline(void);
void __saveds change_color(void);

void DrawNewCurs(struct EditWin *editwin,long c,char *line,
						long x1,long y1,long x2,long y2);

void __saveds __asm make_palgg(register __a5 struct AMIS_Requester *req);
void __saveds __asm layout_buttons(register __a5 struct AMIS_Requester *req);

void __stdargs _XCEXIT(long);

struct List C_keylist;
struct List C_indlist;
struct List C_keylist = {
	(struct Node *)((char *)&C_keylist+4),
	0,
	(struct Node *)&C_keylist
};
struct List C_indlist = {
	(struct Node *)((char *)&C_indlist+4),
	0,
	(struct Node *)&C_indlist
};

struct GfxBase *GfxBase;
struct Library *GadToolsBase;
struct AMIS *AMIS;
struct AMIS *ViewerLib;
struct Library *AMISLibBase;
struct DosLibrary *DOSBase;
struct IntuitionBase *IntuitionBase;

struct AMIS_Requester *req;

struct AMIS_ReqDef prefs_req={-1,25,392,12*256+27,0,0,0,
	"C-Source settings..."};

struct List symbol_list;

struct Node symbol_nodes[10] = {
	{
		&symbol_nodes[1],
		(struct Node *)&symbol_list,
		1,0,
		"Normal text"
	},
	{
		&symbol_nodes[2],
		&symbol_nodes[0],
		2,0,
		"ANSI C/C++ Comment"
	},
	{
		&symbol_nodes[3],
		&symbol_nodes[1],
		4,0,
		"Single quoted text"
	},
	{
		&symbol_nodes[4],
		&symbol_nodes[2],
		3,0,
		"Double quoted text"
	},
	{
		&symbol_nodes[5],
		&symbol_nodes[3],
		8,0,
		"{ and }"
	},
	{
		&symbol_nodes[6],
		&symbol_nodes[4],
		9,0,
		". and ->"
	},
	{
		&symbol_nodes[7],
		&symbol_nodes[5],
		6,0,
		"ANSI C keywords"
	},
	{
		&symbol_nodes[8],
		&symbol_nodes[6],
		5,0,
		"ANSI C symbols"
	},
	{
		&symbol_nodes[9],
		&symbol_nodes[7],
		7,0,
		"Preprocessor commands"
	},
	{
		(struct Node *)(((long)&symbol_list)+4),
		&symbol_nodes[8],
		10,0,
		"User dictionary 1"
	}	
};

struct List symbol_list = {
	&symbol_nodes[0],
	0,
	&symbol_nodes[9]
};

char bold_flag=0,italic_flag=0,underline_flag=0;

struct AMIS_Button prefs_ok =
	{8,11*256+19,100,1*256+6,"_Ok",0,BUTTON_KIND,
	   -1,ClosePrefs};

struct AMIS_Button prefs_load =
	{8,11*256+19,100,1*256+6,"_Load",0,BUTTON_KIND,
	   -2,LoadPrefs};

struct AMIS_Button prefs_save =
	{8,11*256+19,100,1*256+6,"_Save",0,BUTTON_KIND,
	   -3,SavePrefs};

struct AMIS_CheckMark prefs_bold =
	{222,1*256+10,26,1*256+3,"_Bold",0,CHECKBOX_KIND,
	   2,&bold_flag,0,FSF_BOLD,change_bold};

struct AMIS_CheckMark prefs_italic =
	{222,2*256+13,26,1*256+3,"_Italic",0,CHECKBOX_KIND,
	   3,&italic_flag,0,FSF_ITALIC,change_italic};

struct AMIS_CheckMark prefs_underline =
	{222,3*256+16,26,1*256+3,"_Underline",0,CHECKBOX_KIND,
	   4,&underline_flag,0,FSF_UNDERLINED,change_underline};

struct AMIS_Listview prefs_list =
	{14,1*256+10,200,10*256+4,"_Symbols",0,LISTVIEW_KIND,
	   1,&symbol_list,0,0,listselect,0,0,0};

struct AMIS_GText prefs_pal =
	{222,4*256+21,164,1*256+6,"",0,TEXT_KIND,
	   5,0,change_color};

struct AMIS_Backbox prefs_backbox =
	{8,2,384,11*256+15};

ULONG prefs_gadgets[]={
	AM_Listview,(ULONG)&prefs_list,
	AM_GText,(ULONG)&prefs_pal,
	AM_Code,(ULONG)make_palgg,
	AM_UserGadget,0,
	AM_CheckMark,(ULONG)&prefs_bold,
	AM_CheckMark,(ULONG)&prefs_italic,
	AM_CheckMark,(ULONG)&prefs_underline,
	AM_SameWidth,0x00500003,
	AM_Code,(ULONG)layout_buttons,
	AM_Button,(ULONG)&prefs_ok,
	AM_Button,(ULONG)&prefs_load,
	AM_Button,(ULONG)&prefs_save,
	AM_BackBox,(ULONG)&prefs_backbox,
	TAG_END
};

ULONG prefs_tags[]={
	AM_Screen,0,
	AM_MessagePort,0,
	AM_Gadgets,(ULONG)&prefs_gadgets[0],
	AM_EscFunction,(ULONG)ClosePrefs,
	AM_LocaleOffset,0x100000,
	TAG_END
};

struct Gadget *dummy_gg;

#define	COLORS		11

/*
	color 1:  normal text
	color 2:  comment
	color 3:  double-quoted text ("text")
	color 4:  single-quoted text ('text')
	color 5:  c/c++ symbols
	color 6:  c/c++ keywords
	color 7:  preprocessor keywords (example: #include)
	color 8:  '{' and '}'
	color 9:  '->' and '.'
	color 10: User dictionary 1
*/

struct color {
	long	color;
	char	flags;
	char	dummy;
};

struct color colorlist[COLORS] = {
	{0,0},{1,0},{2,0},{2,0},{3,0},{3,FSF_BOLD},{2,0},{1,0},{3,0},{7,0},{2,0}
};

#define	KEYWORDS		96

char *keywordlist[KEYWORDS]={
	"struct",		/* C/C++ symbols */
	"char",
	"int",
	"short",
	"long",
	"float",
	"double",
	"unsigned",
	"void",
	"Object",
	"VOID",
	"BOOL",
	"FLOAT",
	"DOUBLE",
	"TEXT",
	"BYTE",
	"UBYTE",
	"BYTEBITS",
	"BYTEMASK",
	"WORD",
	"UWORD",
	"WORDBITS",
	"LONG",
	"ULONG",
	"LONGBITS",
	"SHORT",
	"USHORT",
	"COUNT",
	"UCOUNT",
	"APTR",
	"BPTR",
	"CPTR",
	"RPTR",
	"STRPTR",
	"TRUE",
	"FALSE",
	"__saveds",
	"__stdargs",
	"__asm",
	"register",
	"__d0",
	"__d1",
	"__d2",
	"__d3",
	"__d4",
	"__d5",
	"__d6",
	"__d7",
	"__a0",
	"__a1",
	"__a2",
	"__a3",
	"__a4",
	"__a5",
	"__a6",
	"__a7",
	"__fp0",
	"__fp1",
	"__fp2",
	"__fp3",
	"__fp4",
	"__fp5",
	"__fp6",
	"__fp7",
	"GLOBAL",
	"IMPORT",
	"STATIC",
	"REGISTER",
	"typedef",
	"auto",
	"continue",
	"do",
	"enum",
	"extern",
	"sizeof",
	"static",
	"union"
	"class",
	"delete",
	"friend",
	"inline",
	"new",
	"operator",
	"overload",
	"public",
	"this",
	"virtual",	/* nr. 86 */

	"if",
	"else",
	"switch",
	"case",
	"default",
	"break",
	"while",
	"for",
	"return",
	"goto",		/* nr. 96 */
};

struct Viewer C_Viewer={
	0,0,								/* must be zero */
	AMIS_1_03,						/* the version of AMIS which you need at least
											to use this viewer */
	0,									/* must be zero */
	"C-Source",						/* name of the viewer */
	0,									/* must be zero */
	"(#?.c|#?.h|#?.cpp|#?.cxx|#?.c++)",
										/* pattern of files to view with this viewer */
	0,									/* no special text at the start of a file */
	0,									/* no special text in file to recognize it */
	0,									/* no switch function */
	(1<<VFLG1_INIT)+(1<<VFLG1_PRINTINIT),0,
										/* flags */
	Display,							/* the display function */
	0,0,0,0,							/* standard control functions */
	1,0,0,0,7,0,					/* normal lines */
	0,0,0,0,0,0,					/* standard control functions */
	&C_keylist,						/* special keylist */
	0,0,								/* standard control functions */
	Quit,
	"C-Source viewer v1.21||Written by Willem Mestrom & Vincent Groenewold.",
	0,
	screen_opens,
	screen_closes,
	drawcurs,
	0,0,0,0,
	Preferences,
	Init,
	&C_indlist						/* special indlist */
};

long leftoffset,printed,init=0;

struct List dict_list;

struct Word {
	struct Node	w_node;
	char	w_buf[40];
};

struct List dict_list = {
	(struct Node *)(((long)&dict_list)+4),
	0,
	(struct Node *)&dict_list
};

struct Word *lw;

struct Viewer __saveds __asm *InitViewer(register __a0 struct AMIS *NewAMIS)
{
	long pf,c,i;
	struct Word *nw;
	char *wb;

	AMIS=NewAMIS;
	ViewerLib=AMIS;
	AMISLibBase=AMIS->AMIS_AMISLibBase;
	C_Viewer.vw_font=AMIS->AMIS_Normal_Font;
	GfxBase=AMIS->AMIS_GfxBase;
	GadToolsBase=AMIS->AMIS_GadToolsBase;
	DOSBase=AMIS->AMIS_DOSBase;
	IntuitionBase=AMIS->AMIS_IntuitionBase;
	prefs_tags[3]=(ULONG)AMIS->AMIS_MsgPort;
	pf=Open("PROGDIR:Viewers/Prefs/C-Viewer.dic",MODE_OLDFILE);
	if(pf!=0)
	{
		while((c=FGetC(pf))!=-1)
		{
			if(nw=(struct Word *)AllocVec(sizeof(struct Word),MEMF_CLEAR))
			{
			   AddTail(&dict_list,(struct Node *)nw);
				wb=nw->w_buf;
				nw->w_node.ln_Name=wb;
				i=0;
				while((c>32)&&(c<128)&&(i<38))
				{
				   wb[i++]=c;
				   c=FGetC(pf);
				}
				wb[i]=0;
				while((c!=10)&&(c!=-1))
					c=FGetC(pf);
				if(c==-1)
					UnGetC(pf,c);
			}
			else
				UnGetC(pf,-1);
		}
		Close(pf);
	}
	nw=(struct Word *)dict_list.lh_Head;
	while((nw->w_node.ln_Succ!=0)&&(nw->w_node.ln_Name[0]<'a'))
		nw=(struct Word *)nw->w_node.ln_Succ;
	lw=nw;
	LoadPrefs();
	return(&C_Viewer);
}

void __saveds screen_opens()
{
	prefs_tags[1]=(ULONG)AMIS->AMIS_ScreenBase;
}

void __saveds screen_closes()
{
   struct Gadget *tg;
	if(req!=0)
	{
		tg=prefs_list.gadget->NextGadget;
		prefs_list.gadget=dummy_gg;
		dummy_gg->NextGadget=tg;
		FreeRequester(req);
		DisposeObject((APTR)prefs_gadgets[7]);
	}
	req=0;
}

/*		Example of using internal commands inside your own viewer
		To activate this function just add it to the C_Viewer structure.

void __saveds SwitchFunc()
{
	AMIS_InternalCommand("Request BODY=\"test\"");
}

*/

void __saveds Quit()
{
	struct Node *dw,*nw;
	dw=dict_list.lh_Head;
	while(dw->ln_Succ!=0)
	{
		nw=dw;
		dw=dw->ln_Succ;
		FreeVec(nw);
	}
}

void __saveds __asm Init(register __a0 char *text,
									register __a1 char *buf,
									register __d0 long length,
									register __a5 struct EditWin *editwin)
{
   init=1;
   Display(text,buf,length,editwin);
   init=0;
}

long __saveds __asm Display(register __a0 char *text,
										register __a1 char *buf,
										register __d0 long length,
										register __a5 struct EditWin *editwin)
{
	long	bufsign=0,charnum=0,tab,temp3,color;
	char	sign,cppcomment=0;
	int	i,j;
	struct Node *dw;
	char	*dtw;

	leftoffset=-(editwin->ed_leftchar);
	printed=0;

	color=editwin->ed_linesinfo[editwin->ed_line].li_viewerdata;
	color=(color==0 ? 1 : color);

	SetAPen(editwin->wn_rast,1);
	SetBPen(editwin->wn_rast,0);

	if((color==1)&&(text[0]=='#'))
	{
		buf[bufsign++]='#'; charnum++;
		while((charnum<length)&&(text[charnum]!=' ')&&(text[charnum]!=9))
			buf[bufsign++]=text[charnum++];
		MyPrint(editwin,buf,bufsign,7);
		bufsign=0;
	}

	tab=(long)editwin->ed_tabsize;
	if(tab==0) tab=8;
	while(charnum<length)
	{
		sign=text[charnum-1];temp3=-1;i=0;
		if(((color==1)&&((charnum==0)||(
				(sign<'0')||
				((sign>'9')&&(sign<'A'))||
				((sign>'Z')&&(sign<'a'))||
				(sign>'z'))&&
				(sign!='_')))&&(init==0))
		{
			i=-1;
			while((i<KEYWORDS-1)&&(temp3==-1))
			{
				j=0; i++;
				while((text[charnum+j]==keywordlist[i][j])&&(j>=0))
				{
					j++; sign=text[charnum+j];
					if((keywordlist[i][j]==0)&&(
							(sign<'0')||
							((sign>'9')&&(sign<'A'))||
							((sign>'Z')&&(sign<'a'))||
							(sign>'z'))&&
							(sign!='_'))
						temp3=i;
				}
			}
			if(temp3==-1)
			{
			   i=0;
				if(text[charnum]>='A')
				{
					i=0;dw=dict_list.lh_Head;
					sign=text[charnum];
					if(sign>='a')
						dw=(struct Node *)lw;
					while((dw->ln_Succ!=0)&&(dw->ln_Name[0]<sign))
						dw=dw->ln_Succ;
					while((dw->ln_Succ!=0)&&(i==0))
					{
						dtw=dw->ln_Name;
						while((dtw[i]==text[charnum+i])&&(dtw[i]!=0))
							i++;
						sign=text[charnum+i];
						if((dtw[i]!=0)||
							((sign>47)&&(sign<58))||
							((sign>63)&&(sign<91))||
							((sign>96)&&(sign<123))||
							(sign==95))
						{
							if(dtw[i]>sign)
								i=-1;
							else
							{
								dw=dw->ln_Succ;
								i=0;
							}
						}
					}
				}
				if(i>0)
				{
					MyPrint(editwin,buf,bufsign,color);bufsign=0;
					MyPrint(editwin,&text[charnum],i,10);
					charnum+=i;
				}
				else
					i=0;
			}
			else
		   {
				MyPrint(editwin,buf,bufsign,color);bufsign=0;
				MyPrint(editwin,keywordlist[i],j,(temp3<86 ? 5 : 6));
				charnum+=j;i=1;
			}
		}
		if(i==0)
		{
			sign=text[charnum];
			if((sign=='/')&&(text[charnum+1]=='/')&&((color==1)||(color==7)))
			{
				MyPrint(editwin,buf,bufsign,color);
				color=2; bufsign=0; cppcomment=1;
			}
			if(((sign=='*')&&(text[charnum+1]=='/')&&(color==2))||
				((sign=='"')&&(color==3))||
				((sign=='\'')&&((text[charnum-1]!='\\')||
				((text[charnum-1]=='\\')&&(text[charnum-2]=='\\')))&&(color==4)))
			{
				if(sign=='*')
				{
					buf[bufsign]='*'; buf[bufsign+1]='/';
					MyPrint(editwin,buf,bufsign+2,color);
					color=1; bufsign=0; charnum+=2;
				}
				else
				{
					if(sign=='"')
					{
				   	if(text[charnum-1]!='\\')
				   	{
							buf[bufsign]='"';
							MyPrint(editwin,buf,bufsign+1,color);
							color=1; bufsign=0; charnum++;
						}
						else
						{
							buf[bufsign++]='"';
							charnum++;
						}
					}
					else
					{
						buf[bufsign]='\'';
						MyPrint(editwin,buf,bufsign+1,color);
						color=1; bufsign=0; charnum++;
					}
				}
			}
			else
			{
				if(((sign=='{')||(sign=='}'))&&(color==1))
				{
					MyPrint(editwin,buf,bufsign,color);
					bufsign=0; charnum++;
					MyPrint(editwin,&sign,1,8);
				}
				else
				{
					if((((sign=='/')&&(text[charnum+1]=='*'))||
							(sign=='"')||(sign=='\''))&&(color==1))
					{
						MyPrint(editwin,buf,bufsign,color);
						if(sign=='/')
						{
							buf[0]='/';buf[1]='*';bufsign=2;
							color=2; charnum+=2;
						}
						else
						{
							if(sign=='"')
							{
								buf[0]='"';bufsign=1;
								color=3; charnum++;
							}
							else
							{
								buf[0]='\'';bufsign=1;
								color=4; charnum++;
							}
						}
					}
					else
					{
						if(((sign=='.')||
							((sign=='-')&&(text[charnum+1]=='>')))&&(color==1))
						{
							MyPrint(editwin,buf,bufsign,color);
							if(sign=='.')
							{
								buf[0]='.';
								bufsign=1;
							}
							else
							{
								buf[0]='-';
								buf[1]='>';
								bufsign=2;
							}
							MyPrint(editwin,buf,bufsign,9);
							charnum+=bufsign; bufsign=0;
						}
						else
						{
							if(sign==9)
							{
								temp3=(bufsign+printed)/tab;
								temp3++;
								temp3*=tab;
								temp3-=(bufsign+printed);
								while(temp3--)
								{
									buf[bufsign]=32;
									bufsign++;
								}
								charnum++;
							}
							else
							{
								buf[bufsign]=sign;
								bufsign++;
								charnum++;
							}
						}
					}
				}
			}
		}
	}

	MyPrint(editwin,buf,bufsign,color);

	if(cppcomment)
		color=0;

	editwin->ed_linesinfo[editwin->ed_line+1].li_viewerdata=(color==2 ? 2 : 1);

	return (-1);
}

void MyPrint(struct EditWin *editwin,char *text,long length,long color)
{
	leftoffset+=length;printed+=length;
	if((leftoffset>0)&&(init==0))
	{
	   if(((editwin->ed_flags5)&(1<<EFLG5_FASTMODE))==0)
	   {
		   SetAPen(editwin->wn_rast,colorlist[color].color);
		   SetSoftStyle(editwin->wn_rast,colorlist[color].flags,-1);
		}
		Text(editwin->wn_rast,text+length-leftoffset,leftoffset);
		leftoffset=0;
	}
}

void __saveds Preferences()
{
   if(!req)
		req=BuiltRequester(&prefs_req,(struct TagList *)&prefs_tags);
	ShowRequester(req);
}

void __saveds ClosePrefs()
{
	CloseRequester(req);
	RedrawViewerWindows(&C_Viewer);
}

void __saveds LoadPrefs(void)
{
	long pf;
	pf=Open("PROGDIR:Viewers/Prefs/C_Viewer.prefs",MODE_OLDFILE);
	Read(pf,&colorlist,COLORS*6);
	Close(pf);
}

void __saveds SavePrefs(void)
{
	long pf;
	if(InternalCommand(
	"Request BODY=\"Preferences will be saved|in Viewers/Prefs/C_Viewer.prefs\" BUTTON=\"_Ok|_Cancel\"")[0]=='1')
	{
		pf=Open("PROGDIR:Viewers/Prefs/C_Viewer.prefs",MODE_NEWFILE);
		Write(pf,&colorlist,COLORS*6);
		Close(pf);
	}
}

void __saveds listselect()
{
	long s=GetListview(prefs_list.gadget,req->ar_window);
	long t=symbol_nodes[s].ln_Type;

	bold_flag=colorlist[t].flags&FSF_BOLD;
	italic_flag=colorlist[t].flags&FSF_ITALIC;
	underline_flag=colorlist[t].flags&FSF_UNDERLINED;
	GT_SetGadgetAttrs(prefs_bold.gadget,req->ar_window,NULL,
		GTCB_Checked,(bold_flag==0 ? 0:1),TAG_DONE);
	GT_SetGadgetAttrs(prefs_italic.gadget,req->ar_window,NULL,
		GTCB_Checked,(italic_flag==0 ? 0:1),TAG_DONE);
	GT_SetGadgetAttrs(prefs_underline.gadget,req->ar_window,NULL,
		GTCB_Checked,(underline_flag==0 ? 0:1),TAG_DONE);
	SetGadgetAttrs((struct Gadget *)prefs_gadgets[7],req->ar_window,NULL,
		PALGA_Color,colorlist[t].color,TAG_DONE);
}

void __saveds change_bold()
{
	long s=GetListview(prefs_list.gadget,req->ar_window);
	long t=symbol_nodes[s].ln_Type;
	colorlist[t].flags=(colorlist[t].flags&(~FSF_BOLD))|bold_flag;
}

void __saveds change_italic()
{
	long s=GetListview(prefs_list.gadget,req->ar_window);
	long t=symbol_nodes[s].ln_Type;
	colorlist[t].flags=(colorlist[t].flags&(~FSF_ITALIC))|italic_flag;
}

void __saveds change_underline()
{
	long s=GetListview(prefs_list.gadget,req->ar_window);
	long t=symbol_nodes[s].ln_Type;
	colorlist[t].flags=(colorlist[t].flags&(~FSF_UNDERLINED))|underline_flag;
}

void __saveds change_color()
{
	long s=GetListview(prefs_list.gadget,req->ar_window);
	long t=symbol_nodes[s].ln_Type;
	colorlist[t].flags=0;
	colorlist[t].color=(long)*((char *)(prefs_gadgets[7]+70));
}

long __saveds __asm drawcurs(register __d0 long x1,
										register __d1 long y1,
										register __d2 long x2,
										register __d3 long y2,
										register __a5 struct EditWin *editwin)
{
	char *linebuf;
	char oc='(',tc;
	long c=editwin->ed_char;
	long cnt=1;
	long l=editwin->ed_line;
	long ll=editwin->ed_linebuflast;
	long ol=1;

	linebuf=editwin->ed_linebuf;
	if((linebuf[c]==')')||(linebuf[c]=='}')||(linebuf[c]==']'))
	{
	   tc=linebuf[c];
	   if(tc=='}')
	   	oc='{';
	   if(tc==']')
	   	oc='[';
		while((l>=0)&&(y1>=editwin->ed_first_y))
		{
			while((--c)>=0)
			{
				if(linebuf[c]==tc)
					cnt++;
				if(linebuf[c]==oc)
					if(--cnt==0)
					{
						DrawNewCurs(editwin,c,linebuf,x1,y1,x2,y2);
						return 0;
					}
			}
			if(ol==1)
			{
				linebuf=editwin->ed_buffer+editwin->ed_bufpos;
				ol=0;
			}
			c=editwin->ed_linesinfo[--l].li_length;
			linebuf-=c;
			y1-=editwin->ed_lineheight;
			y2-=editwin->ed_lineheight;
		}
	}
	else if((linebuf[c]=='(')||(linebuf[c]=='{')||(linebuf[c]=='['))
	{
	   tc=linebuf[c];oc=')';
	   if(tc=='{')
	   	oc='}';
	   if(tc=='[')
	   	oc=']';
		while((l<=editwin->ed_lines)&&(y1<=editwin->ed_last_y))
		{
			while((++c)<ll)
			{
				if(linebuf[c]==tc)
					cnt++;
				if(linebuf[c]==oc)
					if(--cnt==0)
					{
						DrawNewCurs(editwin,c,linebuf,x1,y1,x2,y2);
						return 0;
					}
			}
			if(ol==1)
			{
				linebuf=editwin->ed_buffer+editwin->ed_bufpos+
							editwin->ed_oldlinelength+1;
				ol=0;
			}
			else
				linebuf+=ll;
			ll=editwin->ed_linesinfo[++l].li_length;
			y1+=editwin->ed_lineheight;
			y2+=editwin->ed_lineheight;
			c=-1;
		}
	}
	return 0;
}

void DrawNewCurs(struct EditWin *editwin,long c,char *line,
						long x1,long y1,long x2,long y2)
{
	long om=editwin->wn_rast->Mask;
	long wp=0,cs=0;
	long tab=(long)editwin->ed_tabsize;

	tab=(tab==0 ? 1 : tab);
	while(cs<c)
	{
		if(line[cs++]==9)
			wp=((wp/tab)+1)*tab;
		else
			wp++;
	}
   x2-=x1;
   x1=(wp-editwin->ed_leftchar)*editwin->wn_rast->TxWidth+
   		editwin->ed_cursoffset;
   SetWriteMask(editwin->wn_rast,2);
	RectFill(editwin->wn_rast,x1,y1,x1+x2,y2);
   SetWriteMask(editwin->wn_rast,om);
}

void __saveds __asm make_palgg(register __a5 struct AMIS_Requester *req)
{
	dummy_gg=req->ar_lastgadget;

	prefs_gadgets[7]=(ULONG)NewObject(AMIS->AMIS_PaletteClass,0,
			GA_Left,dummy_gg->LeftEdge,
			GA_Top,(dummy_gg->TopEdge)-(req->ar_top_border),
			GA_Width,dummy_gg->Width,
			GA_Height,dummy_gg->Height,
			GA_ID,0,
			GA_FollowMouse,1,
			GA_Immediate,1,
			GA_RelVerify,1,
			PALGA_Colors,8,
			TAG_END);
	((struct Gadget *)prefs_gadgets[7])->UserData=&(prefs_pal.type);
	prefs_list.gadget->NextGadget=0;
	req->ar_lastgadget=prefs_list.gadget;
}

void __saveds __asm layout_buttons(register __a5 struct AMIS_Requester *req)
{
	long a;
	a=((req->ar_width)-22-3*(req->ar_groupwidth))/2;
	prefs_load.left=(req->ar_groupwidth)+14+a;
	prefs_save.left=2*(req->ar_groupwidth)+14+2*a;
}

void __stdargs _XCEXIT(long l)
{
}
