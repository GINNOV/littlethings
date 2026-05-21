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


MODULE AslTools;

IMPORT I  : Intuition,
       g  : Graphics,
       s  : SYSTEM,
       a  : ASL,
       u  : Utility;

VAR os               : INTEGER;
    fontxpos       * ,
    fontypos       * ,
    fontwidth      * ,
    fontheight     * ,
    modexpos       * ,
    modeypos       * ,
    modewidth      * ,
    modeheight     * ,
    modeinfoxpos   * ,
    modeinfoypos   * ,
    modeinfowidth  * ,
    modeinfoheight * : INTEGER;
    modeinfoopen   * : BOOLEAN;
    fontrequest      : a.FontRequesterPtr;
    moderequest      : a.ScreenModeRequesterPtr;


CONST frontPen  * = 0; (* Consts for displayed setting gadgets in FontRequester *)
      backPen   * = 1;
      fontStyle * = 2;

PROCEDURE FontRequest*(title:s.ADDRESS;wind:I.WindowPtr;attr:g.TextAttrPtr;VAR frontPen,backPen:INTEGER;settings:LONGSET):BOOLEAN;

VAR bool      : BOOLEAN;
    doFp,doBp : I.LONGBOOL;

BEGIN
  bool:=FALSE;
  IF os>=36 THEN
    IF fontrequest=NIL THEN
      fontrequest:=a.AllocAslRequestTags(a.fontRequest,a.initialLeftEdge,fontxpos,
                                                       a.initialTopEdge,fontypos,
                                                       a.initialWidth,fontwidth,
                                                       a.initialHeight,fontheight,
                                                       u.done);
    END;

    doFp:=I.LTRUE;
    doBp:=I.LTRUE;
    IF ~(frontPen IN settings) THEN
      doFp:=I.LFALSE;
    END;
    IF ~(backPen IN settings) THEN
      doBp:=I.LFALSE;
    END;
    bool:=a.AslRequestTags(fontrequest,a.window,wind,
                                      a.hail,title,
                                      a.sleepWindow,I.LTRUE,
                                      a.doStyle,I.LTRUE,
                                      a.doFrontPen,doFp,
                                      a.doBackPen,doBp,
                                      a.initialName,attr.name,
                                      a.initialSize,attr.ySize,
                                      a.initialStyle,s.VAL(SHORTINT,attr.style),
                                      a.initialFrontPen,SHORT(frontPen),
                                      a.initialBackPen,SHORT(backPen),
                                      a.minHeight,5,
                                      a.maxHeight,100,
                                      u.done);

    IF bool THEN
      COPY(fontrequest.attr.name^,attr.name^);
      attr.ySize:=fontrequest.attr.ySize;
      attr.style:=fontrequest.attr.style;
      IF frontPen IN settings THEN
        frontPen:=fontrequest.frontPen;
      END;
      IF backPen IN settings THEN
        backPen:=fontrequest.backPen;
      END;
    END;
    fontxpos:=fontrequest.leftEdge;
    fontypos:=fontrequest.topEdge;
    fontwidth:=fontrequest.width;
    fontheight:=fontrequest.height;
  END;
  RETURN bool;
END FontRequest;

PROCEDURE ScreenModeRequest*(title:s.ADDRESS;wind:I.WindowPtr;VAR displayId,width,height:LONGINT;VAR depth,oscan:INTEGER;VAR autoscroll:BOOLEAN):BOOLEAN;

VAR bool    : BOOLEAN;
    ascroll : LONGINT;

BEGIN
  bool:=FALSE;
  IF os>=38 THEN
    IF moderequest=NIL THEN
      moderequest:=a.AllocAslRequestTags(a.screenModeRequest,a.initialLeftEdge,modexpos,
                                                       a.initialTopEdge,modeypos,
                                                       a.initialWidth,modewidth,
                                                       a.initialHeight,modeheight,
                                                       a.initialInfoOpened,s.VAL(SHORTINT,modeinfoopen),
                                                       a.initialInfoLeftEdge,modeinfoxpos,
                                                       a.initialInfoTopEdge,modeinfoypos,
                                                       u.done);
    END;

    ascroll:=I.LFALSE;
    IF autoscroll THEN
      ascroll:=I.LTRUE;
    END;

    bool:=a.AslRequestTags(moderequest,a.window,wind,
                                      a.hail,title,
                                      a.sleepWindow,1,
                                      a.doWidth,1,
                                      a.doHeight,1,
                                      a.doDepth,1,
                                      a.doOverscanType,1,
                                      a.doAutoScroll,1,
                                      a.smMinWidth,640,
                                      a.smMinHeight,200,
                                      a.smMinDepth,2,
                                      a.initialDisplayID,displayId,
                                      a.initialDisplayWidth,width,
                                      a.initialDisplayHeight,height,
                                      a.initialDisplayDepth,depth,
                                      a.initialOverscanType,oscan,
                                      a.initialAutoScroll,ascroll,
                                      u.done);

    IF bool THEN
      displayId:=moderequest.displayID;
      width:=moderequest.displayWidth;
      height:=moderequest.displayHeight;
      depth:=moderequest.displayDepth;
      oscan:=moderequest.overscanType;
      autoscroll:=moderequest.autoScroll;
    END;

    modexpos:=moderequest.leftEdge;
    modeypos:=moderequest.topEdge;
    modewidth:=moderequest.width;
    modeheight:=moderequest.height;
    modeinfoopen:=moderequest.infoOpened;
    modeinfoxpos:=moderequest.infoLeftEdge;
    modeinfoypos:=moderequest.infoTopEdge;
    modeinfowidth:=moderequest.infoWidth;
    modeinfoheight:=moderequest.infoHeight;
  END;
  RETURN bool;
END ScreenModeRequest;

(*PROCEDURE SetFontRequestSize*(xpos,ypos,width,height:INTEGER);

BEGIN
  fontxpos:=xpos;
  fontypos:=ypos;
  fontwidth:=width;
  fontheight:=height;
END SetFontRequestSize;

PROCEDURE SetFontRequestMinMax*(min,max:INTEGER);
(* $CopyArrays- *)

BEGIN
(*  COPY(defname,attr.name^);
  attr.ySize:=defsize;*)
  minHeight:=min;
  maxHeight:=max;
(*  frontPen:=SHORT(front);
  backPen:=SHORT(back);
  drawMode:=mode;*)
END SetFontRequestMinMax;*)

BEGIN
  os:=I.int.libNode.version;
  IF a.asl=NIL THEN
    os:=0;
  END;
  fontrequest:=NIL;
  moderequest:=NIL;
  fontxpos:=100;
  fontypos:=20;
  fontwidth:=400;
  fontheight:=180;
  modexpos:=100;
  modeypos:=20;
  modewidth:=300;
  modeheight:=180;
CLOSE
  IF fontrequest#NIL THEN
    a.FreeAslRequest(fontrequest);
  END;
  IF moderequest#NIL THEN
    a.FreeAslRequest(moderequest);
  END;
END AslTools.

