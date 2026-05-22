#ifndef	WIZARD_WIZARDSTRING_H
#define	WIZARD_WIZARDSTRING_H

#include	<exec/tasks.h>

struct WizardStringInfo
{
	struct TextFont			*DefFont;
	struct Hook					*DefHook;
	struct IBox					 Dimension;
	struct RastPort			 CalcRPort;

	UBYTE		Translation[256];
	UWORD		(*LineWidth)[];
	UWORD		LineHeight;

	ULONG		TextLen;

	UBYTE		*Buffer;
	UBYTE		*Undo;
	UBYTE		*Paste;

	ULONG		BufferSize;
	ULONG		UndoSize;
	ULONG		PasteSize;

	UWORD		TabPixel;
	UWORD		Justification;

	UWORD		Lines;
	UWORD		MaxLines;

	LONG		TextTop;
	LONG		TextLeft;
	ULONG		TextWidth;
	ULONG		TextHeight;

	struct
	{
		WORD	pos;
		WORD	line;
	}Mark;

	struct
	{
		WORD	pos;
		WORD	line;
	}Cursor;

	struct
	{
		UWORD	BGPen;
		UWORD	TextPen;
		UWORD SBGPen;
		UWORD STextPen;
		UWORD	CBGPen;
		UWORD	CTextPen;
	}
	PenArray;

	UWORD	Flags;
	UWORD	HookFlags;

	ULONG	Seconds;
	ULONG	Micros;

	UWORD	DefMode;
	UWORD	Reserved;

	LONG	Value;
	LONG	MinVal;
	LONG	MaxVal;

};

#define	WINTEGERMODE_DEZ		0
#define	WINTEGERMODE_BIN		1
#define	WINTEGERMODE_HEX		2

#define	WSTRINGFLAG_ACTIVE	1
#define	WSTRINGFLAG_MOUSE		2
#define	WSTRINGFLAG_KEYMARK	4

// Hook-Methoden, die öffentlich sind *******************************

/********************************************************************
**                                                                 **
** Bei einer unbekannten Methode, ist diese an das Object zurück   **
** zu geben. Dabei muß der Returnwert weitergegeben werden.        **
**                                                                 **
** Private Hooks, die den Standard-Hook nicht ersetzen wollen,     **
** müssen unbekannte Methoden an den Standard-Hook zurückgeben.    **
** Die Adresse des Standardhooks finden Sie im UserData des neu    **
** installierten Hooks. Ermitteln Sie diesen immer aufs Neue !     **
**                                                                 **
** Achtung: In Zukunft werden neue Methoden definiert, so das der  **
** Standardhook IMMER berücksichtgt werden muß !
**                                                                 **
********************************************************************/

#define	WSTRINGM_DUMMY					0x100200
#define	WSTRINGM_INIT					WSTRINGM_DUMMY+0
#define	WSTRINGM_GET					WSTRINGM_DUMMY+1
#define	WSTRINGM_SET					WSTRINGM_DUMMY+2
#define	WSTRINGM_INITTEXT				WSTRINGM_DUMMY+3
#define	WSTRINGM_CALCULATEGLYPH		WSTRINGM_DUMMY+4
#define	WSTRINGM_RENDERLINE			WSTRINGM_DUMMY+5
#define	WSTRINGM_GOACTIVE				WSTRINGM_DUMMY+6
#define	WSTRINGM_GOINACTIVE			WSTRINGM_DUMMY+7
#define	WSTRINGM_HANDLEINPUT			WSTRINGM_DUMMY+8
#define	WSTRINGM_TEXTFIT				WSTRINGM_DUMMY+9
#define	WSTRINGM_POINTVISIBLE		WSTRINGM_DUMMY+10
#define	WSTRINGM_INSTALLCLIP			WSTRINGM_DUMMY+11
#define	WSTRINGM_UNINSTALLCLIP		WSTRINGM_DUMMY+12
#define	WSTRINGM_RENDERROWS			WSTRINGM_DUMMY+13
#define	WSTRINGM_MAKEVISIBLE			WSTRINGM_DUMMY+15
#define	WSTRINGM_UPDATE				WSTRINGM_DUMMY+16
#define	WSTRINGM_SETMARK				WSTRINGM_DUMMY+17
#define	WSTRINGM_SETCURSOR			WSTRINGM_DUMMY+18
#define	WSTRINGM_TEXTLEFT				WSTRINGM_DUMMY+19
#define	WSTRINGM_TEXTTOP				WSTRINGM_DUMMY+20
#define	WSTRINGM_MOVECURSOR			WSTRINGM_DUMMY+21
#define	WSTRINGM_INSERTSTRING		WSTRINGM_DUMMY+22
#define	WSTRINGM_COPYBUFFER			WSTRINGM_DUMMY+23
#define	WSTRINGM_INITLINEUNDO		WSTRINGM_DUMMY+24
#define	WSTRINGM_ARROWSTEP			WSTRINGM_DUMMY+25

/********************************************************************
**                                                                 **
** WSTRINGM_INIT:                                                  **
**                                                                 **
** Returnwert soll immer TRUE sein.                                **
**                                                                 **
** Wenn der Hook diese Methode nicht behandelt, dann kann er Sie   **
** ignorieren. In AttrList stehen die Tags, die bei OM_NEW über-   **
** geben wurden. Dieses Funktion dient zum Vorinitialisieren der   **
** StringInfo-Struktur.                                            **
**                                                                 **
********************************************************************/

struct WizardStringInit
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspi_StringInfo;
	struct TagItem				*wspi_AttrList;
	APTR							 wspi_InstData;
};

/********************************************************************
**                                                                 **
** WSTRINGM_GET:                                                   **
**                                                                 **
** Returnwert ist wie bei OM_GET.                                  **
**                                                                 **
** Wenn der Hook diese Methode nicht behandlet, dann kann er Sie   **
** an das Object zurück schicken. Wobei dieses dann diese Methode  **
** behandelt.                                                      **
**                                                                 **
** Möchte der Hook dagegen diese Methode behandeln, dann muß er    **
** Sie an das Object mit der Superklasse weiterleiten, aber mit    **
** der Methode OM_GET und der Struktur opGet !!!                   **
**                                                                 **
********************************************************************/

struct WizardStringGet
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspg_StringInfo;
	struct IClass				*wspg_Class;
	ULONG							 wspg_AttrID;
	ULONG							 wspg_Storage;
};

/********************************************************************
**                                                                 **
** WSTRINGM_SET:                                                   **
**                                                                 **
** Returnwert ist wie bei OM_SET.                                  **
**                                                                 **
** Wenn der Hook diese Methode nicht behandlet, dann kann er Sie   **
** an das Object zurück schicken. Wobei dieses dann diese Methode  **
** behandelt.                                                      **
**                                                                 **
** Möchte der Hook dagegen diese Methode behandeln, dann muß er    **
** Sie an das Object mit der Superklasse weiterleiten, aber mit    **
** der Methoder OM_SET und der Struktur opSet !!!                  **
**                                                                 **
********************************************************************/

struct WizardStringSet
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wsps_StringInfo;
	struct GadgetInfo			*wsps_GInfo;
	struct IClass				*wsps_Class;
	struct TagItem				*wsps_AttrList;
	ULONG							 wsps_Redraw;
};

/********************************************************************
**                                                                 **
** WSTRINGM_INITTEXT:                                              **
**                                                                 **
** Returnwert ist undefiniert, behandelt der Hook diese Methode,   **
** dann muß er nicht an das Object weitergegeben werden !          **
**                                                                 **
** Diese Methode wird von der Standard Set-Methode ausgelösst und  **
** dient dem Berechnen der Dimension des gesamten Textes.          **
**                                                                 **
** Die Textaddresse steht dabei in StringInfo->buffer.             **
** Dabei muß TextWidth, TextHeight und Lines eingetragen werden.   **
** Der RastPort ist temporär und darf nur für Berechnungen wie     **
** TextLength() oder ähnliches benutzt werden,er wurde mit         **
** InitRastPort() vorinitialisiert.                                **
**                                                                 **
** Setzen Sie bitte StringInfo->Lines auf die Anzahl der Zeilen.   **
**                                                                 **
********************************************************************/

struct WizardStringInitText
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspit_StringInfo;
};

/********************************************************************
**                                                                 **
** WSTRINGM_CALCULATEGLYPH:                                        **
**                                                                 **
** Diese Methode dient dem Ausrechnen der Position und Breite des  **
** angegebenen Zeichens. Möchten Sie die Breite der gesamten Zeile **
** wissen, dann sollten Sie in LeftEdge eine NULL eingeben und als **
** Position des zu berechnenden Zeichens die Länge der Zeile.      **
**                                                                 **
********************************************************************/

struct WizardStringCalculateGlyph
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspcg_StringInfo;
	UWORD							 wspcg_Char;
	UWORD							 wspcg_LeftEdge;
	UBYTE							*wspcg_Address;
	UWORD							*wspcg_GlyphLeftEdge;
	UWORD							*wspcg_GlyphWidth;
};

/********************************************************************
**                                                                 **
** WSTRINGM_RENDERLINE:                                            **
**                                                                 **
** Returnwert ist undefiniert, behandelt der Hook diese Methode,   **
** dann muß er nicht an das Object zurückgegeben werden !          **
**                                                                 **
** Dabei muß der Hook die Darstellung dieser einen Zeile über-     **
** nehmen. Die StringInfo-Struktur darf nur gelesen werden !       **
** Der RastPort ist mit einer gültigen Clipping-Region versehen    **
** MinX und MaxX sollen ihnen helfen Elemente bereits ein wenig    **
** vorzuclippen, so das das Zeichnen selbst sehr schnell geht.     **
**                                                                 **
********************************************************************/

struct WizardStringRenderLine
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wsprl_StringInfo;
	struct DrawInfo	 		*wsprl_DrInfo;
	struct RastPort			*wsprl_RPort;
	char							*wsprl_Address;
	ULONG							 wsprl_Line;
	ULONG							 wsprl_Cursor;
	ULONG							 wsprl_MarkBegin;
	ULONG							 wsprl_MarkEnd;
	LONG							 wsprl_LeftEdge;
	LONG							 wsprl_TopEdge;
	LONG							 wsprl_MinX; // ClipGrenzen
	LONG							 wsprl_MaxX; // ClipGrenzen
};

/********************************************************************
**                                                                 **
** WSTRINGM_TEXTFIT:                                               **
**                                                                 **
** Errechnet die Anzahl der Zeichen, die in den angegebenene Ab-   **
** schnitt passen und gibt die Breite zurück.                      **
**                                                                 **
** Der Returnwert ist die Anzahl der Zeichen, die passen.          **
**                                                                 **
********************************************************************/

struct WizardStringTextFit
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wsptf_StringInfo;
	UBYTE						 	*wsptf_Address;
	ULONG							 wsptf_LeftEdge;
	ULONG							 wsptf_MaxWidth;
	UWORD							*wsptf_TextWidth;
};

/********************************************************************
**                                                                 **
** WSTRINGM_POINTVISIBLE:                                          **
**                                                                 **
** Diese Methode darf vom Hook an das Object weitergegeben werden, **
** um zu erfahren, ob die Mouse innerhalb des Objektes ist, dabei  **
** wird die umgebenden Clippingregion berücksichtigt (Fenster-     **
** ränder etc.).                                                   **
**                                                                 **
** Der Returnwert ist TRUE, wenn er sichtbar ist,alos zum Object   **
** gehört. Die Angaben müssen absolut sein !!!                     **
**                                                                 **
********************************************************************/

struct WizardStringPointVisible
{
	ULONG					 		MethodID;
	struct
	{
		LONG	X;
		LONG	Y;
	}								 wsppv_Mouse;
};

/********************************************************************
**                                                                 **
** WSTRINGM_GOACTIVE:                                              **
** WSTRINGM_HANDLEINPUT:                                           **
**                                                                 **
** Der Returnwert ist identisch mit den entsprechenden Methoden    **
** des BOOPSI-Systems.                                             **
**                                                                 **
** Diese Methoden müssen vom Hook behandlet werden, da Sie das     **
** spezifische Verhalten eines String ausmachen. Um die Node unter **
** der Mouse in Erfahrung zu bringen können Sie von hier aus die   **
** Methode WSTRINGM_MOUSEITEM an das Object senden. Dadurch können **
** Sie sich einige Arbeit sparen.                                  **
**                                                                 **
********************************************************************/


struct WizardStringInput
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspi_StringInfo;
	struct GadgetInfo 		*wspi_GInfo;
	struct InputEvent			*wspi_IEvent;
	struct
	{
		LONG	X;
		LONG	Y;
	}								 wspi_Mouse;
};

/********************************************************************
**                                                                 **
** WSTRINGM_GOINACTIVE:                                            **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
** Diese Methode muß vom Hook behandlet werden.                    **
**                                                                 **
********************************************************************/

struct WizardStringInActive
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspia_StringInfo;
	struct GadgetInfo 		*wspia_GInfo;
	ULONG							 wspia_Abort;
};


/********************************************************************
**                                                                 **
** WSTRINGM_INSTALLCLIP:                                           **
**                                                                 **
** Der Returnwert ist FALSE, wenn ein Fehler aufgetreten ist.      **
** Sollte dies der Fall sein, dann wurde die Clippingregion NICHT  **
** installiert ! Das Clipprectangle wird mit dem umgebenden Clip-  **
** rectangle logisch verknüpft.                                    **
**                                                                 **
********************************************************************/

struct WizardStringInstallClip
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspic_StringInfo;
	struct GadgetInfo			*wspic_GInfo;
	struct RastPort			*wspic_RPort;
	struct Region			  **wspic_OldRegion;
	struct Rectangle			*wspic_ClipRectangle;
};

/********************************************************************
**                                                                 **
** WSTRINGM_UNINSTALLCLIP:                                         **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringUnInstallClip
{
	ULONG					 		MethodID;
	struct GadgetInfo			*wspuic_GInfo;
	struct RastPort			*wspuic_RPort;
	struct Region				*wspuic_OldRegion;
};

/********************************************************************
**                                                                 **
** WSTRINGM_MAKEVISIBLE:                                           **
**                                                                 **
** Beauftragt das Object das angegebene Char voll sichtbar zu      **
** machen. Dabei prüft das Object, ob der Char überhaupt in den    **
** sichtbaren Bereich gebracht werden muß.                         **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringMakeVisible
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspmv_StringInfo;
	struct GadgetInfo			*wspmv_GInfo;
	ULONG							 wspmv_Line;
	ULONG							 wspmv_Pos;
};

/********************************************************************
**                                                                 **
** WSTRINGM_UPDATE:                                                **
**                                                                 **
** Beauftragt das Object den angegebene Bereich neu zu zeichnen,   **
** außerdem wird das vertikale Linkobject mit neuen Listendaten    **
** versorgt.                                                       **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringUpdate
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspu_StringInfo;
	struct GadgetInfo			*wspu_GInfo;
	struct RastPort			*wspu_RPort;
	LONG							 wspu_MinX;
	LONG							 wspu_MaxX;
	LONG							 wspu_MinY;
	LONG							 wspu_MaxY;
};

/********************************************************************
**                                                                 **
** WSTRINGM_RENDERROWS:                                            **
**                                                                 **
** Beauftragt das Object die angegebenen Zeilen neu darzustellen,  **
** dabei muß in Count die Anzahl der zusätzlichen Zeilen stehen,   **
** welche ebenfalls noch dargestellt werden soll.                  **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringRenderRows
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wsprr_StringInfo;
	struct DrawInfo			*wsprr_DrInfo;
	struct RastPort			*wsprr_RPort;
	UBYTE							*wsprr_Address;
	ULONG							 wsprr_Line;
	ULONG							 wsprr_Count;
};

/********************************************************************
**                                                                 **
** WSTRINGM_SETMARK:                                               **
**                                                                 **
** Beauftragt das Object die Methoder durchzuführen, dabei werden  **
** alle notwendigen Änderungen am Schirm durchgeführt.             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringSetMark
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspsm_StringInfo;
	struct GadgetInfo			*wspsm_GInfo;
	struct RastPort			*wspsm_RPort;
	ULONG							 wspsm_Line;
	ULONG							 wspsm_Pos;
};

/********************************************************************
**                                                                 **
** WSTRINGM_SETCURSOR:                                             **
**                                                                 **
** Beauftragt das Object die Methoder durchzuführen, dabei werden  **
** alle notwendigen Änderungen am Schirm durchgeführt.             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringSetCursor
{
	ULONG					 		MethodID;
	struct WizardStringInfo	*wspsc_StringInfo;
	struct GadgetInfo			*wspsc_GInfo;
	struct RastPort			*wspsc_RPort;
	ULONG							 wspsc_Line;
	ULONG							 wspsc_Pos;
};

/********************************************************************
**                                                                 **
** WSTRINGM_TEXTLEFT:                                              **
**                                                                 **
** Beauftragt das Object die Methode durchzuführen, dabei werden   **
** alle notwendigen Änderungen am Schirm durchgeführt. Eventuelle  **
** Link-Objekte werden berücksichtigt.                             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringTextLeft
{
	ULONG					 		MethodID;
	ULONG							 wsptl_TextLeft;
	struct GadgetInfo			*wsptl_GInfo;
};

/********************************************************************
**                                                                 **
** WSTRINGM_TEXTTOP:                                               **
**                                                                 **
** Beauftragt das Object die Methode durchzuführen, dabei werden   **
** alle notwendigen Änderungen am Schirm durchgeführt. Eventuelle  **
** Link-Objekte werden berücksichtigt.                             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringTextTop
{
	ULONG					 		MethodID;
	ULONG							 wsptt_TextTop;
	struct GadgetInfo			*wsptt_GInfo;
};

/********************************************************************
**                                                                 **
** WSTRINGM_MOVECURSOR:                                            **
**                                                                 **
** Beauftragt das Object die Marke und den Cursor zu setzten und   **
** alle notwendigen Änderungen am Schirm durchgeführt. Dabei wird  **
** gleichzeitig die Sichtbarkeit des Cursors gecheckt.             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringMoveCursor
{
	ULONG					 		MethodID;
	struct WizardStringInfo *wspmc_StringInfo;
	struct GadgetInfo			*wspmc_GInfo;
	ULONG							 wspmc_Line;
	ULONG							 wspmc_Pos;
};

/********************************************************************
**                                                                 **
** WSTRINGM_INSERTSTRING:                                          **
**                                                                 **
** Beauftragt das Object die Marke und den Cursor zu setzten und   **
** alle notwendigen Änderungen am Schirm durchgeführt. Dabei wird  **
** gleichzeitig die Sichtbarkeit des Cursors gecheckt.             **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringInsertString
{
	ULONG					 		MethodID;
	struct WizardStringInfo *wspis_StringInfo;
	struct GadgetInfo			*wspis_GInfo;
	UBYTE							*wspis_InsertString;
	UBYTE							*wspis_CutBuffer;
	ULONG							 wspis_CutBufferSize;
};

/********************************************************************
**                                                                 **
** WSTRINGM_COPYBUFFER:                                            **
**                                                                 **
** Beauftragt das Object den markierten Bereich in den angegebenen **
** Buffer zu kopieren. Eine Änderung am Schirm erfolgt nicht !     **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringCopyBuffer
{
	ULONG					 		MethodID;
	struct WizardStringInfo *wspcb_StringInfo;
	UBYTE							*wspcb_Buffer;
	ULONG							 wspcb_BufferSize;
};

/********************************************************************
**                                                                 **
** WSTRINGM_INITLINEUNDO:                                          **
**                                                                 **
** Beauftragt das Object die angegebene Zeile in den Undo-Buffer   **
** der StringInfo-Struktur zu kopieren. Später kann man diesen     **
** wieder in diese Zeile einfügen lassen.                          **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardStringInitLineUndo
{
	ULONG					 		MethodID;
	struct WizardStringInfo *wspilu_StringInfo;
};

/********************************************************************
**                                                                 **
** WSTRINGM_ARROWSTEP:                                             **
**                                                                 **
** Returnwert ist undefiniert.                                     **
**                                                                 **
** Wenn der Hook diese Methode nicht behandelt, dann kann er Sie   **
** ignorieren. In AttrList stehen die Tags, die bei OM_NEW über-   **
** geben wurden. Dieses Funktion dient zum Vorinitialisieren der   **
** StringInfo-Struktur.                                            **
**                                                                 **
********************************************************************/

struct WizardStringArrowStep
{
	ULONG MethodID;
	struct WizardStringInfo	*wspas_StringInfo;
	struct GadgetInfo			*wspas_GInfo;
	ULONG							 wspas_Type;
	ULONG							 wspas_Step;
};

#endif /* WIZARD_WIZARDVIEW_H */
