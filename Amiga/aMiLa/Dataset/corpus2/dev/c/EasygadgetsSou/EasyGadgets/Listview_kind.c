/*
 *	File:					Listview_kind.c
 *	Description:	BOOPSI listview gadget class
 *
 *	(C) 1994, Ketil Hunn
 *
 */

#ifndef LISTVIEW_KIND_C
#define LISTVIEW_KIND_C

/* Make sure everything is added from PopUpMenuClass.h */
#define POPUPMENUCLASS_PRIVATE  1

#include    "Listview_kind.h"
#include    <string.h>
#include    <math.h>

#define	DisposeListviewClass(class)	FreeClass(class);

static ULONG __saveds __asm EGLV_Dispatcher(register __a0 Class *class,
																						register __a2 Object *object,
																						register __a1 Msg msg);
static ULONG EGLV_NEW(Class *class, Object *object, struct opSet *ops);
static ULONG EGLV_DISPOSE(Class *class, Object *object, Msg msg);
static ULONG EGLV_SET(Class *class, Object *object, struct opSet *ops);
static ULONG EGLV_GET(Class *class, Object *object, struct opGet *opg);
static ULONG EGLV_UPDATE(Class *class, Object *object, struct opUpdate *opu);
static ULONG EGLV_NOTIFY(Class *class, Object *object, struct opUpdate *opu);
static ULONG EGLV_RENDER(Class *class, Object *object, struct gpRender *gpr);
static ULONG EGLV_GOACTIVE(Class *class, Object *object, struct gpInput *gpi);
static ULONG EGLV_HANDLEINPUT(Class *class, Object *object, struct gpInput *gpi);
static ULONG EGLV_GOINACTIVE(Class *class, Object *object, struct gpGoInactive *gpgi);

/* Protos for static help functions. */

static void     EGLV_MakeCheckings( struct ListviewData *PD );

static void     EGLV_GetGadgetRect( Object *object,
                                    struct GadgetInfo *gi,
                                    struct Rectangle *rect );

static void     EGLV_DrawPopupWindow( struct ListviewData *PD,
                                      struct DrawInfo *dri,
                                      ULONG From,
                                      LONG Count );

static void     EGLV_DrawFrame( struct Window *win,
                                int order,
                                struct DrawInfo *dri,
                                UBYTE *name,
                                struct TextFont *tf,
                                BOOL Active,
                                BOOL NewLook,
                                ULONG ItemHeight );


/*******************************************************************/
/*******************************************************************/
/* The real code starts here.                                      */
/*******************************************************************/
/*******************************************************************/

Class *CreateListviewClass()
{
	Class *class;

	class=MakeClass(NULL, GADGETCLASS, NULL, sizeof(struct ListviewData), 0);
	if(class)
		class->cl_Dispatcher.h_Entry=(HookFunction)EGLV_Dispatcher;

	return( class );
}


/*******************************************************************/
/*******************************************************************/
/* Listview specific class code.                                  */
/*******************************************************************/
/*******************************************************************/

static ULONG __saveds __asm EGLV_Dispatcher(register __a0 Class *class,
																						register __a2 Object *object,
																						register __a1 Msg msg)
{
	ULONG retval;

	switch(msg->MethodID)
	{
		case OM_NEW:
			retval=EGLV_NEW(class, object, (struct opSet *)msg);
			break;
		case OM_DISPOSE:
			retval=EGLV_DISPOSE(class, object, msg);
			break;
		case OM_SET:
			retval=EGLV_SET(class, object, (struct opSet *)msg);
			break;
		case OM_GET:
			retval=EGLV_GET(class, object, (struct opGet *)msg);
			break;
		case OM_UPDATE:
			retval=EGLV_UPDATE(class, object, (struct opUpdate *)msg);
			break;
		case OM_NOTIFY:
			retval=EGLV_NOTIFY(class, object, (struct opUpdate *)msg);
			break;
		case GM_RENDER:
			retval = EGLV_RENDER(class, object, (struct gpRender *)msg);
			break;
		case GM_GOACTIVE:
			retval=EGLV_GOACTIVE(class, object, (struct gpInput *)msg);
			break;
		case GM_HANDLEINPUT:
			retval=EGLV_HANDLEINPUT(class, object, (struct gpInput *)msg);
			break;
		case GM_GOINACTIVE:
			retval=EGLV_GOINACTIVE(class, object, (struct gpGoInactive *)msg);
			break;
		default:
			retval=DoSuperMethodA(class, object, msg);
			break;
	}
	return retval;
}

static ULONG EGLV_NEW(Class *class, Object *object, struct opSet *ops)
{
	Object *object;
	struct ListviewData *lv;

	object=(Object *)DoSuperMethodA(class, object, (Msg)ops);
	if(object)
	{
		lv=INST_DATA(class, object);

		lv->Labels=(struct List *)GetTagData(EGLV_Labels, NULL, ops->ops_AttrList);
		lv->Active=GetTagData(EGLV_Active, 0, ops->ops_AttrList);

		EGLV_MakeCheckings(lv);

		lv->Font=(struct TextFont *)GetTagData(EGLV_TextFont, NULL, ops->ops_AttrList);

		lv->FrameImage=(struct Image *)NewObject(NULL,"frameiclass",
																							IA_Recessed,	FALSE,
																							IA_EdgesOnly,	FALSE,
																							IA_FrameType,	FRAME_BUTTON,
																							TAG_END);
		if(lv->FrameImage==NULL)
		{
			CoerceMethod(class, object, OM_DISPOSE);
			object=NULL;
		}
	}
	return (ULONG)object;
}

static ULONG EGLV_DISPOSE(Class *class, Object *object, Msg msg )
{
	struct ListviewData *lv=INST_DATA(class, object);

	if(lv->popup_window)
		CloseWindow(lv->popup_window);

	if(lv->FrameImage)
		DisposeObject(lv->FrameImage);

	return DoSuperMethodA(class, object, msg);
}

static ULONG EGLV_SET(Class *class, Object *object, struct opSet *ops)
{
	ULONG retval;
	struct ListviewData *lv = INST_DATA( class, object );
	struct TagItem *tag, notify;
	UWORD old_active;

	retval=DoSuperMethodA(class, object, (Msg)ops);

	/* I decided that it would be best that the values which are
	** specific to this class, could bot be changed when we have
	** our Listview window opened. */
	if((ops->ops_AttrList!=NULL) && (lv->popup_window==NULL))
	{
    if(tag=FindTagItem(EGLV_Labels, ops->ops_AttrList))
		{
			lv->Labels=(struct List *)tag->ti_Data;
			retval=TRUE;
		}

    old_active = lv->Active;
    if(tag=FindTagItem(EGLV_Active, ops->ops_AttrList))
		{
			lv->Active=tag->ti_Data;
			retval=TRUE;
		}

		EGLV_MakeCheckings(lv);

		if(tag=FindTagItem(EGLV_TextFont, ops->ops_AttrList))
		{
			lv->Font=(struct TextFont *)tag->ti_Data;
			retval=TRUE;
		}

		if(old_active!=lv->Active)
		{
			/* We send ourselves a OM_NOTIFY message, which will
			** eventually be broadcasted as OM_UPDATE message
			** to the target object. Note that we don't send it
			** simply to our parent, but to ourselves, so if
			** we have a children which needs to add it's own
			** data it will be added. */
			EGLV_SetTagArg( notify, TAG_END, NULL );
			(VOID)DoMethod( object, OM_NOTIFY, &notify, ops->ops_GInfo, 0 );
		}
	}
	return( retval );
}

static ULONG EGLV_GET(Class *class, Object *object, struct opGet *opg)
{
	ULONG retval;
	struct ListviewData *lv=INST_DATA(class, object);

	switch(opg->opg_AttrID)
	{
		case EGLV_Labels:
			*opg->opg_Storage=(ULONG)lv->Labels;
			retval=TRUE;
			break;
		case EGLV_Active:
			*opg->opg_Storage = (ULONG)lv->Active;
			retval = TRUE;
			break;
		case EGLV_TextFont:
			*opg->opg_Storage=(ULONG)lv->Font;
			retval=TRUE;
			break;
		default:
			retval=DoSuperMethodA(class, object, (Msg)opg);
			break;
	}
	return retval;
}

static ULONG EGLV_UPDATE(Class *class, Object *object, struct opUpdate *opu)
{
	ULONG retval;
	struct ListviewData *lv = INST_DATA( class, object );
	struct TagItem *tag, notify;
	struct RastPort *rp;

	retval=DoSuperMethodA(class, object, opu);

	/* Update only if gadget isn't currently manipulated. */
	if(lv->popup_window==NULL)
	{
	  if(opu->opu_AttrList)
		{
		  if(tag=FindTagItem(EGLV_Active, opu->opu_AttrList))
			{
				if(tag->ti_Data!=lv->Active)
				{
					lv->Active=tag->ti_Data;
					EGLV_MakeCheckings(lv);

					if(rp=ObtainGIRPort(opu->opu_GInfo))
					{
						DoMethod(object, GM_RENDER, opu->opu_GInfo, rp, GREDRAW_UPDATE);
		    		ReleaseGIRPort(rp);
					}
		
			  	/* Notify the change. */
			  	EGLV_SetTagArg( notify, TAG_END, NULL );
			  	(void)DoMethod(object, OM_NOTIFY, &notify, opu->opu_GInfo, 0);
  			}
  		}
  	}
  }
	return retval;
}

static ULONG EGLV_NOTIFY(Class *class, Object *object, struct opUpdate *opu)
{
	struct TagItem tags[3];
	struct ListviewData *lv=INST_DATA(class, object);

	EGLV_SetTagArg(tags[0], GA_ID, ((struct Gadget *)object)->GadgetID);
	EGLV_SetTagArg(tags[1], EGLV_Active, lv->Active);

	/* If there are no previous tags in OM_NOTIFY message, we
	** add them there as only ones. Otherwise we tag previous
	** tags to the end of our tags. Got it? :')
	*/
	if(opu->opu_AttrList==NULL)
	    EGLV_SetTagArg(tags[2], TAG_END, NULL);
	else
		EGLV_SetTagArg(tags[2], TAG_MORE, opu->opu_AttrList );

	return DoSuperMethod(class, object, OM_NOTIFY, tags, opu->opu_GInfo, opu->opu_Flags);
}

static ULONG EGLV_RENDER(Class *class, Object *object, struct gpRender *gpr)
{
	ULONG retval, State;
	struct Gadget *gad = (struct Gadget *)object;
	struct Rectangle rect;
	struct DrawInfo *dri;
	struct IBox container;
	struct Node *node;
	struct TextExtent temp_te;
	struct RastPort *RP = gpr->gpr_RPort;
	UWORD BorderWidth, BorderHeight, TextWidth;
	UWORD patterndata[2] = { 0x2222, 0x8888 };
	ULONG TextPen, ImagePen1, ImagePen2;
	struct ListviewData *lv = INST_DATA( class, object );

	retval=DoSuperMethodA(class, object, gpr);

	/* Get real Min and Max positions. */
	EGLV_GetGadgetRect(object, gpr->gpr_GInfo, &rect);

	/* Calculate real dimensions. */
	container.Left		=rect.MinX;
	container.Top			=rect.MinY;
	container.Width		=1+rect.MaxX-rect.MinX;
	container.Height	=1+rect.MaxY-rect.MinY;

	dri=gpr->gpr_GInfo->gi_DrInfo;

	if(gad->Flags & GFLG_DISABLED)
		State=IDS_DISABLED;
	else if(gad->Flags & GFLG_SELECTED)
		State=IDS_SELECTED;
	else
		State=IDS_NORMAL;

	/* Frame rendering goes here. */
	SetAttrs(lv->FrameImage,
  					IA_Left,    container.Left,
  					IA_Top,     container.Top,
  					IA_Width,   container.Width,
  					IA_Height,  container.Height,
  					TAG_END);

	DrawImageState(RP, lv->FrameImage, 0, 0, State, dri);

	if(dri)
	{
		TextPen		=dri->dri_Pens[TEXTPEN];
		ImagePen1	=dri->dri_Pens[SHINEPEN];
		ImagePen2	=dri->dri_Pens[SHADOWPEN];
	}
	else
	{
		// If for some unknown reason Drawinfo is NULL then we
		// Use these predefined values, which should work atleast
		// for current OS releases.
		TextPen		=ImagePen2=1;
		ImagePen1	=2;
	}

	/*******************************/
	/* Text rendering starts here. */
	/*******************************/

	/* Do we have a proper font. If not we use the font we have in RastPort. */
	if(lv->Font==NULL)
		lv->Font=RP->Font;
	else
		SetFont(RP, lv->Font);

/*
	/* Check if we have nothing to print. */
	if(lv->Count>0)
	{
    ULONG len, i = 0;
    char *label_name;

    node = lv->Labels->lh_Head;
    while( node->ln_Succ ) {
        if( i == lv->Active ) {
            label_name = node->ln_Name;
            if( label_name ) {
                len = TextFit( RP, label_name, (ULONG)strlen(label_name),
                    &temp_te, NULL, 1, (ULONG)container.Width - 28,
                    1LU + lv->Font->tf_YSize);

                TextWidth = 1 + temp_te.te_Extent.MaxX - temp_te.te_Extent.MinX;

                SetAPen(RP, TextPen);
                Move( RP, 10L + container.Left + (container.Width - TextWidth)/2
                    - temp_te.te_Extent.MinX, (LONG)
                    lv->Font->tf_Baseline + (1 + container.Top + rect.MaxY
                    - lv->Font->tf_YSize)/2 );

                Text( RP, label_name, len );
            }

            /* End the drawing. */
            break;
        }
        else {
            i++;
            node = node->ln_Succ;
        }
    }
	}
*/

	/* Disabled pattern rendering is here. */
	if(State==IDS_DISABLED)
	{
		BorderHeight=1;
		BorderWidth	=(IntuitionBase->LibNode.lib_Version<39 ? 1 : 2);

		container.Left	+=BorderWidth;
		container.Top		+=BorderHeight;
		container.Width	=MAX(1, container.Width - 2*BorderWidth);
		container.Height=MAX(1, container.Height-2*BorderHeight);

		SetDrMd(RP,JAM1);
		SetAfPt(RP, patterndata, 1);

		RectFill(RP, (LONG)container.Left, (LONG)container.Top,
							-1L + container.Left + container.Width,
							-1L + container.Top + container.Height);

		SetAfPt(RP, NULL, 0 );
	}

	/* Copy current Rectangle. */
	lv->rect=rect;

	return retval;
}

static ULONG EGLV_GOACTIVE(Class *class, Object *object, struct gpInput *gpi)
{
	ULONG retval = GMR_MEACTIVE, Left, Top;
	struct RastPort *rp;
	struct ListviewData *lv = INST_DATA( class, object );
	struct GadgetInfo *gi = gpi->gpi_GInfo;
	struct Gadget *gad = (struct Gadget *)object;

	if(gad->Flags & GFLG_DISABLED)
		return(GMR_NOREUSE);

	/* Call first our parent class. */
	(void)DoSuperMethodA(class, object, gpi);

	/* Chech whether we were activated from mouse or keyboard. */
	lv->ActiveFromMouse=(gpi->gpi_IEvent != NULL);

	/* Select this gadget. */
	gad->Flags|=GFLG_SELECTED;

	if(rp=ObtainGIRPort(gi))
	{
		/* Render ourselves as selected gadget. */
		DoMethod(object, GM_RENDER, gi, rp, GREDRAW_UPDATE);
		ReleaseGIRPort( rp );

		/* Get the domain top/left position. */
		Left=gi->gi_Domain.Left;
		Top	=gi->gi_Domain.Top;

		/* If this is window, we have to add window Left/Top values too. */
    if(gi->gi_Window)
		{
			Left+=gi->gi_Window->LeftEdge;
			Top	+=gi->gi_Window->TopEdge;
		}

		/* Count how many items fits to menu. */
		lv->FitsItems=(gi->gi_Screen->Height - 4) / lv->ItemHeight;
		if(lv->FitsItems>lv->Count)
			lv->FitsItems=lv->Count;

		lv->popup_window=OpenWindowTags(NULL,
        WA_Left,            Left + lv->rect.MinX,
        WA_Top,             Top + lv->rect.MaxY,
        WA_Width,           1 + lv->rect.MaxX - lv->rect.MinX,
        WA_Height,          4 + lv->FitsItems*lv->ItemHeight,
        WA_Activate,        FALSE,
        WA_CustomScreen,    gi->gi_Screen,
        WA_SizeGadget,      FALSE,
        WA_DragBar,         FALSE,
        WA_DepthGadget,     FALSE,
        WA_CloseGadget,     FALSE,
        WA_Borderless,      TRUE,
        WA_Flags,           0,
        WA_AutoAdjust,      TRUE,
        WA_RMBTrap,         TRUE,
        WA_SimpleRefresh,   TRUE,
        WA_NoCareRefresh,   TRUE,
        TAG_END);

		if(lv->popup_window==NULL)
			retval=GMR_NOREUSE;
    else
    {
			/* We make sure Active item isn't too large to display. */
			if(lv->FitsItems<lv->Active)
				lv->Active=lv->FitsItems-1;

			/* If activated from keyboard we can set temporary value
			** to currently activated item. Otherwise we set it
			** to -1 which means that there is no active item. */
			lv->Temp_Active=(lv->ActiveFromMouse ? (ULONG)~0 : lv->Active);

			/* Render all items. */
			EGLV_DrawPopupWindow( lv, gi->gi_DrInfo, 0, -1);
		}
	}
	else
		retval=GMR_NOREUSE;

	return retval;
}

static ULONG EGLV_HANDLEINPUT(Class *class, Object *object, struct gpInput *gpi)
{
	ULONG retval = GMR_MEACTIVE;
	struct InputEvent *ie = gpi->gpi_IEvent;
	struct ListviewData *lv = INST_DATA(class, object);
	WORD X, Y;
	WORD count, old_active;
	struct GadgetInfo *gi = gpi->gpi_GInfo;
	struct TagItem tags;	/* If our possible child class, doesn't know
												** how to handle NULL AttrList ptr, then
												** this can save lots of crashes. */

	/* If there is anykind of AutoPoint program then our main window
	** might get inactive and we wouldn't get any more messages.
	** So we check out that we are active and deactivate ourselves
	** if our window isn't active anymore. */

	if(gi->gi_Window)
		if((gi->gi_Window->Flags & WFLG_WINDOWACTIVE)==0)
			return(GMR_NOREUSE);

	if(lv->ActiveFromMouse)
	{
		X=lv->popup_window->MouseX;
		Y=lv->popup_window->MouseY;

		count=( (Y - 2) >= 0 ) ? (Y - 2) / (lv->ItemHeight) : ~0;

		old_active=lv->Temp_Active;

		if( (X > 2) && (X < (lv->popup_window->Width - 2))
            && (count >= 0) && (count < lv->FitsItems) ) {
        lv->Temp_Active = (UWORD)count;
    }
    else lv->Temp_Active = (UWORD)~0;

    if( old_active != (WORD)lv->Temp_Active ) {
        EGLV_DrawPopupWindow( lv, gi->gi_DrInfo,(ULONG)lv->Temp_Active, 1 );
        EGLV_DrawPopupWindow( lv, gi->gi_DrInfo,(ULONG)old_active, 1 );
    }

    while( ie && (retval == GMR_MEACTIVE) ) {
        if( ie->ie_Class == IECLASS_RAWMOUSE ) {
            if( ie->ie_Code == SELECTUP ) {
                retval = GMR_NOREUSE;

                if( (lv->Temp_Active != (UWORD)~0) ) {
                    lv->Active = lv->Temp_Active;
                    EGLV_MakeCheckings( lv );

                    EGLV_SetTagArg(tags, TAG_END, NULL);
                    (VOID)DoMethod( object, OM_NOTIFY, &tags, gi, 0);

                    retval |= GMR_VERIFY;
                    *gpi->gpi_Termination = (ULONG)lv->Active;
                }
            }
        }

        ie = ie->ie_NextEvent;
    }
}
else {
    while( ie && (retval == GMR_MEACTIVE) ) {
        switch( ie->ie_Class )
        {
        case IECLASS_RAWMOUSE:
            if( ie->ie_Code != IECODE_NOBUTTON ) {
                retval = GMR_REUSE; /* Reuse the InputEvent. */
            }
            break;
        case IECLASS_RAWKEY:
            old_active = lv->Temp_Active;
            switch( ie->ie_Code )
            {
            case CURSORDOWN:
                if( ie->ie_Qualifier & (ALTLEFT|ALTRIGHT) ) {
                    lv->Temp_Active = lv->FitsItems-1;  /* Jump to end. */
                }
                else if( lv->Temp_Active < (lv->FitsItems-1) ) {
                    lv->Temp_Active += 1;
                }
                break;
            case CURSORUP:
                if( ie->ie_Qualifier & (ALTLEFT|ALTRIGHT) ) {
                    lv->Temp_Active = 0;    /* Jump to start. */
                }
                else if( lv->Temp_Active > 0 ) {
                    lv->Temp_Active -= 1;
                }
                break;
            case 0x45:  /* ESC key. */
                retval = GMR_NOREUSE;
                break;
            case 0x44:  /* RETURN key. */
                lv->Active = lv->Temp_Active;
                EGLV_MakeCheckings( lv );

                EGLV_SetTagArg(tags, TAG_END, NULL);
                (VOID)DoMethod( object, OM_NOTIFY, &tags, gi, 0);

                retval = GMR_NOREUSE|GMR_VERIFY;
                *gpi->gpi_Termination = (ULONG)lv->Active;
                break;
            }

            /* Update the popupwindow items, if changes were made. */
            if( old_active != lv->Temp_Active ) {
                EGLV_DrawPopupWindow( lv, gi->gi_DrInfo,
                    (ULONG)lv->Temp_Active, 1 );
                EGLV_DrawPopupWindow( lv, gi->gi_DrInfo,
                    (ULONG)old_active, 1 );
            }
        }

        ie = ie->ie_NextEvent;
    }
}

return(retval);
}

static ULONG EGLV_GOINACTIVE( Class *class,
                              Object *object,
                              struct gpGoInactive *gpgi )
{
    ULONG retval;
    struct RastPort *rp;
    struct ListviewData *lv = INST_DATA(class, object);

    retval = DoSuperMethodA(class, object, gpgi);

    ((struct Gadget *)object)->Flags &= ~GFLG_SELECTED;

    rp = ObtainGIRPort( gpgi->gpgi_GInfo );
    if( rp ) {
        DoMethod( object, GM_RENDER, gpgi->gpgi_GInfo, rp, GREDRAW_UPDATE );
        ReleaseGIRPort( rp );
    }

    if( lv->popup_window ) {
        CloseWindow(lv->popup_window);
        lv->popup_window = NULL;
    }

    return(retval);
}

/* Static functions for help with real Method functions. */

static void EGLV_MakeCheckings( struct ListviewData *lv )
{
    struct Node *node;

    lv->Count = 0;

    if( lv->Labels == NULL ) {
        lv->Active = 0;
    }
    else if( lv->Labels != (struct List *)~0 ) {
        node = (struct Node *)lv->Labels->lh_Head;
        while( node->ln_Succ ) {
            lv->Count += 1;
            node = node->ln_Succ;
        }

        if( lv->Active >= lv->Count ) {
            lv->Active = lv->Count + (lv->Count == 0) - 1;
        }
    }
}

static void EGLV_GetGadgetRect( Object *object,
                                struct GadgetInfo *gi,
                                struct Rectangle *rect )
{
    struct Gadget *gad = (struct Gadget *)object;
    LONG W, H;

    rect->MinX = gad->LeftEdge;
    rect->MinY = gad->TopEdge;
    W = gad->Width;
    H = gad->Height;

    if( gi ) {
        if( gad->Flags & GFLG_RELRIGHT ) rect->MinX += gi->gi_Domain.Width - 1;
        if( gad->Flags & GFLG_RELBOTTOM ) rect->MinY += gi->gi_Domain.Height - 1;
        if( gad->Flags & GFLG_RELWIDTH ) W += gi->gi_Domain.Width;
        if( gad->Flags & GFLG_RELHEIGHT ) H += gi->gi_Domain.Height;
    }

    rect->MaxX = rect->MinX + W - (W > 0);
    rect->MaxY = rect->MinY + H - (H > 0);
}

static void EGLV_DrawPopupWindow( struct ListviewData *lv,
                                  struct DrawInfo *dri,
                                  ULONG From, LONG Count)
{
    int i, End;
    struct Node *node;
    struct Window *win = lv->popup_window;
    struct RastPort *RP = win->RPort;

    if( lv->Count && dri ) {
        /* If we want to draw all entries then we draw
        ** window borders too. */
        if( Count == -1) {
            Count = lv->FitsItems;

            if( lv->NewLook ) {
                /* Set background to MENU background color. */
                SetRast( RP, (ULONG)dri->dri_Pens[BARBLOCKPEN] );

                SetAPen( RP, (ULONG)dri->dri_Pens[BARDETAILPEN] );
                Move( RP, 0, -1L + win->Height );
                Draw( RP, 0, 0 );
                Draw( RP, -1L + win->Width, 0 );
                Draw( RP, -1L + win->Width, -1L + win->Height);
                Draw( RP, 1, -1L + win->Height);
                Draw( RP, 1, 1);
                Move( RP, -2L + win->Width, 1 );
                Draw( RP, -2L + win->Width, -2L + win->Height);
            }
            else {
                SetAPen( RP, (ULONG)dri->dri_Pens[SHINEPEN]);
                Move( RP, 0, -1L + win->Height);
                Draw( RP, 0, 0 );
                Draw( RP, -1L + win->Width, 0 );
                SetAPen( RP, (ULONG)dri->dri_Pens[SHADOWPEN]);
                Draw( RP, -1L + win->Width, -1L + win->Height);
                Draw( RP, 1, -1L + win->Height);
            }
        }

        SetFont( RP, lv->Font );
        SetDrMd( RP, JAM1);

        node = lv->Labels->lh_Head;

        for( i = 0, End = From + Count; node->ln_Succ ; i++ ) {
            if( i < lv->FitsItems ) {
                if( (i >= From) && ( i < End ) ) {
                    EGLV_DrawFrame( lv->popup_window, i, dri, node->ln_Name,
                        lv->Font, (BOOL)(i == lv->Temp_Active),
                        lv->NewLook, (ULONG)lv->ItemHeight );
                }
                else if( i >= End ) return;
            }

            node = node->ln_Succ;
        }
    }
}

static void EGLV_DrawFrame( struct Window *win,
                            int order,
                            struct DrawInfo *dri,
                            UBYTE *name,
                            struct TextFont *tf,
                            BOOL Active,
                            BOOL NewLook,
                            ULONG ItemHeight )
{
    ULONG   Pen1, Pen2, TextPen, BPen;
    ULONG   Top, Width, Bottom, MaxX,
            Len, TextWidth,
            font_height = tf->tf_YSize;
    struct  RastPort *RP = win->RPort;
    struct  TextExtent temp_te;

    TextPen = dri->dri_Pens[TEXTPEN];

    if( Active ) {
        if( NewLook ) {
            BPen = dri->dri_Pens[BARDETAILPEN];
            TextPen = dri->dri_Pens[BARBLOCKPEN];   /* Override previous value. */
        }
        else {
            Pen2 = dri->dri_Pens[SHINEPEN];
            Pen1 = dri->dri_Pens[SHADOWPEN];
            BPen = dri->dri_Pens[FILLPEN];
        }
    }
    else {
        if( NewLook ) {
            BPen = dri->dri_Pens[BARBLOCKPEN];
            TextPen = dri->dri_Pens[BARDETAILPEN];  /* Override previous value. */
        }
        else {
            Pen2 = dri->dri_Pens[SHADOWPEN];
            Pen1 = dri->dri_Pens[SHINEPEN];
            BPen = dri->dri_Pens[BACKGROUNDPEN];
        }
    }

    Top = 2 + order * ItemHeight;
    Bottom = Top + ItemHeight - 1;
    MaxX = win->Width - 4;

    SetAPen( RP, BPen );
    RectFill( RP, 4, Top, MaxX - 1, Bottom );

    if( NewLook == FALSE ) {    /* Draw Recessed Border. */
        SetAPen( RP, Pen1);
        Move( RP, 3, Bottom);
        Draw( RP, 3, Top );
        Draw( RP, MaxX, Top );
        SetAPen( RP, Pen2);
        Draw( RP, MaxX, Bottom );
        Draw( RP, 4, Bottom );
    }

    SetAPen( RP, TextPen);

    Width = win->Width - 10;

    Len = TextFit( RP, name, (ULONG)strlen(name), &temp_te, NULL, 1,
        Width, 1 + font_height);

    TextWidth = temp_te.te_Extent.MaxX - temp_te.te_Extent.MinX;

    Move( RP, 5 + (Width - TextWidth)/2 - temp_te.te_Extent.MinX,
        (ItemHeight - font_height)/2 + 1 + Top + tf->tf_Baseline );
    Text( RP, name, Len );
}

#endif
