#ifndef WIZARD_WIZARDHOOKS_H
#define WIZARD_WIZARDHOOKS_H

/*
** Public Hook-Methods
*/

#define WBUTTONM_INFO           0x100F00
#define WSLIDERM_RENDER         0x100F01


/*
** WBUTTONM_INFO:
**
** returnvalue is not defined.
**
** If the Hook doesn't handle this method, he can ignore it.
*/

struct WizardButtonInfo
{
    ULONG                       MethodID;
    struct WizardViewInfo       *wbp_State;
};



/*
** WSLIDERM_RENDER:
**
** returnvalue is not defined.
**
** If the Hook doesn't handle this method, he can ignore it.
*/

struct WizardSliderRender
{
    ULONG                       MethodID;
    struct RastPort             *wpsl_RastPort;
    struct IBox                 wpsl_Bounds;
    struct IBox                 wpsl_KnobBounds;
};

#endif /* WIZARD_WIZARDHOOK_H */

