#ifndef _CLASS_H
#define _CLASS_H

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/muimaster.h>
#include <proto/utility.h>
#include <proto/locale.h>
#include <proto/freedb.h>
#include <proto/intuition.h>
#include <mui/muiundoc.h>
#include <mui/urltext_mcc.h>
#include <string.h>
#include <stdlib.h>
#include "base.h"
#include "msg.h"

/***********************************************************************/

#define SysBase         (libBase->sysBase)
#define DOSBase         (libBase->dosBase)
#define IntuitionBase   (libBase->intuitionBase)
#define UtilityBase     (libBase->utilityBase)
#define LocaleBase      (libBase->localeBase)
#define GfxBase         (libBase->gfxBase)
#define MUIMasterBase   (libBase->muiMasterBase)

extern struct libBase *libBase;
extern STRPTR *strings;

/***********************************************************************/
/*
** Methods and attributes
*/

/* none defined */

/***********************************************************************/

#define PPRIGHT         "\33r"
#define PPLEFT          "\33l"
#define PPCENTER        "\33c"
#define PPCENTERBOLD    "\33c\33b"

#define vFixSpace   (RectangleObject,MUIA_FixHeightTxt,"A",End)
#define hFixSpace   (RectangleObject,MUIA_FixWidthTxt,"A",End)

/***********************************************************************/

#include "class_protos.h"

/***********************************************************************/

#endif /* _CLASS_H */
