#ifndef	WIZARD_WIZARDEXTERN_H
#define	WIZARD_WIZARDEXTERN_H

/*
**	$VER: wizardextern.h 38.125 (20.09.96)
**
**	© 1996 HAAGE & PARTNER,  All Rights Reserved
**	  Autor: Thomas Mittelsdorf
**
*/

/********************************************************************
**                                                                 **
** Hook-Methoden, die zu den normalen System-Methoden kommen:      **
**                                                                 **
** Alle hier aufgeführten Methoden, müssen an die die Subklasse    **
** weitergeleitet werden. Der Returnwert muß weitergegeben werden. **
** Damit Ihr externer Dispatcher aber Wizardfehigkeiten mitmacht,  **
** sollten Sie diese Methoden natürlich auch selbst beachten.      **
** Unbekannten Methoden sind an die Subklasse weiterzuleiten,      **
** dabei sollte der Returnwert durchgereicht werden.               **
**                                                                 **
********************************************************************/

#define	WEXTERNM_LAYOUT				1048576
#define	WEXTERNM_RENDERCLIP			1048580
#define	WEXTERNM_KEYTEST				1048581
#define	WEXTERNM_SETPATTERN			1048584
#define	WEXTERNM_UPDATEPAGE			1048585
#define	WEXTERNM_INSTALLCLIP			1048596
#define	WEXTERNM_UNINSTALLCLIP		1048597

//**************************************************************

/********************************************************************
**                                                                 **
** WEXTERNM_LAYOUT:                                                **
**                                                                 **
** Diese Methode sendet der Layouter beim Fenster öffnen, wie auch **
** beim Fenstersizen. Updaten Sie also die Position und Dimension  **
** in der eigentlichen Gadget-Struktur. Die Boundsstruktur muß von **
** Subklasse gesetzt werden ! natürlich auch selbst beachten.      **
** Unbekannten Methoden sind an die Subklasse weiterzuleiten,      **
** dabei sollte der Returnwert durchgereiht werden.                **
**                                                                 **
**                                                                 **
** Der Returnwert muß übernommen werden !                          **
**                                                                 **
********************************************************************/


struct WizardExternLayout
{
	ULONG					 MethodID;
	struct GadgetInfo *wepl_GInfo;
	ULONG					 wepl_Privat;
	struct IBox 		 wepl_Bounds;
	struct IBox			 wepl_FullBounds;
	struct Rectangle	 wepl_ClipRectangle;
};

/********************************************************************
**                                                                 **
** WEXTERNM_RENDERCLIP:                                            **
**                                                                 **
** Diese Methode sendet der Layouter, wenn ein Gadget durch das    **
** übergeordnete Gruppengadget pixelweise verschoben wurde und     **
** dabei ein Bereich geupdatet werden muß ! Diser ist in der       **
** Clippingregion spezifiziert. Beachten Sie, das beim die hier    **
** angegebene Clippingregion mittels AND-Verknüpfung mit ihrer     **
** Clippingregion die Ihenen beim layouten mitgeteilt wurde, ver-  **
** knüpft werden muß !                                             **
**                                                                 **
** Der Returnwert muß übernommen werden !                          **
**                                                                 **
********************************************************************/

struct WizardExternRenderClip
{
	ULONG					 MethodID;
	struct GadgetInfo *weprc_GInfo;
	struct RastPort	*weprc_RPort;
	struct Rectangle	 weprc_ClipRectangle;
};

/********************************************************************
**                                                                 **
** WEXTERNM_SETPATTERN:                                            **
**                                                                 **
** Diese Methode sendet der Layouter, wenn ein Gadget in seine     **
** Gruppe eingehangen wurde, beim ihren Dispatcher kann diese      **
** Methode also auch vor der New-Methode kommen !                  **
** Wenn Sie also freie Pixel haben, sollten Sie diese immer mit    **
** den hier angegebenen Design zeichnen.                           **
**                                                                 **
** Der Returnwert muß übernommen werden !                          **
**                                                                 **
********************************************************************/

struct WizardExternSetPattern
{
	ULONG  MethodID;
	ULONG	 wepsp_PatternPen;
	ULONG  wepsp_PatternSz;
	UWORD *wepsp_Pattern;
};

/********************************************************************
**                                                                 **
** WEXTERNM_UPDATEPAGE:                                            **
**                                                                 **
** Diese Methode wird durch das Paging gesendet, möchte Ihre Klasse**
** dies handhaben, dann sollten Sie dies beachten.                 **
**                                                                 **
** Der Returnwert muß übernommen werden !                          **
**                                                                 **
********************************************************************/

struct WizardExternUpdatePage
{
	ULONG	MethodID;
	struct GadgetInfo *wepup_GInfo;
	ULONG					*wepup_Privat;
	ULONG					 wepup_Active;
};

/********************************************************************
**                                                                 **
** WEXTERNM_KEYTEST   :                                            **
**                                                                 **
** Diese Methode wird bei einem WZ_GadgetKey() gesandt.            **
**                                                                 **
** Returnwert:                                                     **
**                                                                 **
**    FALSE- Gadget ist nicht zuständig.                           **
**                                                                 **
**    TRUE - Gadget ist zuständig.                                 **
**           ActivateGadget = Gadget, wenn`s aktiviert werden soll **
**                          = NULL, wenn nicht aktivieren          **
**                                                                 **
**                                                                 **
**                                                                 **
********************************************************************/

struct WizardExternKeyTest
{
	ULONG	MethodID;
	struct GadgetInfo *wepkt_GInfo;
	struct Gadget		*wepkt_ActivateGadget;
	ULONG					 wepkt_Return;
	UWORD					 wepkt_Qualifier;
	UWORD					 wepkt_Key;
};

/* ReturnWert = True, wenn dieses Gadget zuständig war
** danach dann mit diesem Gadget ActiveGadget durchführen !!!
*/


/********************************************************************
**                                                                 **
** WEXTERNM_INSTALLCLIP:                                           **
**                                                                 **
** Diese Methode kann an die Supperklasse geschickt werden.        **
** Dazu muß die Layoutmethod ebenfalls an die Supperklasse weiter- **
** geleitet werden.                                                **
**                                                                 **
** Der Returnwert ist TRUE, wenn die Clippingregion erfolgrich     **
** installiert wurd.                                               **
**                                                                 **
********************************************************************/


struct WizardExternInstallClip
{
	ULONG	MethodID;
	struct GadgetInfo  *wepic_GInfo;
	struct Region		**wepic_OldRegion;
};

/********************************************************************
**                                                                 **
** WEXTERNM_UNINSTALLCLIP:                                         **
**                                                                 **
** Diese Methode kann an die Supperklasse geschickt werden.        **
** Dazu muß die Layoutmethod ebenfalls an die Supperklasse weiter- **
** geleitet werden.                                                **
**                                                                 **
** Der Returnwert ist TRUE, wenn die Clippingregion erfolgrich     **
** installiert wurd.                                               **
**                                                                 **
********************************************************************/


struct WizardExternUnInstallClip
{
	ULONG	MethodID;
	struct GadgetInfo *wepuic_GInfo;
	struct Region		*wepuic_Region;
};

#endif /* WIZARD_WIZARDVIEW_H */
