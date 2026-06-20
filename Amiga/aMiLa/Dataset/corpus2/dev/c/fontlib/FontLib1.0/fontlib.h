//
// FontLib.h
// Version 1.0
//
// FontLib ©1996 Henrik Isaksson
// EMail: henriki@pluggnet.se
// All Rights Reserved.
//
// This library is FreeWare.
// If you plan to use any of theese funtions in commercial software,
// ask me first at the address above.
// I can not be held responsible for any damage or loss of data caused
// by this software. Use it at your own risk.
//
// Questions and suggestions to: henriki@pluggnet.se
//

#ifndef FONTLIB_H
#define FONTLIB_H

//
// Structs
//

typedef struct {
 struct FLFont *Next;	// Next FLFont
 struct FLFont *Prev;	// Previous FLFont
 struct TextAttr ta;	// TextAttr
 struct TextFont *tf;	// TextFont
 UWORD OpenCnt;
} FLFont;

//
// Macros & Defines
//

#define TOPAZ8		"topaz.font",8,0,0
#define TIMES11		"times.font",11,0,0
#define TIMES24		"times.font",24,0,0
#define XEN8		"xen.font",8,0,0
#define XEN11		"xen.font",11,0,0
#define XCOURIER11	"xcourier.font",11,0,0
#define COURIER24	"courier.font",24,0,0
// ^^^ Theese defines does not work with the macros below.

#define TEXTATTR(x,y,z,v)	((FLFont *)FL_LoadFont(x,y,z,v)->ta)
#define TEXTFONT(x,y,z,v)	((FLFont *)FL_LoadFont(x,y,z,v)->tf)
#define SETFONT(rp,x,y,z,v)	SetFont(rp,(struct TextFont *)((FLFont *)FL_LoadFont(x,y,z,v)->tf));
#define SETWFONT(w,x,y,z,v)	SetFont(w->RPort,(struct TextFont *)((FLFont *)FL_LoadFont(x,y,z,v)->tf));
#define SETWDRAW(w,fg,bg,drmd)	SetAPen(w->RPort,fg); SetBPen(w->RPort,bg); SetDrMd(w->RPort,drmd);
#define WTEXT(w,x,y,txt)	Move(w->RPort,x,y+w->RPort->Font->tf_Baseline); Text(w->RPort,txt,strlen(txt));

//
// Protos
//

//
// FL_LoadFont:
//
// Allocates a FLFont structure and tries to open the requested font.
// The arguments will be copied to the TextAttr struct in FLFont.
//
// Returns FLFont or NULL if it fails.
//
FLFont *FL_LoadFont(STRPTR name, UWORD size, UBYTE style, UBYTE flags);

//
// FL_FreeFont:
//
// Deallocates a FLFont structure.
//
void FL_FreeFont(FLFont *flf);

//
// FL_FreeAll:
//
// Deallocates all FLFont structures used by this application.
//
void FL_FreeAll(void);

#endif
