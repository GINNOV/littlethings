#ifndef	WIZARD_WIZARDHOOKS_H
#define	WIZARD_WIZARDHOOKS_H

// Hook-Methoden, die öffentlich sind *******************************

#define	WBUTTONM_INFO				0x100F00
#define	WSLIDERM_RENDER			0x100F01

/********************************************************************
**                                                                 **
** WBUTTONM_INFO:                                                  **
**                                                                 **
** Returnwert ist undefiniert.                                     **
**                                                                 **
** Wenn der Hook diese Methode nicht behandelt, dann kann er Sie   **
** ignorieren.                                                     **
**                                                                 **
********************************************************************/

struct WizardButtonInfo
{
	ULONG					 		MethodID;
	struct WizardViewInfo	*wbp_State;
};



/********************************************************************
**                                                                 **
** WSLIDERM_RENDER:                                                **
**                                                                 **
** Returnwert ist undefiniert.                                     **
**                                                                 **
** Wenn der Hook diese Methode nicht behandelt, dann kann er Sie   **
** ignorieren.                                                     **
**                                                                 **
********************************************************************/

struct WizardSliderRender
{
	ULONG					 		MethodID;
	struct RastPort			*wpsl_RastPort;
	struct IBox					 wpsl_Bounds;
	struct IBox					 wpsl_KnobBounds;
};

#endif /* WIZARD_WIZARDHOOK_H */
