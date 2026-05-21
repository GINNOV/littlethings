(*
Copyright (c) 1994 - 2000 Marc Necker.

This file is part of Analay (v2.0).
http://www.analay.de

Analay is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2
as published by the Free Software Foundation.

Analay is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Analay.  If not, see <https://www.gnu.org/licenses/>.
*)


MODULE RawGadgets;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       d  : Dos,
       s  : SYSTEM,
       u  : Utility,
       gt : GadTools,
       gd : Gadgets,
       st : Strings,
       NoGuruRq;

VAR vinfo     * : gt.VisualInfo;
    textattr  * : g.TextAttrPtr;
    screen    * : I.ScreenPtr;
    busy        : BOOLEAN;


PROCEDURE StartGadgets*(scr:I.ScreenPtr;text:g.TextAttrPtr):gt.VisualInfo;

VAR exit : BOOLEAN;

BEGIN
  exit:=FALSE;
  REPEAT
    WHILE busy DO
      d.Delay(10);
    END;
    e.Forbid();
    IF NOT(busy) THEN
      busy:=TRUE;
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;
  screen:=scr;
  textattr:=text;
  vinfo:=NIL;
  vinfo:=gt.GetVisualInfo(screen,u.done);
  RETURN vinfo;
END StartGadgets;

PROCEDURE StartGadgetsAgain*(scr:I.ScreenPtr;text:g.TextAttrPtr;vi:gt.VisualInfo);

VAR exit : BOOLEAN;

BEGIN
  exit:=FALSE;
  REPEAT
    WHILE busy DO
      d.Delay(10);
    END;
    e.Forbid();
    IF NOT(busy) THEN
      busy:=TRUE;
      exit:=TRUE;
    END;
    e.Permit();
  UNTIL exit;
  screen:=scr;
  textattr:=text;
  vinfo:=vi;
END StartGadgetsAgain;

PROCEDURE EndGadgets*;

BEGIN
  busy:=FALSE;
END EndGadgets;

PROCEDURE SetBooleanGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  gadget:=gt.CreateGadget(gt.buttonKind,prev,newgad,I.gaImmediate,I.LTRUE,
                                                    gt.underscore,s.VAL(SHORTINT,"_"),
                                                    u.done);
  prev:=gadget;
  RETURN gadget;
END SetBooleanGadget;

PROCEDURE SetStringGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;maxchars:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  gadget:=gt.CreateGadget(gt.stringKind,prev,newgad,I.gaImmediate,I.LTRUE,
                                                    gt.underscore,s.VAL(SHORTINT,"_"),
                                                    I.gaTabCycle,I.LTRUE,
                                                    gt.stString,0,
                                                    gt.stMaxChars,maxchars,
                                                    I.stringaExitHelp,I.LTRUE,
                                                    u.done);
  prev:=gadget;
  RETURN gadget;
END SetStringGadget;

PROCEDURE GetString*(gadget:I.GadgetPtr;VAR string:ARRAY OF CHAR);

VAR specialInfo : I.StringInfoPtr;
    i           : LONGINT;

BEGIN
(*  i:=gt.GetGadgetAttrs(gadget,NIL,NIL,gt.stString,s.ADR(string),
                                      u.done);*)
  specialInfo:=gadget.specialInfo;
  COPY(specialInfo.buffer^,string);
END GetString;

PROCEDURE SetString*(gadget:I.GadgetPtr;string:ARRAY OF CHAR);

VAR specialInfo : I.StringInfoPtr;

BEGIN
(*  gt.SetGadgetAttrs(gadget^,NIL,NIL,gt.stString,s.ADR(string),
                                    u.done);*)
  specialInfo:=gadget.specialInfo;
  COPY(string,specialInfo.buffer^);
END SetString;

PROCEDURE SetCheckBoxGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;checked:BOOLEAN;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;
    long   : LONGINT;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  IF checked THEN
    long:=I.LTRUE;
  ELSE
    long:=I.LFALSE;
  END;
  gadget:=gt.CreateGadget(gt.checkBoxKind,prev,newgad,gt.underscore,s.VAL(SHORTINT,"_"),
                                                      gt.cbChecked,long,
                                                      gt.cbScaled,I.LTRUE,
                                                      u.done);
  prev:=gadget;
  RETURN gadget;
END SetCheckBoxGadget;

PROCEDURE SetCycleGadget*(x,y,wi,he:INTEGER;title:e.STRPTR;texts:s.ADDRESS;numactive:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=title;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  gadget:=gt.CreateGadget(gt.cycleKind,prev,newgad,gt.underscore,s.VAL(SHORTINT,"_"),
                                                   gt.cyLabels,texts,
                                                   gt.cyActive,numactive,
                                                   u.done);
  prev:=gadget;
  RETURN gadget;
END SetCycleGadget;

PROCEDURE ChangeCycleGadget*(gadget:I.GadgetPtr;wind:I.WindowPtr;texts:s.ADDRESS;numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gadget^,wind,NIL,gt.cyLabels,texts,
                                     gt.cyActive,numactive,
                                     u.done);
END ChangeCycleGadget;

PROCEDURE SetRadioGadget*(x,y,wi,he:INTEGER;title:e.STRPTR;texts:s.ADDRESS;numactive,spacing:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=title;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  gadget:=gt.CreateGadget(gt.mxKind,prev,newgad,gt.underscore,s.VAL(SHORTINT,"_"),
                                                gt.mxLabels,texts,
                                                gt.mxActive,numactive,
                                                gt.mxSpacing,spacing,
                                                gt.mxScaled,I.LTRUE,
                                                u.done);
  prev:=gadget;
  RETURN gadget;
END SetRadioGadget;

PROCEDURE ChangeRadioGadget*(gadget:I.GadgetPtr;wind:I.WindowPtr;texts:s.ADDRESS;numactive:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gadget^,wind,NIL,gt.mxLabels,texts,
                                     gt.mxActive,numactive,
                                     u.done);
END ChangeRadioGadget;

PROCEDURE SetPaletteGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;depth,numcols,actcol:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;
    i      : LONGINT;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  IF numcols<=0 THEN
    numcols:=1;
    FOR i:=1 TO depth DO
      numcols:=numcols*2;
    END;
  END;
  gadget:=gt.CreateGadget(gt.paletteKind,prev,newgad,gt.underscore,s.VAL(SHORTINT,"_"),
                                                     gt.paDepth,depth,
                                                     gt.paColor,actcol,
                                                     gt.paNumColors,numcols,
                                                     gt.paIndicatorWidth,wi DIV 10,
                                                     gt.paIndicatorHeight,he,
                                                     u.done);
  prev:=gadget;
  RETURN gadget;
END SetPaletteGadget;

PROCEDURE SetScrollerGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;total,visible,top:LONGINT;arrows:BOOLEAN;orientation:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;
    arr    : LONGINT;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  IF arrows THEN
    arr:=textattr.ySize+2;
  ELSE
    arr:=0;
  END;
  gadget:=gt.CreateGadget(gt.scrollerKind,prev,newgad,I.gaImmediate,I.LTRUE,
                                                      I.gaRelVerify,I.LTRUE,
                                                      gt.underscore,s.VAL(SHORTINT,"_"),
                                                      gt.scTop,top,
                                                      gt.scTotal,total,
                                                      gt.scVisible,visible,
                                                      gt.scArrows,arr,
                                                      I.pgaFreedom,orientation,
                                                      u.done);
  prev:=gadget;
  RETURN gadget;
END SetScrollerGadget;

PROCEDURE GetScroller*(gadget:I.GadgetPtr;wind:I.WindowPtr):INTEGER;

VAR specialInfo : I.PropInfoPtr;
    top,i       : LONGINT;

BEGIN

  (* V39 required *)

  IF gt.base.version>=39 THEN
    i:=gt.GetGadgetAttrs(gadget,wind,NIL,gt.scTop,s.ADR(top),
                                         u.done);
  END;
  RETURN SHORT(top);
(*  specialInfo:=gadget.specialInfo;
  IF specialInfo#NIL THEN
    IF orientation=I.lorientVert THEN
      pot:=I.UIntToLong(specialInfo.vertPot);
    ELSE
      pot:=I.UIntToLong(specialInfo.horizPot);
    END;
    i:=total-visible;
    IF i<0 THEN
      i:=0;
    END;
    RETURN SHORT(SHORT((i/65525)*pot));
  ELSE
    RETURN -1;
  END;*)
END GetScroller;

PROCEDURE SetScroller*(gadget:I.GadgetPtr;wind:I.WindowPtr;total,visible,top:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gadget^,wind,NIL,gt.scTop,top,
                                    gt.scTotal,total,
                                    gt.scVisible,visible,
                                    u.done);
END SetScroller;

PROCEDURE SetSliderGadget*(x,y,wi,he:INTEGER;text:e.STRPTR;min,max,level,levellen:LONGINT;orientation:LONGINT;formatstring:e.STRPTR;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;
    newgad : gt.NewGadget;

BEGIN
  newgad.leftEdge:=x;
  newgad.topEdge:=y;
  newgad.width:=wi;
  newgad.height:=he;
  newgad.gadgetText:=text;
  newgad.textAttr:=textattr;
  newgad.gadgetID:=-1;
  newgad.flags:=LONGSET{};
  newgad.visualInfo:=vinfo;
  newgad.userData:=NIL;

  IF formatstring=NIL THEN
    formatstring:=s.ADR("%ld");
  END;
  gadget:=gt.CreateGadget(gt.sliderKind,prev,newgad,I.gaImmediate,I.LTRUE,
                                                    I.gaRelVerify,I.LTRUE,
                                                    gt.underscore,s.VAL(SHORTINT,"_"),
                                                    gt.slMin,min,
                                                    gt.slMax,max,
                                                    gt.slLevel,level,
                                                    gt.slMaxLevelLen,levellen,
                                                    gt.slLevelFormat,formatstring,
(*                                                    gt.slLevelPlace,gt.placeTextLeft,*)
                                                    I.pgaFreedom,orientation,
                                                    gt.slJustification,gt.jLeft,
                                                    u.done);
  prev:=gadget;
  RETURN gadget;
END SetSliderGadget;

PROCEDURE GetSlider*(gadget:I.GadgetPtr;wind:I.WindowPtr):INTEGER;

VAR i,level : LONGINT;

BEGIN
  i:=gt.GetGadgetAttrs(gadget,wind,NIL,gt.slLevel,s.ADR(level),
                                       u.done);
  RETURN SHORT(level);
END GetSlider;

PROCEDURE SetSlider*(gadget:I.GadgetPtr;wind:I.WindowPtr;min,max,level:LONGINT);

BEGIN
  gt.SetGadgetAttrs(gadget^,wind,NIL,gt.slMin,min,
                                    gt.slMax,max,
                                    gt.slLevel,level,
                                    u.done);
END SetSlider;

PROCEDURE SetColorWheel*(x,y,wi,he:LONGINT;slider:I.GadgetPtr;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
  gadget:=I.NewObject(NIL,gd.colorWheelName,I.gaLeft,x,
                                            I.gaTop,y,
                                            I.gaWidth,wi,
                                            I.gaHeight,he,
                                            I.gaFollowMouse,I.LTRUE,
                                            I.gaImmediate,I.LTRUE,
                                            I.gaRelVerify,I.LTRUE,
                                            I.gaPrevious,prev,
                                            gd.wheelGradientSlider,slider,
                                            gd.wheelScreen,screen,
                                            gd.wheelRed,-1,
                                            gd.wheelGreen,-1,
                                            gd.wheelBlue,-1,
                                            u.done);
  prev:=gadget;
  RETURN gadget;
END SetColorWheel;

PROCEDURE SetGradientSlider*(x,y,wi,he:LONGINT;pens:s.ADDRESS;orientation:LONGINT;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

BEGIN
  gadget:=I.NewObject(NIL,"gradientslider.gadget",I.gaLeft,x,
                                                  I.gaTop,y,
                                                  I.gaWidth,wi,
                                                  I.gaHeight,he,
                                                  I.gaImmediate,I.LTRUE,
                                                  I.gaRelVerify,I.LTRUE,
                                                  I.gaPrevious,prev,
                                                  I.pgaFreedom,orientation,
                                                  gd.gradPenArray,pens,
                                                  u.done);
  prev:=gadget;
  RETURN gadget;
END SetGradientSlider;

PROCEDURE SetImageGadget*(xpos,ypos,width,height,depth:INTEGER;data,datasel:s.ADDRESS;VAR prev:I.GadgetPtr):I.GadgetPtr;

VAR gadget   : I.GadgetPtr;
    image,
    imagesel : I.ImagePtr;

BEGIN
  NEW(image);
  image.leftEdge:=0;
  image.topEdge:=0;
  image.width:=width;
  image.height:=height;
  image.depth:=depth;
  image.imageData:=data;
  image.planePick:=SHORTSET{0,1};
  image.planeOnOff:=SHORTSET{};
  image.nextImage:=NIL;
  NEW(imagesel);
  imagesel.leftEdge:=0;
  imagesel.topEdge:=0;
  imagesel.width:=width;
  imagesel.height:=height;
  imagesel.depth:=depth;
  imagesel.imageData:=datasel;
  imagesel.planePick:=SHORTSET{0,1};
  imagesel.planeOnOff:=SHORTSET{};
  imagesel.nextImage:=NIL;
  NEW(gadget);
  gadget.nextGadget:=NIL;
  gadget.leftEdge:=xpos;
  gadget.topEdge:=ypos;
  gadget.width:=width;
  gadget.height:=height;
  gadget.flags:=SET{I.gadgImage,I.gadgHImage};
  gadget.activation:=SET{I.relVerify,I.gadgImmediate};
  gadget.gadgetType:=I.boolGadget;
  gadget.gadgetRender:=image;
  gadget.selectRender:=imagesel;
  gadget.gadgetText:=NIL;
  gadget.mutualExclude:=LONGSET{};
  gadget.specialInfo:=NIL;
  gadget.gadgetID:=-1;
  gadget.userData:=NIL;
  IF prev#NIL THEN
    prev.nextGadget:=gadget;
  END;
  prev:=gadget;
  RETURN gadget;
END SetImageGadget;

PROCEDURE DestructImageGadget*(gadget:I.GadgetPtr);

VAR image : I.ImagePtr;

BEGIN
  image:=gadget.gadgetRender;
  IF image#NIL THEN DISPOSE(image); END;
  image:=gadget.selectRender;
  IF image#NIL THEN DISPOSE(image); END;
END DestructImageGadget;

BEGIN
  busy:=FALSE;
END RawGadgets.

