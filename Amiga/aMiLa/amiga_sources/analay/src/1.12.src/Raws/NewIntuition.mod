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


MODULE NewIntuition;

IMPORT I : Intuition,
       g : Graphics,
       e : Exec,
       s : SYSTEM,
       u : Utility;

VAR plast  : ARRAY 1 OF INTEGER;

PROCEDURE SetScreen*(width,height,depth:INTEGER;title:e.STRPTR;ntsc,oscan,a4:BOOLEAN):I.ScreenPtr;

VAR new    : I.ExtNewScreen;
    screen : I.ScreenPtr;
    mode   : LONGINT;
    modes  : SET;

BEGIN
  modes:=SET{g.hires};
  IF ntsc THEN
    mode:=g.ntscMonitorID;
  ELSE
    mode:=g.palMonitorID;
  END;
  IF height>350 THEN
    mode:=mode+g.hiresLaceKey;
    INCL(modes,g.lace);
  ELSE
    mode:=mode+g.hiresKey;
  END;
(*  new.leftEdge:=0;
  new.topEdge:=0;
  new.width:=width;
  new.height:=height;
  new.depth:=depth;
  new.detailPen:=1;
  new.blockPen:=2;
  new.defaultTitle:=title;
  new.type:=I.customScreen;
  new.viewModes:=modes;
  new.font:=NIL;
  new.gadgets:=NIL;
  new.customBitMap:=NIL;*)
  INCL(new.ns.type,I.nsExtended);
  width:=I.stdScreenWidth;
  IF a4 THEN
    height:=SHORT(SHORT(width*1.41));
  ELSE
    height:=I.stdScreenHeight
  END;
  IF oscan THEN
    screen:=I.OpenScreenTags(new,I.saLeft,0,
                                 I.saTop,0,
                                 I.saWidth,width,
                                 I.saHeight,height,
                                 I.saDepth,depth,
                                 I.saTitle,title,
                                 I.saPens,s.ADR(plast),
                                 I.saDetailPen,1,
                                 I.saBlockPen,2,
                                 I.saAutoScroll,I.saAutoScroll,
                                 I.saDisplayID,mode,
                                 I.saOverscan,I.oScanText,
                                 I.saFont,0,
                                 I.saSysFont,1,
                                 I.saBitMap,0,
                                 u.done);
  ELSE
    screen:=I.OpenScreenTags(new,I.saLeft,0,
                                 I.saTop,0,
                                 I.saWidth,width,
                                 I.saHeight,height,
                                 I.saDepth,depth,
                                 I.saTitle,title,
                                 I.saPens,s.ADR(plast),
                                 I.saDetailPen,1,
                                 I.saBlockPen,2,
                                 I.saDisplayID,mode,
                                 I.saFont,0,
                                 I.saSysFont,1,
                                 I.saBitMap,0,
                                 I.saAutoScroll,I.saAutoScroll,
                                 u.done);
  END;
  RETURN screen;
END SetScreen;

PROCEDURE SetWindow*(xpos,ypos,width,height:INTEGER;title:e.STRPTR;flags,idcmp:LONGSET;gadgetList:I.GadgetPtr;screen:I.ScreenPtr):I.WindowPtr;

VAR new  : I.ExtNewWindow;
    wind : I.WindowPtr;

BEGIN
  new.nw.type:=I.customScreen;
  new.nw.detailPen:=0;
  new.nw.blockPen:=1;
  INCL(flags,I.newLookMenus);
  INCL(new.nw.flags,I.nwExtended);
  wind:=I.OpenWindowTags(new,I.waLeft,xpos,
                             I.waTop,ypos,
                             I.waWidth,width,
                             I.waHeight,height,
                             I.waDetailPen,0,
                             I.waBlockPen,1,
                             I.waIDCMP,idcmp,
                             I.waFlags,flags,
                             I.waGadgets,gadgetList,
                             I.waCheckmark,NIL,
                             I.waNewLookMenus,I.LTRUE,
                             I.waTitle,title,
                             I.waCustomScreen,screen,
(*                             I.waSuperBitMap,screen,*)
                             I.waMinWidth,70,
                             I.waMinHeight,30,
                             I.waMaxWidth,-1,
                             I.waMaxHeight,-1,
                             u.done);
  RETURN wind;
END SetWindow;

BEGIN
  plast[0]:=-1;
END NewIntuition.

