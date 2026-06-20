#ifndef	WIZARD_WIZARDVIEW_H
#define	WIZARD_WIZARDVIEW_H

/********************************************************************
**                                                                 **
** Diese Include-Datei ist für den Programmierer der spzielle      **
** Fähigkeiten für seine Oberflächen benötigt.                     **
**                                                                 **
**	© 1996 HAAGE & PARTNER Computer GmbH                            **
**	Autor: Thomas Mittelsdorf                                       **
**                                                                 **
** All Rights Reserved                                             **
**                                                                 **
********************************************************************/

struct WizardViewInfo
{
	struct MinList		*List;
	struct TextFont	*DefFont;
	struct Hook			*DefHook;
	struct IBox			 Dimension;

	struct WizardVImage *TreeImage;

	UWORD		TreeImageWidth;
	UWORD		Columns;

	UWORD		MinItemHeight;
	UWORD		ItemBorder;
	UWORD		ItemSpace;			// 1, wenn 3D-Selektierung

	LONG		ListTop;
	LONG		ListLeft;
	ULONG		ListWidth;
	ULONG		ListHeight;

	UWORD		Flags;
	UWORD		HookFlags;

	ULONG		BGPen;

	ULONG		Seconds;
	ULONG		Micros;

	LONG		Selected;
	LONG		OldSelected;

	UWORD		Width[32];			// für Tabellen-Modus

};

// Hook-Methoden, die öffentlich sind *******************************

/********************************************************************
**                                                                 **
** Bei einer unbekannten Methode, ist diese an das Object zurück   **
** zu geben. Dabei muß der Returnwert weitergegeben werden.        **
** In Zukunft werden neue Methoden definiert werden, welche an den **
** Standard-Hook weiter zugeben sind. Sie müssen also in jedem     **
** Fall den Standard-Hook berücksichtigen. Methoden die Ihr priv.  **
** Hook vollständig bearbeitet müssen nicht an den Standard-Hook   **
** weitergeleitet werden. Es empfiehlt sich immer nur einzelne     **
** Bereiche zu erweitern oder zu ersetzen, damit das Verhalten des **
** Dispatcher nicht allzu sehr verändert wird.                     **
**                                                                 **
********************************************************************/

#define	WVIEWM_DUMMY				0x100100
#define	WVIEWM_INIT					WVIEWM_DUMMY+0
#define	WVIEWM_GET					WVIEWM_DUMMY+1
#define	WVIEWM_SET					WVIEWM_DUMMY+2
#define	WVIEWM_INITLIST			WVIEWM_DUMMY+3
#define	WVIEWM_INITNODE			WVIEWM_DUMMY+4
#define	WVIEWM_RENDERNODE			WVIEWM_DUMMY+5
#define	WVIEWM_GOACTIVE			WVIEWM_DUMMY+6
#define	WVIEWM_GOINACTIVE			WVIEWM_DUMMY+7
#define	WVIEWM_HANDLEINPUT		WVIEWM_DUMMY+8
#define	WVIEWM_MOUSEITEM			WVIEWM_DUMMY+9
#define	WVIEWM_POINTVISIBLE		WVIEWM_DUMMY+10
#define	WVIEWM_INSTALLCLIP		WVIEWM_DUMMY+11
#define	WVIEWM_UNINSTALLCLIP		WVIEWM_DUMMY+12
#define	WVIEWM_RENDERRANGE		WVIEWM_DUMMY+13
#define	WVIEWM_GETNODE				WVIEWM_DUMMY+14
#define	WVIEWM_MAKENODEVISIBLE	WVIEWM_DUMMY+15
#define	WVIEWM_UPDATE				WVIEWM_DUMMY+16


/********************************************************************
**                                                                 **
** WVIEWM_INIT:                                                    **
**                                                                 **
** Returnwert soll immer TRUE sein.                                **
**                                                                 **
** Wenn der Hook diese Methode nicht behandelt, dann kann er Sie   **
** ignorieren. In AttrList stehen die Tags, die bei OM_NEW über-   **
** geben wurden. Dieses Funktion dient zum Vorinitialisieren der   **
** ViewInfo-Struktur.                                              **
**                                                                 **
********************************************************************/

struct WizardViewInit
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpi_ViewInfo;
	struct TagItem				*wvpi_AttrList;
	APTR							 wvpi_InstData;
};


/********************************************************************
**                                                                 **
** WVIEWM_INITLIST:                                                **
**                                                                 **
** Returnwert ist undefiniert, behandelt der Hook diese Methode,   **
** dann muß er nicht an das Object weitergegeben werden !          **
**                                                                 **
** Diese Methode wird von der Standard Set-Methode ausgelösst und  **
** dient dem Berechnen der Dimension der gesamten Liste.           **
**                                                                 **
** Die Listaddresse steht dabei in ViewInfo->List !                **
** Dabei muß in alle Nodes Width und Height eingetragen werden.    **
** Die ViewInfo-Struktur muß ebenfalls mit ListWidth und List-     **
** Height korrekt initialisiert werden.                            **
** Der RastPort ist temporär und darf nur für Berechnungen wie     **
** TextLength() oder ähnliches benutzt werden,er wurde mit         **
** InitRastPort() vorinitialisiert.                                **
**                                                                 **
** Setzen Sie bitte ViewInfo->Nodes auf die Anzahl der Nodes.      **
**                                                                 **
********************************************************************/

struct WizardViewInitList
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpil_ViewInfo;
	struct GadgetInfo 		*wvpil_GInfo;
	struct RastPort			*wvpil_RPort;	// speziell für Berechnungen
};

/********************************************************************
**                                                                 **
** WVIEWM_INITNODE:                                                **
**                                                                 **
** Der ReturnWert sollte TRUE, sein wenn sich an den Spalten-      **
** breiten etwas geändert hat. Möchte der Hook den Tabellenmodus   **
** nicht unterstützen, kann er generell FALSE liefern.             **
** Ein TRUE veranlasst das Object das Display zu erneuern.         **
**                                                                 **
** Dabei muß in die Node Width und Height eingetragen werden.      **
** Die ViewInfo-Struktur darf NICHT verändert werden.              **
** Der RastPort ist temporär und darf nur für Berechnungen wie     **
** TextLength() oder ähnliches benutzt werden.                     **
**                                                                 **
********************************************************************/

struct WizardViewInitNode
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpin_ViewInfo;
	struct GadgetInfo 		*wvpin_GInfo;
	struct RastPort			*wvpin_RPort;	// speziell für Berechnungen
	struct ExtWizardNode		*wvpin_Node;
	ULONG							*wvpin_Number; // Nummer der Node oder -1
};

/********************************************************************
**                                                                 **
** WVIEWM_RENDERNODE:                                              **
**                                                                 **
** Returnwert ist undefiniert, behandelt der Hook diese Methode,   **
** dann muß er nicht an das Object zurückgegeben werden !          **
**                                                                 **
** Dabei muß der Hook die Darstellung dieser einen Node über-      **
** nehmen. Die ViewInfo-Struktur darf nur gelesen werden !         **
** Der RastPort ist mit einer gültigen Clipping-Region versehen    **
** MinX und MaxX sollen ihnen helfen Elemente bereits ein wenig    **
** vorzuclippen, so das das Zeichnen selbst sehr schnell geht.     **
**                                                                 **
********************************************************************/

struct WizardViewRenderNode
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvprn_ViewInfo;
	struct GadgetInfo 		*wvprn_GInfo;
	struct RastPort			*wvprn_RPort;
	struct ExtWizardNode		*wvprn_Node;
	ULONG							 wvprn_Number;
	WORD							 wvprn_LeftEdge;
	WORD							 wvprn_TopEdge;
	WORD							 wvprn_MinX; // ClipGrenzen
	WORD							 wvprn_MaxX; // ClipGrenzen
};

/********************************************************************
**                                                                 **
** WVIEWM_MOUSEITEM:                                               **
**                                                                 **
** Diese Methode darf vom Hook an das Object weitergegeben werden, **
** um die Node unter der Mouse in Erfahrung zu bringen !           **
**                                                                 **
** Der Returnwert ist TRUE, wenn eine Node ermittelt werden        **
** konnte, ansonsten FALSE !                                       **
**                                                                 **
********************************************************************/

struct WizardViewMouseItem
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpmi_ViewInfo;
	struct
	{
		WORD	X;
		WORD	Y;
	}								 wvpmi_Mouse;
	struct WizardNode		  **wvpmi_Node;
	WORD							*wvpmi_NodeMouseX;
	WORD							*wvpmi_NodeMouseY;
	ULONG							*wvpmi_NodeNumber;
	UWORD							*wvpmi_NodeVisibleHeight;
};

/********************************************************************
**                                                                 **
** WVIEWM_POINTVISIBLE:                                            **
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

struct WizardViewPointVisible
{
	ULONG					 		MethodID;
	struct
	{
		WORD	X;
		WORD	Y;
	}								 wvppv_Mouse;
};

/********************************************************************
**                                                                 **
** WVIEWM_GOACTIVE:                                                **
** WVIEWM_HANDLEINPUT:                                             **
**                                                                 **
** Der Returnwert ist identisch mit den entsprechenden Methoden    **
** des BOOPSI-Systems.                                             **
**                                                                 **
** Diese Methoden müssen vom Hook behandlet werden, da Sie das     **
** spezifische Verhalten eines View ausmachen. Um die Node unter   **
** der Mouse in Erfahrung zu bringen können Sie von hier aus die   **
** Methode WVIEWM_MOUSEITEM an das Object senden. Dadurch können   **
** Sie sich einige Arbeit sparen.                                  **
**                                                                 **
********************************************************************/


struct WizardViewInput
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpi_ViewInfo;
	struct GadgetInfo 		*wvpi_GInfo;
	struct InputEvent			*wvpi_IEvent;
	struct
	{
		WORD	X;
		WORD	Y;
	}								 wvpi_Mouse;
};

/********************************************************************
**                                                                 **
** WVIEWM_GOINACTIVE:                                              **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
** Diese Methode muß vom Hook behandlet werden.                    **
**                                                                 **
********************************************************************/

struct WizardViewInActive
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpia_ViewInfo;
	struct GadgetInfo 		*wvpia_GInfo;
	ULONG							 wvpia_Abort;
};


/********************************************************************
**                                                                 **
** WVIEWM_INSTALLCLIP:                                             **
**                                                                 **
** Der Returnwert ist FALSE, wenn ein Fehler aufgetreten ist.      **
** Sollte dies der Fall sein, dann wurde die Clippingregion NICHT  **
** installiert ! Das Clipprectangle wird mit dem umgebenden Clip-  **
** rectangle logisch verknüpft.                                    **
**                                                                 **
********************************************************************/

struct WizardViewInstallClip
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpic_ViewInfo;
	struct GadgetInfo			*wvpic_GInfo;
	struct RastPort			*wvpic_RPort;
	struct Region			  **wvpic_OldRegion;
	struct Rectangle			*wvpic_ClipRectangle;
};

/********************************************************************
**                                                                 **
** WVIEWM_UNINSTALLCLIP:                                           **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardViewUnInstallClip
{
	ULONG					 		MethodID;
	struct GadgetInfo			*wvpuic_GInfo;
	struct RastPort			*wvpuic_RPort;
	struct Region				*wvpuic_OldRegion;
};

/********************************************************************
**                                                                 **
** WVIEWM_RENDERRANGE:                                             **
**                                                                 **
** Beauftragt das Object die angegebene Node und alle folgenden    **
** Nodes auch zeichnen zu lassen. Das Object sendet dann über den  **
** Hook die Methode WVIEWN_RENDERNODE für die betreffenden Nodes.  **
**                                                                 **
** Die korrekte Clippingregion sollten Sie dabei bereits innerhalb **
** des RastPorts installiert haben.  Count enthält die Anzahl der  **
** nachfolgenden Nodes, die ebenfalls gezeichnet werden sollen.    **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardViewRenderRange
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvprr_ViewInfo;
	struct GadgetInfo			*wvprr_GInfo;
	struct RastPort			*wvprr_RPort;
	struct WizardNode			*wvprr_Node;
	ULONG							 wvprr_Number;
	ULONG							 wvprr_Count;
	LONG							 wvprr_TopEdge;
};

/********************************************************************
**                                                                 **
** WVIEWM_GETNODE:                                                 **
**                                                                 **
** Beauftragt das Object für die angegebene NodeNumber die obere   **
** Position zu berechnen und liefert gleichzeitig die Adresse der  **
** Node.                                                           **
**                                                                 **
** Der Returnwert ist FALSE bei einem Fehler                       **
**                                                                 **
********************************************************************/

struct WizardViewGetNode
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpgn_ViewInfo;
	ULONG							 wvpgn_Number;
	ULONG							*wvpgn_TopEdge;
	struct WizardNode		  **wvpgn_Node;
};

/********************************************************************
**                                                                 **
** WVIEWM_MAKENODEVISIBLE:                                         **
**                                                                 **
** Beauftragt das Object die angegebene Node voll sichtbar zu      **
** machen. Dabei prüft das Object, ob die Node überhauprt in den   **
** gebracht werden muß.                                            **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardViewMakeNodeVisible
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpmnv_ViewInfo;
	struct GadgetInfo			*wvpmnv_GInfo;
	struct RastPort			*wvpmnv_RPort;
	LONG							 wvpmnv_TopEdge;
	LONG							 wvpmnv_Number;
	struct WizardNode		 	*wvpmnv_Node;
};

/********************************************************************
**                                                                 **
** WVIEWM_UPDATE:                                                  **
**                                                                 **
** Beauftragt das Object den angegebene Bereich neu zu zeichnen,   **
** außerdem wird das vertikale Linkobject mit neuen Listendaten    **
** versorgt.                                                       **
**                                                                 **
** Der Returnwert ist undefiniert.                                 **
**                                                                 **
********************************************************************/

struct WizardViewUpdate
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvpu_ViewInfo;
	struct GadgetInfo			*wvpu_GInfo;
	struct RastPort			*wvpu_RPort;
	LONG							 wvpu_MinX;
	LONG							 wvpu_MaxX;
	LONG							 wvpu_MinY;
	LONG							 wvpu_MaxY;
};



#define	WVIEWNODEM_DUMMY				0x100180
#define	WVIEWNODEM_RENDER				WVIEWNODEM_DUMMY+0

/********************************************************************
**                                                                 **
** WVIEWNODE_RENDER:                                               **
**                                                                 **
** Beauftragt den Hook sein Object darzustellen.                   **
** Der Returnwert ist undefiniert, folglich ist Null zu returnen.  **
**                                                                 **
********************************************************************/

struct WizardViewNodeRender
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wvnpr_ViewInfo;
	struct DrawInfo			*wvnpr_DrInfo;
	struct RastPort			*wvnpr_RPort;
	struct WizardNode			*wvnpr_Node;
	APTR							*wvnpr_UserData;
	ULONG							 wvnpr_BGPen;
	LONG							 wvnpr_LeftEdge;
	LONG							 wvnpr_TopEdge;
	LONG							 wvnpr_RightEdge;
	LONG							 wvnpr_BottomEdge;
	LONG							 wvnpr_MinX;
	LONG							 wvnpr_MaxX;
};
#endif /* WIZARD_WIZARDVIEW_H */
