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


MODULE OldIntuition;

IMPORT I : Intuition,
       g : Graphics,
       e : Exec,
       s : SYSTEM;

PROCEDURE SetScreen*(width,height,depth:INTEGER;title:e.STRPTR):I.ScreenPtr;

VAR newscreen : I.NewScreen;
    screen    : I.ScreenPtr;
    set       : SET;

BEGIN
  set:=SET{};
  IF width>500 THEN
    INCL(set,g.hires);
  END;
  IF height>350 THEN
    INCL(set,g.lace);
  END;
  newscreen.leftEdge:=0;
  newscreen.topEdge:=0;
  newscreen.width:=width;
  newscreen.height:=height;
  newscreen.depth:=depth;
  newscreen.detailPen:=1;
  newscreen.blockPen:=2;
  newscreen.viewModes:=set;
  newscreen.type:=I.customScreen;
  newscreen.font:=NIL;
  newscreen.defaultTitle:=title;
  newscreen.gadgets:=NIL;
  newscreen.customBitMap:=NIL;
  screen:=I.OpenScreen(newscreen);
  RETURN screen;
END SetScreen;

PROCEDURE SetWindow*(xpos,ypos,width,height:INTEGER;title:e.STRPTR;flags:LONGSET;idcmp:LONGSET;gadgetList:I.GadgetPtr;screen:I.ScreenPtr):I.WindowPtr;

VAR newwind : I.NewWindow;
    wind    : I.WindowPtr;

BEGIN
  newwind.leftEdge:=xpos;
  newwind.topEdge:=ypos;
  newwind.width:=width;
  newwind.height:=height;
  newwind.detailPen:=0;
  newwind.blockPen:=1;
  newwind.idcmpFlags:=idcmp;
  newwind.flags:=flags;
  newwind.firstGadget:=gadgetList;
  newwind.checkMark:=NIL;
  newwind.title:=title;
  newwind.bitMap:=NIL;
  newwind.minWidth:=50;
  newwind.minHeight:=30;
  newwind.maxWidth:=-1;
  newwind.maxHeight:=-1;
  newwind.type:=I.customScreen;
  newwind.screen:=screen;
  wind:=I.OpenWindow(newwind);
  RETURN wind;
END SetWindow;

END OldIntuition.

