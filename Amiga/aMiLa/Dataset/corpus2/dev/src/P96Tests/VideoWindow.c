#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <intuition/intuition.h>
#include <intuition/imageclass.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/rtg.h>

#include	<stdio.h>
#include	<math.h>

char template[] = "Width=W/N,Height=H/N,Pubscreen=PS/K,Interlace=IL/S";
char *array[] = {NULL, NULL, "Workbench", NULL};

#define	MATCH_RED	0x11
#define	MATCH_GREEN	0x00
#define	MATCH_BLUE	0x11

#ifndef IM
#define IM(o) ((struct Image *) o)
#endif

#define B_GID	1
#define S_GID	2

struct DrawInfo *dri;
Object *bgadget, *sgadget, *sizeimage;

/* Creates a sysiclass object. */
Object *NewImageObject(ULONG which)
{
	return (NewObject(NULL, SYSICLASS,
	 SYSIA_DrawInfo, dri,
	 SYSIA_Which, which,
	 SYSIA_Size, SYSISIZE_HIRES,
	TAG_DONE));
}

/* Creates a buttongclass object. */
Object *NewButtonObject(Object *image, Tag tag1, ...)
{
	return (NewObject(NULL, BUTTONGCLASS,
	 ICA_TARGET, ICTARGET_IDCMP,
	 GA_Image, image,
	/* No need for GA_Width/Height.  buttongclass is smart :) */
	TAG_MORE, &tag1));
}

/* Creates a propgclass object. */
Object *NewPropObject(ULONG freedom, Tag tag1, ...)
{
	return (NewObject(NULL, PROPGCLASS,
	/* Send update to IDCMP.  If we make it a model, we would send the
	 * notification to our model object. */
	 ICA_TARGET, ICTARGET_IDCMP,
	 PGA_Freedom, freedom,
	 PGA_NewLook, TRUE,
	/* Borderless does only look right with newlook screens */
	 PGA_Borderless, ((dri->dri_Flags & DRIF_NEWLOOK) && dri->dri_Depth != 1),
	TAG_MORE, &tag1));
}


main(void)
{
	struct RTGBase *RTGBase;
	struct RDArgs	*rda = NULL;
	LONG	Width = 336, Height = 286;
	LONG	pen;

	if(rda = ReadArgs(template,(LONG *)array,NULL)){
		if(array[3]){
			Width += Width;
			Height += Height;
		}
		if(array[0])	Width =*((LONG *)array[0]);
		if(array[1])	Height=*((LONG *)array[1]);
	}

	/* Later, the application programmer will have to open Picasso96API.library !!! */

	if(RTGBase=(struct RTGBase *)OpenLibrary("picasso96/rtg.library",40)){

		struct Screen		*sc;

		if(sc = LockPubScreen(array[2])){
			struct Window		*wd;

			if(dri = GetScreenDrawInfo(sc)){
				pen = ObtainPen(sc->ViewPort.ColorMap, -1,
									(MATCH_RED<<24)|(MATCH_RED<<16)|(MATCH_RED<<8)|(MATCH_RED),
									(MATCH_GREEN<<24)|(MATCH_GREEN<<16)|(MATCH_GREEN<<8)|(MATCH_GREEN),
									(MATCH_BLUE<<24)|(MATCH_BLUE<<16)|(MATCH_BLUE<<8)|(MATCH_BLUE),
									PEN_EXCLUSIVE);
				if(pen != -1){
					struct SpecialFeature	*spec;

					ULONG Color = pen;
					RGBFTYPE ScreenFormat = rtgGetBitMapAttr(NULL, sc->RastPort.BitMap, GBMA_RGBFORMAT);

					if(!((1<<ScreenFormat) & (RGBFF_PLANAR | RGBFF_CHUNKY))){
						Color = rtgEncodeColor(MATCH_RED, MATCH_GREEN, MATCH_BLUE, ScreenFormat);
					}

					if(spec = rtgCreateSpecialFeatureTags(sc, SFT_VIDEOWINDOW,
																			FA_Format, RGBFB_Y4U2V2,
																			FA_Color, Color,
																			FA_Interlace, (array[3] ? TRUE : FALSE),
																			FA_SourceWidth, Width,
																			FA_SourceHeight, Height,
																			TAG_DONE)){

						ULONG	MinWidth = Width, MinHeight = Height, MaxWidth = Width, MaxHeight = Height;
						WORD w = 2;
						WORD h = 2;

						rtgGetSpecialFeatureAttrsTags(spec,
																FA_MinWidth, &MinWidth,
																FA_MinHeight, &MinHeight,
																FA_MaxWidth, &MaxWidth,
																FA_MaxHeight, &MaxHeight,
																TAG_DONE);

						if(sizeimage = NewImageObject(SIZEIMAGE)){
							w = IM(sizeimage)->Width;
							h = IM(sizeimage)->Height;
							DisposeObject(sizeimage);
						}

						bgadget = NewPropObject(FREEVERT,
														GA_RelRight, - w - 1,
														GA_Top, sc->WBorTop + sc->Font->ta_YSize + 3,
														GA_Width, w - 2,
														GA_RelHeight, - sc->WBorTop - sc->Font->ta_YSize - h - 5,
														GA_RightBorder, TRUE,
														GA_ID, B_GID,
														PGA_Total, 256,
														PGA_Visible, 1,
														TAG_DONE);

/*
						sgadget = NewButtonObject(NULL,
														GA_RelRight, - w - 1,
														GA_Top, sc->WBorTop + sc->Font->ta_YSize + 3,
														GA_Width, w - 2,
														GA_RelHeight, - Height + h,
														GA_RightBorder, TRUE,
														GA_ID, S_GID,
														GA_Previous, bgadget,
														TAG_DONE);
*/

//						if(bgadget && sgadget){
						if(bgadget){

							if(wd=OpenWindowTags(NULL,
														WA_Title, "PicassoIV VideoWindow Test",
														WA_Activate, TRUE,
														WA_RMBTrap, TRUE,
														WA_Left, (sc->Width-Width)/2,
														WA_Top, (sc->Height-Height)/2,
														WA_InnerWidth, Width,
														WA_InnerHeight, Height,
														WA_DragBar, TRUE,
														WA_NotifyDepth, TRUE,
														WA_DepthGadget, TRUE,
														WA_SimpleRefresh, TRUE,
														WA_SizeGadget, TRUE,
														WA_CloseGadget, TRUE,
														WA_Gadgets, bgadget,
														WA_IDCMP, IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|IDCMP_CHANGEWINDOW|IDCMP_ACTIVEWINDOW|IDCMP_INACTIVEWINDOW|IDCMP_IDCMPUPDATE,
														WA_PubScreen, sc, TAG_DONE)){

								struct ExtraData data;

								data.Special = spec;
								if(rtgCreateHashExtra(wd->RPort->Layer, &data)){
									struct Message	*msg;
									BOOL	goahead = TRUE;
									BOOL	front = TRUE;

									WindowToFront(wd);
									WindowLimits(wd,	MinWidth+wd->BorderLeft+wd->BorderRight,
															MinHeight+wd->BorderTop+wd->BorderBottom,
															MaxWidth+wd->BorderLeft+wd->BorderRight,
															MaxHeight+wd->BorderTop+wd->BorderBottom);

									SetAPen(wd->RPort, pen);
									RectFill(wd->RPort,
												wd->BorderLeft, wd->BorderTop,
												wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);

									rtgSetSpecialFeatureAttrsTags(spec,
										FA_Occlusion, FALSE,
										FA_Active, TRUE,
										FA_Left, wd->LeftEdge + wd->BorderLeft,
										FA_Top, wd->TopEdge + wd->BorderTop,
										FA_Width, wd->Width - wd->BorderLeft - wd->BorderRight,
										FA_Height, wd->Height - wd->BorderTop - wd->BorderBottom,
										TAG_DONE);

									do{
										ULONG brightness = 0;
										BOOL	size = FALSE;

										WaitPort(wd->UserPort);
										while(msg = GetMsg(wd->UserPort)){
											struct IntuiMessage	*imsg = (struct IntuiMessage *)msg;
											switch(imsg->Class){
												case	IDCMP_CLOSEWINDOW:
													goahead = FALSE;
													break;
												case	IDCMP_ACTIVEWINDOW:
	//												front = (wd->WLayer->front ? FALSE : TRUE);
													break;
												case	IDCMP_INACTIVEWINDOW:
	//												front = FALSE;
													break;
												case	IDCMP_CHANGEWINDOW:
													switch(imsg->Code){
														case	CWCODE_MOVESIZE:
															size = TRUE;	
															break;
														case	CWCODE_DEPTH:
	//														front = (wd->WLayer->front ? FALSE : TRUE);
															break;
													}
													break;
												case	IDCMP_REFRESHWINDOW:
													BeginRefresh(wd);
													RectFill(wd->RPort,
																wd->BorderLeft, wd->BorderTop,
																wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);
													EndRefresh(wd, TRUE);
													break;
												case IDCMP_IDCMPUPDATE:
													/* IAddress is a pointer to a taglist with new attributes.
													 * We are only interested in the ID of the involved gadget.
													 */
													switch (GetTagData(GA_ID, 0, (struct TagItem *) imsg->IAddress)){
													case	B_GID:
														{

															/* Get right place */
															GetAttr(PGA_Top, bgadget, &brightness);
	//														printf("Brightness: %ld\n",brightness);
														}
														break;
													}
											}
											ReplyMsg(msg);
										}
										rtgSetSpecialFeatureAttrsTags(spec,
	//										FA_Occlusion, !front,
											FA_Brightness, brightness,
											FA_Left, wd->LeftEdge + wd->BorderLeft,
											FA_Top, wd->TopEdge + wd->BorderTop,
											FA_Width, wd->Width - wd->BorderLeft - wd->BorderRight,
											FA_Height, wd->Height - wd->BorderTop - wd->BorderBottom,
											TAG_DONE);
									}while(goahead);

									rtgSetSpecialFeatureAttrsTags(spec, FA_Active, FALSE, TAG_DONE);

									SetAPen(wd->RPort, 0);
									RectFill(wd->RPort,
												wd->BorderLeft, wd->BorderTop,
												wd->Width - 1 - wd->BorderRight, wd->Height - 1 - wd->BorderBottom);

									Forbid();
									while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
									Permit();

									rtgDisposeHashExtra(wd->RPort->Layer);
								}
								CloseWindow(wd);
							}
//							DisposeObject(sgadget);
							DisposeObject(bgadget);
						}
						rtgDeleteSpecialFeature(spec);
					}
					ReleasePen(sc->ViewPort.ColorMap, pen);
				}
				FreeScreenDrawInfo(sc, dri);
			}
			UnlockPubScreen(NULL, sc);
		}
		CloseLibrary((struct Library *)RTGBase);
	}
	if(rda) FreeArgs(rda);
}
