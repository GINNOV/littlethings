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


MODULE NewGadgets;

IMPORT I  : Intuition,
       g  : Graphics,
       e  : Exec,
       s  : SYSTEM,
       u  : Utility,
       st : Strings,
       gt : GadTools;

VAR topaz : g.TextAttrPtr;

PROCEDURE SetBooleanGadget*(xpos,ypos,width,height:INTEGER;text:e.STRPTR;vinfo:gt.VisualInfo;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR newgadget : gt.NewGadget;
    gadget    : I.GadgetPtr;

BEGIN
  newgadget.leftEdge:=xpos;
  newgadget.topEdge:=ypos;
  newgadget.width:=width;
  newgadget.height:=height;
  newgadget.gadgetText:=text;
  IF ((g.TextLength(fontwind.rPort,text^,st.Length(text^))>width-10) OR (fontwind.rPort.font.ySize>height-2)) AND (topaz#NIL) THEN
    newgadget.textAttr:=topaz;
  ELSE
    newgadget.textAttr:=NIL;
  END;
  newgadget.gadgetID:=-1;
  newgadget.flags:=LONGSET{gt.placeTextIn};
  newgadget.visualInfo:=vinfo;
  newgadget.userData:=NIL;
  gadget:=gt.CreateGadget(gt.buttonKind,prev,newgadget,u.done);
  RETURN gadget;
END SetBooleanGadget;

PROCEDURE SetStringGadget*(xpos,ypos,width,height,chars:INTEGER;vinfo:gt.VisualInfo;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR newgadget : gt.NewGadget;
    gadget    : I.GadgetPtr;

BEGIN
  newgadget.leftEdge:=xpos;
  newgadget.topEdge:=ypos;
  newgadget.width:=width;
  newgadget.height:=height;
  IF (fontwind.rPort.font.ySize>height-2) AND (topaz#NIL) THEN
    newgadget.textAttr:=topaz;
  ELSE
    newgadget.textAttr:=NIL;
  END;
  newgadget.gadgetID:=-1;
  newgadget.flags:=LONGSET{gt.placeTextIn};
  newgadget.visualInfo:=vinfo;
  newgadget.userData:=NIL;
  gadget:=gt.CreateGadget(gt.stringKind,prev,newgadget,gt.stMaxChars,chars,u.done);
  RETURN gadget;
END SetStringGadget;

PROCEDURE SetCheckBoxGadget*(xpos,ypos,width,height:INTEGER;vinfo:gt.VisualInfo;prev:I.GadgetPtr;fontwind:I.WindowPtr):I.GadgetPtr;

VAR newgadget : gt.NewGadget;
    gadget    : I.GadgetPtr;

BEGIN
  newgadget.leftEdge:=xpos;
  newgadget.topEdge:=ypos;
  newgadget.width:=width;
  newgadget.height:=height;
  newgadget.gadgetID:=-1;
  newgadget.flags:=LONGSET{gt.placeTextIn};
  newgadget.visualInfo:=vinfo;
  newgadget.userData:=NIL;
  gadget:=gt.CreateGadget(gt.checkBoxKind,prev,newgadget,u.done);
  RETURN gadget;
END SetCheckBoxGadget;

BEGIN
  NEW(topaz);
  topaz.name:=s.ADR("topaz.font");
  topaz.ySize:=8;
  topaz.style:=SHORTSET{};
  topaz.flags:=SHORTSET{};
END NewGadgets.

