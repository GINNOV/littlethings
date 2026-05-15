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


MODULE RawAsl;

IMPORT I : Intuition,
       g : Graphics,
       a : ASL,
       u : Utility,
       s : SYSTEM;

VAR os2         : BOOLEAN;
    fontrequest : a.FontRequesterPtr;

PROCEDURE FontRequest*(xpos,ypos,width,height:INTEGER;title:s.ADDRESS;wind:I.WindowPtr;VAR attr:g.TextAttrPtr;frontPen,backPen:SHORTINT;drawMode:SHORTSET;min,max:INTEGER);

VAR bool : BOOLEAN;

BEGIN
  IF fontrequest=NIL THEN
    fontrequest:=a.AllocAslRequestTags(a.fontRequest,a.leftEdge,xpos,
                                                     a.topEdge,ypos,
                                                     a.width,width,
                                                     a.height,height,
                                                     u.done);
  END;

  bool:=a.AslRequestTags(fontrequest,a.window,wind,
                                    a.hail,title,
                                    a.fontName,attr.name,
                                    a.fontHeight,attr.ySize,
                                    a.fontStyles,s.VAL(SHORTINT,attr.style),
                                    a.fontFlags,s.VAL(SHORTINT,attr.flags),
                                    a.frontPen,frontPen,
                                    a.backPen,backPen,
                                    a.minHeight,min,
                                    a.maxHeight,max,
                                    u.done);
  IF bool THEN
    COPY(fontrequest.attr.name^,attr.name^);
    attr.ySize:=fontrequest.attr.ySize;
    attr.style:=fontrequest.attr.style;
    attr.flags:=fontrequest.attr.flags;
  END;
END FontRequest;

BEGIN
  IF a.asl#NIL THEN
    os2:=TRUE;
  ELSE
   os2:=FALSE;
  END;
  fontrequest:=NIL;
CLOSE
  IF fontrequest#NIL THEN
    a.FreeAslRequest(fontrequest);
  END;
END RawAsl.

