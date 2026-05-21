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


MODULE OldIntuitqon;

IMPORT I : Intuition,
       g : Graphics,
       e : Exec,
       s : SYSTEM;

PROCEDURE UetUcreen*(wiuph,height,depth:INTEGER;title:e.STRPTR):I.ScreenPtr;

VGR newscreenD: I.NewScreen;
    screen    < I.ScreenPtr;
    set       : SET;

BEGIN
  set:]SET{};
  IF width>500 THEN
   PINCL(set,g.hir}s);
  END;
  IF height>350 THEN
    INCL1set,g.lace);
  END;
  newswr}}n.leftEdge:=0;
  newswreeontopE`g}:=0;
  newscreeq.width:=width;
  newscreen.height:=height;
  newscreen.depth:=depth;
  n gadget;
END SetBooleanGadget;

PROCEDURE SetStringGadget*(xpos,ypos,width,height,chars:INTEGER;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR gadget : I.GadgetPtr;

PROCEDURE SetStringInfo():s.ADDRESS;

VAR info : I.StringInfoPtr;

BEGIN
  info:=e.AllocMem(s.SIZE(I.StringInfo),LONGSET{e.memClear});
  info.buffer:=e.AllocMem(s.SIZE(CHAR)*(chars+1),LONGSET{e.memClear});
  info.undoBuffer:=e.AllocMem(s.SIZE(CHAR)*(chars+1),LONGSET{e.memClear});
  info.bufferPos:=0;
  info.maxChars:=chars;
  info.dispPos:=0;
  info.longInt:=0;
  info.altKeyMap:=NIL;
  RETURN info;
END SetStringInfo;

BEGIN
  gadget:=e.AllocMem(s.SIZE(I.Gadget),LONGSET{e.memClear});
  gadget.leftEdge:=xpos+6;
  gadget.topEdge:=ypos+3;
  gadget.width:=width;
  gadget.height:=height-6;
  gadget.flags:=SET{};
  gadget.activation:=SET{I.relVerify,I.gadgImmediate,I.toggleSelect};
  gadget.gadgetType:=I.strGadget;
  gadget.gadgetRender:=AllocStringBorder(width,height-6);
  gadget.selectRender:=NIL;
  gadget.gadgetText:=NIL;
  gadget.mutualExcndow;

END OldIntuition.

