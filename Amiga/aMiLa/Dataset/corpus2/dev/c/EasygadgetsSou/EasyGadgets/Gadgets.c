/*
 *	File:					Gadgets.c
 *	Description:	
 *
 *	(C) 1994,1995 Ketil Hunn
 *
 */

#ifndef EG_GADGETS_H
#define EG_GADGETS_H

/*** INCLUDES ************************************************************************/
#ifndef INTUITION_GADGETCLASS_H
#include <intuition/gadgetclass.h>
#endif

/*** GLOBALS *************************************************************************/
__chip static UWORD EG_GetDirImageData[]=
{
	0x03c0,	/* ......****...... */
	0x0420,	/* .....*....*..... */
	0xf810,	/* *****......*.... */
	0xfc10,	/* ******.....*.... */
	0xc3f0,	/* **....******.... */
	0xc010,	/* **.........*.... */
	0xc010,	/* **.........*.... */
	0xc010,	/* **.........*.... */
	0xc010,	/* **.........*.... */
	0xfff0,	/* ************.... */
};

__chip static UWORD EG_GetFileImageData[]=
{
	0xfc00,	/* ******.......... */
	0xca00,	/* **..*.*......... */
	0xc900,	/* **..*..*........ */
	0xc980,	/* **..*..**....... */
	0xcf80,	/* **..*****....... */
	0xc180,	/* **.....**....... */
	0xc180,	/* **.....**....... */
	0xc180,	/* **.....**....... */
	0xc180,	/* **.....**....... */
	0xff80,	/* *********....... */
};

__chip static UWORD EG_PopUpImageData[]=
{
	0x3800,	/* ..***........... */
	0x3800,	/* ..***........... */
	0x3800,	/* ..***........... */
	0xfe00,	/* *******......... */
	0x7c00,	/* .*****.......... */
	0x3800,	/* ..***........... */
	0x1000,	/* ...*............ */
	0x0000,	/* ................ */
	0xfe00,	/* *******......... */
};

/*** FUNCTIONS ***********************************************************************/
/*
__asm void egCalcGadgetImage(	register __a0 struct egImageExt	*eggad,
															register __a1 struct DrawInfo		*dri,
															register __a2 struct NewGadget	*ng,
															register __a3 UWORD							*imagedata,
															register __d0 ULONG							imagewidth,
															register __d1 ULONG							imageheight,
															register __d2	BYTE							imagedepth)
{
	UBYTE *data;
	struct RastPort	rp;
	ULONG	depth=dri->dri_Depth;
	ULONG	imagesize=(ng->ng_Width+15)/16*4*ng->ng_Height*depth;

#ifdef MYDEBUG_H
	DebugOut("egCalcGadgetImage");
#endif

	eggad->ImageBitMap.BytesPerRow	=2;
	eggad->ImageBitMap.Flags				=0;
	eggad->ImageBitMap.Depth				=imagedepth;
	eggad->ImageBitMap.pad					=0;
	eggad->ImageBitMap.Rows					=imageheight;

	eggad->ImageBitMap.Planes[0]		=
	eggad->ImageBitMap.Planes[1]		=
	eggad->ImageBitMap.Planes[2]		=
	eggad->ImageBitMap.Planes[3]		=
	eggad->ImageBitMap.Planes[4]		=
	eggad->ImageBitMap.Planes[5]		=
	eggad->ImageBitMap.Planes[6]		=
	eggad->ImageBitMap.Planes[7]		=(PLANEPTR)imagedata;

	if(data=AllocVec(imagesize, MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC))
	{
		ULONG planemask=(1L<<depth)-1;
		ULONG y=(ng->ng_Height-imageheight)/2,
					x=(ng->ng_Width-imagewidth)/2;
		register int i;
		register UBYTE *bitplane;
		register ULONG off=imagesize/depth/2;

		eggad->Image1.LeftEdge		=0;
		eggad->Image1.TopEdge			=0;
		eggad->Image1.Width				=ng->ng_Width;
		eggad->Image1.Height			=ng->ng_Height;
		eggad->Image1.Depth				=imagedepth;
		eggad->Image1.PlanePick		=planemask;
		eggad->Image1.PlaneOnOff	=0;
		eggad->Image1.NextImage		=NULL;
		eggad->Image1.ImageData		=(UWORD *)data;
		eggad->Image2							=eggad->Image1;
		eggad->Image2.ImageData		=(UWORD *)(data+imagesize/2);

		InitBitMap(&eggad->BitMap, depth, ng->ng_Width, ng->ng_Height);
		InitRastPort(&rp);
		rp.BitMap=&eggad->BitMap;

		for(bitplane=(PLANEPTR)eggad->Image1.ImageData, i=0; i<depth; i++, bitplane+=off)
			eggad->BitMap.Planes[i]=bitplane;

		SetRast(&rp, dri->dri_Pens[BACKGROUNDPEN]);
		DrawBevelBox(&rp,
									0, 0, ng->ng_Width, ng->ng_Height,
									GT_VisualInfo, ng->ng_VisualInfo,
									TAG_DONE);
//		BltBitMap(&eggad->ImageBitMap, 0, 0, &eggad->BitMap, x, y, imagewidth, imageheight, ABC|ABNC|ANBC, dri->dri_Pens[TEXTPEN],NULL);
		BltBitMap(&eggad->ImageBitMap, 0, 0, &eggad->BitMap, x, y, imagewidth, imageheight, 0xff, dri->dri_Pens[TEXTPEN],NULL);


		for(bitplane=(PLANEPTR)eggad->Image2.ImageData, i=0; i<depth; i++, bitplane+=off)
			eggad->BitMap.Planes[i]=bitplane;

		SetRast(&rp, dri->dri_Pens[FILLPEN]);
		DrawBevelBox(&rp, 0, 0, ng->ng_Width, ng->ng_Height,
									GT_VisualInfo,	ng->ng_VisualInfo,
									GTBB_Recessed,	FALSE,
									TAG_DONE);
		BltBitMap(&eggad->ImageBitMap, 0,0, &eggad->BitMap, x, y, imagewidth, imageheight, ANBC, planemask, NULL);
		BltBitMap(&eggad->ImageBitMap, 0,0, &eggad->BitMap, x, y, imagewidth, imageheight, ABC|ABNC|ANBC,	dri->dri_Pens[FILLTEXTPEN], NULL);
	}
}
*/

__asm void egCalcGadgetImage(	register __a0 struct egImageExt	*eggad,
															register __a1 struct DrawInfo		*dri,
															register __a2 struct NewGadget	*ng,
															register __a3 UWORD							*imagedata,
															register __d0 ULONG							imagewidth,
															register __d1 ULONG							imageheight,
															register __d2	BYTE							imagedepth)
{
	UBYTE *data;
	struct RastPort	rp;
	ULONG	depth=dri->dri_Depth;
	ULONG	imagesize=(ng->ng_Width+15)/16*4*ng->ng_Height*depth;

#ifdef MYDEBUG_H
	DebugOut("egCalcGadgetImage");
#endif

	eggad->ImageBitMap.BytesPerRow	=2;
	eggad->ImageBitMap.Flags				=0;
	eggad->ImageBitMap.Depth				=imagedepth;
	eggad->ImageBitMap.pad					=0;
	eggad->ImageBitMap.Rows					=imageheight;

	eggad->ImageBitMap.Planes[0]		=
	eggad->ImageBitMap.Planes[1]		=
	eggad->ImageBitMap.Planes[2]		=
	eggad->ImageBitMap.Planes[3]		=
	eggad->ImageBitMap.Planes[4]		=
	eggad->ImageBitMap.Planes[5]		=
	eggad->ImageBitMap.Planes[6]		=
	eggad->ImageBitMap.Planes[7]		=(PLANEPTR)imagedata;

	if(data=AllocVec(imagesize, MEMF_CLEAR|MEMF_CHIP|MEMF_PUBLIC))
	{
		ULONG planemask=(1L<<depth)-1;
		ULONG y=(ng->ng_Height-imageheight)/2,
					x=(ng->ng_Width-imagewidth)/2;

		eggad->Image1.LeftEdge		=0;
		eggad->Image1.TopEdge			=0;
		eggad->Image1.Width				=ng->ng_Width;
		eggad->Image1.Height			=ng->ng_Height;
		eggad->Image1.Depth				=imagedepth;
		eggad->Image1.PlanePick		=planemask;
		eggad->Image1.PlaneOnOff	=0;
		eggad->Image1.NextImage		=NULL;
		eggad->Image1.ImageData		=(UWORD *)data;
		eggad->Image2							=eggad->Image1;
		eggad->Image2.ImageData		=(UWORD *)(data+imagesize/2);

		InitBitMap(&eggad->BitMap, depth, ng->ng_Width, ng->ng_Height);
		InitRastPort(&rp);
		rp.BitMap=&eggad->BitMap;

		{
			register int i;
			register ULONG off=imagesize/depth/2;
			register UBYTE *pl=(UBYTE *)eggad->Image1.ImageData;

			for(i=0; i<depth; i++, pl+=off)
				eggad->BitMap.Planes[i]=pl;
		}

		SetRast(&rp, dri->dri_Pens[BACKGROUNDPEN]);
		DrawBevelBox(&rp,
									0, 0, ng->ng_Width, ng->ng_Height,
									GT_VisualInfo, ng->ng_VisualInfo,
									TAG_DONE);
		BltBitMap(&eggad->ImageBitMap, 0, 0, &eggad->BitMap, x, y, imagewidth, imageheight, ABC|ABNC|ANBC, dri->dri_Pens[TEXTPEN],NULL);

		{
			register int i;
			register ULONG off=imagesize/depth/2;
			register UBYTE *pl=(UBYTE *)eggad->Image2.ImageData;

			for(i=0; i<depth; i++, pl+=off)
				eggad->BitMap.Planes[i]=pl;
		}




		SetRast(&rp, dri->dri_Pens[FILLPEN]);
		DrawBevelBox(&rp, 0, 0, ng->ng_Width, ng->ng_Height,
									GT_VisualInfo,	ng->ng_VisualInfo,
									GTBB_Recessed,	FALSE,
									TAG_DONE);
		BltBitMap(&eggad->ImageBitMap, 0,0, &eggad->BitMap, x, y, imagewidth, imageheight, ANBC, planemask, NULL);
		BltBitMap(&eggad->ImageBitMap, 0,0, &eggad->BitMap, x, y, imagewidth, imageheight, ABC|ABNC|ANBC,	dri->dri_Pens[FILLTEXTPEN], NULL);
	}
}

__asm __saveds void egFreeGList(register __a0 struct egTask *task)
{
	register struct egGadget *gad=task->eglist;

#ifdef MYDEBUG_H
	DebugOut("egFreeGList");
#endif

	RemoveGList(task->window, task->glist, -1);
	FreeGadgets(task->glist);
	task->glist=NULL;

	while(gad)
	{
		register struct egGadget *egGad=gad;

		if(egGad->imageext)
		{
			FreeVec(egGad->imageext->Image1.ImageData);
			FreeVec(egGad->imageext);
		}
		if(egGad->kind==EG_GROUP_KIND)
			DisposeObject((Object *)egGad->gadget);

		gad=egGad->NextGadget;
		FreeVec(egGad);
	}
	task->eglist=NULL;
}

__asm __saveds void egRenderGadgets(register __a0 struct egTask *task)
{
#ifdef MYDEBUG_H
	DebugOut("egRenderGadgets");
#endif
	if(task->oldWidth!=task->window->Width || task->oldHeight!=task->window->Height)
	{
		EraseRect(task->window->RPort,
							task->window->BorderLeft,
							task->window->BorderTop,
							MIN(task->window->Width,  task->oldWidth)	-task->window->BorderRight-1,
							MIN(task->window->Height, task->oldHeight)-task->window->BorderBottom-1);

		task->oldWidth	=task->window->Width;
		task->oldHeight	=task->window->Height;
	}
	AddGList(task->window, task->glist, -1, -1, NULL);
	RefreshGList(task->glist, task->window, NULL, -1);
	GT_RefreshWindow(task->window, NULL);
	if(task->lock && ISBITSET(task->flags, TASK_GHOSTWHENBLOCKED))
		egGhostRect(task->window->RPort,
								task->window->BorderLeft,	task->window->BorderTop,
								task->window->Width-task->window->BorderRight-1,
								task->window->Height-task->window->BorderBottom-1,
								1);

	task->coords.LeftEdge	=task->window->LeftEdge;
	task->coords.TopEdge	=task->window->TopEdge;
	task->coords.Width		=task->window->Width;
	task->coords.Height		=task->window->Height;
}

__asm __saveds struct egGadget *egCreateGadgetA(register __a1 struct EasyGadgets *eg,
																								register __a0 struct TagItem *taglist)
{
	struct egGadget	*newgad,
									*tmpgad;
	UWORD *genericImage;
	BYTE imageDepth=1;
	WORD	genericImageWidth, genericImageHeight;

#ifdef MYDEBUG_H
	DebugOut("egCreateGadgetA");
#endif

	if(newgad=(struct egGadget *)AllocVec(sizeof(struct egGadget), MEMF_CLEAR|MEMF_PUBLIC))
	{
		struct TagItem	*tstate;
		register struct TagItem	*tag;

		newgad->active=EG_LISTVIEW_NONE;
		tstate=taglist;
		while(tag=NextTagItem(&tstate))
			switch(tag->ti_Tag)
			{
				case EG_GadgetKind:
					eg->GadgetKind=tag->ti_Data;
					break;
				case EG_TextAttr:
					eg->ng.ng_TextAttr=(struct TextAttr *)tag->ti_Data;
					break;
				case EG_VisualInfo:
					eg->ng.ng_VisualInfo=(void *)tag->ti_Data;
					break;
				case EG_LeftEdge:
					eg->ng.ng_LeftEdge=(WORD)tag->ti_Data;
					break;
				case EG_TopEdge:
					eg->ng.ng_TopEdge=(WORD)tag->ti_Data;
					break;
				case EG_Width:
					eg->ng.ng_Width=(WORD)tag->ti_Data;
					break;
				case EG_Height:
					eg->ng.ng_Height=(WORD)tag->ti_Data;
					break;
				case EG_GadgetText:
					eg->ng.ng_GadgetText=(char *)tag->ti_Data;
					break;
				case EG_GadgetID:
					eg->ng.ng_GadgetID=(UWORD)tag->ti_Data;
					break;
				case EG_Flags:
					eg->ng.ng_Flags=tag->ti_Data;
					break;
				case EG_ParentGadget:
					eg->gad=(struct Gadget *)tag->ti_Data;
					break;
				case EG_Window:
					eg->Window=(struct Window *)tag->ti_Data;
					break;
				case GA_Disabled:
					IFTRUESETBIT(tag->ti_Data, newgad->flags, EG_DISABLED);
					break;
				case EG_PlaceLeft:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_LeftEdge=X1(tmpgad)-eg->HSpace-eg->ng.ng_Width;
					break;
				case EG_PlaceRight:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_LeftEdge=X2(tmpgad)+eg->HSpace;
					break;
				case EG_PlaceBelow:
					tmpgad=(struct egGadget *)tag->ti_Data;
					switch(tmpgad->kind)
					{
						case MX_KIND:
							{
								register UWORD i=0, height=MAX(eg->MXHeight, tmpgad->ng.ng_TextAttr->ta_YSize);

								while(tmpgad->labels[i])
									++i;
								eg->ng.ng_TopEdge=Y1(tmpgad)+i*height+(i-1)*eg->VSpace+eg->VSpace;
							}
							break;
						default:
							eg->ng.ng_TopEdge=Y2(tmpgad)+eg->VSpace;
							break;
					}
					break;
				case EG_PlaceOver:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_TopEdge=Y1(tmpgad)-eg->VSpace-eg->ng.ng_Height;
					break;
				case EG_AlignLeft:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_LeftEdge=X1(tmpgad);
					break;
				case EG_AlignTop:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_TopEdge=Y1(tmpgad);
					break;
				case EG_AlignRight:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_LeftEdge=X2(tmpgad)-eg->ng.ng_Width;
					break;
				case EG_AlignBottom:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_TopEdge=Y2(tmpgad)-eg->ng.ng_Height;
					break;
				case EG_AlignCentreH:
//					tmpgad=(struct egGadget *)tag->ti_Data;
					break;
				case EG_AlignCentreV:
//					tmpgad=(struct egGadget *)tag->ti_Data;
					break;
				case EG_CloneWidth:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_Width=W(tmpgad);
					break;
				case EG_CloneHeight:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_Height=H(tmpgad);
					break;
				case EG_CloneSize:
					tmpgad=(struct egGadget *)tag->ti_Data;
					eg->ng.ng_Height=H(tmpgad);
					eg->ng.ng_Width=W(tmpgad);
					break;
				case EG_PlaceWindowLeft:
					eg->ng.ng_LeftEdge=eg->LeftMargin;
					if(ISBITSET(eg->ng.ng_Flags, PLACETEXT_LEFT) && eg->ng.ng_GadgetText)
						eg->ng.ng_LeftEdge+=EG_LabelSpace+egTextWidth(eg, eg->ng.ng_GadgetText);
					break;
				case EG_PlaceWindowRight:
					eg->ng.ng_LeftEdge=eg->Window->Width-eg->RightMargin-eg->ng.ng_Width;
					if(ISBITSET(eg->ng.ng_Flags, PLACETEXT_RIGHT))
						if(eg->ng.ng_GadgetText)
							eg->ng.ng_LeftEdge-=EG_LabelSpace+egTextWidth(eg, eg->ng.ng_GadgetText);
					break;
				case EG_PlaceWindowTop:
					eg->ng.ng_TopEdge=eg->TopMargin;
					if(ISBITSET(eg->ng.ng_Flags, PLACETEXT_ABOVE) && eg->ng.ng_GadgetText)
						eg->ng.ng_TopEdge+=4+eg->font->tf_YSize;
					break;
				case EG_PlaceWindowBottom:
					eg->ng.ng_TopEdge=eg->Window->Height-eg->ng.ng_Height;
					if(ISBITSET(eg->Window->Flags, WFLG_SIZEBBOTTOM))
						eg->ng.ng_TopEdge-=eg->BottomMargin;
					else
						eg->ng.ng_TopEdge-=eg->BottomMarginNoSize;

					if(ISBITSET(eg->ng.ng_Flags, PLACETEXT_BELOW) && eg->ng.ng_GadgetText)
						eg->ng.ng_TopEdge-=4-eg->font->tf_YSize;
					break;
				case EG_HSpace:
					eg->ng.ng_LeftEdge+=(WORD)tag->ti_Data;
					break;
				case EG_VSpace:
					eg->ng.ng_TopEdge+=(WORD)tag->ti_Data;
					break;
				case GTCY_Labels:
				case GTMX_Labels:
					newgad->labels=(STRPTR *)tag->ti_Data;
					break;
				case GTLV_Labels:
					newgad->list=(struct List *)tag->ti_Data;
					newgad->max=MAX(0, (egCountList(newgad->list)-1));
					break;
				case GTLV_ReadOnly:
					SETBIT(newgad->flags, EG_READONLY);
					break;
				case GTCY_Active:
				case GTMX_Active:
				case GTCB_Checked:
				case GTLV_Selected:
				case GTSL_Level:
					newgad->active=(LONG)tag->ti_Data;
					break;
				case GTSL_Min:
					newgad->min=(WORD)tag->ti_Data;
					break;
				case GTSL_Max:
					newgad->max=(WORD)tag->ti_Data;
					break;
				case GTPA_Depth:
					newgad->max=(WORD)1<<tag->ti_Data;
					break;
				case EG_HelpNode:
					newgad->helpnode=(UBYTE *)tag->ti_Data;
					break;
				case EG_VanillaKey:
					newgad->key=(UBYTE)tag->ti_Data;
					break;
				case EG_Link:
					newgad->link=(struct egGadget *)tag->ti_Data;
					break;
				case EG_Arrows:
					IFTRUESETBIT(tag->ti_Data, newgad->flags, EG_LISTVIEWARROWS);
					break;
				case EG_DefaultWidth:
					switch(eg->GadgetKind)
					{
						case SLIDER_KIND:
						case SCROLLER_KIND:
							eg->ng.ng_Width=eg->SliderWidth;
							break;
						case MX_KIND:
							eg->ng.ng_Width=eg->MXWidth;
							break;
						case CHECKBOX_KIND:
							eg->ng.ng_Width=eg->CheckboxWidth;
							break;
						case EG_GETFILE_KIND:
							eg->ng.ng_Width=EG_GetfileWidth;
							break;
						case EG_POPUP_KIND:
							eg->ng.ng_Width=EG_PopupWidth;
							break;
						case EG_GETDIR_KIND:
							eg->ng.ng_Width=EG_GetdirWidth;
							break;
						default:
//							eg->ng.ng_Width=egTextWidth(eg->RPort, eg->ng.ng_GadgetText)+eg->HInside;
							eg->ng.ng_Width=egTextWidth(eg, eg->ng.ng_GadgetText)+eg->HInside;
							break;
					}
					break;
				case EG_DefaultHeight:
					switch(eg->GadgetKind)
					{
						case SLIDER_KIND:
						case SCROLLER_KIND:
							eg->ng.ng_Height=eg->SliderHeight;
							break;
						case MX_KIND:
							eg->ng.ng_Height=eg->MXHeight;
							break;
						case CHECKBOX_KIND:
							eg->ng.ng_Height=eg->CheckboxHeight;
							break;
						default:
							eg->ng.ng_Height=eg->DefaultHeight;
							break;
					}
					break;

				case EG_Image:
					genericImage=(UWORD *)tag->ti_Data;
					break;
				case EG_ImageWidth:
					genericImageWidth=(WORD)tag->ti_Data;
					break;
				case EG_ImageHeight:
					genericImageHeight=(WORD)tag->ti_Data;
					break;
				case EG_ImageDepth:
					imageDepth=(BYTE)tag->ti_Data;
					break;
		}

		newgad->kind=eg->GadgetKind;

		switch(eg->GadgetKind)
		{
			case EG_GROUP_KIND:
				eg->gad=NewObject(eg->groupframeclass, NULL,
													GA_Left,			eg->ng.ng_LeftEdge,
													GA_Top,				eg->ng.ng_TopEdge,
													GA_Width,			eg->ng.ng_Width,
													GA_Height,		eg->ng.ng_Height,
													GA_Previous,	eg->gad,
													TAG_MORE,			taglist,
													TAG_DONE);
				break;
			default:
				eg->gad=CreateGadget((newgad->kind>=EG_GETFILE_KIND ? GENERIC_KIND : newgad->kind),
														eg->gad,
														&eg->ng,
														GT_Underscore,		EG_Underscorechar,
														GTCB_Scaled,			TRUE,
														GTMX_Scaled,			TRUE,
														GTMX_Spacing,			eg->VSpace,
														STRINGA_ExitHelp,	TRUE,
														TAG_MORE,					taglist,
														TAG_END);
				break;
		}
		if(eg->gad)
		{
			newgad->ng=eg->ng;
			newgad->gadget=eg->gad;
			if(newgad->ng.ng_GadgetText && newgad->kind!=TEXT_KIND)
				newgad->key=egFindVanillaKey(newgad->ng.ng_GadgetText);

			if(newgad->helpnode==NULL)
				newgad->helpnode=eg->lasthelpnode;
			eg->lasthelpnode=newgad->helpnode;

			if(eg->eggad==NULL)
				eg->tmptask->eglist=newgad;
			else
				eg->eggad->NextGadget=newgad;
			eg->eggad=newgad;

			switch(newgad->kind)
			{
				case LISTVIEW_KIND:
				case MX_KIND:
					newgad->ng.ng_Height=eg->gad->Height;
					newgad->ng.ng_Width	=eg->gad->Width;
					break;
				case CHECKBOX_KIND:	
					newgad->ng.ng_Width	=eg->gad->Width;
					break;
			}

			if(newgad->kind>=EG_GETFILE_KIND)
			{
				switch(newgad->kind)
				{
					case EG_DUMMY_KIND:
						newgad->gadget->GadgetType	 |=GTYP_BOOLGADGET;
						newgad->gadget->Flags					=GFLG_GADGHIMAGE|GFLG_GADGIMAGE;
						newgad->gadget->Activation		=0;
						newgad->gadget->GadgetRender	=NULL;
						newgad->gadget->SelectRender	=NULL;
						break;
					default:
						if(newgad->imageext=(struct egImageExt *)AllocVec(sizeof(struct egImageExt), MEMF_CLEAR|MEMF_PUBLIC))
						{
							switch(newgad->kind)
							{
								case EG_GETFILE_KIND:		
									egCalcGadgetImage(newgad->imageext, eg->dri, &eg->ng, EG_GetFileImageData, 9, 10,1);
									break;
								case EG_GETDIR_KIND:		
									egCalcGadgetImage(newgad->imageext, eg->dri, &eg->ng, EG_GetDirImageData, 12, 10,1);
									break;
								case EG_POPUP_KIND:		
									egCalcGadgetImage(newgad->imageext, eg->dri, &eg->ng, EG_PopUpImageData, 7, 9,1);
									break;
								case EG_IMAGE_KIND:
									egCalcGadgetImage(newgad->imageext, eg->dri, &eg->ng,
										genericImage, genericImageWidth, genericImageHeight, imageDepth);
									break;
							}
							eg->gad->GadgetType	 |=GTYP_BOOLGADGET;
							eg->gad->Flags				=GFLG_GADGHIMAGE|GFLG_GADGIMAGE;
							eg->gad->Activation		=GACT_RELVERIFY;
							eg->gad->GadgetRender	=&newgad->imageext->Image1;
							eg->gad->SelectRender	=&newgad->imageext->Image2;
						}
						break;
				}
				if(ISBITSET(newgad->flags, EG_DISABLED))
					OffGadget(eg->gad, eg->Window, NULL);
			}
			return newgad;
		}
	}
	return NULL;
}

__asm __saveds void egCreateContext(register __a0 struct EasyGadgets	*eg,
																		register __a1 struct egTask				*task)
{
#ifdef MYDEBUG_H
	DebugOut("egCreateContext");
#endif
	task->glist			=NULL;
	eg->gad					=CreateContext(&task->glist);
	task->activegad	=task->eglist=NULL;
	eg->tmptask			=task;
	eg->eggad				=NULL;
	task->activekey	=0;
	eg->dri					=task->dri;
	eg->ng.ng_VisualInfo	=task->VisualInfo;
}

__asm BYTE IsNil(register __a0 struct List *list)
{
	if(list==NULL)
		return 1;
	return (BYTE)(IsListEmpty(list));
}

#endif
