/*
 * buttonclass.c
 * =============
 * Extends the intuition frbuttonclass to render disabled state properly.
 *
 * Copyright (C) 1999-2000 Håkan L. Younes (lorens@hem.passagen.se)
 */

#include <intuition/gadgetclass.h>
#include <intuition/imageclass.h>

#include <clib/alib_protos.h>
#include <proto/intuition.h>
#include <proto/utility.h>

#include "apputil.h"


typedef struct {
  struct Image *ghostingPattern;
} ButtonClassData;


static UWORD ghostingData[] = { 0x4444, 0x1111 };


static BOOL ButtonNew(Class *cl, struct Gadget *obj, struct opSet *msg) {
  ButtonClassData *data = INST_DATA(cl, obj);

  data->ghostingPattern =
    (struct Image *)NewObject(NULL, "fillrectclass",
			      IA_Width, obj->Width,
			      IA_Height, obj->Height,
			      IA_APattern, ghostingData,
			      IA_APatSize, 1,
			      TAG_DONE);

  return (BOOL)(data->ghostingPattern != NULL);
}


static VOID ButtonDispose(Class *cl, struct Gadget *obj) {
  ButtonClassData *data = INST_DATA(cl, obj);

  DisposeObject(data->ghostingPattern);
}


static VOID ButtonSet(Class *cl, struct Gadget *obj, struct opSet *msg) {
  struct TagItem *ti, *tstate = msg->ops_AttrList;
  struct RastPort *rp;

  while ((ti = NextTagItem(&tstate)) != NULL) {
    switch (ti->ti_Tag) {
    case GA_Disabled:
      rp = ObtainGIRPort(msg->ops_GInfo);
      if (rp != NULL) {
	DoMethod((Object *)obj, GM_RENDER, msg->ops_GInfo, rp, GREDRAW_REDRAW);
	ReleaseGIRPort(rp);
      }
      break;
    }
  }
}


static VOID ButtonRender(Class *cl, struct Gadget *obj, struct gpRender *msg) {
  ButtonClassData *data = INST_DATA(cl, obj);

  if (obj->Flags & GFLG_DISABLED) {
    data->ghostingPattern->PlanePick =
      msg->gpr_GInfo->gi_DrInfo->dri_Pens[TEXTPEN];
    DrawImageState(msg->gpr_RPort, data->ghostingPattern,
		   (LONG)obj->LeftEdge, (LONG)obj->TopEdge,
		   IDS_NORMAL, msg->gpr_GInfo->gi_DrInfo);
  }
}


static ULONG __saveds __asm ButtonClassDispatch(register __a0 Class *cl,
						register __a2 Object *obj,
						register __a1 Msg msg) {
  ULONG result = 0;

  switch (msg->MethodID) {
  case OM_NEW:
    result = DoSuperMethodA(cl, obj, msg);
    if (result != NULL) {
      if (!ButtonNew(cl, (struct Gadget *)result, (struct opSet *)msg)) {
	DoMethod((Object *)result, OM_DISPOSE);
	result = NULL;
      }
    }
    break;
  case OM_DISPOSE:
    ButtonDispose(cl, (struct Gadget *)obj);
    DoSuperMethodA(cl, obj, msg);
    break;
  case OM_SET:
    DoSuperMethodA(cl, obj, msg);
    ButtonSet(cl, (struct Gadget *)obj, (struct opSet *)msg);
    break;
  case GM_RENDER:
    DoSuperMethodA(cl, obj, msg);
    ButtonRender(cl, (struct Gadget *)obj, (struct gpRender *)msg);
    break;
  default:
    result = DoSuperMethodA(cl, obj, msg);
    break;
  }

  return result;
}


Class *CreateButtonClass(VOID) {
  Class *cl;

  cl = MakeClass(NULL, "frbuttonclass", NULL, sizeof (ButtonClassData), 0);
  if (cl != NULL) {
    cl->cl_Dispatcher.h_SubEntry = NULL;
    cl->cl_Dispatcher.h_Entry = (HOOKFUNC)ButtonClassDispatch;
    cl->cl_Dispatcher.h_Data = NULL;
  }

  return cl;
}
