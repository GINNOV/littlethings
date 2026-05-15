(*
Copyright (c) 1994 - 1996 Marc Necker.

This file is part of Analay (v1.12).
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
    nocols           * : INTEGER;


PROCEDURE FontRequest*(fontrequest:a.FontRequesterPtr;title:s.ADDRESS;wind:I.WindowPtr;attr:g.TextAttrPtr;VAR frontPen,backPen:INTEGER):BOOLEAN;

VAR bool      : BOOLEAN;
    doFp,doBp : INTEGER;

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

    doFp:=1;
    doBp:=1;
    IF frontPen=nocols THEN
      doFp:=0;
      frontPen:=1;
    END;
    IF backPen=nocols THEN
      doBp:=0;
      backPen:=0;
    END;
    bool:=a.AslRequestTags(fontrequest,a.window,wind,
                                      a.hail,title,
                                      a.sleepWindow,1,
                                      a.doStyle,1,
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

    IF frontPen=nocols THEN
      frontPen:=-1;
    END;
    IF backPen=nocols THEN
      backPen:=-1;
    END;
    IF bool THEN
      COPY(fontrequest.attr.name^,attr.name^);
      attr.ySize:=fontrequest.attr.ySize;
      attr.style:=fontrequest.attr.style;
      IF doFp=1 THEN
        frontPen:=fontrequest.frontPen;
      END;
      IF doBp=1 THEN
        backPen:=fontrequest.backPen;
      END;
    END;
    fontxpos:=fontrequest.leftEdge;
    fontypos:=fontrequest.topEdge;
    fontwidth:=fontrequest.width;
    fontheight:=fontrequest.height;

(*    fp:=SHORT(frontPen);
    bp:=SHORT(backPen);
    ra.FontRequest(fontxpos,fontypos,fontwidth,fontheight,title,wind,attr,fp,bp,drawMode,minHeight,maxHeight);
    frontPen:=fp;
    backPen:=bp;*)
  END;
  RETURN bool;
END FontRequest;

PROCEDURE ScreenModeRequest*(moderequest:a.ScreenModeRequesterPtr;title:s.ADDRESS;wind:I.WindowPtr;VAR displayId,width,height:LONGINT;VAR depth,oscan:INTEGER;VAR autoscroll:BOOLEAN):BOOLEAN;

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
  nocols:=-1;
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

